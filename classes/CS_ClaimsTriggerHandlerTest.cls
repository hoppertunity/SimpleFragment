/**
* File Name   :    CS_ClaimsTriggerHandlerTest.cls
* Description :    Test class for CS_ClaimsTriggerHandler.cls
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 17/07/2014 Liza Romanenko	Initial version
*
*
*/
@isTest
private class CS_ClaimsTriggerHandlerTest {

    static testMethod void testFillFieldsFromAccountContactDepot() {
        
        Account a = TestUtil.createAccountClient();
    	insert a;
    	Account d = TestUtil.createAccountDepot();
    	insert d;
    	Contact con = TestUtil.createContact(a.Id);
    	insert con;
    	Account_Address__c aaDef = TestUtil.createAccountAddress(a.Id,null);
    	aaDef.Default__c = true;
    	insert aaDef;
        
        CS_Claims__c claim = new CS_Claims__c();
        claim.Account__c = a.Id;
        claim.Depot__c = d.Id;
        claim.Contact__c = con.Id;
        insert claim;
        
        claim = [SELECT Sender_Contact_Name__c, TNT_account_no__c, Depot_no__c FROM CS_Claims__c WHERE Id = : claim.Id];
        
        system.assertEquals(claim.Sender_Contact_Name__c, 'Test Class Contact');
        system.assertEquals(claim.TNT_account_no__c, '111');
        system.assertEquals(claim.Depot_no__c, '222');
    }
}