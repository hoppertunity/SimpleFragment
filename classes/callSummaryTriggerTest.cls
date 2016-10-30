@IsTest
public class callSummaryTriggerTest {
    static testmethod void CheckCallSummaryTrigger() 
    {
        User u = [select id from user where name='NVM User' Limit 1];
        NVMStatsSF__NVM_Call_Summary__c callSummary = new NVMStatsSF__NVM_Call_Summary__c (
			NVMStatsSF__Agent__c = u.Id
        );
        insert callSummary;
        callSummary = [select NVMStatsSF__Agent__c, OwnerId from NVMStatsSF__NVM_Call_Summary__c where Id = :callSummary.Id Limit 1];
        System.assertEquals(callSummary.NVMStatsSF__Agent__c, callSummary.OwnerId);
        delete callSummary;
    }
}