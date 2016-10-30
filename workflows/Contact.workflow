<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>First_Name_Marked_Inactive</fullName>
        <description>Adds xx to the start of the First Name field to mark it as Inactive</description>
        <field>FirstName</field>
        <formula>&quot;xx&quot; + FirstName</formula>
        <name>First Name Marked Inactive</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>First_Name_marked_Active</fullName>
        <description>Removes xx to the start of the First Name field to mark it as Inactive</description>
        <field>FirstName</field>
        <formula>SUBSTITUTE( FirstName , &quot;xx&quot;, &quot;&quot;)</formula>
        <name>First Name marked Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Last_Name_marked_Active</fullName>
        <description>Removes xx to the start of the Last Name field to mark it as Inactive</description>
        <field>LastName</field>
        <formula>SUBSTITUTE( LastName , &quot;xx&quot;, &quot;&quot;)</formula>
        <name>Last Name marked Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Last_Name_marked_Inactive</fullName>
        <description>Adds xx to the start of the Last Name field to mark it as Inactive</description>
        <field>LastName</field>
        <formula>&quot;xx&quot; + LastName</formula>
        <name>Last Name marked Inactive</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_default_owner_on_Contact</fullName>
        <field>OwnerId</field>
        <lookupValue>integration.user@tnt.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Set default owner on Contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Contact made Active</fullName>
        <actions>
            <name>First_Name_marked_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Last_Name_marked_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Inactive__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Updates the First Name and Last Name fields when a contact is marked as Inactive</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Contact made Inactive</fullName>
        <actions>
            <name>First_Name_Marked_Inactive</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Last_Name_marked_Inactive</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Inactive__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Updates the First Name and Last Name fields when a contact is marked as Inactive</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set default owner on Contact</fullName>
        <actions>
            <name>Set_default_owner_on_Contact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow changes the ownership of a contact when it&apos;s created</description>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
