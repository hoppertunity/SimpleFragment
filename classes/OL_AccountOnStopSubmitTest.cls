/**
* File Name   :    OL_AccountOnStopSubmitTest.cls
* Description :    
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 05/08/2014 Klea Kolaric	Initial version
*
*/
@isTest
public class OL_AccountOnStopSubmitTest {
	
	public static testMethod void testNotOnStop()
	{
		Account a = TestUtil.createAccountClient();
		a.On_Stop__c = false;
		insert a;
		
		Test.setCurrentPage(Page.OL_AccountOnStopSubmitAgent);
		Apexpages.currentPage().getParameters().put('id',a.id);
		
		Test.startTest();
		Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(a);
		OL_AccountOnStopSubmit aoss = new OL_AccountOnStopSubmit(sc);
		aoss.submitAccount();
		Test.stopTest();
	}
	
	public static testMethod void testHasTmpPermission()
	{
		Account a = TestUtil.createAccountClient();
		a.On_Stop__c = true;
		a.Request_Stubbins_Permission__c = true;
		a.Stubbins_Temporary_Permission__c = true;
		insert a;
		
		Test.setCurrentPage(Page.OL_AccountOnStopSubmitAgent);
		Apexpages.currentPage().getParameters().put('id',a.id);
		
		Test.startTest();
		Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(a);
		OL_AccountOnStopSubmit aoss = new OL_AccountOnStopSubmit(sc);
		aoss.submitAccount();
		Test.stopTest();
	}
	
	public static testMethod void testOnStop()
	{
		Account a = TestUtil.createAccountClient();
		a.On_Stop__c = true;
		insert a;
		
		Test.setCurrentPage(Page.OL_AccountOnStopSubmitAgent);
		Apexpages.currentPage().getParameters().put('id',a.id);
		
		Test.startTest();
		Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(a);
		OL_AccountOnStopSubmit aoss = new OL_AccountOnStopSubmit(sc);
		aoss.submitAccount();
		// try again to catch error
		aoss.submitAccount();
		Test.stopTest();
	}

}