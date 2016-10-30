/**
* File Name   :    ContactTriggerHelper.cls
* Description :    handler for contact trigger
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 21/07/2014 Klea Kolaric   Initial version (TNT-455)
* 0.2 21/08/2014 Liza Romanenko TNT-1334
*
*/
public with sharing class ContactTriggerHelper {
    
    // HANDLERS
       
    public static void onAfterInsertHandler(List<Contact> triggerNew)
    {
        updateAccountContactObj(triggerNew, null);
    }
    
    public static void onAfterUpdateHandler(List<Contact> triggerNew, Map<Id,Contact> triggerOldMap)
    {
        updateAccountContactObj(triggerNew, triggerOldMap);
    }
    
    // METHODS
    
    public static void updateAccountContactObj(List<Contact> contacts, Map<Id, Contact> oldContacts){
        Map<Id, Id> new_contactIdToAccountId = new Map<Id, Id>();
        Map<Id, Id> updated_contactIdToAccountId = new Map<Id, Id>();
        Map<String, Account_Contact__c> aIdcId_AccountContacts = new Map<String, Account_Contact__c>();
        List<Account_Contact__c> newAccountContacts = new List<Account_Contact__c>();
        
        for(Contact c : contacts){
            if(c.AccountId != null){
                if(oldContacts == null){
                    new_contactIdToAccountId.put(c.Id, c.AccountId);
                } else if(c.AccountId != oldContacts.get(c.Id).AccountId){
                    updated_contactIdToAccountId.put(c.Id, c.AccountId);
                }
            }
        }
        
        for(Account_Contact__c ac : [SELECT Account__c, Contact__c FROM Account_Contact__c 
                                    WHERE Contact__c IN : updated_contactIdToAccountId.keyset() AND Account__c IN : updated_contactIdToAccountId.values()]){
            String key = (String)ac.Account__c + (String)ac.Contact__c;
            aIdcId_AccountContacts.put(key, ac);
        }
        
        if(!new_contactIdToAccountId.isEmpty()){
            for(String cId : new_contactIdToAccountId.keyset()){
                Account_Contact__c ac = new Account_Contact__c();
                ac.Account__c = new_contactIdToAccountId.get(cId);
                ac.Contact__c = cId;
                newAccountContacts.add(ac);
            }
        }
        
        if(!updated_contactIdToAccountId.isEmpty()){
            for(String cId : updated_contactIdToAccountId.keyset()){
                String key = updated_contactIdToAccountId.get(cId) + cId;
                if(!aIdcId_AccountContacts.containsKey(key)){
                    Account_Contact__c ac = new Account_Contact__c();
                    ac.Account__c = updated_contactIdToAccountId.get(cId);
                    ac.Contact__c = cId;
                    newAccountContacts.add(ac);
                }
            }
        }
        
        if(!newAccountContacts.isEmpty()){
            insert newAccountContacts;
        }
    }
}