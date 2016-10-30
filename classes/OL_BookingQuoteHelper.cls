/**
* File Name   :    OL_BookingQuoteHelper.cls
* Description :    
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 08/07/2014 Klea Kolaric   Initial version
* 0.2 16/07/2014 Klea Kolaric   TNT-476,TNT-477
* 0.3 23/07/2014 Liza Romanenko TNT-532, TNT-609
* 0.4 05/08/2014 Klea Kolaric   TNT-1293
* 0.5 05/08/2014 Liza Romanenko TNT-1326
* 0.6 06/08/2014 Liza Romanenko TNT-1329
* 0.7 19/08/2014 Klea Kolaric   TNT-1560    this extension will only be used for Quotes from now on, instead of both quote and booking
* 0.8 10/10/2014 Klea Kolaric   TNT-2030    mimic address behaviour from Bookings
* 0.9 17/10/2014 Klea Kolaric   TNT-2218    quote shouldn't save if line items fail
* 0.10 14/07/2015 Darryl Hopper             added getNumLongItems from line 361 and 255 to update No_LongLengthITems field
*/
public with sharing class OL_BookingQuoteHelper {
    
    public Id newId {
        get{
            return '000000000000000000';    // faulty Id to signal that we want new record
        }
        private set;
    }
    
    private sObject record;
    public Account currentAccount {get; set;}
    /* public Boolean createContact {get; set;} */
    private String oldRecordId;
    private String bId;
    public Boolean hadAccount {get; private set;}    // assert if record had account on load - glitch fix
    public List<Quote_Line_Item__c> quoteItems {get; set;}
    public List<Quote_Line_Item__c> delQuoteItems {get; set;}
    public String aaDefPC {get; private set;}
    public Boolean hasContactEmail {get; set;}
    
    public OL_BookingQuoteHelper(Apexpages.standardController stdCtrl)
    {
        record = stdCtrl.getRecord();
        hadAccount = ((Id) record.get('Id')) != null && ((Id) record.get(ConstantUtil.FLD_ACCOUNT_APINAME)) != null;
        //clone old record for editing
        oldRecordId = ApexPages.currentPage().getParameters().get('oId');
        bId = ApexPages.currentPage().getParameters().get('bId');
        copyDataFromBooking();
        if(!String.isEmpty(oldRecordId)){
            cloneRecord();
        }
        
        if(record instanceof Quote__c){
            initQuoteLines();
        }
        
        Id accountId = (Id) record.get(ConstantUtil.FLD_ACCOUNT_APINAME);
        if(accountId != null)
        {
            currentAccount = new Account(id = accountId);   // referencing account field in page gives null always for soem reason :(
            if(((Id) record.get('id')) == null && String.isBlank(oldRecordId) && String.isBlank(bId))
            {
                resetAddresses();
            }
        }
        findContactEmail();
    }
    
    public void resetAddresses()
    {
        findCurrentAccount();
        removeAddresses();
        if(record instanceof Quote__c)
        {
            Quote__c q = (Quote__c) record;
            q.Collection_Postcode__c = aaDefPC;
        }
    }
    
    public void collectionPostcodeChanged()
    {
        if(String.isNotBlank(aaDefPC))
        {
            if(record instanceof Quote__c)
            {
                Quote__c q = (Quote__c) record;
                if(q.Collection_Postcode__c != aaDefPC)
                {
                    q.Delivery_Postcode__c = aaDefPC;
                    q.Carriage_Forward__c = true;
                }
                else
                {
                    q.Carriage_Forward__c = false;
                    if(q.Delivery_Postcode__c == aaDefPC)
                    {
                        q.Delivery_Postcode__c = null;
                    }
                }
            }
        }
    }
    
    public void clearAccount()
    {
        currentAccount = null;
        aaDefPC = null;
        record.put(ConstantUtil.FLD_ACCOUNT_APINAME,null);
        removeAddresses();
    }
    
    public void removeAddresses()
    {
        if(record instanceof Quote__c)      // reset address fields
        {
            for(Schema.FieldSetMember fsm : sObjectType.Quote__c.FieldSets.AddressFields.getFields())
            {
                if(fsm.getType() == Schema.DisplayType.String)
                {
                    record.put(fsm.getFieldPath(),null);
                }
                else
                {
                    if(fsm.getType() == Schema.DisplayType.Boolean)
                    {
                        record.put(fsm.getFieldPath(),false);
                    }
                }
            }
        }
    }
    
    public void findCurrentAccount()
    {
        Id accountId = (Id) record.get(ConstantUtil.FLD_ACCOUNT_APINAME);
        currentAccount = accountId == null ? new Account() : 
            (Account) FieldSetUtil.queryViaFieldSet(
                        sObjectType.Account.FieldSets.AccountInfoFields.getFields(),
                        sObjectType.Account.getName(),
                        'Id = \'' + accountId + '\'').get(0);
        // this could have been done as an account child query but Im trying to keep the code interventions to a minimum
        aaDefPC = null;
        for(Account_Address__c aa : [select Postcode__c from Account_Address__c where Default__c = true and Account__c = :accountId])
        {
            aaDefPC = aa.Postcode__c;
            break;
        }
    }
    
    public String getOnStopURL()
    {
        Id accountId = (Id) record.get(ConstantUtil.FLD_ACCOUNT_APINAME);
        return Page.OL_AccountOnStopSubmitAgent.getUrl() + '?id=' + accountId;
    }
    
    public void findContactEmail()
    {
        Id contactId = (Id) record.get(ConstantUtil.FLD_CONTACT_APINAME);
        if(contactId != null)
        {
            Boolean hasEmail = [select count() from Contact where id = :contactId and Email != null] > 0;
            if(hasEmail)
            {
                record.put('Email_Only__c',null);
            }
            hasContactEmail = hasEmail;
        }
        else
        {
            hasContactEmail = false;
        }
    }
    
    public void emptyAction() {}
    
    
    public Boolean processNewAccount(Id accountId)
    {
        // remove fields if an account selected
        if(accountId != null)
        {
            List<Schema.FieldSetMember> fsms = sObjectType.Quote__c.FieldSets.CompanyFields.getFields();
            for(Schema.FieldSetMember fsm : fsms)
            {
                record.put(fsm.getFieldPath(),null);
            }
        }
        else
        {
            String errorMsg = FieldSetUtil.checkRequiredFieldsFS(record,sObjectType.Quote__c.FieldSets.CompanyFields.getFields());
            if(String.isNotBlank(errorMsg))
            {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,errorMsg));
                return false;
            }
        }
        return true;
    }
    
    public Boolean processNewContact(Id contactId)
    {
        // if no contact selected agent should populate contact fields
        if(contactId == null)
        {
            String errorMsg = FieldSetUtil.checkRequiredFieldsFS(record,sObjectType.Quote__c.FieldSets.ContactFields.getFields());
            if(String.isNotBlank(errorMsg))
            {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,errorMsg));
                return false;
            }
        }
        else
        {
            // remove fields if an contact selected
            List<Schema.FieldSetMember> fsms = sObjectType.Quote__c.FieldSets.ContactFields.getFields();
            for(Schema.FieldSetMember fsm : fsms)
            {
                record.put(fsm.getFieldPath(),null);
            }
        }
        return true;
    }
    
    public Pagereference customSave()
    {
        Id accountId = (Id) record.get(ConstantUtil.FLD_ACCOUNT_APINAME);
        Id contactId = (Id) record.get(ConstantUtil.FLD_CONTACT_APINAME);
        
        // process additional objects/fields
        Boolean noErrors = true;
        noErrors &= confirmHasQuoteLineItems();
        noErrors &= processNewAccount(accountId);
        noErrors &= processNewContact(contactId);
        if(!noErrors)
        {
            return null;    // if error while processing, refresh page
        }
        
        Savepoint sp = Database.setSavepoint();
        Boolean isNew = ((Quote__c) record).id == null;
        try
        {
            // check if required fields for object have been set
            String errorMsg = FieldSetUtil.checkRequiredFieldsFS(record,sObjectType.Quote__c.FieldSets.EditFields.getFields());
            if(record instanceof Quote__c){
                errorMsg += FieldSetUtil.checkRequiredFieldsFS(record, sObjectType.Quote__c.FieldSets.AddressFields.getFields());
            }
            if(String.isNotBlank(errorMsg))
            {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,errorMsg));
                return null;
            }
            // if everything ok insert object
            
            //DH
            record.put(Quote__c.No_Long_Length_Items__c,getNumLongLengths());

            
            upsert record;
            
            //check if it has been copied from Booking and update Booking
            if(bookFrom != null){
                bookFrom.Quote__c = record.Id;
                update bookFrom;
            }
            
            if(record instanceof Quote__c){
                saveQuoteLines();
            }
        }
        catch(DmlException ex)
        {
            ApexPages.addMessages(ex);
            if(((Quote__c) record).id != null && isNew) // don't save quote without items
            {
                Database.rollback(sp);  // if you saved quote but got an exception, it means something is wrong with line items
                record.put('id',null);  // remove the id if it was set by the save
            }
            return null;
        }
        return new Pagereference('/' + (String) record.get('Id'));
    }
    
    //Method to clone old Quote or Booking while editing 
    private void cloneRecord(){
        String objectType = '';
        Schema.sObjectType objType;
        Schema.DescribeSObjectResult res;
        if(record instanceof Quote__c){
            objType = Quote__c.sObjectType;
        } else {
            objType = Booking__c.sObjectType;
        }
        
        res = objType.getDescribe();        
        Map<String , Schema.SObjectField> mapFieldList = res.fields.getMap();
        Schema.SObjectField[] fields = mapFieldList.values();
        
        String qry = getSoqlAllFieldsForObject(objType) + ' WHERE Id = \''+oldRecordId+'\'';
        sObject oldObj = Database.query(qry);
        
        List<Schema.FieldSetMember> allFields = SObjectType.Quote__c.FieldSets.EditFields.getFields();
        allFields.addAll(SObjectType.Quote__c.FieldSets.AddressFields.getFields());
        for(Schema.FieldSetMember f : allFields) {
            if(f.getFieldPath() != 'Name'){
                record.put(f.getFieldPath(), oldObj.get(f.getFieldPath()));
            }
        }
    }
    
    //Method to clone Booking and Quiote lines
    /*private void cloneLines(){
        String objectType, parentType;
        String qry;
        Schema.sObjectType objType;
        objType = Booking_Line_Item__c.sObjectType;
        parentType = 'Booking__c';
        
        qry = getSoqlAllFieldsForObject(objType) + ' WHERE ' + parentType + ' = \''+oldRecordId+'\'';
        
        List<sObject> newLines = new List<sObject>();
        for(sObject so : Database.query(qry)){
            sObject nSo = so.clone(false, true);
            nSo.put(parentType, record.Id);
            newLines.add(nSo);
        }
        
        insert newLines;
        
    }*/
    
    //TNT-1329 Add Quote lines to the same edit page with Quote
    private void initQuoteLines(){
        quoteItems = new List<Quote_Line_Item__c>();
        delQuoteItems = new List<Quote_Line_Item__c>();
        
        String qId = (record.Id == null ? oldRecordId : record.Id);
        
        if(qId != null){
            String qry;
            qry = getSoqlAllFieldsForObject(Quote_Line_Item__c.sObjectType) + ' WHERE Quote__c ' + ' = \''+qId+'\'';
            
            for(Quote_Line_Item__c so : Database.query(qry)){
                Quote_Line_Item__c nSo = so;
                if(oldRecordId != null){
                    nSo = so.clone(false, true);
                }
                quoteItems.add(nSo);
            }
        } else if(!String.isBlank(bId)){
            for(Booking_Line_Item__c bli : [SELECT Height__c, Length__c, Number_of_Items__c, Weight__c, Width__c 
                                            FROM Booking_Line_Item__c WHERE Booking__c = : bId]){
                Quote_Line_Item__c qli = new Quote_Line_Item__c();
                qli.Height__c = bli.Height__c;
                qli.Length__c = bli.Length__c;
                qli.Number_of_Items__c = bli.Number_of_Items__c;
                qli.Weight__c = bli.Weight__c;
                qli.Width__c = bli.Width__c;
                
                quoteItems.add(qli);
            }
        } else {
            quoteItems.add(new Quote_Line_Item__c());
        }
    }
    
    //DH
    public decimal getNumLongLengths()
    {
            Decimal count = 0;
                
            for(Quote_Line_Item__c qi : quoteItems)
            {
                if(qi.Length__c > 160 || qi.Width__c > 160 || qi.Height__c > 160)
                {
                    count += qi.Number_of_Items__c == null ? 0:qi.Number_of_Items__c;
                }
                    
            }
        
            return count;
            
    }
    
    
    public PageReference RefreshDarryl()
    {
        //getNumLongLengths();
        return null;
    }

    
    // TNT-1928 check that at least one non-void line item exists
    private Boolean confirmHasQuoteLineItems()
    {
        List<Schema.FieldSetMember> qliFields = SObjectType.Quote_Line_Item__c.FieldSets.EditFields.getFields();
        if(!quoteItems.isEmpty())
        {
            for(Quote_Line_Item__c qli : quoteItems)
            {
                if(!checkObjIsEmpty(qli, qliFields))
                {
                    return true;
                }
            }
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,
                'At least one line item must be valid: all fields cannot be blank or 0.'));
        }
        else
        {
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'You must enter at least one line item.'));
        }
        return false;
    }
    
    //Method saved modified or new lines and delete deleted lines
    private void saveQuoteLines(){
        List<Quote_Line_Item__c> linesToDelete = new List<Quote_Line_Item__c>();
        List<Quote_Line_Item__c> linesToSave = new List<Quote_Line_Item__c>();
        Boolean hasData;
        List<Schema.FieldSetMember> qliFields = SObjectType.Quote_Line_Item__c.FieldSets.EditFields.getFields();
        
        for(Quote_Line_Item__c qli : quoteItems){
            if(qli.Id == null){
                qli.Quote__c = record.Id;
            }
            //check if data is entered
            if(!checkObjIsEmpty(qli, qliFields)){
                linesToSave.add(qli);
            } else if(qli.Id != null){
                linesToDelete.add(qli);
            }
        }
        
        if(!linesToSave.isEmpty()){
            upsert linesToSave;
        }
        
        for(Quote_Line_Item__c qli : delQuoteItems){
            if(qli.Id != null){
                linesToDelete.add(qli);
            }
        }
        
        if(!linesToDelete.isEmpty()){
            delete linesToDelete;
        }
    }
    
    //Method adds line to Quotelines table
    public void addLine(){
        quoteItems.add(new Quote_Line_Item__c());
    }
    
    //Method removes line from Quote lines table
    public void removeLine(){
        Integer rowIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('rowIndex'));
        Quote_Line_Item__c del = quoteItems.remove(rowIndex);
        delQuoteItems.add(del);
    }
    
    /* COPY DATA FROM BOOKING */
    private Booking__c bookFrom;
    
    public void copyDataFromBooking(){
        if(!String.isBlank(bId) && record.Id == null){
            bookFrom = [SELECT Account__c, Coll_Postcode__c, Del_Postcode__c, Enhanced_Liability__c, 
                                Dangerous_Goods__c, Carriage_Forward__c, Company_Name__c, Company_Phone__c, 
                                Order_Contact__c, OC_First_Name__c, OC_Last_Name__c, OC_Phone_Number__c,
                                OC_Email_Address__c, Collection_Ready_Time__c, Goods_Description__c
                               FROM Booking__c WHERE Id = : bId];
                               
            Quote__c qt = (Quote__c)record;
                               
            qt.Account__c = bookFrom.Account__c;
            qt.Company_Name__c = bookFrom.Company_Name__c;
            qt.Company_Phone__c = bookFrom.Company_Phone__c;
            
            qt.Contact__c = bookFrom.Order_Contact__c;
            qt.Contact_First_Name__c = bookFrom.OC_First_Name__c;
            qt.Contact_Last_Name__c = bookFrom.OC_Last_Name__c;
            qt.Contact_Phone__c = bookFrom.OC_Phone_Number__c;
            qt.Contact_Email__c = bookFrom.OC_Email_Address__c;
            
            qt.Collection_Postcode__c = bookFrom.Coll_Postcode__c;
            qt.Delivery_Postcode__c = bookFrom.Del_Postcode__c;
            qt.Enhanced_Liability_Option__c = bookFrom.Enhanced_Liability__c;
            qt.Dangerous_Goods__c = bookFrom.Dangerous_Goods__c;
            qt.Carriage_Forward__c = bookFrom.Carriage_Forward__c;
            qt.Collection_Date__c = (bookFrom.Collection_Ready_Time__c != null ?  bookFrom.Collection_Ready_Time__c.date() : null);
            qt.Items_Description__c = bookFrom.Goods_Description__c;
        }
    }
    
    /* STATIC */
    
    public static String getSoqlAllFieldsForObject(Schema.sObjectType objType){
        String res = '';
        
        Schema.DescribeSObjectResult describeRes = objType.getDescribe();
        
        String expr = getAllFieldsForObject(describeRes);
        res = expr + ' from ' + describeRes.getName();
        
        return res;
    }
    
    public static String getAllFieldsForObject(Schema.DescribeSObjectResult describeRes){
        String res = '';
        Map<String , Schema.SObjectField> mapFieldList = describeRes.fields.getMap();
        Schema.SObjectField[] fields = mapFieldList.values();
        String expr = '';
        for( Integer i=0; i < fields.size()-1; i++ )
        {
            Schema.DescribeFieldResult fieldResult = fields[i].getDescribe();
            expr += fieldResult.getName() + ', ';
        }
        Schema.DescribeFieldResult fieldResult = fields[fields.size() - 1].getDescribe();
        expr += fieldResult.getName();
        
        res = 'Select ' + expr;
        
        return res;
    }
    
    //Check if any data have been added to object
    public static Boolean checkObjIsEmpty(sObject obj, List<Schema.FieldSetMember> fieldsList){
        Boolean res = true;
        
        for(Schema.FieldSetMember f : fieldsList){
            if(obj.get(f.getFieldPath()) != null && obj.get(f.getFieldPath()) != '' && obj.get(f.getFieldPath()) != false
                && (f.getType() != Schema.DisplayType.Double || ((double) obj.get(f.getFieldPath())) != 0))
            {
                res = false;
                break;
            }
        }
        
        return res;
    }
}