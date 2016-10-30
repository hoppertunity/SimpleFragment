/**
* File Name   :    CaseTriggerHandler.cls
* Description :    methods called from Case trigger
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 03/07/2014 Klea Kolaric   Initial version
* 0.2 07/07/2014 James Melville Added changeOwner method TNT-483
* 0.3 21/07/2014 Klea Kolaric   added assignEscalatedCases() method TNT-455
* 0.4 05/08/2014 Liza Romanenko added assignMajorAccountCases() method TNT-1314
* 0.5 15/08/2014 Liza Romanenko added updateCaseTrackingHistory() method TNT-490,TNT-491,TNT-493
* 0.6 20/08/2014 Liza Romanenko added updateOwnerForCallMeBackTasks() method TNT-1428
* 0.7 10/09/2014 James Melville Removed changeOwner method TNT-1603
* 0.8 25/09/2014 Klea Kolaric   TNT-1911
* 0.9 15/01/2015 Mehdi Rahman   TNT-2448
* 10.0 19/01/2016 Darryl Hopper Amended depotQueueAssignment() method for Sprint 12 - ETA/HCP/Redelivery 
*/
public without sharing class CaseTriggerHandler {
    
    // Boolean to control recursion
    public static Boolean isFirstRun = true;
    
    //public static Boolean assignedEscalatedOwner = false;   // prevent clash between owner assignment - execute only once
    private static String majourAccountQueueId = getMajorAccountsQueueId(ConstantUtil.MAJOR_ACCOUNTS_QUEUE);
    
    // HANDLERS
    
    public static void onBeforeInsertHandler(List<Case> triggerNew)
    {
        populate24HDeadline(triggerNew);
        //assignMajorAccountCases(triggerNew);
        assignCases(triggerNew, null);
    }
    
    public static void onAfterInsertHandler(List<Case> triggerNew, Map<Id,Case> triggerNewMap)
    {
        createReminderTask(triggerNew,null);
        updateCaseTrackingHistory(triggerNewMap, null);
    }
    
    public static void onAfterUpdateHandler(List<Case> triggerNew, Map<Id,Case> triggerNewMap, Map<Id,Case> triggerOldMap)
    {
        updateOwnerForCallMeBackTasks(triggerNew, triggerOldMap);
        createReminderTask(triggerNew, triggerOldMap);
        updateCaseTrackingHistory(triggerNewMap, triggerOldMap);
    }

    public static void onBeforeUpdateHandler(List<Case> triggerNew, Map<Id,Case> triggerOldMap)
    {
        //assignMajorAccountCases(triggerNew);
        assignCases(triggerNew, triggerOldMap);
    }
    
    // METHODS
    
    public static List<Task> createReminderTask(List<Case> triggerNew, Map<Id,Case> triggerOldMap)
    {
        if(!isFirstRun){
            return new List<Task>();
        }
        Boolean isInsert = triggerOldMap == null;
        
        RecordType actionTask = [Select Id from RecordType where sObjectType =: 'Task' and Name = 'Action' limit 1]; //JMV
        
        Map<Id, Case> casesWithTasks;
        if(!isInsert){
            casesWithTasks = new Map<Id, Case>([SELECT Id, (SELECT Id FROM Tasks WHERE RecordTypeId = : actionTask.Id AND subject = : ConstantUtil.TASK_SUBJECT_CALL_CLIENT_BACK) 
                            FROM Case WHERE Id IN : triggerOldMap.keyset()]);
        }
        
        List<Task> tsks = new List<Task>();
        for(Case c : triggerNew)
        {
            // if new value not blank and if changed from previous selection
            if(String.isNotBlank(c.Call_me_back__c) && (isInsert || triggerOldMap.get(c.Id).Call_me_back__c != c.Call_me_back__c))
            {
                Task tsk = new Task();
                tsk.WhatId = c.Id;
                tsk.WhoId = c.ContactId;
                tsk.subject = ConstantUtil.TASK_SUBJECT_CALL_CLIENT_BACK;
                tsk.Status = 'Not Started';
                tsk.Priority = 'Normal';
                tsk.RecordTypeId = actionTask.Id; //JMV
                
                // calculate reminder time
                String cmb = c.Call_me_back__c.split(' ').get(0);   // it's either 'Next Working Day' or 'N hours'
                tsk.ReminderDateTime = cmb == 'Next' ? 
                                        TimeUtil.getNextWorkingDay(Datetime.now()) : getSLATime(Integer.valueOf(cmb),null); //DH Commented 30/09 Datetime.now().addHours(Integer.valueOf(cmb));
                                        
                tsk.ActivityDate = tsk.ReminderDateTime.date();
                tsk.SLA_Deadline__c = tsk.ReminderDateTime;
                
                TimeUtil.getWorkingDayResumeDT(tsk.ReminderDateTime);//DH Modified 24/09tsk.ReminderDateTime;
                
                //*****here****
                
                tsk.ReminderDateTime = tsk.ReminderDateTime.addMinutes(-15);    // TNT-2051 reminder 15 minutes before
                tsk.IsReminderSet = true;
                //tsk.Description = 'Call customer back at : ' + tsk.ReminderDateTime.format();
                tsk.OwnerId = UserInfo.getUserId();
                tsk.Action_Type__c = ConstantUtil.PLVAL_TASK_ACTION_TYPE_CONTACT_ACTIONS;
                tsk.Action_Subtype__c = isInsert || casesWithTasks.get(c.Id).Tasks == null || casesWithTasks.get(c.Id).Tasks.isEmpty() ? 
                    ConstantUtil.PLVAL_TASK_ACTION_SUBTYPE_FIRST_CUSTOMER_CONTACT : ConstantUtil.PLVAL_TASK_ACTION_SUBTYPE_CUSTOMER_CONTACT;
                
                tsks.add(tsk);
            }
        }
        insert tsks;
        isFirstRun = false;
        return tsks;
    }
    
    public static DateTime getSLATime(Integer dt, DateTime lt)
    {
        Integer CallBack = dt;
        DateTime logTime = lt != null ? lt:DateTime.Now();
        DateTime effectiveTIme = TimeUtil.getWorkingDayResumeDT(logTime);

        DateTime SLA; 
        
        If(CallBack == 24)
        {
           SLA = TimeUtil.getNextWorkingDay(TimeUtil.getWorkingDayResumeDT(effectiveTIme));
        } 
        else if(CallBack == 48)
        {
            SLA = TimeUtil.getNextWorkingDay(TimeUtil.getNextWorkingDay(TimeUtil.getWorkingDayResumeDT(effectiveTIme)));
        }
        else
        {
            if(logTime < effectiveTIme)//Before start time so use effectTime
            {
                SLA = effectiveTIme.addHours(Callback);
        //if(getWorkingDayResumeDT(SLA) != SLA)//Must have move to next working day so need to calculate hours to add
        //{
           //SLA = TimeUtil.getWorkingDayResumeDT(SLA).AddHOurs(TimeUtil.getDayEndTime(effectiveTime.date()) - (effectiveTime.addHours(CallBack)) * 1000 * 60 * 60);
        //}
            }
            else if( effectiveTIme.addHours(Callback) != TimeUtil.getWorkingDayResumeDT(effectiveTIme.addHours(Callback)))
            {
                Integer difference = effectiveTime.addHours(Callback).hour() - TimeUtil.getDayEndTime(effectiveTime.Date()).hour();         
                SLA = (TimeUtil.getNextWorkingDayStartDT(effectiveTIme.addHours(Callback).Date()).addHours(difference)).addMinutes(effectiveTime.Minute());
            }
            else
            {
                SLA = LogTime.addHOurs(callBack);
            }

        
        }
        return SLA;
    }
    
    public static void populate24HDeadline(List<Case> triggerNew)
    {
        for(Case c : triggerNew)
        {
            Datetime openTime = Datetime.now();
            openTime = Datetime.newInstance(openTime.date(),Time.newInstance(openTime.hour(),openTime.minute(),0,0));   // round up to minute
            c.Twentyfour_Hour_Deadline__c = TimeUtil.getNextWorkingDay(TimeUtil.getWorkingDayResumeDT(openTime));
        }
    }
    
    
    
    /*public static void assignEscalatedCases(List<Case> triggerNew, Map<Id,Case> triggerOldMap)
    {
        if(assignedEscalatedOwner)
        {
            return;
        }
        
        Set<Id> reassignCases = new Set<Id>();  // cases with all related account data
        
        for(Case c : triggerNew)
        {
            if(c.IsEscalated && !triggerOldMap.get(c.Id).IsEscalated && String.isNotBlank(c.Exception__c))
            {
                reassignCases.add(c.Id);
            }
        }
        
        if(!reassignCases.isEmpty())
        {
            depotQueueAssignment(reassignCases,triggerNew);
        }
        assignedEscalatedOwner = true;
    }*/
    
    // we're expecting this method to be triggered by an assignment rule
    public static void assignCases(List<Case> triggerNew, Map<Id,Case> triggerOldMap)
    {
        Set<Id> reassignCases = new Set<Id>();  // cases with all related account data
        
        for(Case c : triggerNew)
        {
            if(c.OwnerId == ConstantUtil.UNASSIGNED_QUEUE_ID 
                && (triggerOldMap == null || triggerOldMap.get(c.Id).OwnerId != ConstantUtil.UNASSIGNED_QUEUE_ID))
            {
                reassignCases.add(c.Id);
            }
            else
            {
                if(c.OwnerId == majourAccountQueueId 
                    && (triggerOldMap == null || triggerOldMap.get(c.Id).OwnerId != majourAccountQueueId))
                {
                    reassignCases.add(c.Id);
                }
            }
        }
        
        if(!reassignCases.isEmpty())
        {
            depotQueueAssignment(reassignCases,triggerNew);
        }
    }
    
    public static void depotQueueAssignment(Set<Id> reassignCases, List<Case> triggerNew)
    {
        Map<Id,Case> fullCases = new Map<Id,Case>([select Exception__c, AccountId, Type, Case_Types_Level_2__c,//DH added Type, Case_Types_Level_2__c 19/01/2016
                                                    Account.Major_Account__c, Account.Assigned_Agent__c, 
                                                    Account.Collection_Queue__c, Account.Delivery_Queue__c,
                                                    Collection_Depot__c, Collection_Depot__r.Collection_Queue__c,
                                                    Delivery_Depot__c, Delivery_Depot__r.Delivery_Queue__c
                                                    from Case where id in :reassignCases]);
        // find queues
        Set<String> queueNames = new Set<String>();
        for(Case c : fullCases.values())
        {
            String ex = String.isBlank(c.Exception__c) ? ConstantUtil.PLVAL_CASE_EXCEPTION_DELIVERY : c.Exception__c;
            if(c.AccountId != null)
            {
                queueNames.add(c.Account.Collection_Queue__c);
                queueNames.add(c.Account.Delivery_Queue__c);
            }
            if(ex == ConstantUtil.PLVAL_CASE_EXCEPTION_COLLECTION && c.Collection_Depot__c != null)
            {
                queueNames.add(c.Collection_Depot__r.Collection_Queue__c);
            }
            if(ex == ConstantUtil.PLVAL_CASE_EXCEPTION_DELIVERY && c.Delivery_Depot__c != null)
            {
                queueNames.add(c.Delivery_Depot__r.Delivery_Queue__c);
            }
        }
        
        Map<String,Group> queues = getQueueNameMap(queueNames);
        
        for(Case originalCase : triggerNew)
        {
            String ex = String.isBlank(originalCase.Exception__c) 
                ? ConstantUtil.PLVAL_CASE_EXCEPTION_DELIVERY : originalCase.Exception__c;
            
            if(fullCases.containsKey(originalCase.Id))  // do check to avoid null pointer exceptions
            {
                Case c = fullCases.get(originalCase.Id);
                if(ex == ConstantUtil.PLVAL_CASE_EXCEPTION_COLLECTION)
                {
                    if(c.AccountId != null && String.isNotBlank(c.Account.Collection_Queue__c))
                    {
                        originalCase.OwnerId = queues.get(c.Account.Collection_Queue__c).Id;
                    }
                    else
                    {
                        if(c.AccountId != null && c.Account.Major_Account__c && c.Account.Assigned_Agent__c != null)
                        {
                            originalCase.OwnerId = c.Account.Assigned_Agent__c;
                        }
                        else
                        {
                            //DH ADded 19/01/2015
                            if(
                                (c.Type == 'Track' && (c.Case_Types_Level_2__c == 'Late Delivery' || c.Case_Types_Level_2__c == 'Paperwork Request'))
                                //|| Comment out as per Kish 02/02/2016
                                //(c.Type == 'General Enquiry' && c.Case_Types_Level_2__c == 'Redelivery Request')
                            )
                            {
                              originalCase.OwnerId = ConstantUtil.MAURITIUS_QUEUE_ID;
                            }
                            //*******************
                            //DH added else to if clause 19/01/2016
                            else if(c.Collection_Depot__c != null && String.isNotBlank(c.Collection_Depot__r.Collection_Queue__c))
                            {
                                originalCase.OwnerId = queues.get(c.Collection_Depot__r.Collection_Queue__c).Id;
                            }
                        }
                    }
                }
                if(ex == ConstantUtil.PLVAL_CASE_EXCEPTION_DELIVERY)
                {
                    if(c.AccountId != null && String.isNotBlank(c.Account.Delivery_Queue__c))
                    {
                        originalCase.OwnerId = queues.get(c.Account.Delivery_Queue__c).Id;
                    }
                    else
                    {
                        if(c.AccountId != null && c.Account.Major_Account__c && c.Account.Assigned_Agent__c != null)
                        {
                            originalCase.OwnerId = c.Account.Assigned_Agent__c;
                        }
                        else
                        {
                            //DH ADded 19/01/2015
                            if(
                                (c.Type == 'Track' && (c.Case_Types_Level_2__c == 'Late Delivery' || c.Case_Types_Level_2__c == 'Paperwork Request'))
                                //|| 
                                //(c.Type == 'General Enquiry' && c.Case_Types_Level_2__c == 'Redelivery Request')
                            )
                            {
                              originalCase.OwnerId = ConstantUtil.MAURITIUS_QUEUE_ID;
                            }
                            //*******************
                            //DH added else to if clause 19/01/2016
                            else if(c.Delivery_Depot__c != null && String.isNotBlank(c.Delivery_Depot__r.Delivery_Queue__c))
                            {
                                originalCase.OwnerId = queues.get(c.Delivery_Depot__r.Delivery_Queue__c).Id;
                            }
                        }
                    }
                }
            }
        }
    }
    
    public static Map<String,Group> getQueueNameMap(Set<String> queueNames)
    {
        Map<String,Group> queues = new Map<String,Group>();
        for(Group q : [select id, DeveloperName from Group where Type = 'Queue' and DeveloperName in :queueNames])
        {
            queues.put(q.DeveloperName,q);
        }
        return queues;
    }
    
    /*private static void assignMajorAccountCases(List<Case> cases){
        String majourAccountQueueId = getMajorAccountsQueueId(ConstantUtil.MAJOR_ACCOUNTS_QUEUE);
        //select Account
        Set<Id> accountIds = new Set<Id>();
        List<Case> casesToReassign = new List<Case>();
        for(Case c : cases){
            if(c.OwnerId == majourAccountQueueId && !c.Case_Back_to_Queue_MA__c){
                casesToReassign.add(c);
                accountIds.add(c.AccountId);
            }
        }
        
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Major_Account__c, Assigned_Agent__c 
                                                        FROM Account WHERE Id IN : accountIds]);
                                                        
        for(Case c : casesToReassign){
            Account a = accounts.get(c.AccountId);
            if(a != null && a.Major_Account__c && a.Assigned_Agent__c != null){
                c.OwnerId = a.Assigned_Agent__c;
            }
        }
    }*/
    
    private static String getMajorAccountsQueueId(String name){
        Group res = [SELECT Id FROM Group WHERE DeveloperName = : name LIMIT 1];
        
        return res.Id;
    }
    
    
    //Case Tracking History  
    private static void updateCaseTrackingHistory(Map<Id,Case> triggerNewMap, Map<Id,Case> triggerOldMap){
        List<Case_Tracking_History__c> caseHistory = new List<Case_Tracking_History__c>();
        
        Map<Id, Case> casesWithOwners = new Map<Id, Case>([SELECT OwnerId, Owner.Name FROM Case WHERE ID IN : triggerNewMap.keyset()]);
        
        Map<Id, Map<String, Case_Tracking_History__c>> openCaseHistory = new Map<Id, Map<String, Case_Tracking_History__c>>();
        if(triggerOldMap != null){
            for(Case_Tracking_History__c cth : [SELECT Case__c, Category__c, Main_Field_Current_Value__c, 
                                                    Secondary_Field_Current_Value__c, Finished_on__c 
                                                FROM Case_Tracking_History__c
                                                WHERE Finished_on__c = null AND Case__c IN : triggerOldMap.keyset()]){
                if(!openCaseHistory.containsKey(cth.Case__c)){
                    openCaseHistory.put(cth.Case__c, new Map<String, Case_Tracking_History__c>());
                }
                
                openCaseHistory.get(cth.Case__c).put(cth.Category__c, cth);
            }
        }
        
        for(Case c : triggerNewMap.values()){
            for(String cat : categoryToFields.keyset()){
                Case_Tracking_History__c oldCth = openCaseHistory.isEmpty() || !openCaseHistory.containsKey(c.Id) 
                                                    ? null : openCaseHistory.get(c.Id).get(cat);
                
                caseHistory.addAll(updateCaseTrackingHistoryObj(cat, c, oldCth, casesWithOwners));
            }
        }
        
        if(!caseHistory.isEmpty()){
            upsert caseHistory;
        }
    }
    
    private static List<Case_Tracking_History__c> updateCaseTrackingHistoryObj(String categ, Case newCase, Case_Tracking_History__c oldCth, Map<Id, Case> casesWithOwners){
        List<Case_Tracking_History__c> res = new List<Case_Tracking_History__c>();
        Case_Tracking_History__c cth = null;
        String mFieldName = categoryToFields.get(categ)[0];
        String sFieldName = categoryToFields.get(categ).size() > 1 ? categoryToFields.get(categ)[1] : null;
        
        String mFieldVal = categ == ConstantUtil.PLVAL_CTH_CATEGORY_OWNER ? (casesWithOwners.get(newCase.Id).Owner.Name ): String.ValueOf(newCase.get(mFieldName));
        String sFieldVal = sFieldName != null ? String.ValueOf(newCase.get(sFieldName)) : null;
        
        if(oldCth == null || oldCth.Main_Field_Current_Value__c != mFieldVal || oldCth.Secondary_Field_Current_Value__c != sFieldVal){ 
        
            cth = new Case_Tracking_History__c();
            
            cth.Case__c = newCase.Id;
            cth.Category__c = categ;
            cth.Started_On__c = DateTime.now();
            cth.Finished_on__c = newCase.isClosed ? DateTime.now() : null;
            if(oldCth != null){
                oldCth.Finished_on__c = DateTime.now();
                res.add(oldCth);
            }
            
            cth.Main_Field__c = mFieldName;
            cth.Main_Field_Current_Value__c = mFieldVal;
            cth.Main_Field_Prior_Value__c = oldCth != null ? oldCth.Main_Field_Current_Value__c : null;
            
            if(categoryToFields.get(categ).size() > 1){
                cth.Secondary_Field__c = sFieldName;
                cth.Secondary_Field_Current_Value__c = sFieldVal;
                cth.Secondary_Field_Prior_Value__c = oldCth != null ? oldCth.Secondary_Field_Current_Value__c : null;
            }
            
            cth.User__c = UserInfo.getUserId();
            
            //check if waiting
            if((categ == ConstantUtil.PLVAL_CTH_CATEGORY_APPROVAL && mFieldVal == String.valueOf(true)) || (categ == ConstantUtil.PLVAL_CTH_CATEGORY_STATUS && mFieldVal == ConstantUtil.PLVAL_CASE_STATUS_WAITING_FOR_CUSTOMER) || 
                        (categ == ConstantUtil.PLVAL_CTH_CATEGORY_OWNER && newCase.OwnerId.getSObjectType() != Group.sObjectType)){
                cth.Case_Waiting__c = true;
            }
            
            res.add(cth);
        
        } else if(oldCth != null && newCase.isClosed){
            oldCth.Finished_on__c = DateTime.now();
            res.add(oldCth);
        }
        
        
        return res;
    }
    
    private static Map<String, List<String>> categoryToFields = new Map<String, List<String>>{
            ConstantUtil.PLVAL_CTH_CATEGORY_OWNER => new List<String>{'Owner'},
            ConstantUtil.PLVAL_CTH_CATEGORY_TYPE => new List<String>{'Type', 'Case_Types_Level_2__c'},
            ConstantUtil.PLVAL_CTH_CATEGORY_REASON => new List<String>{'Reason'},
            ConstantUtil.PLVAL_CTH_CATEGORY_STATUS => new List<String>{'Status'},
            ConstantUtil.PLVAL_CTH_CATEGORY_PRIORITY => new List<String>{'Priority', 'Priority_Change_Explanation__c'},
            ConstantUtil.PLVAL_CTH_CATEGORY_APPROVAL => new List<String>{'In_Approval__c'}};
            
    
    // Change ownwer for call me back tasks
    private static void updateOwnerForCallMeBackTasks(List<Case> cases, Map<Id,Case> triggerOldMap){
        Map<Id, Id> caseToOwnerMap = new Map<Id, Id>();
        for(Case c : cases){
            if(c.OwnerId != triggerOldMap.get(c.Id).OwnerId && c.OwnerId.getSObjectType() != Group.sObjectType){
                caseToOwnerMap.put(c.Id, c.OwnerId);
            }
        }
        
        if(!caseToOwnerMap.isEmpty()){
            List<Task> tasksToUpdate = [SELECT WhatId, Subject, OwnerId, IsClosed FROM Task 
                            WHERE WhatId IN : caseToOwnerMap.keyset() AND IsClosed = false AND Subject = : ConstantUtil.TASK_SUBJECT_CALL_CLIENT_BACK];
            for(Task t : tasksToUpdate){
                t.OwnerId = caseToOwnerMap.get(t.WhatId);
            }
            
            if(!tasksToUpdate.isEmpty()){
                update tasksToUpdate;
            }
        }
    }
}