<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Booking_History_Id</fullName>
        <field>Booking_History_Id__c</field>
        <formula>Booking__r.Booking_Id__c + &apos;_&apos; + TEXT(Movement_Type__c) + &apos;_&apos; + SUBSTITUTE(
SUBSTITUTE(
SUBSTITUTE(
SUBSTITUTE(TEXT(Movement_Date_Time__c),&apos;-&apos;,&apos;&apos;),
&apos; &apos;,&apos;&apos;),
&apos;:&apos;,&apos;&apos;),
&apos;Z&apos;,&apos;&apos;)</formula>
        <name>Update Booking History Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Create Booking History Id</fullName>
        <actions>
            <name>Update_Booking_History_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISBLANK( Booking_History_Id__c )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
