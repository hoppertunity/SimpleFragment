trigger CS_ClaimsTrigger on CS_Claims__c (before insert, after insert, before update, after update) {
	
	if(trigger.isBefore && trigger.isInsert)
	{
		CS_ClaimsTriggerHandler.onBeforeInsertHandler(trigger.new);
	}
	
	if(trigger.isAfter && trigger.isInsert)
	{
		CS_ClaimsTriggerHandler.onAfterInsertHandler(trigger.new);
	}
	
	if(trigger.isAfter && trigger.isUpdate)
	{
		CS_ClaimsTriggerHandler.onAfterUpdateHandler(trigger.new, trigger.oldMap);
	}
	
	if(trigger.isBefore && trigger.isUpdate)
	{
		CS_ClaimsTriggerHandler.onBeforeUpdateHandler(trigger.new, trigger.oldMap);
	}
}