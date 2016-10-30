<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Action_Set_Completed_Time</fullName>
        <description>This field update is to set a Date/Time field when a the status of when a case Action is compeleted</description>
        <field>End_Time__c</field>
        <formula>NOW()</formula>
        <name>Action Set Completed Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Call_Tagging_to_Call_Result</fullName>
        <description>Copies value from pick list field to a text field.</description>
        <field>CallDisposition</field>
        <formula>TEXT(Call_Tagging__c)</formula>
        <name>Copy Call Tagging to Call Result</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Action Completed Set Completed Time</fullName>
        <actions>
            <name>Action_Set_Completed_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Status</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task.Action_Subtype__c</field>
            <operation>equals</operation>
            <value>First Customer Contact,Customer Contact</value>
        </criteriaItems>
        <description>This workflow rule will kick off when An Action&apos;s Status is set to Complete. An end date field will be populated. To Determine if an SLA has been met or missed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Copy Call Tagging to Call Result Field</fullName>
        <actions>
            <name>Copy_Call_Tagging_to_Call_Result</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Call_Tagging__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Copies the value from the custom field to the standard Salesforce field. This is required by NVM Stats Package v1.83 onwards to tag the disposition code onto the NVM Call Summary records.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
