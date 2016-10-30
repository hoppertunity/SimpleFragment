trigger BookingLineItemTrigger on Booking_Line_Item__c (after delete, after insert, after update) {
	
	if(trigger.isAfter && trigger.isInsert)
	{
		BookingLineItemTriggerHelper.onAfterInsertHandler(trigger.new);
	}
	
	if(trigger.isAfter && trigger.isUpdate)
	{
		BookingLineItemTriggerHelper.onAfterUpdateHandler(trigger.new, trigger.oldMap);
	}
	
	if(trigger.isAfter && trigger.isDelete)
	{
		BookingLineItemTriggerHelper.onAfterDeleteHandler(trigger.old);
	}

}