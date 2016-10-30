/**
* File Name   :    TaskTriggerHandler.cls
* Description :    methods called from Task trigger
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 13/04/2015 Liza Romanenko	Initial version (TNT-2697)
*
*/
public with sharing class TaskTriggerHandler {
	// HANDLERS
	
	public static void onBeforeInsertHandler(List<Task> triggerNew)
	{
		calculateSLAInBussinessHours(triggerNew);
	}
	
	public static void onBeforeUpdateHandler(List<Task> triggerNew)
	{
		calculateSLAInBussinessHours(triggerNew);
	}
	
	// METHODS
	
	private static void calculateSLAInBussinessHours(List<Task> newTasks){
		
		for(Task t : newTasks){
			// When should we calculate activity age
			if((t.Action_Subtype__c == ConstantUtil.PLVAL_TASK_ACTION_SUBTYPE_FIRST_CUSTOMER_CONTACT 
						|| t.Action_Subtype__c == ConstantUtil.PLVAL_TASK_ACTION_SUBTYPE_CUSTOMER_CONTACT) 
						&& t.SLA_Deadline__c != null && t.End_Time__c != null){
				
				t.SLA_Minutes_in_Business_Hours__c = TimeUtil.calculateMinutesInBusinessHours(t.Start_Time__c, t.End_Time__c);
			}
		}
		
	}

}