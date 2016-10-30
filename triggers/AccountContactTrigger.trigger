trigger AccountContactTrigger on Account_Contact__c (after insert) {
	
	if(trigger.isAfter && trigger.isInsert)
	{
		AccountContactTriggerHandler.onAfterInsertHandler(trigger.new);
	}

}