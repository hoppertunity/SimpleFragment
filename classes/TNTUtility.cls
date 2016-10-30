public class TNTUtility {
    
    public static void updateCallSummaryOwner(NVMStatsSF__NVM_Call_Summary__c[] callSummaries) {
        for (NVMStatsSF__NVM_Call_Summary__c callSummary: callSummaries) {
            if (callSummary.NVMStatsSF__Agent__c != null) {
                callSummary.OwnerId = callSummary.NVMStatsSF__Agent__c;
            }
        }
    }
    
    public static void updateAgentSummaryOwner(NVMStatsSF__NVM_Agent_Summary__c[] agentSummaries) {
        for (NVMStatsSF__NVM_Agent_Summary__c agentSum: agentSummaries) {
            if (agentSum.NVMStatsSF__Agent__c != null) {
                agentSum.OwnerId = agentSum.NVMStatsSF__Agent__c;
            }
        }
    }
    
}