trigger ContactTrigger on Contact (before insert, after insert, after update) {
    
    //if(trigger.isBefore && trigger.isInsert)
  //  {
  //      ContactTriggerHelper.onBeforeInsertHandler(trigger.new);
  //  }
    
    if(trigger.isAfter && trigger.isInsert)
    {
        ContactTriggerHelper.onAfterInsertHandler(trigger.new);
    }
    
    if(trigger.isAfter && trigger.isUpdate)
    {
        ContactTriggerHelper.onAfterUpdateHandler(trigger.new, trigger.oldMap);
    }

}