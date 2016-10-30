/**
* File Name   :    CaseTriggerHandlerTest.cls
* Description :    
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 03/07/2014 Klea Kolaric   Initial version
* 0.2 19/08/2014 Liza Romanenko Tests for updateCaseTrackingHistory() method TNT-490,TNT-491,TNT-493
* 0.3 20/08/2014 Liza Romanenko Tests for updateOwnerForCallMeBackTasks() method TNT-1428
* 0.4 10/09/2014 James Melville Removed changeOwner method TNT-1603
* 0.4 14/10/2014 Klea Kolaric   Reminder now 15 before due date TNT-2051
* 0.5 20/10/2015 Darryl Hopper	Added test_getSLATime() method to test SLA Time scenario
* 0.5 20/10/2015 Darrylhopper	Amended testCreateReminderTask() to take SLA time into questio
*/
@isTest
private class CaseTriggerHandlerTest {
    
    static Integer mins = -15;

    static testMethod void quickCoverTrigger()
    {
        Account a = TestUtil.createAccountClient();
        insert a;
        Account d = TestUtil.createAccountDepot();
        insert d;
        Contact con = TestUtil.createContact(a.Id);
        insert con;
        Case c = TestUtil.createCase(a.Id, con.Id, d.Id);
        
        Test.startTest();
        insert c;
        update c;
        delete c;
        Test.stopTest();
    }
    
    static testMethod void testCreateReminderTask()
    {
        Account a = TestUtil.createAccountClient();
        insert a;
        Account d = TestUtil.createAccountDepot();
        insert d;
        Contact con = TestUtil.createContact(a.Id);
        insert con;
        Case c1 = TestUtil.createCase(a.Id, con.Id, d.Id);
        insert c1;
        Case c2 = TestUtil.createCase(a.Id, con.Id, d.Id);
        insert c2;
        
        system.assertEquals(0,[select count() from Task]);  // no task should be created before Call_me_back__c is set
        
        Map<Id,Case> oldMap = new Map<Id,Case>{c1.Id => c1.clone(true,true), c2.Id => c2.clone(true,true)};
        Integer hourDiffA = 1;
        Integer hourDiffB = 4;
        c1.Call_me_back__c = hourDiffA + ' hour';
        //DH Changed 19/10/15
        c2.Call_me_back__c = '24 hours';
        
        Test.startTest();
        CaseTriggerHandler.isFirstRun = true;
        CaseTriggerHandler.createReminderTask(new List<Case>{c1,c2},oldMap);
        c1.Call_me_back__c = hourDiffB + ' hours';
        oldMap.put(c2.id,c2);   // override old value to mimic unchanged field
        CaseTriggerHandler.isFirstRun = true;
        CaseTriggerHandler.createReminderTask(new List<Case>{c1,c2},oldMap);
        Test.stopTest();
        
        Datetime nextWorkingDay = TimeUtil.getNextWorkingDay(Datetime.now());
        
        // give 5 minute leeway as we're working with datetime which has a granularity of milliseconds
        
        // two tasks will be created for first case because we changed the reminder
        /*
        system.assertEquals(1,[select count() from Task where WhatId = :c1.Id 
            and ReminderDateTime > :Datetime.now().addHours(hourDiffA).addMinutes(-5+mins) 
            and ReminderDateTime < :Datetime.now().addHours(hourDiffA).addMinutes(5+mins)]);
        system.assertEquals(1,[select count() from Task where WhatId = :c1.Id 
            and ReminderDateTime > :Datetime.now().addHours(hourDiffB).addMinutes(-5+mins) 
            and ReminderDateTime < :Datetime.now().addHours(hourDiffB).addMinutes(5+mins)]);
        */
        //DH new version of test above
        system.assertEquals(1,[select count() from Task where WhatId = :c1.Id 
            and ReminderDateTime > :CaseTriggerHandler.getSLATime(hourDiffA,Datetime.now()).addMinutes(-5+mins) 
            and ReminderDateTime < :CaseTriggerHandler.getSLATime(hourDiffA,Datetime.now()).addMinutes(5+mins)]);
        system.assertEquals(1,[select count() from Task where WhatId = :c1.Id 
            and ReminderDateTime > :CaseTriggerHandler.getSLATime(hourDiffB,Datetime.now()).addMinutes(-5+mins) 
            and ReminderDateTime < :CaseTriggerHandler.getSLATime(hourDiffB,Datetime.now()).addMinutes(5+mins)]);
        
        // only one task for c2 DH Amended for new SLA calculation
        system.assertEquals(1,[select count() from Task where WhatId = :c2.Id 
            and ReminderDateTime > :CaseTriggerHandler.getSLATime(24,Datetime.now()).addMinutes(-5+mins)  
            and ReminderDateTime < :CaseTriggerHandler.getSLATime(24,Datetime.now()).addMinutes(5+mins) ]);
    }
    
    static testMethod void testPopulate24HDeadline()
    {
        Account a = TestUtil.createAccountClient();
        insert a;
        Contact con = TestUtil.createContact(a.Id);
        insert con;
        Case c = TestUtil.createCase(a.Id, con.Id);
        
        Test.startTest();
        CaseTriggerHandler.populate24HDeadline(new List<Case>{c});
        Test.stopTest();
        system.assert(c.Twentyfour_Hour_Deadline__c != null,'Twentyfour_Hour_Deadline__c is not populated'); // can't assert time
    }
     
    /*static testMethod void testAssignEscalatedCases()
    {
        List<Group> queues = new List<Group>();
        queues.add(new Group(Type = 'Queue', Name = 'ClientCollection', DeveloperName = 'ClientCollection'));
        queues.add(new Group(Type = 'Queue', Name = 'ClientDelivery', DeveloperName = 'ClientDelivery'));
        queues.add(new Group(Type = 'Queue', Name = 'DepotCollection', DeveloperName = 'DepotCollection'));
        queues.add(new Group(Type = 'Queue', Name = 'DepotDelivery', DeveloperName = 'DepotDelivery'));
        queues = (List<Group>) TestUtil.proxyInsert(queues);
        
        Account ac1 = TestUtil.createAccountClient();
        ac1.Collection_Queue__c = queues.get(0).DeveloperName;
        ac1.Delivery_Queue__c = queues.get(1).DeveloperName;
        insert ac1;
        Account ac2 = TestUtil.createAccountClient();
        ac2.Name += '2';
        ac2.AccountNumber += '2';
        insert ac2;
        Account ad = TestUtil.createAccountDepot();
        ad.Collection_Queue__c = queues.get(2).DeveloperName;
        ad.Delivery_Queue__c = queues.get(3).DeveloperName;
        insert ad;
        
        List<Case> cases = new List<Case>();
        Case c;
        
        // will use client queue for collection
        c = TestUtil.createCase(ac1.Id, null);
        c.Exception__c = ConstantUtil.PLVAL_CASE_EXCEPTION_COLLECTION;
        c.Collection_Depot__c = ad.id;
        cases.add(c);
        // will use client queue for delivery
        c = TestUtil.createCase(ac1.Id, null);
        c.Exception__c = ConstantUtil.PLVAL_CASE_EXCEPTION_DELIVERY;
        c.Delivery_Depot__c = ad.id;
        cases.add(c);
        // will use depot queue for collection
        c = TestUtil.createCase(ac2.Id, null);
        c.Exception__c = ConstantUtil.PLVAL_CASE_EXCEPTION_COLLECTION;
        c.Collection_Depot__c = ad.id;
        cases.add(c);
        // will use depot queue for delivery
        c = TestUtil.createCase(ac2.Id, null);
        c.Exception__c = ConstantUtil.PLVAL_CASE_EXCEPTION_DELIVERY;
        c.Delivery_Depot__c = ad.id;
        cases.add(c);
        
        insert cases;
        Map<Id,Case> oldMap = new Map<Id,Case>(cases.deepClone(true,true,true));
        
        for(Case cas : cases)
        {
            cas.IsEscalated = true;
        }
        
        Test.startTest();
        CaseTriggerHandler.assignEscalatedCases(cases,oldMap);
        System.assert(CaseTriggerHandler.assignedEscalatedOwner);
        CaseTriggerHandler.assignEscalatedCases(cases,oldMap);  // just to cover execution skip
        Test.stopTest();
        
        System.assertEquals(cases.get(0).OwnerId,[select Id from Group where DeveloperName = :ac1.Collection_Queue__c].Id);
        System.assertEquals(cases.get(1).OwnerId,[select Id from Group where DeveloperName = :ac1.Delivery_Queue__c].Id);
        System.assertEquals(cases.get(2).OwnerId,[select Id from Group where DeveloperName = :ad.Collection_Queue__c].Id);
        System.assertEquals(cases.get(3).OwnerId,[select Id from Group where DeveloperName = :ad.Delivery_Queue__c].Id);
    }*/
    
    static testMethod void testAssignCases()
    {
        List<Group> queues = new List<Group>();
        queues.add(new Group(Type = 'Queue', Name = 'ClientCollection', DeveloperName = 'ClientCollection'));
        queues.add(new Group(Type = 'Queue', Name = 'ClientDelivery', DeveloperName = 'ClientDelivery'));
        queues.add(new Group(Type = 'Queue', Name = 'DepotCollection', DeveloperName = 'DepotCollection'));
        queues.add(new Group(Type = 'Queue', Name = 'DepotDelivery', DeveloperName = 'DepotDelivery'));
        
        //DH added 19/01/2016
        //queues.add(new Group(Type = 'Queue', Name = 'Mauritius_Team', DeveloperName = 'Mauritius_Team'));
        queues = (List<Group>) TestUtil.proxyInsert(queues);
          
        Account ac1 = TestUtil.createAccountClient();
        ac1.Collection_Queue__c = queues.get(0).DeveloperName;
        ac1.Delivery_Queue__c = queues.get(1).DeveloperName;
        insert ac1;
        Account ac2 = TestUtil.createAccountClient();
        ac2.Name += '2';
        ac2.AccountNumber += '2';
        insert ac2;
        Account ad = TestUtil.createAccountDepot();
        ad.Collection_Queue__c = queues.get(2).DeveloperName;
        ad.Delivery_Queue__c = queues.get(3).DeveloperName;
        insert ad;
        
        List<Case> cases = new List<Case>();
        Case c;
        
        // will use client queue for collection
        c = TestUtil.createCase(ac1.Id, null);
        c.Exception__c = ConstantUtil.PLVAL_CASE_EXCEPTION_COLLECTION;
        c.Collection_Depot__c = ad.id;
        c.OwnerId = UserInfo.getUserId();
        c.Origin = ConstantUtil.PLVAL_CASE_ORIGIN_PHONE;
        cases.add(c);
        // will use client queue for delivery
        
        c = TestUtil.createCase(ac1.Id, null);
        c.Exception__c = ConstantUtil.PLVAL_CASE_EXCEPTION_DELIVERY;
        c.Delivery_Depot__c = ad.id;
        c.OwnerId = UserInfo.getUserId();
        c.Origin = ConstantUtil.PLVAL_CASE_ORIGIN_PHONE;
        cases.add(c);
        // will use depot queue for collection
        c = TestUtil.createCase(ac2.Id, null);
        c.Exception__c = ConstantUtil.PLVAL_CASE_EXCEPTION_COLLECTION;
        c.Collection_Depot__c = ad.id;
        c.OwnerId = UserInfo.getUserId();
        c.Origin = ConstantUtil.PLVAL_CASE_ORIGIN_PHONE;
        cases.add(c);
        // will use depot queue for delivery
        c = TestUtil.createCase(ac2.Id, null);
        c.Exception__c = ConstantUtil.PLVAL_CASE_EXCEPTION_DELIVERY;
        c.Delivery_Depot__c = ad.id;
        c.OwnerId = UserInfo.getUserId();
        c.Origin = ConstantUtil.PLVAL_CASE_ORIGIN_PHONE;
        cases.add(c);
        
        //DH added 19/01/2016
        // will use Mauritius queue
        c = TestUtil.createCase(ac2.Id, null);
        c.Exception__c = ConstantUtil.PLVAL_CASE_EXCEPTION_COLLECTION;
        c.Collection_Depot__c = ad.id;
        c.OwnerId = UserInfo.getUserId();
        c.Origin = ConstantUtil.PLVAL_CASE_ORIGIN_PHONE;
        c.Type = 'Track';
        c.Case_Types_Level_2__c = 'Late Delivery';
        cases.add(c);
        // will use Mauritius queue
        c = TestUtil.createCase(ac2.Id, null);
        c.Exception__c = ConstantUtil.PLVAL_CASE_EXCEPTION_DELIVERY;
        c.Delivery_Depot__c = ad.id;
        c.OwnerId = UserInfo.getUserId();
        c.Origin = ConstantUtil.PLVAL_CASE_ORIGIN_PHONE;
        c.Type = 'Track';
        c.Case_Types_Level_2__c = 'Late Delivery';
        cases.add(c);
        // will use Mauritius queue
        c = TestUtil.createCase(ac2.Id, null);
        c.Exception__c = ConstantUtil.PLVAL_CASE_EXCEPTION_COLLECTION;
        c.Collection_Depot__c = ad.id;
        c.OwnerId = UserInfo.getUserId();
        c.Origin = ConstantUtil.PLVAL_CASE_ORIGIN_PHONE;
        c.Type = 'Track';
        c.Case_Types_Level_2__c = 'Paperwork Request';
        cases.add(c);
        // will use Mauritius queue
        c = TestUtil.createCase(ac2.Id, null);
        c.Exception__c = ConstantUtil.PLVAL_CASE_EXCEPTION_DELIVERY;
        c.Delivery_Depot__c = ad.id;
        c.OwnerId = UserInfo.getUserId();
        c.Origin = ConstantUtil.PLVAL_CASE_ORIGIN_PHONE;
        c.Type = 'Track';
        c.Case_Types_Level_2__c = 'Paperwork Request';
        cases.add(c);
        // will use Mauritius queue
        c = TestUtil.createCase(ac2.Id, null);
        c.Exception__c = ConstantUtil.PLVAL_CASE_EXCEPTION_COLLECTION;
        c.Collection_Depot__c = ad.id;
        c.OwnerId = UserInfo.getUserId();
        c.Origin = ConstantUtil.PLVAL_CASE_ORIGIN_PHONE;
        c.Type = 'General Enquiry';
        c.Case_Types_Level_2__c = 'Redelivery Request';
        cases.add(c);
        // will use Mauritius queue
        c = TestUtil.createCase(ac2.Id, null);
        c.Exception__c = ConstantUtil.PLVAL_CASE_EXCEPTION_DELIVERY;
        c.Delivery_Depot__c = ad.id;
        c.OwnerId = UserInfo.getUserId();
        c.Origin = ConstantUtil.PLVAL_CASE_ORIGIN_PHONE;
        c.Type = 'General Enquiry';
        c.Case_Types_Level_2__c = 'Redelivery Request';
        cases.add(c);
        
        //**Negative Test by DH 19/01/2016
        // will NOT use Mauritius queue
        c = TestUtil.createCase(ac2.Id, null);
        c.Exception__c = ConstantUtil.PLVAL_CASE_EXCEPTION_COLLECTION;
        c.Collection_Depot__c = ad.id;
        c.OwnerId = UserInfo.getUserId();
        c.Origin = ConstantUtil.PLVAL_CASE_ORIGIN_PHONE;
        c.Type = 'Track';
        c.Case_Types_Level_2__c = 'Redelivery Request';
        cases.add(c);
        // will NOT use Mauritius queue
        c = TestUtil.createCase(ac2.Id, null);
        c.Exception__c = ConstantUtil.PLVAL_CASE_EXCEPTION_DELIVERY;
        c.Delivery_Depot__c = ad.id;
        c.OwnerId = UserInfo.getUserId();
        c.Origin = ConstantUtil.PLVAL_CASE_ORIGIN_PHONE;
        c.Type = 'Track';
        c.Case_Types_Level_2__c = 'Redelivery Request';
        cases.add(c);
        
        insert cases;
        Map<Id,Case> oldMap = new Map<Id,Case>(cases.deepClone(true,true,true));
        
        for(Case cas : cases)
        {
            cas.OwnerId = ConstantUtil.UNASSIGNED_QUEUE_ID;
        }

        
        
        Test.startTest();
        CaseTriggerHandler.assignCases(cases,oldMap);
        Test.stopTest();
        //00G20000001u5UrEAI
        ID testMauritiusID = ConstantUtil.MAURITIUS_QUEUE_ID;
        //system.assertEquals(testMauritiusID,'00G20000001u5UrEAI');
        System.assertEquals(cases.get(0).OwnerId,[select Id from Group where DeveloperName = :ac1.Collection_Queue__c].Id);
        System.assertEquals(cases.get(1).OwnerId,[select Id from Group where DeveloperName = :ac1.Delivery_Queue__c].Id);
        System.assertEquals(cases.get(2).OwnerId,[select Id from Group where DeveloperName = :ad.Collection_Queue__c].Id);
        System.assertEquals(cases.get(3).OwnerId,[select Id from Group where DeveloperName = :ad.Delivery_Queue__c].Id);
        //Added by DH 19/01/2016
        System.assertEquals(cases.get(4).OwnerId,testMauritiusID);
        System.assertEquals(cases.get(5).OwnerId,testMauritiusID);
        System.assertEquals(cases.get(6).OwnerId,testMauritiusID);
        System.assertEquals(cases.get(7).OwnerId,testMauritiusID);
        //Commented out 02/02/2016 ref Kish due to Redelivery status not being included at this time
        //System.assertEquals(cases.get(8).OwnerId,testMauritiusID);
        //System.assertEquals(cases.get(9).OwnerId,testMauritiusID);
        //Negative TEst
        System.assertNOTEquals(cases.get(10).OwnerId,testMauritiusID);
        System.assertNOTEquals(cases.get(11).OwnerId,testMauritiusID);
        
    }
    
    /*static testMethod void testAssignMajorAccountCases() {

        User u = TestUtil.createAgentUser();
        insert u;
        Account a = TestUtil.createAccountClient();
        a.Major_Account__c = true;
        a.Assigned_Agent__c = u.Id;
        insert a;
        Contact con = TestUtil.createContact(a.Id);
        insert con;
        
        Group res = [SELECT Id FROM Group WHERE DeveloperName = : ConstantUtil.MAJOR_ACCOUNTS_QUEUE LIMIT 1];
        String majourAccountQueueId = res.Id;
        
        Case c = TestUtil.createCase(a.Id, con.Id);
        c.OwnerId = majourAccountQueueId;
        insert c;

        c = [SELECT Id, OwnerId FROM Case WHERE Id = :c.Id];

        system.assertEquals(u.Id, c.OwnerId, 'Owner should have been updated to user u');
     }*/
     
     /*static testMethod void testAssignMajorAccountCasesToQueue() {

        User u = TestUtil.createAgentUser();
        insert u;
        Account a = TestUtil.createAccountClient();
        a.Major_Account__c = true;
        a.Assigned_Agent__c = u.Id;
        insert a;
        Contact con = TestUtil.createContact(a.Id);
        insert con;
       
        Group res = [SELECT Id FROM Group WHERE DeveloperName = : ConstantUtil.MAJOR_ACCOUNTS_QUEUE LIMIT 1];
        String majourAccountQueueId = res.Id;
        
        Case c = TestUtil.createCase(a.Id, con.Id);
        insert c;

        c = [SELECT Id, OwnerId, Case_Back_to_Queue_MA__c FROM Case WHERE Id = :c.Id];
        
        //update with Queue to run trigger
        c.OwnerId = majourAccountQueueId;
        c.Case_Back_to_Queue_MA__c = true;
        
        update c;
        
        c = [SELECT Id, OwnerId, Case_Back_to_Queue_MA__c FROM Case WHERE Id = :c.Id];

        system.assertEquals(majourAccountQueueId, c.OwnerId, 'Owner should stay in Queue');
     }*/
     
     static testMethod void testCaseHistoryTracking() {

        Account a = TestUtil.createAccountClient();
        insert a;
        Account d = TestUtil.createAccountDepot();
        insert d;
        Contact con = TestUtil.createContact(a.Id);
        insert con;

        Case c = TestUtil.createCase(a.Id, con.Id, d.Id);

        insert c;
        
        c.Status = ConstantUtil.PLVAL_CASE_STATUS_WAITING_FOR_CUSTOMER;
        
        update c;

        List<Case_Tracking_History__c> cthList = [SELECT Category__c, Case_Waiting__c, Finished_on__c 
                                                    FROM Case_Tracking_History__c 
                                                    WHERE Category__c = : ConstantUtil.PLVAL_CTH_CATEGORY_STATUS ORDER BY Case_Waiting__c];
        
        system.assertEquals(2, cthList.size());
        system.assertEquals(true, cthList[1].Case_Waiting__c);
        system.assertEquals(null, cthList[1].Finished_on__c);
     }
     
     static testMethod void testCaseHistoryTracking_CloseCase() {

        Account a = TestUtil.createAccountClient();
        insert a;
        Account d = TestUtil.createAccountDepot();
        insert d;
        Contact con = TestUtil.createContact(a.Id);
        insert con;

        Case c = TestUtil.createCase(a.Id, con.Id, d.Id);

        insert c;
        
        c.Status = 'Closed';
        
        update c;

        List<Case_Tracking_History__c> cthList = [SELECT Category__c, Case_Waiting__c, Finished_on__c 
                                                    FROM Case_Tracking_History__c 
                                                    WHERE Finished_on__c = : null];
        
        system.assertEquals(0, cthList.size());
     }
     
     static testMethod void test_updateOwnerForCallMeBackTasks() {

        Account a = TestUtil.createAccountClient();
        insert a;
        Account d = TestUtil.createAccountDepot();
        insert d;
        Contact con = TestUtil.createContact(a.Id);
        insert con;
        User u = TestUtil.createAgentUser();
        insert u;

        Case c = TestUtil.createCase(a.Id, con.Id, d.Id);
        c.Call_me_back__c = '1 hour';
        insert c;
        
        Task t = [SELECT OwnerId FROM Task WHERE Subject = : ConstantUtil.TASK_SUBJECT_CALL_CLIENT_BACK LIMIT 1];
        
        system.assertEquals(UserInfo.getUserId(), t.OwnerId);
        
        Test.startTest();
        
        c.OwnerId = u.Id;
        update c;
        
        Test.stopTest();
        
        t = [SELECT OwnerId FROM Task WHERE Subject = : ConstantUtil.TASK_SUBJECT_CALL_CLIENT_BACK LIMIT 1];
        
        system.assertEquals(u.Id, t.OwnerId);
     }
     
     static testMethod void test_updateOwnerForCallMeBackClosedTasks() {

        Account a = TestUtil.createAccountClient();
        insert a;
        Account d = TestUtil.createAccountDepot();
        insert d;
        Contact con = TestUtil.createContact(a.Id);
        insert con;
        User u = TestUtil.createAgentUser();
        insert u;

        Case c = TestUtil.createCase(a.Id, con.Id, d.Id);
        c.Call_me_back__c = '1 hour';
        insert c;
        
        Task t = [SELECT Status, OwnerId FROM Task WHERE Subject = : ConstantUtil.TASK_SUBJECT_CALL_CLIENT_BACK LIMIT 1];
        
        system.assertEquals(UserInfo.getUserId(), t.OwnerId);
        
        t.Status = 'Completed';
        update t;
        
        Test.startTest();
        
        c.OwnerId = u.Id;
        update c;
        
        Test.stopTest();
        
        t = [SELECT OwnerId FROM Task WHERE Subject = : ConstantUtil.TASK_SUBJECT_CALL_CLIENT_BACK LIMIT 1];
        
        system.assertEquals(UserInfo.getUserId(), t.OwnerId);
     }
    
        static testMethod void test_getSLATime() 
        {
            //All tests assume start and end time are 08:00 and 18:00, respectively
            //---Test all callback hours when logged pre start Monday
            DateTime logTime = DateTime.newInstance(2015,09,21,04,59,00);
            Integer callBack = 1;
            DateTime SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,21,9,0,0), SLAResult);
            callBack = 2;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,21,10,0,0), SLAResult);
            callBack = 3;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,21,11,0,0), SLAResult);
            callBack = 4;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,21,12,0,0), SLAResult);
            callBack = 5;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,21,13,0,0), SLAResult);
            callBack = 24;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,22,8,0,0), SLAResult);
            callBack = 48;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,23,8,0,0), SLAResult);
            
            //---Test all callback hours when logged within Monday working day and SLA result doesnot exceed working day or is 24 or 48 hour 
            logTime = DateTime.newInstance(2015,09,21,10,59,00);
            callBack = 1;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,21,11,59,0), SLAResult);
            callBack = 2;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,21,12,59,0), SLAResult);
            callBack = 3;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,21,13,59,0), SLAResult);
            callBack = 4;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,21,14,59,0), SLAResult);
            callBack = 5;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,21,15,59,0), SLAResult);
            callBack = 24;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,22,10,59,0), SLAResult);
            callBack = 48;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,23,10,59,0), SLAResult);
            
            //---Test all callback hours when logged Monday working day buty SLA result is today but then passes end of day or is 24 or 48 hour 
            logTime = DateTime.newInstance(2015,09,21,15,59,00);
            callBack = 1;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,21,16,59,0), SLAResult);
            callBack = 2;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,21,17,59,0), SLAResult);
            callBack = 3;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            //Should go to Tuesday Morning here
            System.assertEquals(DateTime.newInstance(2015,09,22,08,59,0), SLAResult);
            callBack = 4;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,22,09,59,0), SLAResult);
            callBack = 5;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,22,10,59,0), SLAResult);
            callBack = 24;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,22,15,59,0), SLAResult);
            callBack = 48;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,23,15,59,0), SLAResult);
            
            //---Test all callback hours when logged Monday after working day  
            logTime = DateTime.newInstance(2015,09,21,18,01,00);
            callBack = 1;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            //Should go to Tuesday starting from start time e.g. 8:00 here so first hour  = 9
            System.assertEquals(DateTime.newInstance(2015,09,22,9,0,0), SLAResult);
            callBack = 2;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,22,10,0,0), SLAResult);
            callBack = 3;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            //Should go to Tuesday Morning here
            System.assertEquals(DateTime.newInstance(2015,09,22,11,0,0), SLAResult);
            callBack = 4;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,22,12,0,0), SLAResult);
            callBack = 5;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,22,13,0,0), SLAResult);
            callBack = 24;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            //Should go to Wednesday start time
            System.assertEquals(DateTime.newInstance(2015,09,23,8,0,0), SLAResult);
            callBack = 48;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,24,8,0,0), SLAResult);
            //*******************************************************
            //---Test all callback hours when logged pre start Friday
            logTime = DateTime.newInstance(2015,09,25,04,59,00);
            callBack = 1;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,25,9,0,0), SLAResult);
            callBack = 2;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,25,10,0,0), SLAResult);
            callBack = 3;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,25,11,0,0), SLAResult);
            callBack = 4;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,25,12,0,0), SLAResult);
            callBack = 5;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,25,13,0,0), SLAResult);
            callBack = 24;
            //Should be next Monday (weekend)
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,28,8,0,0), SLAResult);
            callBack = 48;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,29,8,0,0), SLAResult);
            
            //---Test all callback hours when logged within Friday working day and SLA result doesnot exceed working day or is 24 or 48 hour 
            logTime = DateTime.newInstance(2015,09,25,10,59,00);
            callBack = 1;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,25,11,59,0), SLAResult);
            callBack = 2;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,25,12,59,0), SLAResult);
            callBack = 3;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,25,13,59,0), SLAResult);
            callBack = 4;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,25,14,59,0), SLAResult);
            callBack = 5;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,25,15,59,0), SLAResult);
            callBack = 24;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,28,10,59,0), SLAResult);
            callBack = 48;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,29,10,59,0), SLAResult);
            
            //---Test all callback hours when logged Friday working day buty SLA result is today but then passes end of day or is 24 or 48 hour 
            logTime = DateTime.newInstance(2015,09,25,15,59,00);
            callBack = 1;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,25,16,59,0), SLAResult);
            callBack = 2;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,25,17,59,0), SLAResult);
            callBack = 3;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            //Should go to Monday Morning here
            System.assertEquals(DateTime.newInstance(2015,09,28,08,59,0), SLAResult);
            callBack = 4;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,28,09,59,0), SLAResult);
            callBack = 5;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,28,10,59,0), SLAResult);
            callBack = 24;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,28,15,59,0), SLAResult);
            callBack = 48;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,29,15,59,0), SLAResult);
            
            //---Test all callback hours when logged Fri after working day  
            logTime = DateTime.newInstance(2015,09,25,18,01,00);
            callBack = 1;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            //Should go to Monday starting from start time e.g. 8:00 here so first hour  = 9
            System.assertEquals(DateTime.newInstance(2015,09,28,9,0,0), SLAResult);
            callBack = 2;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,28,10,0,0), SLAResult);
            callBack = 3;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            //Should go to Tuesday Morning here
            System.assertEquals(DateTime.newInstance(2015,09,28,11,0,0), SLAResult);
            callBack = 4;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,28,12,0,0), SLAResult);
            callBack = 5;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,28,13,0,0), SLAResult);
            callBack = 24;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            //Should go to Tuesday start time
            System.assertEquals(DateTime.newInstance(2015,09,29,8,0,0), SLAResult);
            callBack = 48;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,30,8,0,0), SLAResult);
            
            //Test login Saturday*********************************
            //---Test all callback hours when logged Saturday
            logTime = DateTime.newInstance(2015,09,26,04,59,00);
            callBack = 1;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,28,9,0,0), SLAResult);
            callBack = 2;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,28,10,0,0), SLAResult);
            callBack = 3;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,28,11,0,0), SLAResult);
            callBack = 4;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,28,12,0,0), SLAResult);
            callBack = 5;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,28,13,0,0), SLAResult);
            callBack = 24;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,29,8,0,0), SLAResult);
            callBack = 48;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,30,8,0,0), SLAResult);
            
            //Test login Saturday*********************************
            //---Test all callback hours when logged Bak Holiday
            logTime = DateTime.newInstance(2015,08,31,04,59,00);
            callBack = 1;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,01,9,0,0), SLAResult);
            callBack = 2;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,01,10,0,0), SLAResult);
            callBack = 3;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,01,11,0,0), SLAResult);
            callBack = 4;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,01,12,0,0), SLAResult);
            callBack = 5;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,01,13,0,0), SLAResult);
            callBack = 24;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,02,8,0,0), SLAResult);
            callBack = 48;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,03,8,0,0), SLAResult);    
            
            //*******************************************************
            //---Test all callback hours when logged pre start Friday and Bank Holiday Monday follows
            logTime = DateTime.newInstance(2015,08,28,04,59,00);
            callBack = 1;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,08,28,9,0,0), SLAResult);
            callBack = 2;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,08,28,10,0,0), SLAResult);
            callBack = 3;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,08,28,11,0,0), SLAResult);
            callBack = 4;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,08,28,12,0,0), SLAResult);
            callBack = 5;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,08,28,13,0,0), SLAResult);
            callBack = 24;
            //Should be next Tuesday (weekend & BH)
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,01,8,0,0), SLAResult);
            callBack = 48;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,02,8,0,0), SLAResult);
            
            //---Test all callback hours when logged within Friday working day and SLA result doesnot exceed working day or is 24 or 48 hour 
            logTime = DateTime.newInstance(2015,08,28,10,59,00);
            callBack = 1;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,08,28,11,59,0), SLAResult);
            callBack = 2;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,08,28,12,59,0), SLAResult);
            callBack = 3;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,08,28,13,59,0), SLAResult);
            callBack = 4;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,08,28,14,59,0), SLAResult);
            callBack = 5;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,08,28,15,59,0), SLAResult);
            callBack = 24;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,01,10,59,0), SLAResult);
            callBack = 48;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,02,10,59,0), SLAResult);
            
            //---Test all callback hours when logged Friday & BH Monday working day buty SLA result is today but then passes end of day or is 24 or 48 hour 
            /* Commented out as will fail next year
            logTime = DateTime.newInstance(2015,08,28,15,59,00);
            callBack = 1;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,08,28,16,59,0), SLAResult);
            callBack = 2;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,08,28,17,59,0), SLAResult);
            callBack = 3;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            //Should go to Monday Morning here
            System.assertEquals(DateTime.newInstance(2015,09,01,08,59,0), SLAResult);
            callBack = 4;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,01,09,59,0), SLAResult);
            callBack = 5;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,01,10,59,0), SLAResult);
            callBack = 24;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,01,15,59,0), SLAResult);
            callBack = 48;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,02,15,59,0), SLAResult);
            */
            //---Test all callback hours when logged Fri after working day  
            logTime = DateTime.newInstance(2015,08,28,18,01,00);
            callBack = 1;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            //Should go to Tuesday (BH Monday) starting from start time e.g. 8:00 here so first hour  = 9
            System.assertEquals(DateTime.newInstance(2015,09,01,9,0,0), SLAResult);
            callBack = 2;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,01,10,0,0), SLAResult);
            callBack = 3;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            //Should go to Tuesday Morning here
            System.assertEquals(DateTime.newInstance(2015,09,01,11,0,0), SLAResult);
            callBack = 4;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,01,12,0,0), SLAResult);
            callBack = 5;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,01,13,0,0), SLAResult);
            callBack = 24;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            //Should go to Tuesday start time
            System.assertEquals(DateTime.newInstance(2015,09,02,8,0,0), SLAResult);
            callBack = 48;
            SLAResult = CaseTriggerHandler.getSLATime(callBack,logtime);
            System.assertEquals(DateTime.newInstance(2015,09,03,8,0,0), SLAResult);
        }
}