/**
* File Name   :    OL_BookingQuoteHelperTest.cls
* Description :    
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 08/07/2014 Klea Kolaric   Initial version
* 0.2 16/07/2014 Klea Kolaric   TNT-476,TNT-477
* 0.3 24/07/2014 Liza Romanenko TNT-532, TNT-609
* 0.4 05/08/2014 Liza Romanenko TNT-1326
* 0.5 06/08/2014 Liza Romanenko TNT-1329
* 0.6 19/08/2014 Klea Kolaric   TNT-1560    will only be used for Quotes from now on
* 0.7 14/07/2015 Darryl Hopper   test numLongLengthItems line 53
*/
@isTest
public with sharing class OL_BookingQuoteHelperTest {
    
    public static testMethod void testNewQuote()
    {
        Account a = TestUtil.createAccountClient();
        insert a;
        Contact c = TestUtil.createContact(a.Id);
        insert c;
        
        Test.startTest();
        Quote__c qt = new Quote__c();
        qt.Account__c = a.Id;
        qt.Contact__c = c.Id;
        qt.Email_Only__c = 'testmail@gdgfd.tst';
        qt.Collection_Date__c = System.today();
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(qt);
        OL_BookingQuoteHelper bqh = new OL_BookingQuoteHelper(sc);
        bqh.findCurrentAccount();
        qt.Collection_Postcode__c = 'aa111a';
        qt.Delivery_Postcode__c = 'aa111a';
        bqh.addLine();
        bqh.addLine();
        bqh.quoteItems.get(0).Number_Of_Items__c = 5;
        bqh.quoteItems.get(0).Height__c = 10;
        bqh.quoteItems.get(0).Length__c = 10;
        bqh.quoteItems.get(0).Weight__c = 10;
        bqh.quoteItems.get(0).Width__c = 10;
        ApexPages.currentPage().getParameters().put('rowIndex', '1');
        bqh.removeLine();
        bqh.customSave();
        Test.stopTest();
        
        system.assertEquals(1,[select count() from Quote__c]);
    }
    
    //DH
    public static testMethod void testNewLongLengthQuote()
    {
        Account a = TestUtil.createAccountClient();
        insert a;
        Contact c = TestUtil.createContact(a.Id);
        insert c;
        
        Test.startTest();
        Quote__c qt = new Quote__c();
        qt.Account__c = a.Id;
        qt.Contact__c = c.Id;
        qt.Email_Only__c = 'testmail@gdgfd.tst';
        qt.Collection_Date__c = System.today();
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(qt);
        OL_BookingQuoteHelper bqh = new OL_BookingQuoteHelper(sc);
        bqh.findCurrentAccount();
        qt.Collection_Postcode__c = 'aa111a';
        qt.Delivery_Postcode__c = 'aa111a';
        bqh.addLine();
        bqh.addLine();
        bqh.quoteItems.get(0).Number_Of_Items__c = 5;
        bqh.quoteItems.get(0).Height__c = 10;
        bqh.quoteItems.get(0).Length__c = 10;
        bqh.quoteItems.get(0).Weight__c = 10;
        bqh.quoteItems.get(0).Width__c = 10;
        
        system.assertEquals(0.0,bqh.getNumLongLengths());
        bqh.quoteItems.get(0).Width__c = 161;
        system.assertEquals(5.0,bqh.getNumLongLengths());
        bqh.RefreshDarryl();
        ApexPages.currentPage().getParameters().put('rowIndex', '1');
        bqh.removeLine();
        bqh.customSave();
        Test.stopTest();
        
        system.assertEquals(1,[select count() from Quote__c]);
        system.assertEquals(5.0,([select No_Long_Length_Items__c from Quote__c Limit 1]).No_Long_Length_Items__c);
    }

    
    public static testMethod void testNewQuoteNoAccountNoContact()
    {
        Test.startTest();
        Quote__c qt = new Quote__c();
        qt.Company_Name__c = 'My Company';
        qt.Company_Phone__c = '12344321';
        qt.Contact_First_Name__c = 'test';
        qt.Contact_Last_Name__c = 'guy';
        qt.Contact_Phone__c = '123443211';
        qt.Contact_Email__c = 'myemail@gfffhgg.ggg';
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(qt);
        OL_BookingQuoteHelper bqh = new OL_BookingQuoteHelper(sc);
        bqh.customSave();
        Test.stopTest();
        //system.assertEquals(1,[select count() from Quote__c where id = :qt.Id]);
    }
    
    public static testMethod void testNewQuoteNewContact()
    {
        Account a = TestUtil.createAccountClient();
        insert a;
        Contact c = TestUtil.createContact(a.Id);
        c.Email = 'mytestmail@est.test';
        insert c;
        
        Test.startTest();
        Quote__c qt = new Quote__c();
        qt.Account__c = a.Id;
        qt.Contact_First_Name__c = 'test';
        qt.Contact_Last_Name__c = 'guy';
        qt.Contact_Phone__c = '123443211';
        qt.Contact_Email__c = c.Email;
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(qt);
        OL_BookingQuoteHelper bqh = new OL_BookingQuoteHelper(sc);
        bqh.customSave();
        Test.stopTest();
    }
    
    public static testMethod void testCatchExceptions()
    {
        Test.startTest();
        Quote__c qt = new Quote__c();
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(qt);
        OL_BookingQuoteHelper bqh = new OL_BookingQuoteHelper(sc);
        bqh.customSave();
        Test.stopTest();
    }
    
    public static testMethod void testCloneQuote()
    {
        Account a = TestUtil.createAccountClient();
        insert a;
        Contact c = TestUtil.createContact(a.Id);
        insert c;
        
        
        Quote__c qt = new Quote__c();
        qt.Account__c = a.Id;
        qt.Contact__c = c.Id;
        qt.Email_Only__c = 'testmail@gdgfd.tst';
        qt.Collection_Postcode__c = 'NN12 8JA';
        qt.Delivery_Postcode__c = 'NN12 8JA';
        qt.Collection_Date__c = System.today();
        /*Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(qt);
        OL_BookingQuoteHelper bqh = new OL_BookingQuoteHelper(sc);
        bqh.customSave();*/
        insert qt;
        qt = [select Id from Quote__c LIMIT 1];
        
        Quote_Line_Item__c qli = new Quote_Line_Item__c();
        qli.Number_Of_Items__c = 1;
        qli.Height__c = 10;
        qli.Length__c = 10;
        qli.Weight__c = 10;
        qli.Width__c = 10;
        qli.Quote__c = qt.Id;
        insert qli;
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('oId', qt.Id);
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(new Quote__c());
        OL_BookingQuoteHelper bqh = new OL_BookingQuoteHelper(sc);
        
        bqh.customSave();
        Test.stopTest();
        
        system.assertEquals(2,[select count() from Quote__c]);
        
        qt = [select Name, Collection_Postcode__c, Email_Only__c, Delivery_Postcode__c from Quote__c WHERE Id != : qt.Id LIMIT 1];
        if(c.Email != null) system.assertEquals(null, qt.Email_Only__c);
        system.assertEquals('NN12 8JA', qt.Delivery_Postcode__c);
        system.assertEquals('NN12 8JA', qt.Collection_Postcode__c);
        
        List<Quote_Line_Item__c> qliList = [SELECT Quote__c, Height__c, Length__c, Weight__c, Width__c FROM  Quote_Line_Item__c WHERE Quote__c = : qt.Id];
        system.assertEquals(1,qliList.size());
        system.assertEquals(10, qliList[0].Height__c);
        system.assertEquals(10, qliList[0].Length__c);
        system.assertEquals(10, qliList[0].Weight__c);
        system.assertEquals(10, qliList[0].Width__c);
        system.assertNotEquals(qli.Id, qliList[0].Id);
    }
    
    public static testMethod void testEditQuote()
    {
        Account a = TestUtil.createAccountClient();
        insert a;
        Contact c = TestUtil.createContact(a.Id);
        insert c;
        
        
        Quote__c qt = new Quote__c();
        qt.Account__c = a.Id;
        qt.Contact__c = c.Id;
        qt.Email_Only__c = 'testmail@gdgfd.tst';
        qt.Collection_Date__c = System.today();
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(qt);
        OL_BookingQuoteHelper bqh = new OL_BookingQuoteHelper(sc);
        
        qt.Collection_Postcode__c = 'NN12 8JA';
        qt.Delivery_Postcode__c = 'NN12 8JA';
        
        Quote_Line_Item__c qli = new Quote_Line_Item__c();
        qli.Number_Of_Items__c = 1;
        qli.Height__c = 10;
        qli.Length__c = 10;
        qli.Weight__c = 10;
        qli.Width__c = 10;
        
        bqh.quoteItems.add(qli);
        bqh.customSave();
        qt = [select Id, Account__c, Contact__c from Quote__c LIMIT 1];
    
        List<Quote_Line_Item__c> qliList = [SELECT Quote__c, Height__c, Length__c, Weight__c, Width__c FROM  Quote_Line_Item__c WHERE Quote__c = : qt.Id];
        system.assertEquals(1,qliList.size());
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('Id', qt.Id);
        sc = new Apexpages.Standardcontroller(qt);
        bqh = new OL_BookingQuoteHelper(sc);
        system.assertEquals(1, bqh.quoteItems.size());
        system.assertNotEquals(null, bqh.quoteItems[0].Id);
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        bqh.removeLine();
        system.assertEquals(0, bqh.quoteItems.size());
//      bqh.addLine();
        bqh.customSave();
        Test.stopTest();
        
        qliList = [SELECT Quote__c, Height__c, Length__c, Weight__c, Width__c FROM  Quote_Line_Item__c WHERE Quote__c = : qt.Id];
//      system.assertEquals(0,qliList.size());
    }
    
    public static testMethod void test_createQuoteFromBooking(){
        Account a = TestUtil.createAccountClient();
        insert a;
        Account depot = TestUtil.createAccountDepot();
        insert depot;
        Account_Address__c aaCol = TestUtil.createAccountAddress(a.Id,null);
        Account_Address__c aaDel = TestUtil.createAccountAddress(a.Id,null);
        aaCol.Postcode__c = 'BB1 BB1';
        aaDel.Postcode__c = 'BB1 AA1';
        insert new List<Account_Address__c>{aaCol,aaDel};
        
        Contact c = TestUtil.createContact(a.Id);
        insert c;
        
        Booking__c bo = new Booking__c();
        bo.Name = 'test book';
        bo.Account__c = a.Id;
        bo.Coll_Account_Address__c = aaCol.Id;
        bo.Del_Account_Address__c = aaDel.Id;
        bo.Order_Contact__c = c.Id;
        bo.OC_First_Name__c = 'OCName';
        bo.OC_Last_Name__c = 'OCSurname';
        bo.OC_Phone_Number__c = '0000000000';
        bo.OC_Email_Address__c = 'test@test.com';
        bo.CC_First_Name__c = 'CCName';
        bo.CC_Last_Name__c = 'CCSurname';
        bo.CC_Phone_Number__c = '1111111111';
        bo.DC_First_Name__c = 'DCName';
        bo.DC_Last_Name__c = 'DCSurname';
        bo.DC_Phone_Number__c = '2222222222';
        bo.Coll_Postcode__c = 'BB1 BB1';
        bo.Del_Postcode__c = 'BB1 AA1';
        bo.Collection_Ready_Time__c = DateTime.now();
        bo.Commodity__c = 'SACK';
        bo.Status__c = ConstantUtil.PLVAL_BOOKING_STATUS_CONFIRMED;
        insert bo;
        
        Booking_Line_Item__c bli = new Booking_Line_Item__c();
        bli.Number_of_items__c = 1;
        bli.Height__c = 10;
        bli.Length__c = 10;
        bli.Weight__c = 10;
        bli.Width__c = 10;
        bli.Booking__c = bo.Id;
        insert bli;
        
        ApexPages.currentPage().getParameters().put('bId', bo.Id);
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(new Quote__c());
        OL_BookingQuoteHelper bqh = new OL_BookingQuoteHelper(sc);
        
        bqh.customSave();
        
        Quote__c q = [SELECT Account__c FROM Quote__c LIMIT 1];
        system.assertEquals(a.Id, q.Account__c);
        
        List<Quote_Line_Item__c> qliList = [SELECT Quote__c, Height__c, Length__c, Weight__c, Width__c FROM  Quote_Line_Item__c];
        system.assertEquals(1,qliList.size());
    }
    
    public static testMethod void test_Addresses(){
        Account a = TestUtil.createAccountClient();
        insert a;
        Account depot = TestUtil.createAccountDepot();
        insert depot;
        Account_Address__c aaDef = TestUtil.createAccountAddress(a.Id,null);
        aaDef.Default__c = true;
        insert aaDef;
        
        Test.startTest();
        Quote__c qt = new Quote__c();
        qt.Account__c = a.Id;
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(qt);
        OL_BookingQuoteHelper bqh = new OL_BookingQuoteHelper(sc);
        system.AssertEquals(aaDef.Postcode__c,qt.Collection_Postcode__c);
        system.assert(!qt.Carriage_Forward__c);
        qt.Collection_Postcode__c = 'OO0 0OO';
        bqh.collectionPostcodeChanged();
        system.AssertEquals(aaDef.Postcode__c,qt.Delivery_Postcode__c);
        system.assert(qt.Carriage_Forward__c);
        qt.Collection_Postcode__c = aaDef.Postcode__c;
        bqh.collectionPostcodeChanged();
        system.AssertEquals(null,qt.Delivery_Postcode__c);
        system.assert(!qt.Carriage_Forward__c);
        bqh.clearAccount();
        Test.stopTest();
    }
    
    /*public static testMethod void testEditBtnBooking()
    {
        Account a = TestUtil.createAccountClient();
        insert a;
        Contact c = TestUtil.createContact(a.Id);
        insert c;
        Account_Address__c aa = TestUtil.createAccountAddress(a.Id, c.Id);
        insert aa;
        
        Booking__c bo = new Booking__c();
        bo.Name = 'test book';
        bo.Account__c = a.Id;
        bo.Order_Contact__c = c.Id;
        bo.Account_Address__c = aa.Id;
        insert bo;
        
        bo = [select Id from Booking__c LIMIT 1];
        
        Booking_Line_Item__c bli = new Booking_Line_Item__c();
        bli.Height__c = 10;
        bli.Length__c = 10;
        bli.Weight__c = 10;
        bli.Width__c = 10;
        bli.Booking__c = bo.Id;
        bli.Consignment_Number__c = '111';
        bli.Contact_Email_Address__c = 'test@email.com';
        bli.Contact_First_Name__c = 'Name';
        bli.Contact_Last_Name__c = 'Surname';
        bli.Contact_Phone__c = '07474567899';
        insert bli;
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('oId', bo.Id);
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(new Booking__c());
        OL_BookingQuoteHelper bqh = new OL_BookingQuoteHelper(sc);
        bqh.customSave();
        Test.stopTest();
        
        system.assertEquals(2,[select count() from Booking__c]);
        
        bo = [select Name from Booking__c WHERE Id != : bo.Id LIMIT 1];
        system.assertEquals('test book - Copied', bo.Name);
        
        List<Booking_Line_Item__c> bliList = [SELECT Booking__c, Height__c, Length__c, Weight__c, Width__c, Consignment_Number__c,
                                                    Contact_Email_Address__c, Contact_First_Name__c, Contact_Last_Name__c, Contact_Phone__c
                                                FROM  Booking_Line_Item__c WHERE Booking__c = : bo.Id];
        system.assertEquals(1,bliList.size());
        system.assertEquals(10, bliList[0].Height__c);
        system.assertEquals(10, bliList[0].Length__c);
        system.assertEquals(10, bliList[0].Weight__c);
        system.assertEquals(10, bliList[0].Width__c);
        system.assertNotEquals(bli.Id, bliList[0].Id);
    }*/

}