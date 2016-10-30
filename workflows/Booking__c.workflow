<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_a_booking_reference</fullName>
        <description>Email a booking reference</description>
        <protected>false</protected>
        <recipients>
            <field>Order_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>OC_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>External_Templates/Email_a_Booking_reference</template>
    </alerts>
    <alerts>
        <fullName>New_Lead_from_Booking_to_Sales_Account_Team</fullName>
        <description>New Lead from Booking to Sales/Account Team</description>
        <protected>false</protected>
        <recipients>
            <recipient>Sales_Accounts</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Internal_Templates/New_Lead_from_Booking</template>
    </alerts>
    <fieldUpdates>
        <fullName>Change_Record_Type_to_Blocked</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Blocked_Booking</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change Record Type to Blocked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Record_Type_to_New</fullName>
        <field>RecordTypeId</field>
        <lookupValue>New_Booking</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change Record Type to New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Lock Booking</fullName>
        <actions>
            <name>Change_Record_Type_to_Blocked</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Booking__c.Status__c</field>
            <operation>equals</operation>
            <value>Cancelled,Collected</value>
        </criteriaItems>
        <criteriaItems>
            <field>Booking__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Blocked Booking</value>
        </criteriaItems>
        <description>When a Booking is Collected or Cancelled, it can&apos;t be edited</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send New Lead from Booking to Sales%2FAccount Team</fullName>
        <actions>
            <name>New_Lead_from_Booking_to_Sales_Account_Team</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This rule will send a new account lead to the Sales/Account Team when a booking is saved for a contact who does not hold a TNT account</description>
        <formula>((( Order_Contact__r.Email = &apos;&apos; ) || ( Account__r.Name =&apos;&apos;)) &amp;&amp; (( OC_Email_Address__c   &lt;&gt; &apos;&apos;)  || ( Company_Name__c  &lt;&gt; &apos;&apos;)  || ( Company_Phone__c  &lt;&gt; &apos;&apos;)  || ( OC_First_Name__c  &lt;&gt; &apos;&apos;)  || ( OC_Last_Name__c  &lt;&gt; &apos;&apos;)  || ( OC_Phone_Number__c  &lt;&gt; &apos;&apos;))) &amp;&amp; ( $Profile.Name = &apos;Major Accounts Agent&apos; || $Profile.Name = &apos;CS Agent&apos;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Send a booking reference via email</fullName>
        <actions>
            <name>Email_a_booking_reference</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>This workflow triggers an email to be sent to a contact when a booking reference is requested and the email address of the contact is known. The email address can be for a contact at an existing account, or it can be for a new contact with no account.</description>
        <formula>(( Order_Contact__r.Email &lt;&gt; &apos;&apos; ) || (  OC_Email_Address__c  &lt;&gt; &apos;&apos;)) &amp;&amp;  Email_the_booking_reference__c  = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Unlock Booking</fullName>
        <actions>
            <name>Change_Record_Type_to_New</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Booking__c.Status__c</field>
            <operation>notEqual</operation>
            <value>Cancelled,Collected</value>
        </criteriaItems>
        <criteriaItems>
            <field>Booking__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>New Booking</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
