public class TaggedState {
    
    public static void applyCustomStates(NVMStatsSF__NVM_Agent_Summary__c[] agentSummaries) {
        
        final String CHKSTR_END_CHAR_REGEX = '\\|';        
        List<String> customStates = new List<String>();
        
        //Set up the CustomState variables
        String customState1 = 'Return to work 10 mins';
        String customState2 = 'Admin at workdesk';
        String customState3 = 'Admin Team Duties Walkaway';
        String customState4 = 'Computer Related Issues';
        String customState5 = 'Debrief with Supervisor';
        String customState6 = 'Helping advising Colleagues';
        //Set up MinorState variables
        String minorState1 = 'Comfort Break';
  
        
        for (NVMStatsSF__NVM_Agent_Summary__c b :agentSummaries){
            
            String keyString = b.NVMStatsSF__Key_Event_String__c;
            //No processing if the Key Events String is empty
            if (keyString != null ) {
            //We need to replace Custom State 320 etc with acual values
            b.NVMStatsSF__Key_Event_String__c = b.NVMStatsSF__Key_Event_String__c.replaceAll('Custom State 305', customState1);
            b.NVMStatsSF__Key_Event_String__c = b.NVMStatsSF__Key_Event_String__c.replaceAll('Custom State 320', customState2);
            b.NVMStatsSF__Key_Event_String__c = b.NVMStatsSF__Key_Event_String__c.replaceAll('Custom State 321', customState3);
            b.NVMStatsSF__Key_Event_String__c = b.NVMStatsSF__Key_Event_String__c.replaceAll('Custom State 322', customState4);
            b.NVMStatsSF__Key_Event_String__c = b.NVMStatsSF__Key_Event_String__c.replaceAll('Custom State 323', customState5);
            b.NVMStatsSF__Key_Event_String__c = b.NVMStatsSF__Key_Event_String__c.replaceAll('Custom State 324', customState6);
 
                
                //First lets check for each of the Custom States in the Key Event String:
                Boolean cState1 = keyString.contains(customState1);
                Boolean cState2 = keyString.contains(customState2);
                Boolean cState3 = keyString.contains(customState3);
                Boolean cState4 = keyString.contains(customState4);
                Boolean cState5 = keyString.contains(customState5);
                Boolean cState6 = keyString.contains(customState6);            
                //Then search for the standard values:
                Boolean mState1 = keyString.contains(minorState1); 
                
                //Blank the values on the Custom States if no matches
                if (!cState1) { b.Custom_State_1__c = 0; }
                if (!cState2) { b.Custom_State_2__c = 0; }
                if (!cState3) { b.Custom_State_3__c = 0; }
                if (!cState4) { b.Custom_State_4__c = 0; }
                if (!cState5) { b.Custom_State_5__c = 0; }
                if (!cState6) { b.Custom_State_6__c = 0; }
                //Blank values on Minor State fields    
                if (!mState1) { b.Comfort_Break__c = 0; }
                
                //After initial checks split the string by the pipe character          
                customStates = (''+b.NVMStatsSF__Key_Event_String__c).split(CHKSTR_END_CHAR_REGEX);
                String cs1tempValue;
                Integer cs1value;
                Integer cs1FinalValue;
                Integer cState1Value;
                
                String cs2tempValue;
                Integer cs2value;
                Integer cs2FinalValue;
                Integer cState2Value;
                
                String cs3tempValue;
                Integer cs3value;
                Integer cs3FinalValue;
                Integer cState3Value;
                
                String cs4tempValue;
                Integer cs4value;
                Integer cs4FinalValue;
                Integer cState4Value;
                
                String cs5tempValue;
                Integer cs5value;
                Integer cs5FinalValue;
                Integer cState5Value;
                
                String cs6tempValue;
                Integer cs6value;
                Integer cs6FinalValue;
                Integer cState6Value;
                
                String ms1tempValue;
                Integer ms1value;
                Integer ms1FinalValue;
                Integer mState1Value;
                
                
                for (Integer i = 0; i < customStates.size(); i++) {
                    //Inner loop addding up values
                    /* Start of each CustomState */ 
                    Boolean i1 = customStates[i].contains(customState1);
                    if (i1) {
                        cs1tempValue = customStates[i].right(5);
                        cs1tempValue = cs1tempValue.replaceAll('[^0-9.]', '');
                        cs1value = integer.valueOf(cs1tempValue);
                        system.debug('value is ' + cs1value + ' second value is ' + cs1FinalValue);
                        if (cs1FinalValue == null){
                            cs1FinalValue = cs1value;
                        } 
                        else if (cs1FinalValue != null) { 
                            cs1FinalValue = cs1FinalValue + cs1value;
                        }  
                    }
                    /* End of each CustomState */
                    
                    /* Start of each CustomState */ 
                    Boolean i2 = customStates[i].contains(customState2);
                    if (i2) {
                        cs2tempValue = customStates[i].right(5);
                        cs2tempValue = cs2tempValue.replaceAll('[^0-9.]', '');
                        cs2value = integer.valueOf(cs2tempValue);
                        system.debug('value is ' + cs2value + ' second value is ' + cs2FinalValue);
                        if (cs2FinalValue == null){
                            cs2FinalValue = cs2value;
                        } 
                        else if (cs2FinalValue != null) { 
                            cs2FinalValue = cs2FinalValue + cs2value;
                        }  
                    }
                    /* End of each CustomState */
                    
                    /* Start of each CustomState */ 
                    Boolean i3 = customStates[i].contains(customState3);
                    if (i3) {
                        cs3tempValue = customStates[i].right(5);
                        cs3tempValue = cs3tempValue.replaceAll('[^0-9.]', '');
                        cs3value = integer.valueOf(cs3tempValue);
                        system.debug('value is ' + cs3value + ' second value is ' + cs3FinalValue);
                        if (cs3FinalValue == null){
                            cs3FinalValue = cs3value;
                        } 
                        else if (cs3FinalValue != null) { 
                            cs3FinalValue = cs3FinalValue + cs3value;
                        }  
                    }
                    /* End of each CustomState */
                    
                    /* Start of each CustomState */ 
                    Boolean i4 = customStates[i].contains(customState4);
                    if (i4) {
                        cs4tempValue = customStates[i].right(5);
                        cs4tempValue = cs4tempValue.replaceAll('[^0-9.]', '');
                        cs4value = integer.valueOf(cs4tempValue);
                        system.debug('value is ' + cs4value + ' second value is ' + cs4FinalValue);
                        if (cs4FinalValue == null){
                            cs4FinalValue = cs4value;
                        } 
                        else if (cs4FinalValue != null) { 
                            cs4FinalValue = cs4FinalValue + cs4value;
                        }  
                    }
                    /* End of each CustomState */
                    
                    
                    /* Start of each CustomState */ 
                    Boolean i5 = customStates[i].contains(customState5);
                    if (i5) {
                        cs5tempValue = customStates[i].right(5);
                        cs5tempValue = cs5tempValue.replaceAll('[^0-9.]', '');
                        cs5value = integer.valueOf(cs5tempValue);
                        system.debug('value is ' + cs5value + ' second value is ' + cs5FinalValue);
                        if (cs5FinalValue == null){
                            cs5FinalValue = cs5value;
                        } 
                        else if (cs5FinalValue != null) { 
                            cs5FinalValue = cs5FinalValue + cs5value;
                        }  
                    }
                    /* End of each CustomState */
                    
                    
                    /* Start of each CustomState */ 
                    Boolean i6 = customStates[i].contains(customState6);
                    if (i6) {
                        cs6tempValue = customStates[i].right(5);
                        cs6tempValue = cs6tempValue.replaceAll('[^0-9.]', '');
                        cs6value = integer.valueOf(cs6tempValue);
                        system.debug('value is ' + cs6value + ' second value is ' + cs6FinalValue);
                        if (cs6FinalValue == null){
                            cs6FinalValue = cs6value;
                        } 
                        else if (cs6FinalValue != null) { 
                            cs6FinalValue = cs6FinalValue + cs6value;
                        }  
                    }
                    /* End of each CustomState */
                    
                    /* Start of each MinorState */ 
                    Boolean m1 = customStates[i].contains(minorState1);
                    if (m1) {
                        ms1tempValue = customStates[i].right(5);
                        ms1tempValue = ms1tempValue.replaceAll('[^0-9.]', '');
                        ms1value = integer.valueOf(ms1tempValue);
                        system.debug('value is ' + ms1value + ' second value is ' + ms1FinalValue);
                        if (ms1FinalValue == null){
                            ms1FinalValue = ms1value;
                        } 
                        else if (ms1FinalValue != null) { 
                            ms1FinalValue = ms1FinalValue + ms1value;
                        }  
                    }
                    /* End of each MinorState */
                    
                                        /* Start of each MinorState */ 

                } //end for loop
                
                //Time to set Custom State fields
                b.Custom_State_1__c = cs1FinalValue;
                b.Custom_State_2__c = cs2FinalValue;  
                b.Custom_State_3__c = cs3FinalValue;  
                b.Custom_State_4__c = cs4FinalValue;  
                b.Custom_State_5__c = cs5FinalValue;  
                b.Custom_State_6__c = cs6FinalValue;  
                //Minor State fields
                b.Comfort_Break__c = ms1FinalValue;
            }
            
            
            
        } // end of loop
        
        
        
    }  
}