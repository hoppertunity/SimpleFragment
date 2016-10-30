/**
* File Name   :    OL_AccountOnStopSubmit.cls
* Description :    
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 05/08/2014 Klea Kolaric	Initial version (TNT-1293)
*
*/
public without sharing class OL_AccountOnStopSubmit {
	
	public Boolean hasError {get; set;}
	Account a;
	
	public OL_AccountOnStopSubmit(Apexpages.standardController stdCtrl)
	{
		Account a = (Account) stdCtrl.getRecord();
	}
	
	public void submitAccount()
	{
		Id aId = Apexpages.currentPage().getparameters().get('id');
		Account a = [select Name, On_Stop__c, Request_Stubbins_Permission__c, Stubbins_Temporary_Permission__c 
						from Account where id = :aId limit 1];
		
		if(a.On_Stop__c && !a.Stubbins_Temporary_Permission__c)
		{
			a.Request_Stubbins_Permission__c = true;
			update a;
			
			// submit for approval
			Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
	        req1.setComments('Requested by agent ' + UserInfo.getName() + ' (' + UserInfo.getUserId() + ').');
	        req1.setObjectId(a.id);
	        try
	        {
	        	Approval.ProcessResult result = Approval.process(req1);
	        	
	        	hasError = !result.isSuccess();
		        if(hasError)
		        {
		        	for(Database.error err : result.getErrors())
		        	{
		        		Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,err.getMessage()));
		        	}
		        }
	        }
	        catch(exception e)
	        {
	        	Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,e.getMessage()));
	        	hasError = true;
	        }
		}
		else
		{
			hasError = false;
		}
	}

}