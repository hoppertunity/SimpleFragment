/**
* File Name   :    BookingTriggerHandlerTest.cls
* Description :    Test class for BookingTriggerHandler
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 24/07/2014 Liza Romanenko	Initial version
* 0.2 29/08/2014 Liza Romanenko add test for generateBookingId() method TNT-1414
*
*/
@isTest
private class BookingTriggerHandlerTest {
	
	/* tested code is depricated 9 Apr 2015. 
    static testMethod void testBookingRejection() {

        Account a = TestUtil.createAccountClient();
        a.Auto_Case_Creation__c = true;
        insert a;
        Contact con = TestUtil.createContact(a.Id);
        insert con;
        
        Booking__c bo = new Booking__c();
		bo.Name = 'test book';
		bo.Account__c = a.Id;
		bo.Order_Contact__c = con.Id;
		bo.Commodity__c = 'SACK';
		bo.Status__c = ConstantUtil.PLVAL_BOOKING_STATUS_CONFIRMED;
		insert bo;
		
		Test.startTest();
		bo.Booking_Rejected_by_Depot__c = true;
		bo.Reason_for_Depot_Rejection__c = 'reason';
		update bo;
		Test.stopTest();
		
		List<Case> cases = [SELECT Subject, Booking__c, AccountId, ContactId, Description, Origin, Status, Type, Priority FROM Case];
		
		system.assertEquals(1, cases.size());
		system.assertEquals(bo.Id, cases[0].Booking__c);
		system.assertEquals(bo.Account__c, cases[0].AccountId);
		system.assertEquals(bo.Order_Contact__c, cases[0].ContactId);
		system.assertEquals(bo.Reason_for_Depot_Rejection__c, cases[0].Description);
		
     }
     
     static testMethod void testBookingRejectedUpdate() {

        Account a = TestUtil.createAccountClient();
        a.Auto_Case_Creation__c = true;
        insert a;
        
        Account d = TestUtil.createAccountDepot();
        insert d;
        
        Contact con = TestUtil.createContact(a.Id);
        insert con;
        
        Booking__c bo = new Booking__c();
		bo.Name = 'test book';
		bo.Account__c = a.Id;
		bo.Order_Contact__c = con.Id;
		bo.Commodity__c = 'SACK';
		bo.Status__c = ConstantUtil.PLVAL_BOOKING_STATUS_CONFIRMED;
		insert bo;
		
		
		bo.Booking_Rejected_by_Depot__c = true;
		bo.Reason_for_Depot_Rejection__c = 'reason';
		bo.Collection_Depot__c = d.Id;
		update bo;
		
		Test.startTest();
		update bo;
		Test.stopTest();
		
		List<Case> cases = [SELECT Subject FROM Case];
		
		system.assertEquals(1, cases.size());
     }*/
     
     static testMethod void testUpdateAccountLob()
     {
     	Account a1 = TestUtil.createAccountClient();
     	a1.Name += '1';
     	Account a2 = TestUtil.createAccountClient();
     	a2.Name += '2';
        insert new List<Account>{a1,a2};
        
        Contact con1 = TestUtil.createContact(a1.Id);
        Contact con2 = TestUtil.createContact(a2.Id);
        con2.LastName += 'Second';
        con2.Email += '123';
        insert new List<Contact>{con1,con2};
        
        Line_Of_Business__c lob1 = new Line_Of_Business__c();
		lob1.Name = 'LOB1';
		lob1.Line_Of_Business_Reference__c = '10';
		Line_Of_Business__c lob2 = new Line_Of_Business__c();
		lob2.Name = 'LOB2';
		lob2.Line_Of_Business_Reference__c = '20';
		insert new List<Line_Of_Business__c>{lob1,lob2};
		insert new List<Account_LOB__c>{new Account_LOB__c(Account__c = a1.Id, Line_Of_Business__c = lob1.id), 
										new Account_LOB__c(Account__c = a1.Id, Line_Of_Business__c = lob2.id),
										new Account_LOB__c(Account__c = a2.Id, Line_Of_Business__c = lob2.id)};
        
        Booking__c bo1 = new Booking__c();
		bo1.Name = 'test book1';
		bo1.Account__c = a1.Id;
		bo1.Order_Contact__c = con1.Id;
		bo1.Status__c = ConstantUtil.PLVAL_BOOKING_STATUS_CONFIRMED;
		bo1.Line_Of_Business__c = lob1.id;
		bo1.Commodity__c = 'SACK';
        Booking__c bo2 = new Booking__c();
		bo2.Name = 'test book2';
		bo2.Account__c = a2.Id;
		bo2.Order_Contact__c = con2.Id;
		bo2.Status__c = ConstantUtil.PLVAL_BOOKING_STATUS_CONFIRMED;
		bo2.Line_Of_Business__c = lob2.id;
		bo2.Commodity__c = 'SACK';
		insert new List<Booking__c>{bo1,bo2};
		
		Booking__c bo1Old = bo1.clone(true,true);
		Booking__c bo2Old = bo2.clone(true,true);
		bo1.Status__c = ConstantUtil.PLVAL_BOOKING_STATUS_COLLECTED;
		bo2.Status__c = ConstantUtil.PLVAL_BOOKING_STATUS_COLLECTED;
		
		Date refDate = Date.today();
		
		Test.startTest();
		BookingTriggerHandler.updateAccountLob(new List<Booking__c>{bo1,bo2}, new Map<Id,Booking__c>{bo1.Id => bo1Old,bo2.Id => bo2Old});
		Test.stopTest();
		
		List<Account_LOB__c> als = [select Last_Collection_Date__c from Account_LOB__c 
									order by Account__r.Name asc, Line_Of_Business__r.Name asc];	// order important!!!
		system.assertEquals(3,als.size());
		system.assert(als.get(0).Last_Collection_Date__c >= refDate);	// a1, lob1	- updated
		system.assert(als.get(1).Last_Collection_Date__c == null);		// a1, lob2 - not updated
		system.assert(als.get(2).Last_Collection_Date__c >= refDate);	// a2, lob2 - updated
     }
     
     static testMethod void testBookingIdCreation() {
		Integer stDepot = Integer.valueOf(Label.Salesforce_Start_Depot);
		
		Booking_Id_Settings__c bis = new Booking_Id_Settings__c();
		bis.Name = 'Default';
		bis.Prefix__c = stDepot;
		bis.Current_Number__c = 9999999;
		insert bis;
		
        Account a = TestUtil.createAccountClient();
        insert a;
        Contact con = TestUtil.createContact(a.Id);
        insert con;
        
        Booking__c bo = new Booking__c();
		bo.Name = 'test book';
		bo.Account__c = a.Id;
		bo.Order_Contact__c = con.Id;
		bo.Commodity__c = 'SACK';
		bo.Status__c = ConstantUtil.PLVAL_BOOKING_STATUS_CONFIRMED;
		insert bo;
		
		bo = [SELECT Booking_Id__c FROM Booking__c WHERE Id = : bo.Id];
		system.assertEquals(Label.Salesforce_Start_Depot+'9999999', bo.Booking_Id__c);
		
		bis = [SELECT Prefix__c, Current_Number__c FROM Booking_Id_Settings__c WHERE Name = 'Default'];
		system.assertEquals(stDepot+1, bis.Prefix__c);
		system.assertEquals(0, bis.Current_Number__c);
     }
     
     static testMethod void testUpdateLastUsedOnAccountAddress()
     {
        Account a = TestUtil.createAccountClient();
        insert a;
        Contact con = TestUtil.createContact(a.Id);
        insert con;
        Account_Address__c aaCol = TestUtil.createAccountAddress(a.Id,null);
        aaCol.Default__c = true;
        Account_Address__c aaDel = TestUtil.createAccountAddress(a.Id,null);
        aaDel.Postcode__c = 'N1 9NL';
        insert new List<Account_Address__c>{aaCol,aaDel};
        Account depot = TestUtil.createAccountDepot();
        insert depot;
        
        Booking__c bo = new Booking__c();
        bo.Name = 'test book';
        bo.Account__c = a.Id;
        bo.Order_Contact__c = con.Id;
        bo.Collection_Contact__c = con.Id;
        bo.Coll_Account_Address__c = aaCol.id;
        bo.Del_Account_Address__c = aaDel.id;
        bo.Collection_Depot__c = depot.id;
        bo.Commodity__c = 'SACK';
        bo.Status__c = ConstantUtil.PLVAL_BOOKING_STATUS_CONFIRMED;
        insert bo;
        
        aaCol.Last_Used__c = null;
        aaDel.Last_Used__c = null;
        update new List<Account_Address__c>{aaCol,aaDel};
        
        List<Booking__c> newBookList = new List<Booking__c>{bo.clone(true,true)};
        bo.Coll_Account_Address__c = null;
        bo.Del_Account_Address__c = null;
        Map<Id,Booking__c> oldBookMap = new Map<Id,Booking__c>{bo.id => bo};
        
        Test.startTest();
        BookingTriggerHandler.updateLastUsedOnAccountAddress(newBookList,oldBookMap);
        Test.stopTest();
        system.assertEquals(2,[select count() from Account_Address__c where Last_Used__c != null]);
     }
     
     static testMethod void testBookingRejectionToCS() 
     {
	
         //Added by DH 25/01/2016
        List<RejectionCaseLOBs__c> rjcs = new List<RejectionCaseLOBs__c>();
        rjcs.add(new RejectionCaseLOBs__c(Name = '010'));
        rjcs.add(new RejectionCaseLOBs__c(Name = '251'));
        rjcs.add(new RejectionCaseLOBs__c(Name = '190'));
        rjcs.add(new RejectionCaseLOBs__c(Name = '240'));
        rjcs.add(new RejectionCaseLOBs__c(Name = '160'));
         rjcs.add(new RejectionCaseLOBs__c(Name = '260'));
         rjcs.add(new RejectionCaseLOBs__c(Name = '280'));
         rjcs.add(new RejectionCaseLOBs__c(Name = '370'));
         insert rjcs;
        
         //Create LOBs ***********
         Line_Of_Business__c lobForCase = new Line_Of_Business__c(Line_of_Business_Reference__c = '010');//Will do rejection case creation
         
         insert lobForCase;
         
         Line_Of_Business__c lobForWithoutCase = new Line_Of_Business__c(Line_of_Business_Reference__c = '390');//Will NOT do rejection case creation
         
         insert lobForWithoutCase;
         //***********************
         
        Account a = TestUtil.createAccountClient();
        a.Auto_Case_Creation__c = true;
        a.Collection_Queue__c = 'Lount_Admin_1';
        insert a;
        Account depot = TestUtil.createAccountDepot();
        insert depot;
        Contact con = TestUtil.createContact(a.Id);
        insert con;
               
        Booking__c bo = new Booking__c();
		bo.Name = 'test book';
		bo.Account__c = a.Id;
		bo.Order_Contact__c = con.Id;
		bo.Commodity__c = 'SACK';
		bo.Status__c = ConstantUtil.PLVAL_BOOKING_STATUS_CONFIRMED;
		bo.Collection_Depot__c = depot.Id;
         
        Account b = TestUtil.createAccountClient();
        b.Auto_Case_Creation__c = true;
        b.Collection_Queue__c = 'Lount_Admin_1';
        insert b;
        Contact con2 = TestUtil.createContact(b.Id);
        insert con2;
         
                     
        Booking__c boLOBNoCase = new Booking__c();
		boLOBNoCase.Name = 'test book2';
		boLOBNoCase.Account__c = b.Id;
		boLOBNoCase.Order_Contact__c = con2.Id;
		boLOBNoCase.Commodity__c = 'SACK';
		boLOBNoCase.Status__c = ConstantUtil.PLVAL_BOOKING_STATUS_CONFIRMED;
		boLOBNoCase.Collection_Depot__c = depot.Id;
         
        Account c = TestUtil.createAccountClient();
        c.Auto_Case_Creation__c = false;//Should not create a case even if LOB is in custom list
        c.Major_Account__c = true;
        c.Collection_Queue__c = 'Lount_Admin_1';
        insert c;
        Contact con3 = TestUtil.createContact(c.Id);
        insert con3;
        
        Booking__c boNotAutoCase = new Booking__c();
		boNotAutoCase.Name = 'test book3';
		boNotAutoCase.Account__c = c.Id;
		boNotAutoCase.Order_Contact__c = con3.Id;
		boNotAutoCase.Commodity__c = 'SACK';
		boNotAutoCase.Status__c = ConstantUtil.PLVAL_BOOKING_STATUS_CONFIRMED;
		boNotAutoCase.Collection_Depot__c = depot.Id;
        
        Booking__c boNoAccount = new Booking__c();
		boNoAccount.Name = 'test book4';
		//boNotAutoCase.Account__c = c.Id;
		//boNotAutoCase.Order_Contact__c = con3.Id;
		boNoAccount.Commodity__c = 'SACK';
		boNoAccount.Status__c = ConstantUtil.PLVAL_BOOKING_STATUS_CONFIRMED;
		boNoAccount.Collection_Depot__c = depot.Id;
        
         bo.Line_of_Business__c = lobForCase.id;
         boLOBNoCase.Line_of_Business__c = lobForWithoutCase.id;    
         boNotAutoCase.Line_of_Business__c = lobForCase.id;//In list but should be created as AutoCase not selected
	     
         insert bo;
         insert boLOBNoCase;
         insert boNotAutoCase;
         insert boNoAccount;
         
         system.assert(ConstantUtil.AutoRejectionCaseLOBList.size() == 8);
         Set<string> testLOB = ConstantUtil.AutoRejectionCaseLOBList;
         for(string s:testLOB)
         {
             system.debug('**Code: ' + s);
         }
         
		Test.startTest();
		bo.Status__c = ConstantUtil.PLVAL_BOOKING_STATUS_REJECTED_TO_CS;
        boLOBNoCase.Status__c =  ConstantUtil.PLVAL_BOOKING_STATUS_REJECTED_TO_CS;
        boNotAutoCase.Status__c = ConstantUtil.PLVAL_BOOKING_STATUS_REJECTED_TO_CS;
        boNoAccount.Status__c = ConstantUtil.PLVAL_BOOKING_STATUS_REJECTED_TO_CS;
		update bo;
        update boLOBNoCase;
        update boNotAutoCase;
        update boNoAccount;
        Test.stopTest();
		
		//Only 1 Case should be created for the bookings whos LOB code matches the custom list RejectionCaseLOBs and has AutoCase selected on Account
      
		List<Case> cases = [SELECT Subject, Booking__c, AccountId, ContactId, Description, Origin, Status, Type, Priority, OwnerId FROM Case order by createdDate];
		
        //Assert that only 2 cases created out of the 4 bookings and that they are the expected as ordered by creation datetime
        system.assertEquals(2, cases.size());
         
		system.assertEquals(bo.Id, cases[0].Booking__c);
		system.assertEquals(bo.Account__c, cases[0].AccountId);
		system.assertEquals(bo.Order_Contact__c, cases[0].ContactId);
		system.assertEquals(ConstantUtil.PLVAL_CASE_ORIGIN_SYSTEM, cases[0].Origin);
		system.assertEquals(ConstantUtil.LOUNT_ADMIN_1_QUEUE_ID, cases[0].OwnerId);
         
        system.assertEquals(boNoAccount.Id, cases[1].Booking__c);
		system.assertEquals(ConstantUtil.PLVAL_CASE_ORIGIN_SYSTEM, cases[1].Origin);
        system.debug(cases[1].OwnerId);
        Group g = [Select id from Group where Name = 'Unassigned' limit 1];
		system.assertEquals(g.id , cases[1].OwnerId);
         
	
		
     }

     static testMethod void testBookingLocking() {

        Account a = TestUtil.createAccountClient();
        insert a;
        Contact con = TestUtil.createContact(a.Id);
        insert con;
        
        Booking__c bo = new Booking__c();
		bo.Name = 'test book';
		bo.Account__c = a.Id;
		bo.Order_Contact__c = con.Id;
		bo.Commodity__c = 'SACK';
		bo.Status__c = ConstantUtil.PLVAL_BOOKING_STATUS_CONFIRMED;
		insert bo;

		bo = [SELECT Id, RecordType.Name FROM Booking__c WHERE Id = :bo.Id];
		System.assertEquals(ConstantUtil.PLVAL_BOOKING_RECORD_TYPE_NEW,bo.RecordType.Name);
		
		Test.startTest();

		bo.Status__c = ConstantUtil.PLVAL_BOOKING_STATUS_COLLECTED;
		update bo;

		bo = [SELECT Id, RecordType.Name FROM Booking__c WHERE Id = :bo.Id];
		System.assertEquals(ConstantUtil.PLVAL_BOOKING_RECORD_TYPE_BLOCKED,bo.RecordType.Name);

		Test.stopTest();
		
     }

     static testMethod void testBookingUnlocking() {

        Account a = TestUtil.createAccountClient();
        insert a;
        Contact con = TestUtil.createContact(a.Id);
        insert con;
        
        Booking__c bo = new Booking__c();
		bo.Name = 'test book';
		bo.Account__c = a.Id;
		bo.Order_Contact__c = con.Id;
		bo.Commodity__c = 'SACK';
		bo.Status__c = ConstantUtil.PLVAL_BOOKING_STATUS_COLLECTED;
		insert bo;

		bo = [SELECT Id, RecordType.Name FROM Booking__c WHERE Id = :bo.Id];
		System.assertEquals(ConstantUtil.PLVAL_BOOKING_RECORD_TYPE_BLOCKED,bo.RecordType.Name);
		
		Test.startTest();

		bo.Status__c = ConstantUtil.PLVAL_BOOKING_STATUS_CONFIRMED;
		update bo;

		bo = [SELECT Id, RecordType.Name FROM Booking__c WHERE Id = :bo.Id];
		System.assertEquals(ConstantUtil.PLVAL_BOOKING_RECORD_TYPE_NEW,bo.RecordType.Name);

		Test.stopTest();
		
     }
}