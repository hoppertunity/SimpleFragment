trigger AgentSummaryTrigger on NVMStatsSF__NVM_Agent_Summary__c (before insert, before update) { 

    //A Comment 22
    NVMStatsSF__NVM_Agent_Summary__c[] agentSummaries = Trigger.new; 
    TNTUtility.updateAgentSummaryOwner(agentSummaries);
    TaggedState.applyCustomStates(agentSummaries); 
}