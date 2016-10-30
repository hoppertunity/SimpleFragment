trigger AccountContactTrigger on Account_Contact__c (after insert) {
	
	//A comment
	if(trigger.isAfter && trigger.isInsert)
	{
		AccountContactTriggerHandler.onAfterInsertHandler(trigger.new);
	}

}