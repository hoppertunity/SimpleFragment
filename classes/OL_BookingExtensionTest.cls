/**
* File Name   :    OL_BookingExtensionTest.cls
* Description :    
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 22/08/2014 Klea Kolaric   TNT-1560
* 0.2 28/08/2014 Liza Romanenko TNT-1328
* 0.3 14/07/2015 Darryl Hopper 
*/
@isTest
private class OL_BookingExtensionTest {
    
    public static List<Contact> createContacts(Id aId)
    {
        Contact co = TestUtil.createContact(aId);
        co.LastName += 'CO';
        co.Email += 'CO';
        co.Phone += '1';
        Contact cc = TestUtil.createContact(aId);
        cc.LastName += 'CC';
        cc.Email += 'CC';
        cc.Phone += '2';
        Contact cd = TestUtil.createContact(aId);
        cd.LastName += 'CD';
        cd.Email += 'CD';
        cd.Phone += '3';
        insert new List<Contact>{co,cc,cd};
        return new List<Contact>{co,cc,cd};
    }
    
    public static List<Line_Of_Business__c> createLOBs(Id aId)
    {
        Line_Of_Business__c lob1 = new Line_Of_Business__c();
        lob1.Name = 'LOB1';
        lob1.Line_Of_Business_Reference__c = '10';
        lob1.Commodities__c = 'SACK;CARTON;ROLL';
        lob1.Routing_Network__c = 'EXP';
        lob1.Active__c = true;
        Line_Of_Business__c lob2 = new Line_Of_Business__c();
        lob2.Name = 'LOB2';
        lob2.Line_Of_Business_Reference__c = '20';
        lob2.Commodities__c = 'SACK;CARTON;ROLL';
        lob2.Routing_Network__c = 'EWW';
        lob2.Active__c = true;
        insert new List<Line_Of_Business__c>{lob1,lob2};
        insert new List<Account_LOB__c>{new Account_LOB__c(Account__c = aId, Line_Of_Business__c = lob1.id), 
            new Account_LOB__c(Account__c = aId, Line_Of_Business__c = lob2.id)};
            
        // add services
        Service__c s1 = new Service__c();
        s1.Name = 'Service 1';
        s1.Service_Code__c = 'SER1';
        s1.Active__c = true;
        Service__c s2 = new Service__c();
        s2.Name = 'Service 2';
        s2.Service_Code__c = 'SER2';
        s2.Active__c = true;
        insert new List<Service__c>{s1,s2};
        
        insert new List<LOB_Service__c>{
            new LOB_Service__c(Line_Of_Business__c = lob1.id, Service__c = s1.id, Active__c = true),
            new LOB_Service__c(Line_Of_Business__c = lob1.id, Service__c = s2.id, Active__c = true),
            new LOB_Service__c(Line_Of_Business__c = lob2.id, Service__c = s1.id, Active__c = true)
        };
        
        return new List<Line_Of_Business__c>{lob1,lob2};
    }
    
    // TESTS
    
    public static testMethod void testNewBooking()
    {
        Account a = TestUtil.createAccountClient();
        insert a;
        Account depot = TestUtil.createAccountDepot();
        insert depot;
        Account_Address__c aaCol = TestUtil.createAccountAddress(a.Id,null);
        Account_Address__c aaDel = TestUtil.createAccountAddress(a.Id,null);
        aaDel.Postcode__c = 'BB1 AA1';
        insert new List<Account_Address__c>{aaCol,aaDel};
        
        List<Contact> cons = createContacts(a.Id);
        Contact co = cons.get(0);
        Contact cc = cons.get(1);
        Contact cd = cons.get(2);
        
        Test.startTest();
        Booking__c bo = new Booking__c();
        bo.Name = 'test book';
        bo.Account__c = a.Id;
        bo.Close_Time__c = '20:00';
        bo.Enhanced_Liability__c = ConstantUtil.PLVAL_QUOTE_ENHANCED_LIABILITY_OPTION_NONE;
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(bo);
        OL_BookingExtension bex = new OL_BookingExtension(sc);
        bex.commercialInvoiceRequired = 'false';
        bex.paperworkRequired = 'false';
        system.assert(!bex.getHasLOBs());
        
        bo.Order_Contact__c = co.Id;
        bex.loadContactValuesOC();
        bo.Collection_Contact__c = cc.Id;
        bex.loadContactValuesCC();
        bo.Delivery_Contact__c = cd.Id;
        bex.loadContactValuesDC();
        
        bex.getAccountAddessesCOL();
        bex.getAccountAddessesDEL();
        bex.aaIdCOL = aaCol.Id;
        bex.aaIdDEL = aaDel.Id;
        bex.loadAddressCOL();
        bex.loadAddressDEL();
        
        bex.enterLOBEditMode();
        bo.Commodity__c = 'SACK';
        bex.enterDepotEditMode();
        bex.book.Collection_Depot__c = depot.id;
        bex.customSave();
        Test.stopTest();
        
        system.assertEquals(1,[select count() from Booking__c 
                                where Coll_Account_Address__c = :aaCol.Id and Del_Account_Address__c = :aaDel.id]);
    }
    
    public static testMethod void testEditBooking()
    {
        Account a = TestUtil.createAccountClient();
        insert a;
        Account depot = TestUtil.createAccountDepot();
        insert depot;
        Account_Address__c aaCol = TestUtil.createAccountAddress(a.Id,null);
        Account_Address__c aaDel = TestUtil.createAccountAddress(a.Id,null);
        aaDel.Postcode__c = 'BB1 AA1';
        insert new List<Account_Address__c>{aaCol,aaDel};
        
        Booking__c bo = new Booking__c();
        bo.Name = 'test book';
        bo.Account__c = a.Id;
        bo.Close_Time__c = '20:00';
        bo.Enhanced_Liability__c = ConstantUtil.PLVAL_QUOTE_ENHANCED_LIABILITY_OPTION_NONE;
        bo.Coll_Account_Address__c = aaCol.Id;
        bo.Del_Account_Address__c = aaDel.Id;
        bo.OC_First_Name__c = 'OCName';
        bo.OC_Last_Name__c = 'OCSurname';
        bo.OC_Phone_Number__c = '0000000000';
        bo.CC_First_Name__c = 'CCName';
        bo.CC_Last_Name__c = 'CCSurname';
        bo.CC_Phone_Number__c = '1111111111';
        bo.DC_First_Name__c = 'DCName';
        bo.DC_Last_Name__c = 'DCSurname';
        bo.DC_Phone_Number__c = '2222222222';
        bo.Commodity__c = 'SACK';
        bo.Status__c = ConstantUtil.PLVAL_BOOKING_STATUS_CONFIRMED;
        insert bo;
        
        Test.startTest();
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(bo);
        OL_BookingExtension bex = new OL_BookingExtension(sc);      
        bex.getAccountAddessesCOL();
        bex.getAccountAddessesDEL();
        bex.aaIdCOL = aaCol.Id;
        bex.loadAddressCOL();
        bex.aaIdDEL = aaDel.Id;
        bex.loadAddressDEL();
        bex.createContactOrd = true;
        bex.createContactDel = true;
        bex.createContactCol = true;
        bex.enterLOBEditMode();
        bo.Commodity__c = 'SACK';
        bex.enterDepotEditMode();
        bex.book.Collection_Depot__c = depot.id;
        bex.customSave();
        Test.stopTest();
        
        List<Contact> cons = [select id from Contact order by Phone asc];
        system.assertEquals(3,cons.size());
        system.assertEquals(1,[select count() from Booking__c 
            where Coll_Account_Address__c = :aaCol.Id and Del_Account_Address__c = :aaDel.id
            and Order_Contact__c = :cons.get(0).Id and Collection_Contact__c = :cons.get(1).Id and Delivery_Contact__c = :cons.get(2).Id]);
    }
    
    public static testMethod void testAddAddressesBookingNoAccount()
    {
        Account a = TestUtil.createAccountClient();
        insert a;
        Account depot = TestUtil.createAccountDepot();
        insert depot;
        Account_Address__c aaCol = TestUtil.createAccountAddress(a.Id,null);
        Account_Address__c aaDel = TestUtil.createAccountAddress(a.Id,null);
        aaDel.Postcode__c = 'BB1 AA1';
        
        List<Contact> cons = createContacts(a.Id);
        Contact co = cons.get(0);
        Contact cc = cons.get(1);
        Contact cd = cons.get(2);
        
        Booking__c bo = new Booking__c();
        bo.Name = 'test book';
        bo.Company_Name__c ='test company';
        bo.Close_Time__c = '20:00';
        bo.Enhanced_Liability__c = ConstantUtil.PLVAL_QUOTE_ENHANCED_LIABILITY_OPTION_NONE;

        bo.Coll_Org_Name__c = aaCol.Org_Name__c;
        bo.Coll_Street_1__c = aaCol.Street_1__c;
        bo.Coll_Postcode__c = aaCol.Postcode__c;
        bo.Coll_City__c = aaCol.City__c;
        bo.Coll_Country__c = ConstantUtil.ISOCODE_UK;
        bo.Del_Org_Name__c = aaDel.Org_Name__c;
        bo.Del_Street_1__c = aaDel.Street_1__c;
        bo.Del_Postcode__c = aaDel.Postcode__c;
        bo.Del_City__c = aaDel.City__c;
        bo.Del_Country__c = ConstantUtil.ISOCODE_UK;

        Test.startTest();
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(bo);
        OL_BookingExtension bex = new OL_BookingExtension(sc);
        bex.commercialInvoiceRequired = 'false';
        bex.paperworkRequired = 'false';
        bex.selectAccount();
        
        system.assertEquals(OL_BookingExtension.newId,bex.aaIdCOL);
        system.assertEquals(OL_BookingExtension.newId,bex.aaIdDEL);
        
        bo.Order_Contact__c = co.Id;
        bex.loadContactValuesOC();
        bo.Order_Contact__c = null;
        bo.Collection_Contact__c = cc.Id;
        bex.loadContactValuesCC();
        bo.Collection_Contact__c = null;
        bo.Delivery_Contact__c = cd.Id;
        bex.loadContactValuesDC();
        bo.Delivery_Contact__c = null;
        
        bex.enterLOBEditMode();
        bo.Commodity__c = 'SACK';
        bex.enterDepotEditMode();
        bex.book.Collection_Depot__c = depot.id;
        bex.customSave();
        Test.stopTest();
        
        system.assertEquals(1,[select count() from Booking__c 
                                where Account__c = null
                                and Coll_Postcode__c = :aaCol.Postcode__c 
                                and Del_Postcode__c = :aaDel.Postcode__c]);
    }

    public static testMethod void testGBMailer()
    {
        Account a = TestUtil.createAccountClient();
        insert a;
        Account depot = TestUtil.createAccountDepot();
        insert depot;
        
        Booking__c bo = new Booking__c();
        bo.Name = 'test book';
        bo.Account__c = a.Id;
        bo.Close_Time__c = '20:00';
        bo.Enhanced_Liability__c = ConstantUtil.PLVAL_QUOTE_ENHANCED_LIABILITY_OPTION_NONE;
        bo.OC_First_Name__c = 'OCName';
        bo.OC_Last_Name__c = 'OCSurname';
        bo.OC_Phone_Number__c = '0000000000';
        bo.CC_First_Name__c = 'CCName';
        bo.CC_Last_Name__c = 'CCSurname';
        bo.CC_Phone_Number__c = '1111111111';
        bo.DC_First_Name__c = 'DCName';
        bo.DC_Last_Name__c = 'DCSurname';
        bo.DC_Phone_Number__c = '2222222222';
        bo.Coll_Postcode__c = 'sw162jp';
        bo.Del_Postcode__c = 'sw162jp';
        bo.Inv_Postcode__c = 'sw162jp';

        Test.startTest();
        Test.setMock(WebServiceMock.class, new GBMailer_ServiceMockImpl());

        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(bo);
        OL_BookingExtension bex = new OL_BookingExtension(sc);
        bex.commercialInvoiceRequired = 'true';
        bex.paperworkRequired = 'true';
        bex.getNoGBMailerCOL();
        bex.getNoGBMailerDEL();
        bex.getNoGBMailerINV();
        bex.emptyAction();
        bex.getAccountAddessesCOL();
        bex.getAccountAddessesDEL();
        bex.aaIdCOL = OL_BookingExtension.newId;
        bex.aaIdDEL = OL_BookingExtension.newId;
        bex.pinpointPostcodeGBMailerCOL();
        system.assertEquals(2,bex.getGBMAddressesCOL().size());
        system.assert(!bex.getExceededGBMailerCOL());
        bex.addressIndexStrCOL = '0';
        bex.populateGBMailerAddressCOL();
        bex.pinpointPostcodeGBMailerDEL();
        system.assertEquals(2,bex.getGBMAddressesDEL().size());
        system.assert(!bex.getExceededGBMailerDEL());
        bex.addressIndexStrDEL = '0';
        bex.populateGBMailerAddressDEL();
        bex.pinpointPostcodeGBMailerINV();
        system.assertEquals(2,bex.getGBMAddressesINV().size());
        system.assert(!bex.getExceededGBMailerINV());
        bex.addressIndexStrINV = '0';
        bex.populateGBMailerAddressINV();
        bex.enterLOBEditMode();
        bo.Commodity__c = 'SACK';
        bex.enterDepotEditMode();
        bex.book.Collection_Depot__c = depot.id;
        bex.customSave();
        Test.stopTest();
        
        system.assertEquals(1,[select count() from Booking__c 
                                where Coll_Org_Name__c = 'Address Name' 
                                and Del_Org_Name__c = 'Address Name'
                                and Inv_Org_Name__c = 'Address Name']);
    }
    
    public static testMethod void testOnStop()
    {
        Account a = TestUtil.createAccountClient();
        a.On_Stop__c = true;
        insert a;
        Account depot = TestUtil.createAccountDepot();
        insert depot;
        
        Test.startTest();
        Booking__c bo = new Booking__c();
        bo.Name = 'test book';
        bo.Account__c = a.Id;
        bo.Close_Time__c = '20:00';
        bo.Enhanced_Liability__c = ConstantUtil.PLVAL_QUOTE_ENHANCED_LIABILITY_OPTION_NONE;
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(bo);
        OL_BookingExtension bex = new OL_BookingExtension(sc);
        system.assertNotEquals(null,bex.getAccountNotifications());
        Test.stopTest();
    }
    
    public static testMethod void testAddAddressesBookingCarriageForward()
    {
        Account a = TestUtil.createAccountClient();
        insert a;
        Account depot = TestUtil.createAccountDepot();
        insert depot;
        Account_Address__c aaDef = TestUtil.createAccountAddress(a.Id,null);
        aaDef.Default__c = true;
        Account_Address__c aaReg = TestUtil.createAccountAddress(a.Id,null);
        aaReg.Postcode__c = 'BB1 AA1';
        insert new List<Account_Address__c>{aaDef,aaReg};
        
        Booking__c bo = new Booking__c();
        bo.Name = 'test book';
        bo.Account__c = a.Id;
        bo.Close_Time__c = '20:00';
        bo.Enhanced_Liability__c = ConstantUtil.PLVAL_QUOTE_ENHANCED_LIABILITY_OPTION_NONE;
        Test.startTest();
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(bo);
        OL_BookingExtension bex = new OL_BookingExtension(sc);
        
        bex.getAccountAddessesCOL();
        bex.getAccountAddessesDEL();
        system.assertEquals(aaDef.Id,bex.aaDefId);
        system.assertEquals(aaDef.Id,bex.aaIdCOL);
        system.assertEquals(null,bex.aaIdDEL);
        system.assert(!bo.Carriage_Forward__c);
        
        bex.aaIdCOL = aaReg.Id;
        bex.loadAddressCOL();
        system.assertEquals(aaDef.Id,bex.aaIdDEL);
        system.assert(bo.Carriage_Forward__c);
        
        bex.aaIdCOL = aaDEF.Id;
        bex.loadAddressCOL();
        system.assertEquals(null,bex.aaIdDEL);
        system.assert(!bo.Carriage_Forward__c);
        
        bex.aaIdDEL = OL_BookingExtension.newId;
        bex.loadAddressDEL();
        bex.aaIdCOL = aaREG.Id;
        bex.loadAddressCOL();
        system.assertEquals(aaDef.Id,bex.aaIdDEL);
        system.assert(bo.Carriage_Forward__c);
        
        bex.aaIdDEL = OL_BookingExtension.newId;
        bex.aaIdCOL = aaDEF.Id;
        bex.loadAddressCOL();
        system.assertEquals(OL_BookingExtension.newId,bex.aaIdDEL);
        system.assert(!bo.Carriage_Forward__c);
        
        Test.stopTest();
    }
    
    public static testMethod void testAddAddressesFails()
    {
        Account a = TestUtil.createAccountClient();
        insert a;
        Account depot = TestUtil.createAccountDepot();
        insert depot;
        Account_Address__c aaDef = TestUtil.createAccountAddress(a.Id,null);
        aaDef.Default__c = true;
        Account_Address__c aaReg = TestUtil.createAccountAddress(a.Id,null);
        aaReg.Postcode__c = 'BB1 AA1';
        insert new List<Account_Address__c>{aaDef,aaReg};
        
        List<Contact> cons = createContacts(a.Id);
        Contact co = cons.get(0);
        Contact cc = cons.get(1);
        Contact cd = cons.get(2);
        
        Booking__c bo = new Booking__c();
        bo.Name = 'test book';
        bo.Account__c = a.Id;
        bo.Close_Time__c = '20:00';
        bo.Enhanced_Liability__c = ConstantUtil.PLVAL_QUOTE_ENHANCED_LIABILITY_OPTION_NONE;
        Test.startTest();
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(bo);
        OL_BookingExtension bex = new OL_BookingExtension(sc);
        bex.commercialInvoiceRequired = 'false';
        bex.paperworkRequired = 'false';
        
        bo.Order_Contact__c = co.Id;
        bex.loadContactValuesOC();
        bex.copyContactValuesCO2CC();
        bo.Order_Contact__c = null;
        bo.Collection_Contact__c = null;
        bo.Delivery_Contact__c = cd.Id;
        bex.loadContactValuesDC();
        bo.Delivery_Contact__c = null;
        
        bex.getAccountAddessesCOL();
        bex.getAccountAddessesDEL();
        system.assertEquals(aaDef.Id,bex.aaIdCOL);
        bex.aaIdCOL = aaReg.Id;
        bex.loadAddressCOL();
        system.assertEquals(aaDef.Id,bex.aaIdDEL);
        system.assert(bo.Carriage_Forward__c);
        
        //TNT-2650 temporary disablement of validation pending revised address validation / automation structure
        /*
        bex.aaIdCOL = aaDef.Id;
        bex.enterDepotEditMode();
        bex.book.Collection_Depot__c = depot.id;
        bex.customSave();
        system.assertEquals(null,bo.id);    // save failed because both addresses are the same
        
        bex.aaIdCOL = aaReg.Id;
        bex.aaIdDEL = null;
        bo.Carriage_Forward__c = true;
        bex.enterDepotEditMode();
        bex.book.Collection_Depot__c = depot.id;
        bex.book.Del_Postcode__c = null;
        bex.customSave();
        system.assertEquals(null,bo.id);    // save failed because we need delivery address if CF
        
        bo.Carriage_Forward__c = true;
        bex.aaIdCOL = OL_BookingExtension.newId;
        bex.loadAddressCOL();
        bex.aaIdDEL = null;
        bex.clearAddressDEL();
        bex.loadAddressDEL();
        
        bo.Coll_Org_Name__c = aaDef.Org_Name__c;
        bo.Coll_Street_1__c = aaDef.Street_1__c;
        bo.Coll_Postcode__c = aaDef.Postcode__c;
        bo.Coll_City__c = aaDef.City__c;
        bo.Coll_Country__c = ConstantUtil.ISOCODE_UK;
        
        bex.customSave();
        bex.enterDepotEditMode();
        bex.book.Collection_Depot__c = depot.id;
        system.assertEquals(null,bo.id);    // save failed because we need delivery address if CF
        
        bo.Carriage_Forward__c = false;
        bex.loadAddressDEL();
        
        bex.enterLOBEditMode();
        bo.Commodity__c = 'SACK';
        bex.enterDepotEditMode();
        bex.book.Collection_Depot__c = depot.id;
        bex.customSave();
        system.assertNotEquals(null,bo.id);
        */
        Test.stopTest();
    }
    
    public static testMethod void testLOB()
    {
        Account a = TestUtil.createAccountClient();
        insert a;
        Account depot = TestUtil.createAccountDepot();
        insert depot;
        Account_Address__c aaDef = TestUtil.createAccountAddress(a.Id,null);
        aaDef.Default__c = true;
        Account_Address__c aaReg = TestUtil.createAccountAddress(a.Id,null);
        aaReg.Postcode__c = 'SW15 1NP';
        insert new List<Account_Address__c>{aaDef,aaReg};
        
        List<Contact> cons = createContacts(a.Id);
        Contact co = cons.get(0);
        Contact cc = cons.get(1);
        Contact cd = cons.get(2);
        
        createLOBs(a.Id);
        
        List<Account_LOB__c> acclobs = [select id, Residential_Collection_Charge__c, Residential_Delivery_Charge__c
                                        from Account_LOB__c];
        for(Account_LOB__c alob : acclobs)
        {
            alob.Residential_Collection_Charge__c = true;
            alob.Residential_Delivery_Charge__c = true;
        }
        update acclobs;
        
        insert new List<Postcode__c>{
            new Postcode__c(Name = aaDef.Postcode__c, Category__c = ConstantUtil.PLVAL_POSTCODE_CATEGORY_RESIDENTIAL), 
            new Postcode__c(Name = aaReg.Postcode__c, Category__c = ConstantUtil.PLVAL_POSTCODE_CATEGORY_RESIDENTIAL)};
        
        Booking__c bo = new Booking__c();
        bo.Name = 'test book';
        bo.Account__c = a.Id;
        bo.Close_Time__c = '20:00';
        Test.startTest();
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(bo);
        OL_BookingExtension bex = new OL_BookingExtension(sc);
        bex.commercialInvoiceRequired = 'false';
        bex.paperworkRequired = 'false';
        
        system.assert(bex.getIsAddressEditMode());
        bex.enterAddressEditMode();
        bex.clearContactValues(OL_BookingExtension.CONTACT_ORDER_PREFIX);
        
        bo.Order_Contact__c = co.Id;
        bex.loadContactValuesOC();
        bex.copyContactValuesCO2CC();
        bo.Delivery_Contact__c = cd.Id;
        bex.loadContactValuesDC();
        
        bex.getAccountAddessesCOL();
        bex.getAccountAddessesDEL();
        bex.aaIdDEL = aaReg.id;
        bex.loadAddressDEL();
        
        bex.enterLOBEditMode();
        system.assert(bex.getIsLOBEditMode());
        bex.resetSubLOB();
        
        system.assertEquals(2,bex.getAvailableLOBs().size());
        system.assert(bex.getHasLOBs());
        system.assertEquals(3,bex.getAvailableCommodities().size());
        system.assert(bex.getHasCommodity());
        system.assertNotEquals(null,bex.getLOBNotifications());
        bex.getLiabilityOptions();
        
        system.assertEquals(2,bex.getAvailableServices().size());
        system.assert(bex.getHasServices());
        
        bex.enterDepotEditMode();
        bex.book.Collection_Depot__c = depot.id;
        bo.Enhanced_Liability__c = ConstantUtil.PLVAL_QUOTE_ENHANCED_LIABILITY_OPTION_NONE;
        bex.customSave();
        system.assertNotEquals(null,bo.id);
        system.assertNotEquals(null,bo.Line_of_Business__c);
        system.assertNotEquals(null,bo.Service__c);
        
        Test.stopTest();
    }
    
    public static testMethod void testContactCopy() // make sure contacts are not duplicated
    {
        Account a = TestUtil.createAccountClient();
        insert a;
        Account depot = TestUtil.createAccountDepot();
        insert depot;
        Account_Address__c aaDef = TestUtil.createAccountAddress(a.Id,null);
        aaDef.Default__c = true;
        Account_Address__c aaReg = TestUtil.createAccountAddress(a.Id,null);
        aaReg.Postcode__c = 'BB1 AA1';
        insert new List<Account_Address__c>{aaDef,aaReg};
        
        List<Contact> cons = createContacts(a.Id);
        Contact co = cons.get(0);
        Contact cc = cons.get(1);
        Contact cd = cons.get(2);
        
        createLOBs(a.Id);
        
        Booking__c bo = new Booking__c();
        bo.Name = 'test book';
        bo.Account__c = a.Id;
        bo.Close_Time__c = '20:00';
        bo.Enhanced_Liability__c = ConstantUtil.PLVAL_QUOTE_ENHANCED_LIABILITY_OPTION_NONE;
        Test.startTest();
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(bo);
        OL_BookingExtension bex = new OL_BookingExtension(sc);
        
        bo.Order_Contact__c = co.Id;
        bex.loadContactValuesOC();
        bo.Order_Contact__c = null;
        bex.copyContactValuesCO2CC();
        bo.Collection_Contact__c = null;
        bex.copyContactValuesCO2DC();
        bo.Delivery_Contact__c = null;
        bex.createContactOrd = true;
        bex.createContactCol = true;
        bex.createContactDel = true;
        
        bex.getAccountAddessesCOL();
        bex.getAccountAddessesDEL();
        
        bex.enterLOBEditMode();
        bo.Commodity__c = 'SACK';
        bex.enterDepotEditMode();
        bex.book.Collection_Depot__c = depot.id;
        bex.customSave();
        
        system.assertEquals(bo.Order_Contact__c,bo.Collection_Contact__c);
        system.assertEquals(bo.Order_Contact__c,bo.Delivery_Contact__c);
        
        Test.stopTest();
    }

    public static testMethod void testBookingLineItems()
    {
        Account a = TestUtil.createAccountClient();
        insert a;
        Account depot = TestUtil.createAccountDepot();
        insert depot;
        Account_Address__c aaCol = TestUtil.createAccountAddress(a.Id,null);
        Account_Address__c aaDel = TestUtil.createAccountAddress(a.Id,null);
        aaDel.Postcode__c = 'BB1 AA1';
        insert new List<Account_Address__c>{aaCol,aaDel};
        
        Booking__c bo = new Booking__c();
        bo.Name = 'test book';
        bo.Account__c = a.Id;
        bo.Close_Time__c = '20:00';
        bo.Enhanced_Liability__c = ConstantUtil.PLVAL_QUOTE_ENHANCED_LIABILITY_OPTION_NONE;
        bo.Coll_Account_Address__c = aaCol.Id;
        bo.Del_Account_Address__c = aaDel.Id;
        bo.OC_First_Name__c = 'OCName';
        bo.OC_Last_Name__c = 'OCSurname';
        bo.OC_Phone_Number__c = '0000000000';
        bo.CC_First_Name__c = 'CCName';
        bo.CC_Last_Name__c = 'CCSurname';
        bo.CC_Phone_Number__c = '1111111111';
        bo.DC_First_Name__c = 'DCName';
        bo.DC_Last_Name__c = 'DCSurname';
        bo.DC_Phone_Number__c = '2222222222';
        bo.Commodity__c = 'SACK';
        bo.Status__c = ConstantUtil.PLVAL_BOOKING_STATUS_CONFIRMED;
        insert bo;
        
        Booking_Line_Item__c bli = new Booking_Line_Item__c();
        bli.Number_Of_Items__c = 1;
        bli.Height__c = 10;
        bli.Length__c = 10;
        bli.Weight__c = 10;
        bli.Width__c = 10;
        bli.Booking__c = bo.Id;
        insert bli;
        
        Test.startTest();
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(bo);
        OL_BookingExtension bex = new OL_BookingExtension(sc);      
        bex.addLine();
        
        Booking_Line_Item__c bli1 = new Booking_Line_Item__c();
        bli1.Number_Of_Items__c = 1;
        bli1.Height__c = 10;
        bli1.Length__c = 10;
        bli1.Weight__c = 10;
        bli1.Width__c = 10;
        
        bex.bookingItems.add(bli1);
        
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        bex.removeLine();
        bex.enterLOBEditMode();
        bo.Commodity__c = 'SACK';
        bex.enterDepotEditMode();
        bex.book.Collection_Depot__c = depot.id;
        bex.aaIdCOL = aaCol.id;
        bex.loadAddressCOL();
        bex.aaIdDEL = aaDel.id;
        bex.loadAddressDEL();
        bex.customSave();
        Test.stopTest();
        
        List<Booking_Line_Item__c> cons = [select id from Booking_Line_Item__c];
        system.assertEquals(1,cons.size());
        system.assertNotEquals(bli.Id,cons[0].Id);
    }
    
    public static testMethod void testDepotRouting()
    {
        Account a = TestUtil.createAccountClient();
        insert a;
        Account_Address__c aaDef = TestUtil.createAccountAddress(a.Id,null);
        aaDef.Default__c = true;
        insert aaDef;
        
        List<Contact> cons = createContacts(a.Id);
        Contact co = cons.get(0);
        Contact cc = cons.get(1);
        Contact cd = cons.get(2);
        
        List<Line_of_Business__c> lobs = createLOBs(a.Id);
        Date collDate = Date.newInstance(2014,9,1);
        Account depot = TestUtil.setupDepotRouting(lobs.get(0).id,aaDef,collDate);
        
        // we expect only one routing table record, and that 'Service 1' is selected
        insert new Service_Guarantee__c(Service__c = [select id from Service__c where Name like '%1' limit 1].id,
                                        Routing_Table__c = [select id from Routing_Table__c limit 1].id);
                
        Booking__c bo = new Booking__c();
        bo.Name = 'test book';
        bo.Account__c = a.Id;
        bo.Close_Time__c = '20:00';
        bo.Enhanced_Liability__c = ConstantUtil.PLVAL_QUOTE_ENHANCED_LIABILITY_OPTION_NONE;
        Test.startTest();
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(bo);
        OL_BookingExtension bex = new OL_BookingExtension(sc);
        
        system.assert(bex.getIsAddressEditMode());
        bex.enterAddressEditMode();
        bex.clearContactValues(OL_BookingExtension.CONTACT_ORDER_PREFIX);
        
        bo.Order_Contact__c = co.Id;
        bex.loadContactValuesOC();
        bex.copyContactValuesCO2CC();
        bo.Delivery_Contact__c = cd.Id;
        bex.loadContactValuesDC();
        
        bex.getAccountAddessesCOL();
        bex.getAccountAddessesDEL();
        
        bex.enterLOBEditMode();
        bex.resetSubLOB();
        bex.getAvailableLOBs();
        bex.getLiabilityOptions();
        bex.getAvailableServices();
        bex.getAvailableCommodities();
        system.assertNotEquals(null,bo.Line_of_Business__c);
        
        bex.overrideCollDepot = true;
        bex.onManualOverride();
        bex.overrideCollDepot = false;
        bo.Collection_Ready_Time__c = Datetime.newInstance(collDate,Time.newInstance(12,0,0,0));
        bex.collectionReadyTime = '01/09/2014 12:00';
        bex.enterDepotEditMode();
        bex.getCollDepotNotifications();
        system.assert(bex.getIsDepotEditMode());
        bex.customSave();   // save is actually failing because collection date is in the past, but not really relavant for test
        system.assertEquals(depot.id,bo.Collection_Depot__c);
        system.assertNotEquals(null,bo.Routing_Table__c);
        system.assertNotEquals(null,bo.Depot_Routing__c);
        
        Test.stopTest();
    }
    
    public static testMethod void testItegration()
    {
        Account a = TestUtil.createAccountClient();
        insert a;
        Account_Address__c aaCol = TestUtil.createAccountAddress(a.Id,null);
        Account_Address__c aaDel = TestUtil.createAccountAddress(a.Id,null);
        aaDel.Postcode__c = 'BB1 AA1';
        insert new List<Account_Address__c>{aaCol,aaDel};
        
        Booking__c bo = new Booking__c();
        bo.Name = 'test book';
        bo.Account__c = a.Id;
        bo.Close_Time__c = '20:00';
        bo.Enhanced_Liability__c = ConstantUtil.PLVAL_QUOTE_ENHANCED_LIABILITY_OPTION_NONE;
        bo.Coll_Account_Address__c = aaCol.Id;
        bo.Del_Account_Address__c = aaDel.Id;
        bo.OC_First_Name__c = 'OCName';
        bo.OC_Last_Name__c = 'OCSurname';
        bo.OC_Phone_Number__c = '0000000000';
        bo.CC_First_Name__c = 'CCName';
        bo.CC_Last_Name__c = 'CCSurname';
        bo.CC_Phone_Number__c = '1111111111';
        bo.DC_First_Name__c = 'DCName';
        bo.DC_Last_Name__c = 'DCSurname';
        bo.DC_Phone_Number__c = '2222222222';
        bo.Commodity__c = 'SACK';
        bo.Status__c = ConstantUtil.PLVAL_BOOKING_STATUS_CONFIRMED;
        insert bo;
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new uksvcsTntComBookingServiceMock());
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(bo);
        OL_BookingExtension bex = new OL_BookingExtension(sc);
        
        bex.saveBookingToUniverse();
        Test.stopTest();
        
        bo = [SELECT Status__c, Is_Synchronisation_Failed__c, Synchronisation_Error_Message__c 
                FROM Booking__c WHERE Id = : bo.Id];
        system.assertEquals(ConstantUtil.PLVAL_BOOKING_STATUS_CONFIRMED, bo.Status__c);
        /*system.assertEquals(null, bo.Synchronisation_Error_Message__c);
        
        List<Booking_History__c> bh = [SELECT Id, Movement_Type__c FROM Booking_History__c];
        system.assertEquals(1, bh.size());
        system.assertEquals(ConstantUtil.PLVAL_BOOKING_HISTORY_MOVEMENT_TYPE_RAISED, bh[0].Movement_Type__c);*/
    }
    
    public static testMethod void test_createFromQuote()
    {
        Account a = TestUtil.createAccountClient();
        insert a;
        Contact c = TestUtil.createContact(a.Id);
        insert c;
        
        Quote__c qt = new Quote__c();
        qt.Account__c = a.Id;
        qt.Contact__c = c.Id;
        qt.Email_Only__c = 'testmail@gdgfd.tst';
        qt.Collection_Postcode__c = 'aa111a';
        qt.Delivery_Postcode__c = 'aa111a';
        insert qt;
        
        Quote_Line_Item__c qli = new Quote_Line_Item__c();
        qli.Number_of_Items__c = 1;
        qli.Height__c = 10;
        qli.Length__c = 10;
        qli.Weight__c = 10;
        qli.Width__c = 10;
        qli.Quote__c = qt.Id;
        insert qli;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('qId', qt.Id);
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(new Booking__c());
        OL_BookingExtension bex = new OL_BookingExtension(sc);
        Test.stopTest();
        
        system.assertEquals(1,bex.bookingItems.size());
        system.assertEquals(10,bex.bookingItems[0].Height__c);
        system.assert(bex.accountSelected);
    }
    
    public static testMethod void test_createFromQuote2()
    {
        Account a = TestUtil.createAccountClient();
        insert a;
        Contact c = TestUtil.createContact(a.Id);
        insert c;
        
        Quote__c qt = new Quote__c();
        qt.Company_Name__c = 'My Company';
        qt.Company_Phone__c = '12344321';
        qt.Contact_First_Name__c = 'test';
        qt.Contact_Last_Name__c = 'guy';
        qt.Contact_Phone__c = '123443211';
        qt.Contact_Email__c = 'myemail@gfffhgg.ggg';
        qt.Collection_Postcode__c = 'aa111a';
        qt.Delivery_Postcode__c = 'aa111a';
        qt.Email_the_quote__c = false;
        insert qt;
        
        Quote_Line_Item__c qli = new Quote_Line_Item__c();
        qli.Number_of_Items__c = 1;
        qli.Height__c = 10;
        qli.Length__c = 10;
        qli.Weight__c = 10;
        qli.Width__c = 10;
        qli.Quote__c = qt.Id;
        insert qli;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('qId', qt.Id);
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(new Booking__c());
        OL_BookingExtension bex = new OL_BookingExtension(sc);
        Test.stopTest();
        
        system.assertEquals(1,bex.bookingItems.size());
        system.assertEquals(10,bex.bookingItems[0].Height__c);
        system.assert(bex.accountSelected);
    }
    
    public static testMethod void testFindServiceGuaranteeForDelivery()
    {
        Account a = TestUtil.createAccountClient();
        insert a;
        Account_Address__c aaDef = TestUtil.createAccountAddress(a.Id,null);
        aaDef.Default__c = true;
        insert aaDef;
        
        List<Line_of_Business__c> lobs = createLOBs(a.Id);
        Date collDate = Date.newInstance(2014,9,1);
        Account depot = TestUtil.setupDepotRouting(lobs.get(0).id,aaDef,collDate);
        
        // we expect only one routing table record, and that 'Service 1' is selected
        insert new Service_Guarantee__c(Service__c = [select id from Service__c where Name like '%1' limit 1].id,
                                        Routing_Table__c = [select id from Routing_Table__c limit 1].id);
                                        
        Booking__c bo = new Booking__c();
        bo.Name = 'test book';
        bo.Account__c = a.Id;
        bo.Close_Time__c = '20:00';
        bo.Enhanced_Liability__c = ConstantUtil.PLVAL_QUOTE_ENHANCED_LIABILITY_OPTION_NONE;
        Test.startTest();
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(bo);
        OL_BookingExtension bex = new OL_BookingExtension(sc);
        
        system.assert(bex.getIsAddressEditMode());
        bex.enterAddressEditMode();
        bex.clearContactValues(OL_BookingExtension.CONTACT_ORDER_PREFIX);
        
        bex.getAccountAddessesCOL();
        bex.getAccountAddessesDEL();
        bex.aaIdCOL = OL_BookingExtension.newId;
        bex.loadAddressCOL();
        system.assertEquals(bex.aaIdDEL,aaDef.Id);
        
        bex.enterLOBEditMode();
        bex.resetSubLOB();
        bex.getAvailableLOBs();
        bex.getLiabilityOptions();
        bex.getAvailableServices();
        bex.getAvailableCommodities();
        system.assertNotEquals(null,bo.Line_of_Business__c);
        
        bo.Collection_Ready_Time__c = Datetime.newInstance(collDate,Time.newInstance(12,0,0,0));
        bex.enterDepotEditMode();
        String errorMsg = bex.getCollDepotNotifications();
        
        Test.stopTest();
        
        system.assert(errorMsg.contains(Label.Service_NOT_Guaranteed_Message));
    }
    
    public static testMethod void testQuickClone()
    {
        Account a = TestUtil.createAccountClient();
        insert a;
        Account_Address__c aaCol = TestUtil.createAccountAddress(a.Id,null);
        Account_Address__c aaDel = TestUtil.createAccountAddress(a.Id,null);
        aaDel.Postcode__c = 'BB1 AA1';
        insert new List<Account_Address__c>{aaCol,aaDel};
        
        Booking__c bo = new Booking__c();
        bo.Name = 'test book';
        bo.Account__c = a.Id;
        bo.Coll_Account_Address__c = aaCol.Id;
        bo.Del_Account_Address__c = aaDel.Id;
        bo.OC_First_Name__c = 'OCName';
        bo.OC_Last_Name__c = 'OCSurname';
        bo.OC_Phone_Number__c = '0000000000';
        bo.CC_First_Name__c = 'CCName';
        bo.CC_Last_Name__c = 'CCSurname';
        bo.CC_Phone_Number__c = '1111111111';
        bo.DC_First_Name__c = 'DCName';
        bo.DC_Last_Name__c = 'DCSurname';
        bo.DC_Phone_Number__c = '2222222222';
        bo.Commodity__c = 'SACK';
        bo.Collection_Ready_Time__c = Datetime.now();
        bo.Status__c = ConstantUtil.PLVAL_BOOKING_STATUS_CONFIRMED;
        insert bo;
        
        Booking_Line_Item__c bli = new Booking_Line_Item__c();
        bli.Booking__c = bo.Id;
        bli.Number_of_items__c = 3;
        bli.Weight__c = 2;
        bli.Height__c = 100;
        bli.Width__c = 100;
        bli.Length__c = 100;
        insert bli;
        
        ApexPages.currentPage().getParameters().put('oId', bo.Id);
        Test.startTest();
        Booking__c boClone = new Booking__c();
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(boClone);
        OL_BookingExtension bex = new OL_BookingExtension(sc);
        Test.stopTest();
        
        system.assertEquals(null,boClone.id);
        system.assertEquals(bo.Account__c,boClone.Account__c);
        system.assertEquals(bo.OC_First_Name__c,boClone.OC_First_Name__c);
        system.assertEquals(1,bex.bookingItems.size());
        system.assertEquals(null,bex.bookingItems.get(0).Id);
        system.assertEquals(null,bex.bookingItems.get(0).Booking__c);
    }
    
    public static testMethod void testInvoiceAddressesBookingNoAccount()
    {
        Account a = TestUtil.createAccountClient();
        insert a;
        Account depot = TestUtil.createAccountDepot();
        insert depot;
        Account_Address__c aaCol = TestUtil.createAccountAddress(a.Id,null);
        Account_Address__c aaDel = TestUtil.createAccountAddress(a.Id,null);
        aaDel.Postcode__c = 'BB1 AA1';
        
        List<Contact> cons = createContacts(a.Id);
        Contact co = cons.get(0);
        Contact cc = cons.get(1);
        Contact cd = cons.get(2);
        
        Booking__c bo = new Booking__c();
        bo.Name = 'test book';
        bo.Company_Name__c ='test company';
        bo.Close_Time__c = '20:00';
        bo.Enhanced_Liability__c = ConstantUtil.PLVAL_QUOTE_ENHANCED_LIABILITY_OPTION_NONE;

        bo.Coll_Org_Name__c = aaCol.Org_Name__c;
        bo.Coll_Street_1__c = aaCol.Street_1__c;
        bo.Coll_Postcode__c = aaCol.Postcode__c;
        bo.Coll_City__c = aaCol.City__c;
        bo.Coll_Country__c = ConstantUtil.ISOCODE_UK;
        bo.Del_Org_Name__c = aaDel.Org_Name__c;
        bo.Del_Street_1__c = aaDel.Street_1__c;
        bo.Del_Postcode__c = aaDel.Postcode__c;
        bo.Del_City__c = aaDel.City__c;
        bo.Del_Country__c = ConstantUtil.ISOCODE_UK;
        bo.Carriage_Forward__c = true;

        Test.startTest();
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(bo);
        OL_BookingExtension bex = new OL_BookingExtension(sc);
        bex.commercialInvoiceRequired = 'false';
        bex.paperworkRequired = 'false';
        bex.selectAccount();
        
        system.assertEquals(OL_BookingExtension.newId,bex.aaIdCOL);
        system.assertEquals(OL_BookingExtension.newId,bex.aaIdDEL);
        
        bo.Order_Contact__c = co.Id;
        bex.loadContactValuesOC();
        bo.Order_Contact__c = null;
        bo.Collection_Contact__c = cc.Id;
        bex.loadContactValuesCC();
        bo.Collection_Contact__c = null;
        bo.Delivery_Contact__c = cd.Id;
        bex.loadContactValuesDC();
        bo.Delivery_Contact__c = null;
        
        bex.enterLOBEditMode();
        bo.Commodity__c = 'SACK';
        bex.enterDepotEditMode();
        bex.book.Collection_Depot__c = depot.id;
        bex.customSave();
        Test.stopTest();
        
        system.assertEquals(0,[select count() from Booking__c 
                                where Account__c = null
                                and Coll_Postcode__c = :aaCol.Postcode__c 
                                and Del_Postcode__c = :aaDel.Postcode__c]); //save falied because inv address missed
                                
        bo.Inv_Org_Name__c = aaDel.Org_Name__c;
        bo.Inv_Street_1__c = aaDel.Street_1__c;
        bo.Inv_Postcode__c = aaDel.Postcode__c;
        bo.Inv_City__c = aaDel.City__c;
        bo.Inv_Country__c = ConstantUtil.ISOCODE_UK;
        
        bex.customSave();
        
        system.assertEquals(1,[select count() from Booking__c 
                                where Account__c = null
                                and Coll_Postcode__c = :aaCol.Postcode__c 
                                and Del_Postcode__c = :aaDel.Postcode__c]);
    }
    
    //DH
        public static testMethod void testLongLengthBookingLineItems()
    {
        Account a = TestUtil.createAccountClient();
        insert a;
        Account depot = TestUtil.createAccountDepot();
        insert depot;
        Account_Address__c aaCol = TestUtil.createAccountAddress(a.Id,null);
        Account_Address__c aaDel = TestUtil.createAccountAddress(a.Id,null);
        aaDel.Postcode__c = 'BB1 AA1';
        insert new List<Account_Address__c>{aaCol,aaDel};
        
        Booking__c bo = new Booking__c();
        bo.Name = 'test book';
        bo.Account__c = a.Id;
        bo.Close_Time__c = '20:00';
        bo.Enhanced_Liability__c = ConstantUtil.PLVAL_QUOTE_ENHANCED_LIABILITY_OPTION_NONE;
        bo.Coll_Account_Address__c = aaCol.Id;
        bo.Del_Account_Address__c = aaDel.Id;
        bo.OC_First_Name__c = 'OCName';
        bo.OC_Last_Name__c = 'OCSurname';
        bo.OC_Phone_Number__c = '0000000000';
        bo.CC_First_Name__c = 'CCName';
        bo.CC_Last_Name__c = 'CCSurname';
        bo.CC_Phone_Number__c = '1111111111';
        bo.DC_First_Name__c = 'DCName';
        bo.DC_Last_Name__c = 'DCSurname';
        bo.DC_Phone_Number__c = '2222222222';
        bo.Commodity__c = 'SACK';
        bo.Status__c = ConstantUtil.PLVAL_BOOKING_STATUS_CONFIRMED;
        insert bo;
        
        Booking_Line_Item__c bli = new Booking_Line_Item__c();
        bli.Number_Of_Items__c = 1;
        bli.Height__c = 10;
        bli.Length__c = 10;
        bli.Weight__c = 10;
        bli.Width__c = 10;
        bli.Booking__c = bo.Id;
        insert bli;
        
        Test.startTest();
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(bo);
        OL_BookingExtension bex = new OL_BookingExtension(sc);      
        bex.addLine();
        
        Booking_Line_Item__c bli1 = new Booking_Line_Item__c();
        bli1.Number_Of_Items__c = 1;
        bli1.Height__c = 10;
        bli1.Length__c = 10;
        bli1.Weight__c = 10;
        bli1.Width__c = 10;
        
        bex.bookingItems.add(bli1);

        system.AssertEquals(0.0, bex.getNumLongLengths());
        bli1.Height__c = 161;
        bli1.Number_of_Items__c = 2;
        system.AssertEquals(2.0, bex.getNumLongLengths());
        
        bex.RefreshDarryl();
        
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        bex.removeLine();
        bex.enterLOBEditMode();
        bo.Commodity__c = 'SACK';
        bex.enterDepotEditMode();
        bex.book.Collection_Depot__c = depot.id;
        bex.aaIdCOL = aaCol.id;
        bex.loadAddressCOL();
        bex.aaIdDEL = aaDel.id;
        bex.loadAddressDEL();
        bex.customSave();
        Test.stopTest();
        
        List<Booking_Line_Item__c> cons = [select id from Booking_Line_Item__c];
        system.assertEquals(1,cons.size());
        system.assertNotEquals(bli.Id,cons[0].Id);
    }

}