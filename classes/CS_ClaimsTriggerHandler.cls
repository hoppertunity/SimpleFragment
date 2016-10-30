/**
* File Name   :    CS_ClaimsTriggerHandler.cls
* Description :    methods called from CS_Claims trigger
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 16/07/2014 Liza Romanenko	Initial version
*
*/
public with sharing class CS_ClaimsTriggerHandler {
	
	// HANDLERS
	
	public static void onBeforeInsertHandler(List<CS_Claims__c> triggerNew)
	{
		fillDataFromRelatedObjects(triggerNew);	
	}
	
	public static void onAfterInsertHandler(List<CS_Claims__c> triggerNew)
	{
		
	}
	
	public static void onAfterUpdateHandler(List<CS_Claims__c> triggerNew, Map<Id,CS_Claims__c> triggerOldMap)
	{
		
	}

	public static void onBeforeUpdateHandler(List<CS_Claims__c> triggerNew, Map<Id,CS_Claims__c> triggerOldMap)
	{
		
	}
	
	// METHODS
	
	private static void fillDataFromRelatedObjects(List<CS_Claims__c> claims){
		Set<Id> accountIds = new Set<Id>();
		Set<Id> contactIds = new Set<Id>();
		
		for(CS_Claims__c c : claims){
			accountIds.add(c.Account__c);
			accountIds.add(c.Depot__c);
			contactIds.add(c.Contact__c);
		}
		
		Map<Id, Account> accounts = new Map<Id, Account>([SELECT Name, AccountNumber, BillingStreet, BillingState, BillingPostalCode,
																BillingCountry, BillingCity, Phone
															FROM Account WHERE Id IN : accountIds]);
		Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT Name, Email, MailingStreet, MailingState, MailingPostalCode,
																MailingCountry, MailingCity, Phone
															FROM Contact WHERE Id IN : contactIds]);
		//Select Address Information
		Map<Id, Account_Address__c> aId_DefAddress = new Map<Id, Account_Address__c>();
		for(Account_Address__c aa : [SELECT Account__c, Street_1__c, Street_2__c, City__c, Postcode__c FROM Account_Address__c WHERE Account__c IN : accountIds AND Default__c = true]){
			aId_DefAddress.put(aa.Account__c, aa);
		}
		
		//fill fields in Claims
		for(CS_Claims__c c : claims){
			Account a = accounts.get(c.Account__c);
			Account d = accounts.get(c.Depot__c);
			Contact cont = contacts.get(c.Contact__c);
			Account_Address__c aa = aId_DefAddress.get(c.Account__c);
			
			c.TNT_account_no__c = a.AccountNumber;
			c.Sender_company_name__c = a.Name;
			if(aa != null){
				c.Sender_Address_1__c = aa.Street_1__c;
				c.Sender_Address_2__c = aa.Street_2__c;
				c.Sender_Address_3__c = aa.City__c;
				c.Sender_Postcode__c = aa.Postcode__c;
			}
			c.Sender_Telephone_no__c =   a.Phone;
			c.Depot_no__c = d.AccountNumber;
			if(cont != null){
				c.Sender_Contact_Name__c = cont.Name;
				if(c.Sender_Email_Address__c == null || c.Sender_Email_Address__c == ''){
					c.Sender_Email_Address__c = cont.Email;
				}
			}
			
		}
		
	}
}