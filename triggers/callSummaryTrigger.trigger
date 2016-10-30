trigger callSummaryTrigger on NVMStatsSF__NVM_Call_Summary__c (before update, before insert) {
    NVMStatsSF__NVM_Call_Summary__c[] callSummaries = Trigger.new; 
    TNTUtility.updateCallSummaryOwner(callSummaries);
}