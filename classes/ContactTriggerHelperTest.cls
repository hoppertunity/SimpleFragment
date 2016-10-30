/**
* File Name   :    ContactTriggerHelperTest.cls
* Description :    test for contact trigger handler
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 21/07/2014 Klea Kolaric   Initial version (TNT-455)
*
*
*/
@isTest
private class ContactTriggerHelperTest {

    static testMethod void quickCoverTrigger()
    {
        Account a = TestUtil.createAccountClient();
        insert a;
        Contact c = TestUtil.createContact(a.Id);
        
        Test.startTest();
        insert c;
        update c;
        delete c;
        Test.stopTest();
    }
       
    static testMethod void test_updateAccountContactObj()
    {
        Account a1 = TestUtil.createAccountClient();
        insert a1;
        Contact c1 = TestUtil.createContact(a1.Id);
        insert c1;
        
        List<Account_Contact__c> acList = [SELECT Account__c, Contact__c FROM Account_Contact__c];
        System.assertEquals(1, acList.size());
    }
    
    static testMethod void test_updateAccountContactObj_updateAccount()
    {
        Account a0 = TestUtil.createAccountClient();
        insert a0;
        Account a1 = TestUtil.createAccountClient();
        insert a1;
        Contact c1 = TestUtil.createContact(a1.Id);
        insert c1;
        
        c1.AccountId = a0.Id;
        update c1;
        
        c1.AccountId = a1.Id;
        update c1;
        
        List<Account_Contact__c> acList = [SELECT Account__c, Contact__c FROM Account_Contact__c];
        System.assertEquals(2, acList.size());
    }
}