@IsTest
public class TestTaggedCustomState {
    static testMethod void insertNewAgentSummary() {
         
        List<NVMStatsSF__NVM_Agent_Summary__c> summaryToCreate = new List<NVMStatsSF__NVM_Agent_Summary__c>();  
        //Populate fields
         
        //Insert 5 with Custom States
        for (Integer i = 0; i < 5; i++) {
            NVMStatsSF__NVM_Agent_Summary__c s = new NVMStatsSF__NVM_Agent_Summary__c();
            String TEST_STRING = '40385Custom State 320:20|40385Custom State 321:21|40385Custom State 322:22|40385Custom State 323:23|40385Custom State 324:24|40385Custom State 305:20';
            s.NVMStatsSF__Key_Event_String__c = TEST_STRING;
            s.NVMStatsSF__dateAgentId__c = '201507061006' + i;
            s.NVMStatsSF__AgentID__c = '1006' + i;
            summaryToCreate.add(s);
        }
        try {
            //Insert the record
            System.debug('summaryToCreate is ' + summaryToCreate.size());
            insert summaryToCreate;
             
        } catch (DmlException e) {
            //   
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here
                 
                System.debug(e.getDmlMessage(i));
            }
        }
         
        //Check all records were inserted
        Integer i = 0;
        for (NVMStatsSF__NVM_Agent_Summary__c tmp : [SELECT Comfort_Break__c, Custom_State_1__c, Custom_State_2__c, Custom_State_3__c, Custom_State_4__c, Custom_State_5__c, Custom_State_6__c, CreatedDate FROM NVMStatsSF__NVM_Agent_Summary__c ORDER By CreatedDate DESC]) {
            i++;
            System.debug(i);
        }
        System.debug('Records returned = ' + i);
        System.AssertEquals(5, i);
         
        List<NVMStatsSF__NVM_Agent_Summary__c> summaryToCreate2 = new List<NVMStatsSF__NVM_Agent_Summary__c>();  
         
        //Insert 5 without any Custom or Minor
        for (Integer j = 0; j < 5; j++) {
            NVMStatsSF__NVM_Agent_Summary__c m = new NVMStatsSF__NVM_Agent_Summary__c();
            String TEST_STRING = '123123123 | 2342 34234 234 | 329472347234 | 53344Training 320:20';
            m.NVMStatsSF__Key_Event_String__c = TEST_STRING;
            m.NVMStatsSF__dateAgentId__c = '201507061006' + j;
            m.NVMStatsSF__AgentID__c = '1006' + j;
            summaryToCreate2.add(m);
        }
        //5 with Custom States
        for (Integer h = 0; h < 5; h++) {
            NVMStatsSF__NVM_Agent_Summary__c m = new NVMStatsSF__NVM_Agent_Summary__c();
            String TEST_STRING = '123123123 | 2342 34234 234 | 329472347234 | 53344Custom State 320:20 | 53344Comfort Break 320:20';
            m.NVMStatsSF__Key_Event_String__c = TEST_STRING;
            m.NVMStatsSF__dateAgentId__c = '201507061006' + h;
            m.NVMStatsSF__AgentID__c = '1006' + h;
            summaryToCreate2.add(m);
        } 
         
        try {
            //Insert the record
            System.debug('summaryToCreate2 is ' + summaryToCreate2.size());
            insert summaryToCreate2;
             
        } catch (DmlException e) {
            //   
            for (Integer j = 0; j < e.getNumDml(); j++) {
                // Process exception here
                 
                System.debug(e.getDmlMessage(j));
            }
        }
         
        //Check all records were inserted
        Integer j = 0;
        for (NVMStatsSF__NVM_Agent_Summary__c tmp2 : [SELECT Comfort_Break__c, Custom_State_1__c, Custom_State_2__c, Custom_State_3__c, Custom_State_4__c, Custom_State_5__c, Custom_State_6__c, CreatedDate FROM NVMStatsSF__NVM_Agent_Summary__c WHERE Custom_State_1__c = 20 ORDER By CreatedDate DESC]) {
            j++;
            System.debug(i);
        }
        System.debug('Records returned = ' + j);
        System.AssertEquals(5, j);      
    } //end of method
     
     
} //end of test class