<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Allow_On_Stop_Temp</fullName>
        <description>This action temporarily allows making bookings for On-Stop accounts</description>
        <field>Stubbins_Temporary_Permission__c</field>
        <literalValue>1</literalValue>
        <name>Allow On-Stop Temp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Auto_Case_Creation_Ticked</fullName>
        <description>Ticks the checkbox</description>
        <field>Auto_Case_Creation__c</field>
        <literalValue>1</literalValue>
        <name>Auto Case Creation Ticked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Auto_Case_Creation_Unticked</fullName>
        <description>Unticks the checkbox</description>
        <field>Auto_Case_Creation__c</field>
        <literalValue>0</literalValue>
        <name>Auto Case Creation Unticked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Deactivate_Temp_Permission</fullName>
        <description>Action to deactivate the temporary permission for On-Stop accounts</description>
        <field>Stubbins_Temporary_Permission__c</field>
        <literalValue>0</literalValue>
        <name>Deactivate Temp Permission</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Remove_Request</fullName>
        <field>Request_Stubbins_Permission__c</field>
        <literalValue>0</literalValue>
        <name>Remove Request</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_default_owner_on_Account</fullName>
        <field>OwnerId</field>
        <lookupValue>integration.user@tnt.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Set default owner on Account</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Account Auto Case Creation Disable</fullName>
        <actions>
            <name>Auto_Case_Creation_Unticked</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Major_Account__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Auto_Case_Creation__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Auto_Case_Creation_Exception__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Unticks the Auto Case Creation field on the Account when the Account is changed from a normal Account to a Major Account</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Account Auto Case Creation Enable</fullName>
        <actions>
            <name>Auto_Case_Creation_Ticked</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Major_Account__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Auto_Case_Creation__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Auto_Case_Creation_Exception__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Ticks the Auto Case Creation field on the Account when the Account is changed from Major Account to a normal Account</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Deactivate Temp No On-Stop</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Account.Stubbins_Temporary_Permission__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Workflow to deactivate the temporary permission for On-Stop accounts</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Deactivate_Temp_Permission</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>10</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Set default owner on Account</fullName>
        <actions>
            <name>Set_default_owner_on_Account</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow changes the ownership of a contact when it&apos;s created</description>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
