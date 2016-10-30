trigger BookingTrigger on Booking__c (after insert, after update, before insert, before update) {
	
	if(trigger.isBefore && trigger.isInsert)
	{
		BookingTriggerHandler.onBeforeInsertHandler(trigger.new);
	}
	
	if(trigger.isAfter && trigger.isInsert)
	{
		BookingTriggerHandler.onAfterInsertHandler(trigger.new);
	}
	
	if(trigger.isAfter && trigger.isUpdate)
	{
		BookingTriggerHandler.onAfterUpdateHandler(trigger.new, trigger.oldMap);
	}
	
	if(trigger.isBefore && trigger.isUpdate)
	{
		BookingTriggerHandler.onBeforeUpdateHandler(trigger.new, trigger.oldMap);
	}

}