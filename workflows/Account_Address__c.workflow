<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Default_Checkbox_set_to_True</fullName>
        <description>Account Address: Default Checkbox is set to True</description>
        <field>Default__c</field>
        <literalValue>1</literalValue>
        <name>Default Checkbox set to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Account Address%3A Set Default</fullName>
        <actions>
            <name>Default_Checkbox_set_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account_Address__c.Legacy_Address_Id__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Makes the Account Address received from Universe via &apos;Replicate Account&apos; interface the &apos;Default&apos;.  This is used to calculate Carriage Forward within bookings and controls which address is shown on the Account record address VF section.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
