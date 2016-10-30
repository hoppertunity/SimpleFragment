/**
* File Name   :    AccountContactTriggerHandlerTest.cls
* Description :    test for Account_Contact trigger handler
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 21/08/2014 Liza Romanenko	Initial version (TNT-1334)
*
*
*/
@isTest
private class AccountContactTriggerHandlerTest {

	static testMethod void test_updateAccountContactObj_updateAccount()
    {
    	Account a0 = TestUtil.createAccountClient();
    	insert a0;
    	Account a1 = TestUtil.createAccountClient();
    	a1.ParentId = a0.Id;
    	insert a1;
    	Contact c1 = TestUtil.createContact(a1.Id);
    	insert c1;
    	
    	List<Account_Contact__c> acList = [SELECT Account__c, Contact__c FROM Account_Contact__c];
    	System.assertEquals(2, acList.size());
    	
    	c1.AccountId = a0.Id;
    	update c1;
    	
    	c1.AccountId = a1.Id;
    	update c1;
    	
    	acList = [SELECT Account__c, Contact__c FROM Account_Contact__c];
    	System.assertEquals(2, acList.size());
    }
}