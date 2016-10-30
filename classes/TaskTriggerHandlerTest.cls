/**
* File Name   :    TaskTriggerHandlerTest.cls
* Description :    test for Task trigger handler
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 13/04/2015 Liza Romanenko	Initial version (TNT-2697)
*
*
*/
@isTest
private class TaskTriggerHandlerTest {
	
	static testMethod void coverTaskTrigger(){
		
		Account a = TestUtil.createAccountClient();
        insert a;
        Account d = TestUtil.createAccountDepot();
        insert d;
        Contact con = TestUtil.createContact(a.Id);
        insert con;
        Case c = TestUtil.createCase(a.Id, con.Id, d.Id);
        c.Call_me_back__c = '1 hour';
        insert c;
        
        Task t = [SELECT Status FROM Task WHERE Subject = : ConstantUtil.TASK_SUBJECT_CALL_CLIENT_BACK LIMIT 1];
               
        Test.startTest();
        
        t.Status = ConstantUtil.PLVAL_TASK_STATUS_COMPLETED;
        update t;
               
        Test.stopTest();
        
        t = [SELECT SLA_Minutes_in_Business_Hours__c FROM Task WHERE Subject = : ConstantUtil.TASK_SUBJECT_CALL_CLIENT_BACK LIMIT 1];
        
        system.assertNotEquals(null, t.SLA_Minutes_in_Business_Hours__c);
		
	}
	
	
}