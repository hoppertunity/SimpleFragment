/**
* File Name   :    OL_BookingExtension.cls
* Description :    
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 19/08/2014 Klea Kolaric   TNT-1560    this extension will only be used for Bookings
* 0.2 28/08/2014 Liza Romanenko TNT-1328    Be able to enter item for a booking on the same page of the booking
* 0.3 03/09/2014 Liza Romanenko TNT-1414    Synchronise booking with other TNT systems
* 0.4 11/09/2014 Liza Romanenko TNT-515     Create Booking from Quote
* 0.5 23/09/2014 Klea Kolaric   TNT-1717    New time format
* 0.6 15/01/2015 Liza Romanenko TNT-2399    Add Invoice Address Logic
* 0.7 19/01/2015 Liza Romanenko TNT-2418/19 Remove logic to save Account Address, allow local changes to selected addresses
* 0.8 22/01/2015 Liza Romanenko TNT-2411    Split Collection Ready Date / Time, Not recalculate Depot on time change
* 0.9 14/07/2015 Darryl Hopper              Added method getNumLongLengthItems and RefreshDarryl line 1354
* 0.10 08/02/2016 Darryl Hopper             Amended line 243 to default Total_Items__c to 1 (was 0)
*/
public with sharing class OL_BookingExtension {
    
    public static Id newId {
        get{
            return '000000000000000000';    // faulty Id to signal that we want new record
        }
    }
    
    public static String BOOKING_COLLECTION_PREFIX
    {
        get { return 'Coll_'; }
    }
    public static String BOOKING_DELIVERY_PREFIX
    {
        get { return 'Del_'; }
    }
    public static String BOOKING_INVOICE_PREFIX
    {
        get { return 'Inv_'; }
    }
    
    public static String CONTACT_ORDER_PREFIX
    {
        get { return 'OC_'; }
    }
    public static String CONTACT_COLLECTION_PREFIX
    {
        get { return 'CC_'; }
    }
    public static String CONTACT_DELIVERY_PREFIX
    {
        get { return 'DC_'; }
    }
    
    public static String LIABILITY_ACCOUNTLEVEL
    {
        get { return ConstantUtil.PLVAL_BOOKING_LIABILITY_ACCOUNTLEVEL; }
    }
    
    // default line of business
    public static Id DEFAULT_DIVISION_ID
    {
        get
        {
            List<Line_of_Business__c> lobs = [select id from Line_of_Business__c where Line_of_Business_Reference__c = '10'];
            return !lobs.isEmpty() ? lobs.get(0).id : null;
        }
    }
    
    public String getTabTitle(){
        if(book.Id == null){
            return 'New Booking';
        } else if (!String.isBlank(book.Name)){
            return book.Name;
        } else {
            return [SELECT Name FROM Booking__c WHERE Id = : book.Id].Name;
        }
    }
    
    // string time hh:mm
    public TimeUtil.HMTime closeTime {get; set;}
    public TimeUtil.HMTime lunchStart {get; set;}
    public TimeUtil.HMTime lunchEnd {get; set;}
    
    private Booking__c book;
    public Boolean accountSelected {get; set;}
    public Boolean regularCustomer {get; set;}
    private Account acc; 
    public Boolean createContactOrd {get; set;}
    public Boolean createContactDel {get; set;}
    public Boolean createContactCol {get; set;}
    
    // address handling COLLECTION
    public Id aaIdCOL {get; set;}
    //public Account_Address__c aa {get; set;}
    private List<Map<String, String>> gbmAddressesCOL;  // addresses received from GB mailer
    public String addressIndexStrCOL {get; set;}    // store address index when using GBMailer 
    
    // address handling DELIVERY
    public Id aaIdDEL {get; set;}
    //public Account_Address__c aa {get; set;}
    private List<Map<String, String>> gbmAddressesDEL;  // addresses received from GB mailer
    public String addressIndexStrDEL {get; set;}    // store address index when using GBMailer 
    
    // address handling INVOICE
    //public Id aaIdDEL {get; set;}
    //public Account_Address__c aa {get; set;}
    private List<Map<String, String>> gbmAddressesINV;  // addresses received from GB mailer
    public String addressIndexStrINV {get; set;}    // store address index when using GBMailer 
    public Boolean showINV {get{return book.Account__c == null && book.Carriage_Forward__c;}}
    public Integer addressColumns {get{Integer res = 2; if(showINV) res = 3; return res;}}
    
    public Id aaDefId;  // point to default address
    
    public Integer stage;
    public static final Integer ADDRESS_EDIT = 1;
    public static final Integer LOB_EDIT = 2;
    public static final Integer DEPOT_EDIT = 3;
    
    public Boolean overrideCollDepot {get; set;}
    private String oldRecordId;
    public Boolean unknownShipper;  // do not initialise
    public String paperworkRequired {get; set;}
    public String commercialInvoiceRequired {get; set;}
    
    //add jq component for CollectionReadyDateTime
    public String collectionReadyTime {get; set;}
    
    //variable to store prew data for Depot calculation
    private BookindDepotCalculationData prewDepotData;
    
    private Boolean isCollectionDTCorrect;
    
    public OL_BookingExtension(Apexpages.standardController stdCtrl)
    {
        qId = ApexPages.currentPage().getParameters().get('qId');
        isSaved = false;
        overrideCollDepot = false;
        book = (Booking__c) stdCtrl.getRecord();
        copyDataFromQuote();
        
        oldRecordId = ApexPages.currentPage().getParameters().get('oId');
        if(String.isNotBlank(oldRecordId)){
            cloneRecord();
        }
        
        stage = book.id == null ? ADDRESS_EDIT : DEPOT_EDIT;
        if(ApexPages.currentPage().getUrl() == null || !ApexPages.currentPage().getUrl().contains('OL_BookingLinesList')){
            createContactOrd = false;
            createContactDel = false;
            createContactCol = false;
            accountSelected = book.Account__c != null || book.Company_Name__c != null || book.Id != null;
            if(accountSelected)
            {
                selectAccount();
            }
            if(book.id == null && String.isNotBlank(book.Order_Contact__c))
            {
                loadContactValuesOC();
            }
            
            initCustomPickLists();
                        
            initCollectionReadyDT();
            
            if(oldRecordId != null || qId != null){
                findCollectionDepot();
            }
        }
        
        initTime();
        initBookingLines();
        
        if(String.isNotBlank(oldRecordId)){ // if cloning, try to recalculate depot
            enterDepotEditMode();
            getCollDepotNotifications();
        }
        
        if(ApexPages.currentPage().getUrl() == null || !ApexPages.currentPage().getUrl().contains('OL_BookingLinesList')){
            prewDepotData = new BookindDepotCalculationData(book);
        }
    }
    
    private void initCustomPickLists(){
        paperworkRequired = book.id == null && String.isBlank(oldRecordId) ? 'null' : String.valueOf(book.Paperwork_Required__c);
        commercialInvoiceRequired = book.id == null && String.isBlank(oldRecordId) ? 'null' : String.valueOf(book.Commercial_Invoice_Required__c);
    }
    
    public pagereference selectAccount()
    {
        if(book.Account__c == null && book.Company_Name__c == null && book.Id == null)
        {
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'You must select an Account or add a Company Name.'));
        }
        else
        {
            if(book.Account__c != null)
            {
                book.Company_Name__c = null;
                String q = 'select id, Name, On_Stop__c, Regular_Customer__c, '
                    + '(select id, Name, Default__c, ' + String.join(addressFieldNames, ', ') + ' from Account_Addresses__r '
                    + 'order by Default__c desc, Last_Used__c desc nulls last, Org_Name__c asc '
                    + 'limit ' + ConstantUtil.CS_ACCOUNTADDRESSROWLIMIT + ' ), '
                    
                    + '(select Line_Of_Business__c, Line_Of_Business__r.Name, Line_Of_Business__r.Line_Of_Business_Reference__c, '
                    + 'Inspection_Required__c, Transit_Liability_Charge__c, Residential_Collection_Charge__c, Residential_Delivery_Charge__c '
                    + 'from Account_LOBs__r where Line_Of_Business__r.Active__c = true order by Line_Of_Business__r.Line_Of_Business_Reference__c asc) '
                + 'from Account where Id = ' + '\'' + book.Account__c + '\'';
                acc = (Account) database.query(q);
                
                // prepopulate fields
                Boolean pureNew = book.id == null && String.isBlank(oldRecordId) && String.isBlank(qId);    // no fields have been prepopulated in any way
                
                aaDefId = !acc.Account_Addresses__r.isEmpty() && acc.Account_Addresses__r.get(0).Default__c ? 
                            acc.Account_Addresses__r.get(0).id : null;  // if there is a default address, it will be first in list
                aaIdCOL = pureNew && aaDefId != null ? aaDefId : book.Coll_Account_Address__c;
                aaIdDEL = book.Del_Account_Address__c;
                if(aaIdCOL != null && pureNew)
                {
                    populateAccountAddressCOL();    // preload default account
                }
                
                regularCustomer = acc.Regular_Customer__c;
            }
            else
            {
                aaIdCOL = newId;
                aaIdDEL = newId;
            }
            accountSelected = true;
            
            if(!String.isBlank(qId)){
                aaIdCOL = newId;
                aaIdDEL = newId;
            }
            
            // prepopulate fields - some default values not working
            Datetime now = Datetime.now();
            if(book.Collection_Ready_Time__c == null)   // TNT-1408
            {
                book.Collection_Ready_Time__c = Datetime.newInstance(now.date(), Time.newInstance(now.hour(),now.minute(),0,0));
            }
            book.Status__c = String.isBlank(book.Status__c) ? ConstantUtil.PLVAL_BOOKING_STATUS_CONFIRMED : book.Status__c;
            //DH modified 02/02/2016
            book.Total_Items__c = book.Total_Items__c == null ? 1 : book.Total_Items__c;
            book.Total_Weight__c = book.Total_Weight__c == null ? 0 : book.Total_Weight__c;
            book.Number_of_Consignments__c = book.Number_of_Consignments__c == null ? 1 : book.Number_of_Consignments__c;
        }
        return null;
    }
    
    public void initTime()
    {
        closeTime = new TimeUtil.HMTime(book.Close_Time__c);
        lunchStart = new TimeUtil.HMTime(book.Lunch_Start__c);
        lunchEnd = new TimeUtil.HMTime(book.Lunch_End__c);
    }
    
    public void initCollectionReadyDT(){
        if(book.Collection_Ready_Time__c == null){
            collectionReadyTime = DateTime.now().format(TimeUtil.DATETIMEPICKER_FORMAT);
        } else {
            collectionReadyTime = book.Collection_Ready_Time__c.format(TimeUtil.DATETIMEPICKER_FORMAT);
        }
    }
    
    // page controls
    
    public void enterAddressEditMode()
    {
        stage = ADDRESS_EDIT;
    }
    
    public void enterLOBEditMode()
    {
        stage = LOB_EDIT;
    }
    
    public void enterDepotEditMode()
    {
        findCollectionDepot();
        overrideCollDepot = false;
        stage = DEPOT_EDIT;
    }
    
    public Boolean getIsAddressEditMode()
    {
        return stage == ADDRESS_EDIT;
    }
    
    public Boolean getIsLOBEditMode()
    {
        return stage == LOB_EDIT;
    }
    
    public Boolean getIsDepotEditMode()
    {
        return stage == DEPOT_EDIT;
    }
    
    // contacts
    
    public void loadContactValuesOC()
    {
        loadContactValues(CONTACT_ORDER_PREFIX,book.Order_Contact__c);
    }
    
    public void loadContactValuesCC()
    {
        loadContactValues(CONTACT_COLLECTION_PREFIX,book.Collection_Contact__c);
    }
    
    public void loadContactValuesDC()
    {
        loadContactValues(CONTACT_DELIVERY_PREFIX,book.Delivery_Contact__c);
    }
    
    public void loadContactValues(String prefix, Id cId)
    {
        if(cId != null)
        {
            copyContactValues(prefix,cId);
        }
        else
        {
            clearContactValues(prefix);
        }
    }
    
    public void copyContactValues(String prefix, Id cId)
    {
        Contact c = [select FirstName, LastName, Phone, Email from Contact where id = :cId limit 1];
        fillContactFields(prefix, c.FirstName, c.LastName, c.Phone, c.Email);
    }
    
    public void clearContactValues(String prefix)
    {
        fillContactFields(prefix, null, null, null, null);
    }
    
    // copy order contact to collection contact
    public void copyContactValuesCO2CC()
    {
        book.Collection_Contact__c = book.Order_Contact__c;
        copyContactValuesCO2(CONTACT_COLLECTION_PREFIX);
    }
    
    // copy order contact to collection contact
    public void copyContactValuesCO2DC()
    {
        book.Delivery_Contact__c = book.Order_Contact__c;
        copyContactValuesCO2(CONTACT_DELIVERY_PREFIX);
    }
    
    public void copyContactValuesCO2(String prefix)
    {
        if(String.isNotBlank(book.Order_Contact__c)){
            loadContactValuesOC();
        }
        
        fillContactFields(prefix, book.OC_First_Name__c, book.OC_Last_Name__c, book.OC_Phone_Number__c, book.OC_Email_Address__c);
    }
    
    public void fillContactFields(String prefix, String firstName, String lastName, String phoneNum, String email){
        book.put(prefix + 'First_Name__c',(object) firstName);
        book.put(prefix + 'Last_Name__c',(object) lastName);
        book.put(prefix + 'Phone_Number__c',(object) phoneNum);
        book.put(prefix + 'Email_Address__c',(object) email);
    }
    
    // ADDRESS HANDLING
    
    // extract addresses into select options from account]
    
    public List<selectOption> getAccountAddessesCOL()
    {
        //aaIdCOL = book.Coll_Account_Address__c;
        return getAccountAddesses(acc.Account_Addresses__r);
    }
    
    public List<selectOption> getAccountAddessesDEL()
    {
        //aaIdDEL = book.Del_Account_Address__c;
        return getAccountAddesses(acc.Account_Addresses__r);
    }
    
    //if select CF for new Booking it copies def address to right
    public void makeCarriageForward(){
        //check if booking is new and CF is selected
        if(book.Id == null && book.Carriage_Forward__c && String.isNotBlank(aaDefId)){
            if(aaIdCOL == aaDefId){
                clearAddressCOL();
                aaIdCOL = null;
            }
            aaIdDEL = aaDefId;
            loadAddressDEL();
        }
        
        clearAddressINV();
    }
    
    // selecting an account address will remove the GBMailer selection
    public void loadAddressCOL()
    {
        addressIndexStrCOL = null;
        gbmAddressesCOL = null;
        
        if(String.isNotBlank(aaIdCOL))
        {
            if(aaIdCOL != newId)
            {
                clearAddressCOL();
                populateAccountAddressCOL();
            }
                
            madeCarrigeForward();
        }
    }
    
    public void madeCarrigeForward()
    {
        if(String.isNotBlank(aaDefId))
        {
            if(aaIdCOL == aaDefId)
            {
                book.Carriage_Forward__c = false;
                if(aaIdDEL == aaDefId)  // they can't both be default
                {
                    aaIdDEL = null;
                    loadAddressDEL();
                }
            }
            else
            {
                book.Carriage_Forward__c = true;
                aaIdDEL = aaDefId;
                loadAddressDEL();
            }
        }
    }
    
    public void loadAddressDEL()
    {
        addressIndexStrDEL = null;
        gbmAddressesDEL = null;
        
        if(String.isNotBlank(aaIdDEL) && aaIdDEL != newId)
        {
            clearAddressDEL();
            populateAccountAddressDEL();
        }
    }
    
    public void populateAccountAddressCOL()
    {
        Account_Address__c aa = (new Map<Id,Account_Address__c>(acc.Account_Addresses__r)).get(aaIdCOL);
        populateAccountAddress(BOOKING_COLLECTION_PREFIX,aa);
    }
    
    public void populateAccountAddressDEL()
    {
        Account_Address__c aa = (new Map<Id,Account_Address__c>(acc.Account_Addresses__r)).get(aaIdDEL);
        populateAccountAddress(BOOKING_DELIVERY_PREFIX,aa);
    }
    
    // fields on account address should match those on booking
    public void populateAccountAddress(String prefix, Account_Address__c aa)
    {
        List<Schema.FieldSetMember> fieldSet = sObjectType.Account_Address__c.FieldSets.QuickCreateFields.getFields();
        for(Schema.FieldSetMember fsm : fieldSet)
        {
            book.put(prefix+fsm.getFieldPath(),aa.get(fsm.getFieldPath()));
        }
    }
    
    public void clearAddressCOL()
    {
        clearAddress(BOOKING_COLLECTION_PREFIX);
    }
    
    public void clearAddressDEL()
    {
        clearAddress(BOOKING_DELIVERY_PREFIX);
    }
    
    public void clearAddressINV()
    {
        clearAddress(BOOKING_INVOICE_PREFIX);
        book.put('Inv_Phone__c',null);
        book.put('Inv_Email__c',null);
        resetGBMailerINV();
    }
    
    public void clearAddress(String prefix)
    {
        book.put(prefix + 'Org_Name__c',null);
        book.put(prefix + 'Sub_Premise__c',null);
        book.put(prefix + 'Premise_Name__c',null);
        book.put(prefix + 'Premise_Number__c',null);
        book.put(prefix + 'Street_1__c',null);
        book.put(prefix + 'Street_2__c',null);
        book.put(prefix + 'District__c',null);
        book.put(prefix + 'City__c',null);
        book.put(prefix + 'County__c',null);
        book.put(prefix + 'Postcode__c',null);
        book.put(prefix + 'Country__c',null);
    }
    
    public Boolean isAddressEmpty(String prefix)
    {
        Boolean res = String.isBlank(String.valueOf(book.get(prefix + 'Org_Name__c'))) &&
            String.isBlank(String.valueOf(book.get(prefix + 'Sub_Premise__c'))) &&
            String.isBlank(String.valueOf(book.get(prefix + 'Premise_Name__c'))) &&
            String.isBlank(String.valueOf(book.get(prefix + 'Premise_Number__c'))) &&
            String.isBlank(String.valueOf(book.get(prefix + 'Street_1__c'))) &&
            String.isBlank(String.valueOf(book.get(prefix + 'Street_2__c'))) &&
            String.isBlank(String.valueOf(book.get(prefix + 'District__c'))) &&
            String.isBlank(String.valueOf(book.get(prefix + 'City__c'))) &&
            String.isBlank(String.valueOf(book.get(prefix + 'County__c'))) &&
            String.isBlank(String.valueOf(book.get(prefix + 'Postcode__c'))) &&
            String.isBlank(String.valueOf(book.get(prefix + 'Country__c')));
        return res;
    }
    
    // gbmailer
    
    public List<Selectoption> getGBMAddressesCOL()
    {
        return getGBMailerAddresses(gbmAddressesCOL);
    }
    
    public List<Selectoption> getGBMAddressesDEL()
    {
        return getGBMailerAddresses(gbmAddressesDEL);
    }
    
    public List<Selectoption> getGBMAddressesINV()
    {
        return getGBMailerAddresses(gbmAddressesINV);
    }
    
    // these conditions are not rendering correctly in the page so i will pass it from the controller
    public Boolean getNoGBMailerCOL()
    {
        return gbmAddressesCOL == null;
    }
    
    public Boolean getNoGBMailerDEL()
    {
        return gbmAddressesDEL == null;
    }
    
    public Boolean getNoGBMailerINV()
    {
        return gbmAddressesINV == null;
    }
    
    // inform user if not all results returned
    public Boolean getExceededGBMailerCOL()
    {
        return gbmAddressesCOL != null && gbmAddressesCOL.size() == GBMailer_Util.GBMAILER_SYSTEM_LIMIT;
    }
    
    public Boolean getExceededGBMailerDEL()
    {
        return gbmAddressesDEL != null && gbmAddressesDEL.size() == GBMailer_Util.GBMAILER_SYSTEM_LIMIT;
    }
    
    public Boolean getExceededGBMailerINV()
    {
        return gbmAddressesINV != null && gbmAddressesINV.size() == GBMailer_Util.GBMAILER_SYSTEM_LIMIT;
    }
    
    public void emptyAction() {}
    
    //
    
    public void pinpointPostcodeGBMailerCOL()
    {
        resetGBMailerCOL();
        if(String.isNotBlank(book.Coll_Postcode__c))
        {
            gbmAddressesCOL = pinpointPostcodeGBMailer(book.Coll_Postcode__c);
        }
    }
    
    public void pinpointPostcodeGBMailerDEL()
    {
        resetGBMailerDEL();
        if(String.isNotBlank(book.Del_Postcode__c))
        {
            gbmAddressesDEL = pinpointPostcodeGBMailer(book.Del_Postcode__c);
        }
    }
    
    public void pinpointPostcodeGBMailerINV()
    {
        resetGBMailerINV();
        if(String.isNotBlank(book.Inv_Postcode__c))
        {
            gbmAddressesINV = pinpointPostcodeGBMailer(book.Inv_Postcode__c);
        }
    }
    
    public void resetGBMailerCOL()
    {
        gbmAddressesCOL = null;
        addressIndexStrCOL = null;
    }
    
    public void resetGBMailerDEL()
    {
        gbmAddressesDEL = null;
        addressIndexStrDEL = null;
    }
    
    public void resetGBMailerINV()
    {
        gbmAddressesINV = null;
        addressIndexStrINV = null;
    }
    
    public void populateGBMailerAddressCOL()
    {
        if(String.isNotBlank(addressIndexStrCOL))
        {
            Integer indx = Integer.valueOf(addressIndexStrCOL);
            populateGBMailerAddress(BOOKING_COLLECTION_PREFIX,gbmAddressesCOL.get(indx));
        }
        else
        {
            clearAddressCOL();
        }
        aaIdCOL = null;
        //make carrige forward and populate delivery address with default one
        if(!book.Carriage_Forward__c && String.isBlank(aaIdCOL) && isAddressEmpty(BOOKING_DELIVERY_PREFIX)){
            madeCarrigeForward();
        }
        
    }
    
    public void populateGBMailerAddressDEL()
    {
        if(String.isNotBlank(addressIndexStrDEL))
        {
            Integer indx = Integer.valueOf(addressIndexStrDEL);
            populateGBMailerAddress(BOOKING_DELIVERY_PREFIX,gbmAddressesDEL.get(indx));
        }
        else
        {
            clearAddressDEL();
        }
    }
    
    public void populateGBMailerAddressINV()
    {
        if(String.isNotBlank(addressIndexStrINV))
        {
            Integer indx = Integer.valueOf(addressIndexStrINV);
            populateGBMailerAddress(BOOKING_INVOICE_PREFIX,gbmAddressesINV.get(indx));
        }
        else
        {
            clearAddressINV();
        }
    }
    
    public void populateGBMailerAddress(String prefix, Map<String,String> addr)
    {
        book.put(prefix + 'Org_Name__c',addr.get(GBMailer_Util.CODE_ORGANISATION));
        book.put(prefix + 'Sub_Premise__c',addr.get(GBMailer_Util.CODE_SUBPREMISE));
        book.put(prefix + 'Premise_Name__c',addr.get(GBMailer_Util.CODE_BUILDINGNAME));
        book.put(prefix + 'Premise_Number__c',addr.get(GBMailer_Util.CODE_BUILDINGNUMBER));
        book.put(prefix + 'Street_1__c',addr.get(GBMailer_Util.CODE_STREET));
        book.put(prefix + 'Street_2__c',addr.get(GBMailer_Util.CODE_DUBDEPLOC));
        book.put(prefix + 'District__c',addr.get(GBMailer_Util.CODE_DEPLOC));
        book.put(prefix + 'City__c',addr.get(GBMailer_Util.CODE_TOWN));
        book.put(prefix + 'County__c',addr.get(GBMailer_Util.CODE_COUNTY));
        book.put(prefix + 'Postcode__c',addr.get(GBMailer_Util.CODE_POSTCODE));
        book.put(prefix + 'Country__c',ConstantUtil.ISOCODE_UK);
    }
    
    // line of business
    
    public List<Selectoption> getAvailableLOBs()
    {
        List<Selectoption> lobs = new List<Selectoption>();
        //lobs.add(new selectoption('','- none -'));
        Boolean hasDefault = false;
        if(acc != null)
        {
            for(Account_LOB__c alob : acc.Account_LOBs__r)
            {
                lobs.add(new selectoption(alob.Line_Of_Business__c,
                    alob.Line_Of_Business__r.Line_Of_Business_Reference__c + ' - ' + alob.Line_Of_Business__r.Name));
                hasDefault |= alob.Line_Of_Business__c == DEFAULT_DIVISION_ID;
            }
        }
        if(book.Line_Of_Business__c == null)
        {
            book.Line_Of_Business__c = hasDefault ? DEFAULT_DIVISION_ID : (lobs.isEmpty() ? null : (Id) lobs.get(0).getValue());
        }
        getLiability();
        return lobs;
    }
    
    public Boolean getHasLOBs()
    {
        return acc == null || !acc.Account_LOBs__r.isEmpty();
    }
    
    public void resetSubLOB()
    {
        book.Service__c = null;
        book.Commodity__c = null;
        getLiability();
    }
    
    public List<Selectoption> getAvailableServices()
    {
        List<Selectoption> sos = new List<Selectoption>();
        if(book.Line_Of_Business__c != null)
        {
            for(LOB_Service__c lobser : [select Service__c, Service__r.Service_Code__c, Service__r.Name 
                                        from LOB_Service__c 
                                        where Active__c = true and Service__r.Active__c = true and Line_Of_Business__c = :book.Line_Of_Business__c
                                        order by Service__r.Service_Code__c asc])
            {
                sos.add(new Selectoption(lobser.Service__c,lobser.Service__r.Name + ' - ' + lobser.Service__r.Service_Code__c));
            }
        }
        if(book.Service__c == null)
        {
            book.Service__c = sos.isEmpty() ? null : (Id) sos.get(0).getValue();
        }
        return sos;
    }
    
    public Boolean getHasServices()
    {
        return book.Service__c != null;
    }
    
    public List<Selectoption> getAvailableCommodities()
    {
        List<Selectoption> sos = new List<Selectoption>();
        if(book.Line_Of_Business__c != null)
        {
            String comms = [select Commodities__c from Line_Of_Business__c where id = :book.Line_Of_Business__c limit 1].Commodities__c;
            if(String.isNotBlank(comms))
            {
                List<String> commsL = comms.split(';');
                for(String comm : commsL)
                {
                    sos.add(new Selectoption(comm,comm));
                }
            }
        }
        if(book.Commodity__c == null)
        {
            book.Commodity__c = sos.isEmpty() ? null : sos.get(0).getValue();
        }
        return sos;
    }
    
    public Boolean getHasCommodity()
    {
        return book.Commodity__c != null;
    }
    
    public void getLiability()
    {
        if(acc != null && !acc.Account_LOBs__r.isEmpty() && book.Line_Of_Business__c != null)
        {
            for(Account_LOB__c alob : acc.Account_LOBs__r)
            {
                if(alob.Line_Of_Business__c == book.Line_Of_Business__c)
                {
                    book.Enhanced_Liability__c = alob.Transit_Liability_Charge__c != null ? LIABILITY_ACCOUNTLEVEL : null;
                }
            }
        }
        else
        {
            book.Enhanced_Liability__c = null;
        }
    }
    
    public List<Selectoption> getLiabilityOptions() // need to filter options out so we can't choose 'Account Level'
    {
        List<SelectOption> options = new List<SelectOption>();
        
        List<Schema.PicklistEntry> ple = Booking__c.Enhanced_Liability__c.getDescribe().getPicklistValues();
        
        if(book.Enhanced_Liability__c != LIABILITY_ACCOUNTLEVEL)
        {
            for(Schema.PicklistEntry f : ple)
            {
                if(f.getLabel() != LIABILITY_ACCOUNTLEVEL)
                {
                    options.add(new SelectOption(f.getLabel(), f.getValue()));
                }
            }    
        }
        else
        {
            options.add(new SelectOption(LIABILITY_ACCOUNTLEVEL, LIABILITY_ACCOUNTLEVEL));
        }
        return options;
    }
    
    // depot
    
    public void findCollectionDepot()
    {
        if((prewDepotData!= null && prewDepotData.isUpdated(book)) || prewDepotData == null){
            overrideCollDepot = false;
            Account collDepot = OL_DepotRoutingHelper.findCollectionDepot(
                book.Coll_Postcode__c, book.Coll_District__c, book.Coll_City__c, book.Line_of_Business__c, book.Collection_Ready_Time__c);
            book.Collection_Depot__c = collDepot == null ? null : collDepot.Id;
            book.Routing_Table__c = collDepot == null ? null : OL_DepotRoutingHelper.routingTableId;
            book.Depot_Routing__c = collDepot == null ? null : OL_DepotRoutingHelper.depotRoutingId;
            book.Master_Round_Number__c = 
                book.Depot_Routing__c == null ? null : [select Master_Round_Number__c from Depot_Routing__c where id = :book.Depot_Routing__c limit 1].Master_Round_Number__c;
        }
            
        if(prewDepotData != null){
            prewDepotData.updateData(book);
        }
    }
    
    public void onManualOverride()
    {
        if(overrideCollDepot)
        {
            book.Routing_Table__c = null;
            book.Depot_Routing__c = null;
            book.Master_Round_Number__c = 0;
            book.Collection_Depot__c = null;
        }
        else
        {
            findCollectionDepot();
        }
    }
    
    public void changeReadyDateTime(){
        isCollectionDTCorrect = false;
        try {
            DateTime readyDT = DateTime.parse(collectionReadyTime);
            Boolean notRecalculate = book.Collection_Ready_Time__c != null && readyDT != null && book.Collection_Ready_Time__c.date() == readyDT.date();
            book.Collection_Ready_Time__c = readyDT;
            if(notRecalculate){
                getCollDepotNotifications();
                prewDepotData.updateData(book);
            } else {
                findCollectionDepot();
            }
            isCollectionDTCorrect = true;
        } catch (Exception ex){
            Apexpages.addMessages(ex);
        }
    }
    
    // notifications
    
    public String getAccountNotifications()
    {
        if(acc == null) return null;
        String msg = '';
        msg += !acc.On_Stop__c ? '' : '* Account is On Stop<br/>';
        return String.isBlank(msg) ? null : msg;
    }
    
    public String getLOBNotifications()
    {
        String msg = '';
        if(book.Line_Of_Business__c != null)
        {
            Account_LOB__c alob;
            if(acc != null)
            {
                for(Account_LOB__c acclob : acc.Account_LOBs__r)
                {
                    if(acclob.Line_Of_Business__c == book.Line_Of_Business__c)
                    {
                        alob = acclob;
                        break;
                    }
                }
                if(alob != null)
                {
                    if(alob.Inspection_Required__c)
                    {
                        msg += '* Unknown shipper - no booking within the last 90 days<br/>';
                    }
                    unknownShipper = alob.Inspection_Required__c;
                }
            }
            if(acc == null || (alob != null && alob.Residential_Collection_Charge__c && String.isNotBlank(book.Coll_Postcode__c)))
            {
                msg += !getIsResidentialPostcode(book.Coll_Postcode__c) 
                    ? '' : '* ' + Label.Residential_Collection_Postcode_Warning +'<br/>';
            }
            if(acc == null || (alob != null && alob.Residential_Delivery_Charge__c && String.isNotBlank(book.Del_Postcode__c)))
            {
                msg += !getIsResidentialPostcode(book.Del_Postcode__c) 
                    ? '' : '* ' + Label.Residential_Delivery_Postcode_Warning +'<br/>';
            }
        }
        return String.isBlank(msg) ? null : msg;
    }
    
    public Boolean getIsResidentialPostcode(String postcode)
    {
        if(String.isNotBlank(postcode))
        {
            for(Postcode__c p : [select Category__c from Postcode__c where Name = :postcode])
            {
                if(p.Category__c == ConstantUtil.PLVAL_POSTCODE_CATEGORY_RESIDENTIAL)
                {
                    return true;
                }
            }
        }
        return false;
    }
    
    public String getCollDepotNotifications()
    {
        String msg = '';
        msg += OL_DepotRoutingHelper.errorMsg == null ? '' : (OL_DepotRoutingHelper.errorMsg + '<br/><br/>');
        if(book.Collection_Ready_Time__c != null && TimeUtil.getDayOfWeek(book.Collection_Ready_Time__c) == ConstantUtil.FRIDAY_ABRV
            && book.Service__c != null)
        {
            // if it's a friday and service is not Saturday service
            if([select count() from Service__c where Saturday_Service__c = true and id = :book.Service__c] == 0)
            {
                msg += '* ' + Label.Saturday_Service_Info + '<br/>';
            }
        }
        if(book.Del_Postcode__c != null && book.Del_City__c != null && book.Service__c != null)
        {
            Routing_Table__c rtDel = OL_DepotRoutingHelper.findRoutingTableEntry(book.Del_Postcode__c, book.Del_District__c, book.Del_City__c);
            if(rtDel != null && 0 < [select count() from Service_Guarantee__c 
                                        where Routing_Table__c = :rtDel.id and Service__c = :book.Service__c])
            {
                msg += '* ' + Label.Service_NOT_Guaranteed_Message + '<br/>';
            }
        }
        String cutOffTime = OL_DepotRoutingHelper.cutOffTime != null ? OL_DepotRoutingHelper.cutOffTime :
            (book.Depot_Routing__c == null ? 
                null : [select Collection_Cut_Off_Time__c from Depot_Routing__c where id = :book.Depot_Routing__c limit 1].Collection_Cut_Off_Time__c);
        if(cutOffTime != null)
        {
            msg += '* Depot cut off time is ' + cutOffTime + '.';
            Time cot = TimeUtil.parseTime(cutOffTime);
            if(book.Collection_Ready_Time__c != null && book.Collection_Ready_Time__c.time() >= cot)
            {
                msg += ' Your selected collection time is after the cut off time.';
            }
            msg += '<br/>';
        }
        return String.isBlank(msg) ? null : msg;
    }
    
    // saver methods
    
    public Boolean saveAddresses()
    {
        //TNT-2650 temporary disablement of validation pending revised address validation / automation structure
        /*if(aaIdCOL == aaIdDEL && aaIdCOL != newId && aaIdCOL != null)
        {
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'Collection and Delivery addresses must be different.'));
            return false;
        }*/
        
        book.Coll_Account_Address__c = (aaIdCOL == newId || aaIdCOL == null) ? null : aaIdCOL;
        book.Del_Account_Address__c = (aaIdDEL == newId || aaIdDEL == null) ? null : aaIdDEL;
        return true;
    }
    
    public Boolean saveContacts()
    {
        List<Schema.FieldSetMember> fieldSet = sObjectType.Booking__c.FieldSets.ContactFields.getFields();
        
        if(book.Order_Contact__c == null)
        {
            Contact c = createContact(CONTACT_ORDER_PREFIX,book.Order_Contact__c,fieldSet,createContactOrd);
            if(c == null) return false;
            if(c.id != null) 
            {
                book.Order_Contact__c = c.id;
            }
        }
        if(book.Collection_Contact__c == null)
        {
            if(!String.isBlank(book.OC_First_Name__c) && !String.isBlank(book.OC_Last_Name__c) && !String.isBlank(book.OC_Phone_Number__c) &&
                book.OC_First_Name__c == book.CC_First_Name__c && book.OC_Last_Name__c == book.CC_Last_Name__c
                && book.OC_Email_Address__c == book.CC_Email_Address__c && book.OC_Phone_Number__c == book.CC_Phone_Number__c
                && book.Order_Contact__c != null)
            {
                book.Collection_Contact__c = book.Order_Contact__c; // we're obviously duplicating contact
            }
            else
            {
                Contact c = createContact(CONTACT_COLLECTION_PREFIX,book.Collection_Contact__c,fieldSet,createContactCol);
                if(c == null) return false;
                if(c.id != null) 
                {
                    book.Collection_Contact__c = c.id;
                }
            }
        }
        if(book.Delivery_Contact__c == null && createContactDel)    // delivery contact not required
        {
            Contact c = createContact(CONTACT_DELIVERY_PREFIX,book.Delivery_Contact__c,fieldSet,createContactDel);
            if(c == null) return false;
            if(c.id != null) 
            {
                book.Delivery_Contact__c = c.id;
            }
        }
        
        //check required fields
        Boolean res = true;
        if(book.Order_Contact__c != null){
            res &= checkRequiredFieldsForContact(CONTACT_ORDER_PREFIX,book.Order_Contact__c,fieldSet);
        }
        if(book.Collection_Contact__c != null){
            res &= checkRequiredFieldsForContact(CONTACT_COLLECTION_PREFIX,book.Order_Contact__c,fieldSet);
        }
        if(book.Delivery_Contact__c != null){
            res &= checkRequiredFieldsForContact(CONTACT_DELIVERY_PREFIX,book.Order_Contact__c,fieldSet);
        }
        
        
        return res;
    }
    
    public Boolean checkRequiredFieldsForContact(String prefix, Id contactId, List<Schema.FieldSetMember> fullFieldSet){
        // if no contact selected agent should populate contact fields
        List<Schema.FieldSetMember> fieldSet = new List<Schema.FieldSetMember>();
        for(Schema.FieldSetMember fsm : fullFieldSet)
        {
            if(fsm.getFieldPath().startsWith(prefix))
            {
                fieldSet.add(fsm);
            }
        }
        
        String errorMsg = FieldSetUtil.checkRequiredFieldsFS(book,fieldSet);
        if(String.isNotBlank(errorMsg))
        {
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,errorMsg));
            return false;
        }
        
        return true;
    }
    
    public Contact createContact(String prefix, Id contactId, List<Schema.FieldSetMember> fullFieldSet, Boolean doSave)
    {
        // if no contact selected agent should populate contact fields
        List<Schema.FieldSetMember> fieldSet = new List<Schema.FieldSetMember>();
        for(Schema.FieldSetMember fsm : fullFieldSet)
        {
            if(fsm.getFieldPath().startsWith(prefix))
            {
                fieldSet.add(fsm);
            }
        }
        
        String errorMsg = FieldSetUtil.checkRequiredFieldsFS(book,fieldSet);
        if(String.isNotBlank(errorMsg))
        {
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,errorMsg));
            return null;
        }
        
        if(doSave)  // create new contact
        {
            Contact con = new Contact(AccountId = book.Account__c,
                                        FirstName = (String) book.get(prefix + 'First_Name__c'),
                                        LastName = (String) book.get(prefix + 'Last_Name__c'),
                                        Phone = (String) book.get(prefix + 'Phone_Number__c'),
                                        Email = (String) book.get(prefix + 'Email_Address__c'));
            try
            {
                insert con;
            }
            catch(exception e)
            {
                Apexpages.addMessages(e);
                return null;
            }
            return con;
        }
        else    // try to match contact
        {
            String contactEmail = (String) book.get(prefix + 'Email_Address__c');
            if(String.isNotBlank(contactEmail))
            {
                List<Contact> cons = [select id from Contact where AccountId =:book.Account__c and Email = :contactEmail];
                if(!cons.isEmpty())
                {
                    return cons.get(0);
                }
            }
        }
        return new Contact();
    }
    
    public void setTimes()
    {
        book.Close_Time__c = closeTime.getFormatedTime();
        book.Lunch_Start__c = lunchStart.getFormatedTime();
        book.Lunch_End__c = lunchEnd.getFormatedTime();
    }
    
    public pageReference customSave()
    {   
        changeReadyDateTime();
        Boolean noErrors = isCollectionDTCorrect;
        
        setTimes();
        if(!generalValidation())
        {
            return null;
        }
        
        
        if(book.Account__c != null)
        {
            noErrors &= saveAddresses();
            noErrors &= saveContacts();
        }
        if(!noErrors) return null;
        
        try
        {
            upsert book;
            
            saveBookingLines();
            
            isSaved = true;
        }
        catch(exception e)
        {
            Apexpages.addMessages(e);
            isSaved = false;
            return null;
        }
        
        return null;
        //return new Pagereference('/' + book.Id);
    }
    
    public Boolean generalValidation()
    {
        if(!getIsDepotEditMode())
        {
            Apexpages.addMessage(
                new Apexpages.Message(ApexPages.Severity.ERROR,'Please finish Address and Line of Business sections before saving.'));
            return false;
        }
        
        if(book.Collection_Depot__c == null && book.Status__c != ConstantUtil.PLVAL_BOOKING_STATUS_CANCELLED)
        {
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'Booking must have collection depot.'));
            return false;
        }
        
        if(book.Collection_Ready_Time__c != null && book.Collection_Ready_Time__c.Date() < Date.Today() && book.Status__c != ConstantUtil.PLVAL_BOOKING_STATUS_CANCELLED)
        {
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'Collection Ready date must be today or later.'));
            return false;
        }
        
        if(book.Total_Items__c == null || book.Total_Weight__c == null)
        {
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'You must populate Total Items and Total Weight.'));
            return false;
        }
        if(String.isBlank(book.Close_Time__c))
        {
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'Please enter Close Time.'));
            return false;
        }
        if(String.isBlank(book.Enhanced_Liability__c))
        {
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'You must populate Enhanced Liability.'));
            return false;
        }
        
        if(unknownShipper != null)  // avoiding null exception
        {
            if(unknownShipper)
            {
                if(book.Collection_Instructions__c == null || !book.Collection_Instructions__c.startsWith(ConstantUtil.UNKNOWN_PREFIX))
                {
                    book.Collection_Instructions__c = 
                        ConstantUtil.UNKNOWN_PREFIX + (book.Collection_Instructions__c != null ? (' '+book.Collection_Instructions__c) : '');
                }
            }
            else
            {
                if(book.Collection_Instructions__c != null && book.Collection_Instructions__c.startsWith(ConstantUtil.UNKNOWN_PREFIX))
                {
                    book.Collection_Instructions__c = book.Collection_Instructions__c.replaceFirst(ConstantUtil.UNKNOWN_PREFIX,'');
                }
            }
        }
        
        
        // validate addresses
        List<Schema.FieldSetMember> fieldSetCol = new List<Schema.FieldSetMember>();
        List<Schema.FieldSetMember> fieldSetDel = new List<Schema.FieldSetMember>();
        List<Schema.FieldSetMember> fieldSetInv = new List<Schema.FieldSetMember>();
        Integer skip = 3;
        {
            List<Schema.FieldSetMember> fieldSet = sObjectType.Booking__c.FieldSets.AddressFields.getFields();
            for(Schema.FieldSetMember fsm : fieldSet)
            {
                if(Math.mod(skip,3) == 0)
                {
                    fieldSetCol.add(fsm);
                } 
                else if(Math.mod(skip,3) == 1)
                {
                    fieldSetDel.add(fsm);
                }
                else
                {
                    fieldSetInv.add(fsm);
                }
                skip++;
            }
        }
        if((String.isBlank(book.Coll_Postcode__c) || String.isNotBlank(FieldSetUtil.checkRequiredFieldsFS(book,fieldSetCol))) 
                && book.Status__c != ConstantUtil.PLVAL_BOOKING_STATUS_CANCELLED)
        {
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,
                'You must select/enter a collection address: Org Name, Postal Code, Street Address 1, and City/Town have to be populated.'));
            return false;
        }
        
        if(book.Carriage_Forward__c && (String.isBlank(book.Del_Postcode__c) || String.isNotBlank(FieldSetUtil.checkRequiredFieldsFS(book,fieldSetDel)))
                && book.Status__c != ConstantUtil.PLVAL_BOOKING_STATUS_CANCELLED)
        {
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,
                'You must select/enter a delivery address with Carriage Forward: Org Name, Postal Code, Street Address 1, and City/Town have to be populated.'));
            return false;
        }
        
        if(book.Carriage_Forward__c && book.Account__c == null && (String.isBlank(book.Inv_Postcode__c) || String.isNotBlank(FieldSetUtil.checkRequiredFieldsFS(book,fieldSetInv)))
                && book.Status__c != ConstantUtil.PLVAL_BOOKING_STATUS_CANCELLED)
        {
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,
                'You must select/enter an invoice address with Carriage Forward: Org Name, Postal Code, Street Address 1, and City/Town have to be populated.'));
            return false;
        }
        
        if(paperworkRequired == 'null'){
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,
                'You must select value for field "Driver take notes".'));
            return false;
        } else {
            book.Paperwork_Required__c = Boolean.valueOf(paperworkRequired);
        }
        
        if(commercialInvoiceRequired == 'null'){
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,
                'You must select value for field "Commercial Invoice Required".'));
            return false;
        } else {
            book.Commercial_Invoice_Required__c = Boolean.valueOf(commercialInvoiceRequired);
        }
        
        return true;
    }
    
    /* CREATE BOOKING FROM QUOTE */
    
    private String qId; 
    
    public void copyDataFromQuote(){
        if(!String.isBlank(qId) && book.Id == null){
        
            Quote__c qt = [SELECT Account__c, Contact__c, Contact__r.Email, Contact__r.FirstName,
                                Contact__r.LastName, Contact__r.Phone, Items_Description__c,
                                Collection_Date__c, Collection_Postcode__c, Delivery_Postcode__c,
                                Enhanced_Liability_Option__c, Total_Number_of_Items__c, Total_Weight__c,
                                Dangerous_Goods__c, Carriage_Forward__c, Company_Name__c, Company_Phone__c, 
                                Contact_Email__c, Contact_First_Name__c, Contact_Last_Name__c, Contact_Phone__c
                            FROM Quote__c WHERE Id = : qId];
            
            if(qt.Account__c != null) {
                book.Account__c = qt.Account__c;
            } else {
                book.Company_Name__c = qt.Company_Name__c;
                book.Company_Phone__c = qt.Company_Phone__c;
            }
            if(qt.Contact__c != null){
                book.Order_Contact__c = qt.Contact__c;
                book.OC_First_Name__c = qt.Contact__r.FirstName;
                book.OC_Last_Name__c = qt.Contact__r.LastName;
                book.OC_Phone_Number__c = qt.Contact__r.Phone;
                book.OC_Email_Address__c = qt.Contact__r.Email;
            } else {
                book.OC_First_Name__c = qt.Contact_First_Name__c;
                book.OC_Last_Name__c = qt.Contact_Last_Name__c;
                book.OC_Phone_Number__c = qt.Contact_Phone__c;
                book.OC_Email_Address__c = qt.Contact_Email__c;
            }
            
            book.Coll_Postcode__c = qt.Collection_Postcode__c;
            book.Del_Postcode__c = qt.Delivery_Postcode__c;
            book.Enhanced_Liability__c = qt.Enhanced_Liability_Option__c;
            book.Total_Items__c = qt.Total_Number_of_Items__c;
            book.Total_Weight__c = qt.Total_Weight__c;
            book.Dangerous_Goods__c = qt.Dangerous_Goods__c;
            book.Carriage_Forward__c = qt.Carriage_Forward__c;
            book.Quote__c = qt.Id;
            book.Collection_Ready_Time__c = (qt.Collection_Date__c != null ? 
                            DateTime.newInstance(qt.Collection_Date__c, Time.newInstance(DateTime.now().hour(), DateTime.now().minute(), 0, 0)) : null);
            book.Goods_Description__c = qt.Items_Description__c == null ? null
                            : (qt.Items_Description__c.length() > 30 ? qt.Items_Description__c.substring(0,30) : qt.Items_Description__c);
        }
        
    }
    
    /* INTEGRATION */
    
    public Boolean isSaved{get; set;}
    
    public pageReference saveBookingToUniverse(){
        String res = OL_BookingIntegrationUtil.saveBookingToUniverse(book.Id);
        
        if(res != null){
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 
                res + '<br/>You can view the booking <a href="/' + book.Id + '">here</a>.'));
        }
        
        if(Apexpages.hasMessages()){
            isSaved = false;
            return null;
        }
        return new Pagereference('/' + book.Id);
    }
    
    /* BOOKING LINE ITEM */
    
    public List<Booking_Line_Item__c> bookingItems {get; set;}
    public List<Booking_Line_Item__c> delBookingItems {get; set;}
    
    //DH
    public decimal getNumLongLengths()
    {
            Decimal count = 0;
                
            for(Booking_Line_Item__c bi : bookingItems)
            {
                if(bi.Length__c > 160 || bi.Width__c > 160 || bi.Height__c > 160)
                {
                    count += bi.Number_of_Items__c == null ? 0:bi.Number_of_Items__c;
                }
                    
            }
        
            return count;
            
    }
    
    
    public PageReference RefreshDarryl()
    {
        //getNumLongLengths();
        return null;
    }

    
    private void initBookingLines(){
        bookingItems = new List<Booking_Line_Item__c>();
        delBookingItems = new List<Booking_Line_Item__c>();
        
        String bId = book.Id == null ? oldRecordId : book.Id;
        
        if(bId != null){
            String qry;
            qry = OL_BookingQuoteHelper.getSoqlAllFieldsForObject(Booking_Line_Item__c.sObjectType) + ' WHERE Booking__c ' + ' = \''+bId+'\' ORDER BY Serial_Number__c';
            
            for(Booking_Line_Item__c so : Database.query(qry)){
                Booking_Line_Item__c nSo = so;
                if(oldRecordId != null){
                    nSo = so.clone(false, true);
                    nSo.Booking_Line_Item_Id__c = null; // erase unique field;
                    nSo.Serial_Number__c = null;
                    nSo.Booking__c = null;
                }
                bookingItems.add(nSo);
            }
        } else if(!String.isBlank(qId)){
            for(Quote_Line_Item__c qli : [SELECT Height__c, Length__c, Number_of_Items__c, Weight__c, Width__c 
                                            FROM Quote_Line_Item__c WHERE Quote__c = : qId]){
                Booking_Line_Item__c bli = new Booking_Line_Item__c();
                bli.Height__c = qli.Height__c;
                bli.Length__c = qli.Length__c;
                bli.Number_of_Items__c = qli.Number_of_Items__c;
                bli.Weight__c = qli.Weight__c;
                bli.Width__c = qli.Width__c;
                
                bookingItems.add(bli);
            }
        } else {
            bookingItems.add(new Booking_Line_Item__c());
        }
    }
    
    //Method adds line to Quotelines table
    public void addLine(){
        bookingItems.add(new Booking_Line_Item__c());
    }
    
    //Method removes line from Quote lines table
    public void removeLine(){
        Integer rowIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('rowIndex'));
        Booking_Line_Item__c del = bookingItems.remove(rowIndex);
        delBookingItems.add(del);
    }
    
    //Method saved modified or new lines and delete deleted lines
    private void saveBookingLines(){
        List<Booking_Line_Item__c> linesToDelete = new List<Booking_Line_Item__c>();
        List<Booking_Line_Item__c> linesToSave = new List<Booking_Line_Item__c>();
        Boolean hasData;
        List<Schema.FieldSetMember> bliFields = SObjectType.Booking_Line_Item__c.FieldSets.EditFields.getFields();
        
        Integer serialNum = 1;
        AggregateResult[] groupedResults = [SELECT MAX(Serial_Number__c) maxSN FROM Booking_Line_Item__c WHERE Booking__c = : book.Id];
        if(!groupedResults.isEmpty() && groupedResults[0].get('maxSN') != null){
            serialNum = Integer.valueOf(groupedResults[0].get('maxSN')) + 1;
        }
        
        for(Booking_Line_Item__c bli : bookingItems){
            if(bli.Id == null){
                bli.Booking__c = book.Id;
            }
            //check if data is entered
            if(!OL_BookingQuoteHelper.checkObjIsEmpty(bli, bliFields)){
                if(bli.Serial_Number__c == null){
                    bli.Serial_Number__c = serialNum;
                    serialNum++;
                }
                linesToSave.add(bli);
            } else if(bli.Id != null){
                linesToDelete.add(bli);
            }
        }
        
        if(!linesToSave.isEmpty()){
            upsert linesToSave;
        }
        
        for(Booking_Line_Item__c bli : delBookingItems){
            if(bli.Id != null){
                linesToDelete.add(bli);
            }
        }
        
        if(!linesToDelete.isEmpty()){
            delete linesToDelete;
        }
    }
    
    // TNT-1780 clone
    
    //Method to clone old Quote or Booking while editing, copied from the original method on OL_BookingQuoteHelper
    private void cloneRecord(){
        Schema.sObjectType objType = Booking__c.sObjectType;
        Schema.DescribeSObjectResult res = objType.getDescribe();       
        Map<String , Schema.SObjectField> mapFieldList = res.fields.getMap();
        Schema.SObjectField[] fields = mapFieldList.values();
        
        String qry = OL_BookingQuoteHelper.getSoqlAllFieldsForObject(objType) + ' WHERE Id = \''+oldRecordId+'\'';
        sObject oldObj = Database.query(qry);
        
        List<Schema.FieldSetMember> allFields = SObjectType.Booking__c.FieldSets.AddressFields.getFields();
        allFields.addAll(SObjectType.Booking__c.FieldSets.ContactFields.getFields());
        allFields.addAll(SObjectType.Booking__c.FieldSets.EditFields.getFields());  // all other fields to be copied should be added here
        for(Schema.FieldSetMember f : allFields) {
            if(f.getFieldPath() != 'Name'){
                book.put(f.getFieldPath(), oldObj.get(f.getFieldPath()));
            }
        }
    }
    
    /* STATIC */
    
    public static List<String> addressFieldNames
    {
        get
        {
            List<String> retLst = new List<String>();
            List<Schema.FieldSetMember> fieldSet = sObjectType.Account_Address__c.FieldSets.QuickCreateFields.getFields();
            for(Schema.FieldSetMember fsm : fieldSet)
            {
                retLst.add(fsm.getFieldPath());
            }
            return retLst;
        }
    }
    
    public static List<selectOption> getAccountAddesses(List<Account_Address__c> aas)
    {
        List<selectOption> sos = new List<selectOption>();
        
        sos.add(new selectOption('','- none -'));
    //  sos.add(new selectOption(newId,'- enter manually -'));
            
        if(aas != null)
        {
            for(Account_Address__c aaTmp : aas)
            {
                sos.add(new selectOption(aaTmp.id,
                                            aaTmp.Org_Name__c + ' (' + aaTmp.Street_1__c + ', ' + aaTmp.City__c + ' ' 
                                            + aaTmp.Postcode__c + ', ' + aaTmp.Country__c + ')'));
            }
        }
        return sos;
    }
    
    // lookup address bassed on postcode via gb mailer
    public List<Map<String, String>> pinpointPostcodeGBMailer(String postcode)
    {
        //resetGBMailer();
        List<Map<String, String>> gbmAddresses;
        if(String.isNotBlank(postcode))
        {
            try{
                gbmAddresses = GBMailer_Util.getAddresses(postcode);
            } catch(Exception ex) {
                Apexpages.addMessages(ex);  
            }
            if(gbmAddresses == null)
            {
                gbmAddresses = new List<Map<String,String>>();  // if null, won't render at all
            }
        }
        return gbmAddresses;
    }
    
    public static List<selectoption> getGBMailerAddresses(List<Map<String, String>> gbmAddresses)
    {
        List<selectoption> sos = new List<selectoption>();
        sos.add(new selectoption('','- none -'));
        
        if(gbmAddresses != null && !gbmAddresses.isEmpty())
        {
            Integer i = 0;
            for(Map<String,String> addr : gbmAddresses)
            {
                if(addr == null || addr.isEmpty()) continue;
                String lab = 
                    (String.isNotBlank(addr.get(GBMailer_Util.CODE_ORGANISATION)) ? addr.get(GBMailer_Util.CODE_ORGANISATION) : '(unknown)')
                    + ': ' +
                    (String.isNotBlank(addr.get(GBMailer_Util.CODE_BUILDINGNAME)) ? addr.get(GBMailer_Util.CODE_BUILDINGNAME) : '')
                    + ' ' +
                    (String.isNotBlank(addr.get(GBMailer_Util.CODE_STREET)) ? addr.get(GBMailer_Util.CODE_STREET) : '')
                    + ' ' +
                    (String.isNotBlank(addr.get(GBMailer_Util.CODE_BUILDINGNUMBER)) ? addr.get(GBMailer_Util.CODE_BUILDINGNUMBER) : '')
                    + ', ' +
                    (String.isNotBlank(addr.get(GBMailer_Util.CODE_TOWN)) ? addr.get(GBMailer_Util.CODE_TOWN) : '')
                    + ' ' +
                    (String.isNotBlank(addr.get(GBMailer_Util.CODE_POSTCODE)) ? addr.get(GBMailer_Util.CODE_POSTCODE) : '')
                    + ', UK';   // only UK supported as country so far
                
                sos.add(new selectoption('' + i++,lab));
            }
        }
        return sos;
    }
    
    //class to store data that is used to calcualate depot 
    public class BookindDepotCalculationData{
        private String collPostcode;
        private String collDistrict;
        private String collCity;
        private String lineOfBusiness;
        private DateTime collectionReadyTime;
        
        public BookindDepotCalculationData(Booking__c book){
            updateData(book);
        }
        
        public void updateData(Booking__c book){
            collPostcode = book.Coll_Postcode__c;
            collDistrict = book.Coll_District__c;
            collCity = book.Coll_City__c;
            lineOfBusiness = book.Line_of_Business__c;
            collectionReadyTime = book.Collection_Ready_Time__c;
        }
        
        public Boolean isUpdated(Booking__c book){
            return (collPostcode != book.Coll_Postcode__c && (!String.isBlank(collPostcode) || !String.isBlank(book.Coll_Postcode__c))) || 
                (collDistrict != book.Coll_District__c && (!String.isBlank(collDistrict) || !String.isBlank(book.Coll_District__c))) ||
                (collCity != book.Coll_City__c && (!String.isBlank(collCity) || !String.isBlank(book.Coll_City__c))) || 
                lineOfBusiness != book.Line_of_Business__c ||
                collectionReadyTime != book.Collection_Ready_Time__c;
        }
        
    }

}