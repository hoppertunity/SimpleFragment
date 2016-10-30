<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Priority_Change_Accepted</fullName>
        <description>Priority Change Accepted</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Internal_Templates/Priority_Change_Accepted</template>
    </alerts>
    <alerts>
        <fullName>Priority_Change_Rejected</fullName>
        <description>Priority Change Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Internal_Templates/Priority_Change_Rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>Case_Record_Type_to_Standard_Support</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Standard_Support_Process</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Case Record Type = Standard Support</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Case_Record_Type_to_Claim</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Claim_Case_Support_Process</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change Case Record Type to Claim</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Change_Priority</fullName>
        <field>Change_Priority__c</field>
        <literalValue>0</literalValue>
        <name>Clear Change Priority</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Escalate_Case</fullName>
        <field>Escalate_Case__c</field>
        <literalValue>0</literalValue>
        <name>Clear Escalate Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Priority_Change_Accepted</fullName>
        <field>Priority_Change_Accepted__c</field>
        <literalValue>0</literalValue>
        <name>Clear Priority Change Accepted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Enter_Approval</fullName>
        <description>Field update to check when the case enters the approval</description>
        <field>In_Approval__c</field>
        <literalValue>1</literalValue>
        <name>Enter Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Escalated_Upgraded_to_True</fullName>
        <field>Escalated_Upgraded_Audit_Trail__c</field>
        <literalValue>1</literalValue>
        <name>Escalated /Upgraded to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Exit_Approval</fullName>
        <description>Field update to check when the case exists the approval</description>
        <field>In_Approval__c</field>
        <literalValue>0</literalValue>
        <name>Exit Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Monitor_Until_Audit_History_Set</fullName>
        <field>Monitor_Until_Audit_History__c</field>
        <formula>Monitor_Until__c</formula>
        <name>Monitor Until Audit History Set</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Monitored_At_Field_Set</fullName>
        <description>Sets this field when the Monitor Until Field is Blanked Out</description>
        <field>Monitored_At__c</field>
        <formula>NOW()</formula>
        <name>Monitored At Field Set</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Priority_Change_Accepted</fullName>
        <description>This update will prevent to go to Step 2</description>
        <field>Priority_Change_Accepted__c</field>
        <literalValue>1</literalValue>
        <name>Priority Change Accepted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Proactive_Checkbox_Ticked</fullName>
        <field>Proactive_Case__c</field>
        <literalValue>1</literalValue>
        <name>Proactive Checkbox Ticked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reopened_Audit_Trail_to_True</fullName>
        <description>Sets the field to True</description>
        <field>Reopened_Audit_Trail__c</field>
        <literalValue>1</literalValue>
        <name>Reopened Audit Trail to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reviewed_by_Team_Leader</fullName>
        <description>When the source origin for a case is not a phone call, it is routed to the Non-Phone Origin Queue. A Team Leader must review the case to save the relevant Case Type and Case Priority. Then they should check this field to route the case to Unassigned queue</description>
        <field>OwnerId</field>
        <lookupValue>Unassigned</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Reviewed by Team Leader to queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reviewed_by_Team_Leader_Checkbox_checked</fullName>
        <description>When the source origin for a case is not a phone call, it is routed to the Non-Phone Origin Queue. A Team Leader must review the case to save the relevant Case Type and Case Priority. Then they should check this field to route the case to Unassigned queue</description>
        <field>Reviewed_by_Team_Leader__c</field>
        <literalValue>1</literalValue>
        <name>Reviewed by Team Leader Checkbox checked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Escalated_to_False</fullName>
        <field>IsEscalated</field>
        <literalValue>0</literalValue>
        <name>Set Escalated to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Escalated_to_True</fullName>
        <field>IsEscalated</field>
        <literalValue>1</literalValue>
        <name>Set Escalated to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Priority_to_High</fullName>
        <field>Priority</field>
        <literalValue>High</literalValue>
        <name>Set Priority to High</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Priority_to_Medium</fullName>
        <field>Priority</field>
        <literalValue>Medium</literalValue>
        <name>Set Priority to Medium</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Priority_Change_Explanation</fullName>
        <field>Priority_Change_Explanation__c</field>
        <formula>$Label.Auto_Escalation_Comment</formula>
        <name>Update Priority Change Explanation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Priority_to_High</fullName>
        <field>Priority</field>
        <literalValue>High</literalValue>
        <name>Update Priority to High</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Priority_to_Medium</fullName>
        <field>Priority</field>
        <literalValue>Medium</literalValue>
        <name>Update Priority to Medium</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Change Case Record Type to Claim</fullName>
        <actions>
            <name>Change_Case_Record_Type_to_Claim</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Claim</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change Case Record Type to Standard Case</fullName>
        <actions>
            <name>Case_Record_Type_to_Standard_Support</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>notEqual</operation>
            <value>Claim</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Claim Case Support Process</value>
        </criteriaItems>
        <description>Case Record Type should be changed to Standard Support Process based on the Case &apos;Type&apos; Selected.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Escalate Low Priority Cases</fullName>
        <active>true</active>
        <description>Escalate cases from Low to Medium after a certain period.</description>
        <formula>Owner:Queue.QueueName = &apos;Unassigned&apos; &amp;&amp;  !IsClosed &amp;&amp;  ISPICKVAL( Priority , &apos;Low&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Priority_Change_Explanation</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Priority_to_Medium</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Escalate Medium Priority Cases</fullName>
        <active>true</active>
        <description>Escalate cases from Medium to High after a certain period.</description>
        <formula>Owner:Queue.QueueName = &apos;Unassigned&apos; &amp;&amp;  !IsClosed &amp;&amp;  ISPICKVAL( Priority , &apos;Medium&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Priority_to_High</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Escalated %2F Upgraded Audit Trail</fullName>
        <actions>
            <name>Escalated_Upgraded_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Escalated / Upgraded</value>
        </criteriaItems>
        <description>Sets the field to true if the Case status is ever set to &apos;Escalated / Upgraded&apos;. This field can then be used to report on Escalated Cases without the need to look at Case Tracking History data.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Monitor Until AuditTrail - Set to %27Monitor Until%27 field value</fullName>
        <actions>
            <name>Monitor_Until_Audit_History_Set</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Monitor_Until__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Sets the field to the same date/time as the user has entered in the &apos;Monitor Until&apos; field.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Monitored At - Date%2FTime Set to Now</fullName>
        <actions>
            <name>Monitored_At_Field_Set</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Monitor_Until__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Sets the field with the current date/time when the Case &apos;Monitor Until&apos; field is blanked out after any required checks have been completed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Proactive Checkbox Ticked if Case Origin is Agent</fullName>
        <actions>
            <name>Proactive_Checkbox_Ticked</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Agent</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Proactive_Case__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>If the origin of the case is an Agent then this should be a proactive case so this will automate this process in case agents forget to update it manually.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Reopened Audit Trail</fullName>
        <actions>
            <name>Reopened_Audit_Trail_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Reopened</value>
        </criteriaItems>
        <description>Sets the field to true if the Case status is ever set to &apos;Reopened&apos;. This field can then be used to report on Escalated Cases without the need to look at Case Tracking History data.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Reviewed by Team Leader Checkbox checked</fullName>
        <actions>
            <name>Reviewed_by_Team_Leader</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Case.Reviewed_by_Team_Leader__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>When the source origin for a case is not a phone call, it is routed to the Non-Phone Origin Queue. A Team Leader must review the case to save the relevant Case Type and Case Priority. Then they should check this field to route the case to Unassigned queue</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Escalated to False</fullName>
        <actions>
            <name>Set_Escalated_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Escalated / Upgraded</value>
        </criteriaItems>
        <description>Sets the standard Escalated field to False so that the Case Number removes the red arrow marker against it in List Views</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Escalated to True</fullName>
        <actions>
            <name>Set_Escalated_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Escalated / Upgraded</value>
        </criteriaItems>
        <description>Sets the standard Escalated field to True so that the Case Number has a red arrow marker against it in List Views</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
