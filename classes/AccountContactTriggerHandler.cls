/**
* File Name   :    AccountContactTriggerHandler.cls
* Description :    methods called from Account_Contact trigger
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 21/08/2014 Liza Romanenko	Initial version (TNT-1334)
*
*/
public with sharing class AccountContactTriggerHandler {
	// HANDLERS
	
	public static void onAfterInsertHandler(List<Account_Contact__c> triggerNew)
	{
		createParentAccountContactObj(triggerNew);
	}
	
	// METHODS
	private static void createParentAccountContactObj(List<Account_Contact__c> newAC){
		List<Account_Contact__c> newAccountContacts = new List<Account_Contact__c>();
		
		Map<Id, Id> contactId_accountId = new Map<Id, Id>();
		Map<Id, Id> accountId_parentId = new Map<Id, Id>();
		
		for(Account_Contact__c ac : newAC){
			contactId_accountId.put(ac.Contact__c, ac.Account__c);
		}
		
		for(Account a : [SELECT ParentId FROM Account WHERE Id IN : contactId_accountId.values()]){
			if(a.ParentId != null){
				accountId_parentId.put(a.Id, a.ParentId);
			}
		}
		
		if(!accountId_parentId.isEmpty()){
			Map<String, Account_Contact__c> existedAccountContacts = new Map<String, Account_Contact__c>();
			for(Account_Contact__c ac : [SELECT Account__c, Contact__c FROM Account_Contact__c 
										WHERE Contact__c IN : contactId_accountId.keyset() AND Account__c IN : accountId_parentId.values()]){
				String key = (String)ac.Account__c + (String)ac.Contact__c;
				existedAccountContacts.put(key, ac);
			}
			
			for(Account_Contact__c ac : newAC){
				if(accountId_parentId.containsKey(ac.Account__c)){
					String key = (String)accountId_parentId.get(ac.Account__c) + (String)ac.Contact__c;
					if(!existedAccountContacts.containsKey(key)){
						Account_Contact__c newRec = new Account_Contact__c();
						newRec.Account__c = accountId_parentId.get(ac.Account__c);
						newRec.Contact__c = ac.Contact__c;
						newAccountContacts.add(newRec);	
					}
				}
			}
			
			if(!newAccountContacts.isEmpty()){
				insert newAccountContacts;
			}
		}
		
	} 
}