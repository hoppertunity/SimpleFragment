/**
* File Name   :    BookingTriggerHandler.cls
* Description :    methods called from Booking trigger
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 24/07/2014 Liza Romanenko	Initial version TNT-536
* 0.2 28/08/2014 Klea Kolaric	TNT-1400
* 0.3 29/08/2014 Liza Romanenko add generateBookingId() method TNT-1414
* 0.4 12/09/2014 Liza Romanenko update createCaseIfRejected() method TNT-1605
*
*/
public with sharing class BookingTriggerHandler {
	
	// HANDLERS
	
	public static void onBeforeInsertHandler(List<Booking__c> triggerNew)
	{
		generateBookingId(triggerNew);
		maintainRecordType(triggerNew);
	}
	
	public static void onAfterInsertHandler(List<Booking__c> triggerNew)
	{
		updateAccountLob(triggerNew,null);
		updateLastUsedOnAccountAddress(triggerNew,null);
	}
	
	public static void onAfterUpdateHandler(List<Booking__c> triggerNew, Map<Id,Booking__c> triggerOldMap)
	{
		createCaseIfRejected(triggerNew, triggerOldMap);
		updateAccountLob(triggerNew, triggerOldMap);
		updateLastUsedOnAccountAddress(triggerNew,triggerOldMap);
	}

	public static void onBeforeUpdateHandler(List<Booking__c> triggerNew, Map<Id,Booking__c> triggerOldMap)
	{
		maintainRecordType(triggerNew);
	}
	
	// METHODS
	
	public static void createCaseIfRejected(List<Booking__c> bookings, Map<Id,Booking__c> oldMap){
		
		List<Booking__c> books = new List<Booking__c>();
		for(Booking__c b : bookings)
		{
			if( (b.Booking_Rejected_by_Depot__c && (b.Booking_Rejected_by_Depot__c != oldMap.get(b.Id).Booking_Rejected_by_Depot__c))
				|| (b.Status__c == ConstantUtil.PLVAL_BOOKING_STATUS_REJECTED_TO_CS && (b.Status__c != oldMap.get(b.Id).Status__c)) )
			{
				books.add(b);
			}
		}
		if(books.isEmpty()) return;
		
        System.debug('Bookings Not Empty');
        
		// find all relevant accounts
		Map<Id,Account> accMap = new Map<Id,Account>();
		{
			Set<Id> accIds = new Set<Id>();
			for(Booking__c b : books)
			{
				if(b.Account__c != null)
				{
					accIds.add(b.Account__c);
				}
			}
			if(!accIds.isEmpty())
			{
				accMap = new Map<Id,Account>([select id, Auto_Case_Creation__c from Account where id in :accIds]);
			}
		}
        
        // find all relevant LOBs added by DH 22/01/2016
        Map<Id,Line_Of_Business__c> lobMap = new Map<Id,Line_Of_Business__c>();
		{
			Set<Id> lobIds = new Set<Id>();
			for(Booking__c b : books)
			{
				if(b.Line_Of_Business__c != null)
				{
					lobIds.add(b.Line_Of_Business__c);
				}
			}
			if(!lobIds.isEmpty())
			{
				lobMap = new Map<Id,Line_Of_Business__c>([select id, Line_Of_Business_Reference__c from Line_Of_Business__c where id in :lobIds]);
			}
		}
		
        
             
		List<Case> cases = new List<Case>();
        
        Set<String> AutoCaseLOBs = ConstantUtil.AutoRejectionCaseLOBList;
        
        
		for(Booking__c b : books){
           
            System.Debug('This bookings LOB is: ' + b.Line_of_Business__c);
            
			if(b.Account__c == null || (accMap.get(b.Account__c).Auto_Case_Creation__c && (lobMap.containsKey(b.Line_of_Business__c) && AutoCaseLOBs.contains(lobMap.get(b.Line_of_Business__c).Line_of_Business_Reference__c))))
			{
				//check if rejected
				/*Change made by Liza Romanenko
				Code depricated, had a discussion with Kishan he said this is not used 9 Apr 2015	
				if(b.Booking_Rejected_by_Depot__c && (b.Booking_Rejected_by_Depot__c != oldMap.get(b.Id).Booking_Rejected_by_Depot__c)){
					//Create Case
					Case c = createCase(b);
					c.Subject = 'Booking ' + b.Name + ' Rejected';
					c.Description = b.Reason_for_Depot_Rejection__c;
					c.Origin = ConstantUtil.PLVAL_CASE_ORIGIN_PHONE;
					c.Type = ConstantUtil.PLVAL_CASE_TYPE_BOOKING_ADN_QUOTES;
					
					cases.add(c);
				} */
                               
				if(b.Status__c == ConstantUtil.PLVAL_BOOKING_STATUS_REJECTED_TO_CS && (b.Status__c != oldMap.get(b.Id).Status__c)){
					//Create Case
					Case c = createCase(b);
					c.Subject = 'Booking ' + b.Name + ' Rejected to CS';
					c.Description = b.Reason_for_Depot_Rejection__c;
					c.Origin = ConstantUtil.PLVAL_CASE_ORIGIN_SYSTEM;
					c.Type = ConstantUtil.PLVAL_CASE_TYPE_BOOKINGS;
					c.Case_Types_Level_2__c = ConstantUtil.PLVAL_CASE_TYPE_LAVEL1_CS_FAILED_COLLECTION;
					c.Proactive_Case__c = true;
					c.Collection_Depot__c = b.Collection_Depot__c;
					c.Delivery_Depot__c = b.Delivery_Depot__c;
					c.Exception__c = ConstantUtil.PLVAL_CASE_EXCEPTION_COLLECTION;
                    //DH added 01/02/2016 for call back
                    c.Call_me_back__c = '1 hour';
                    
					cases.add(c);
				}
			}
		}
		
		if(!cases.isEmpty()){
			// make sure cases pass through assignment rule
			AssignmentRule AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
			//Creating the DMLOptions for "Assign using active assignment rules" checkbox
			Database.DMLOptions dmlOpts = new Database.DMLOptions();
			dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
			for(Case c : cases) {
				c.setOptions(dmlOpts);
			}
			
			insert cases;
		}
	}
	
	private static Case createCase(Booking__c b){
		Case c = new Case();
		c.AccountId = b.Account__c;
		c.Booking__c = b.Id;
		c.ContactId = b.Order_Contact__c;
		c.Status = ConstantUtil.PLVAL_CASE_STATUS_NEW;
		c.Priority = ConstantUtil.PLVAL_CASE_PRIORITY_MEDIUM;
		return c;
	}	

	public static void updateAccountLob(List<Booking__c> triggerNew, Map<Id,Booking__c> triggerOldMap)
	{
		final String US = '_';
		Boolean isInsert = triggerOldMap == null;
		Set<String> bookCombo = new Set<String>();	// accountID_lineOfBusinessID
		Set<id> accIds = new Set<id>();
		Set<id> lobIds = new Set<id>();
		
		for(Booking__c bo: triggerNew)
		{
			if(bo.Status__c == ConstantUtil.PLVAL_BOOKING_STATUS_COLLECTED && bo.Account__c != null && bo.Line_Of_Business__c != null
				&& (isInsert || triggerOldMap.get(bo.id).Status__c != ConstantUtil.PLVAL_BOOKING_STATUS_COLLECTED))
			{
				accIds.add(bo.Account__c);
				lobIds.add(bo.Line_Of_Business__c);
				bookCombo.add(bo.Account__c+US+bo.Line_Of_Business__c);
			}
		}
		
		if(!bookCombo.isEmpty()) {
			List<Account_LOB__c> acclobs = [SELECT ID, Last_Collection_Date__c, Account__c, 
												   Line_Of_Business__c
											  FROM Account_LOB__c
											 WHERE Account__c IN :accIds
													AND Line_Of_Business__c IN :lobIds
												    AND (Last_Collection_Date__c < TODAY OR Last_Collection_Date__c = null)];
			
			Integer n = acclobs.size();							
			for(Integer i = 0; i < n; i++)
			{
				Account_LOB__c al = acclobs.get(i);
				if(bookCombo.contains(al.Account__c+US+al.Line_Of_Business__c))
				{
					al.Last_Collection_Date__c = Date.today();
				}
				else
				{
					acclobs.remove(i);
					i--;
					n--;
				}
			}
			update acclobs;
		}
	}
	
	public static void generateBookingId(List<Booking__c> bookings){
		
        Boolean generateIds = false;

        for(Booking__c bk : bookings) {
            if(bk.Booking_Id__c == null) {
                generateIds = true;
                break;
            }
        }

        if(generateIds) {

            Integer startDepot = Integer.valueOf(Label.Salesforce_Start_Depot);
            Integer endDepot = Integer.valueOf(Label.Salesforce_End_Depot);

            list<Booking_Id_Settings__c> biss = [SELECT Prefix__c, Current_Number__c FROM Booking_Id_Settings__c WHERE Name = 'Default' FOR UPDATE];

            if(biss.isEmpty()) {
                biss.add(new Booking_Id_Settings__c(Name = 'Default', Prefix__c = Integer.valueOf(Label.Salesforce_Start_Depot), Current_Number__c = 0));
            }

            Booking_Id_Settings__c bis = biss.get(0);

            Integer prefix = (Integer)bis.Prefix__c;
            Integer numPointer = (Integer)bis.Current_Number__c;

            for(Booking__c bk : bookings) {
                if(bk.Booking_Id__c == null) {

                    bk.Booking_Id__c = String.valueOf((prefix*10000000) + numPointer);
                    //increment number and prefix
                    numPointer++;
                    if(numPointer == 10000000){
                        numPointer = 0;
                        prefix = prefix == endDepot ? startDepot : prefix + 1;
                    }
                }
            }

            bis.Prefix__c = prefix;
            bis.Current_Number__c = numPointer;
            
            upsert bis;
        }

        for(Booking__c bk : bookings) {
            if(bk.Name == null || bk.Name == '') {
                bk.Name = bk.Booking_Id__c;
            }
        }
	}
	
	public static void updateLastUsedOnAccountAddress(List<Booking__c> triggerNew, Map<Id,Booking__c> triggerOldMap)
	{
		Set<Id> aaIds = new Set<Id>();
		for(Booking__c book : triggerNew)
		{
			if(book.Coll_Account_Address__c != null 
				&& (triggerOldMap == null || book.Coll_Account_Address__c != triggerOldMap.get(book.id).Coll_Account_Address__c))
			{
				aaIds.add(book.Coll_Account_Address__c);
			}
			if(book.Del_Account_Address__c != null
				&& (triggerOldMap == null || book.Del_Account_Address__c != triggerOldMap.get(book.id).Del_Account_Address__c))
			{
				aaIds.add(book.Del_Account_Address__c);
			}
		}
		
		if(!aaIds.isEmpty())
		{
			List<Account_Address__c> aas = [select id, Last_Used__c from Account_Address__c where id in :aaIds];
			for(Account_Address__c aa : aas)
			{
				aa.Last_Used__c = Datetime.now();
			}
			update aas;
		}
	}

	private static void maintainRecordType(List<Booking__c> triggerNew) {
/*
		Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Booking__c.RecordTypeInfosByName;
		Id newBookingId = rtMapByName.get(ConstantUtil.PLVAL_BOOKING_RECORD_TYPE_NEW).RecordTypeId;
		Id blockedBookingId = rtMapByName.get(ConstantUtil.PLVAL_BOOKING_RECORD_TYPE_BLOCKED).RecordTypeId;

		for(Booking__c book : triggerNew) {
			if((book.Status__c == ConstantUtil.PLVAL_BOOKING_STATUS_COLLECTED || book.Status__c == ConstantUtil.PLVAL_BOOKING_STATUS_CANCELLED)
				&& book.RecordTypeId != blockedBookingId) {
                System.debug('****I am setting this booking to a BLOCKED booking Record type****');
				book.RecordTypeId = blockedBookingId;
			}
			else if(book.RecordTypeId != newBookingId) {
				System.debug('****I am setting this booking to a NEW booking Record type****');
                book.RecordTypeId = newBookingId;
			}
		}
*/	}
}