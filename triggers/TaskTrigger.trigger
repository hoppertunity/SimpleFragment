trigger TaskTrigger on Task (before insert, before update) {
	
	if(trigger.isBefore && trigger.isInsert)
	{
		TaskTriggerHandler.onBeforeInsertHandler(trigger.new);
	}
	if(trigger.isBefore && trigger.isUpdate)
	{
		TaskTriggerHandler.onBeforeUpdateHandler(trigger.new);
	}

}