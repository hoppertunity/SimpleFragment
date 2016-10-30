trigger CaseTrigger on Case (after insert, after update, before insert, before update) {
	
	if(trigger.isBefore && trigger.isInsert)
	{
		CaseTriggerHandler.onBeforeInsertHandler(trigger.new);
	}
	
	if(trigger.isAfter && trigger.isInsert)
	{
		CaseTriggerHandler.onAfterInsertHandler(trigger.new, trigger.newMap);
	}
	
	if(trigger.isAfter && trigger.isUpdate)
	{
		CaseTriggerHandler.onAfterUpdateHandler(trigger.new, trigger.newMap, trigger.oldMap);
	}
	
	if(trigger.isBefore && trigger.isUpdate)
	{
		CaseTriggerHandler.onBeforeUpdateHandler(trigger.new, trigger.oldMap);
	}

}