<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>BookingLineItemId_Update</fullName>
        <field>Booking_Line_Item_Id__c</field>
        <formula>Booking__r.Booking_Id__c + &apos;_&apos; + TEXT(Serial_Number__c)</formula>
        <name>BookingLineItemId Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>GenerteBookingLineItemId</fullName>
        <actions>
            <name>BookingLineItemId_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>= Bookingr.Booking_Id__c + _ + Serial_Number__c</description>
        <formula>ISBLANK( Booking_Line_Item_Id__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
