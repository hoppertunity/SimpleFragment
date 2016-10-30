<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_a_quote</fullName>
        <description>Email a quote</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Email_Only__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>External_Templates/Email_a_Quote</template>
    </alerts>
    <alerts>
        <fullName>New_Lead_from_Quote_to_Sales_Account_Team_Alert</fullName>
        <description>New Lead from Quote to Sales/Account Team Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Sales_Accounts</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Internal_Templates/New_Lead_from_Quote</template>
    </alerts>
    <fieldUpdates>
        <fullName>Populate_Contact_Email</fullName>
        <field>Contact_Email__c</field>
        <formula>Email_Only__c</formula>
        <name>Populate Contact Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Quote_Priced_RecordType_update</fullName>
        <description>Update Quote Record Type when price have been selected</description>
        <field>RecordTypeId</field>
        <lookupValue>PricedQuote</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Quote Priced RecordType update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Quote_is_Valid</fullName>
        <description>24 Hours after a quote is created, it is out of date and invalid, and unable to proceed to booking</description>
        <field>Quote_is_Valid__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Quote is Valid</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Make Quote Priced</fullName>
        <actions>
            <name>Quote_Priced_RecordType_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Close Quote after price and service have been selected</description>
        <formula>!ISBLANK( Price__c )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Contact Email</fullName>
        <actions>
            <name>Populate_Contact_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>if contact details added and email_only__c populated</description>
        <formula>ISBLANK( Contact__c ) &amp;&amp; !ISBLANK( Contact_Last_Name__c ) &amp;&amp; !ISBLANK( Email_Only__c ) &amp;&amp; ISBLANK( Contact_Email__c )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Quote is out of date and invalid</fullName>
        <active>true</active>
        <description>A quote remains valid to proceed to a booking until midnight. After this time, it is out of data and invalid.</description>
        <formula>Quote_is_Valid__c &amp;&amp;  !ISBLANK(Validation_Deadline__c )</formula>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Uncheck_Quote_is_Valid</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Quote__c.Validation_Deadline__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Send New Lead from Quote to Sales%2FAccount Team</fullName>
        <actions>
            <name>New_Lead_from_Quote_to_Sales_Account_Team_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This rule will send a potential new account lead to the Sales/Account Team when a quote is saved for a contact who is not currently a TNT account</description>
        <formula>((( Contact__r.Email = &apos;&apos; ) || ( Account__r.Name =&apos;&apos;)) &amp;&amp; Email_Only__c  &lt;&gt; &apos;&apos;) &amp;&amp; ( $Profile.Name = &apos;Major Accounts Agent&apos; || $Profile.Name = &apos;CS Agent&apos;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Send a quote via email</fullName>
        <actions>
            <name>Email_a_quote</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This workflow triggers an email to be sent to a contact when a quote is requested and the email address of the contact is known. The email address can be for a contact at an existing account, or it can be for a new contact with no account.</description>
        <formula>(( Contact__r.Email  &lt;&gt; &apos;&apos; ) || (  Email_Only__c   &lt;&gt; &apos;&apos;))   &amp;&amp;   Email_the_quote__c  = TRUE &amp;&amp; !ISBLANK(Price__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
