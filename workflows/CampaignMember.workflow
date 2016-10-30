<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>SSS_Booking_Promotion_Email</fullName>
        <description>SSS Booking Promotion Email</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>customer.service.domestic@tnt.co.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Campaigns/Speech_Self_Service_Pack</template>
    </alerts>
    <fieldUpdates>
        <fullName>Campaign_Email_Sent_set_to_Current_Date</fullName>
        <description>Set to the current Date/Time via workflow rule</description>
        <field>Campaign_Email_Sent__c</field>
        <formula>NOW()</formula>
        <name>Campaign Email Sent set to Current Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Responded</fullName>
        <description>Status field set to &apos;Responded&apos;</description>
        <field>Status</field>
        <literalValue>Responded</literalValue>
        <name>Status = Responded</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Campaign Member Status set to Responded</fullName>
        <actions>
            <name>Status_Responded</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CampaignMember.Interested__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Set to Responded if the Interested field is not blank</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email SSS Pack to Interested Campaign Member</fullName>
        <actions>
            <name>SSS_Booking_Promotion_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Campaign_Email_Sent_set_to_Current_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.IsActive</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>CampaignMember.Interested__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>equals</operation>
            <value>SSS Booking Promotion</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Email</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Sends the SSS Pack Email Template if the campaign is Active, contact is tagged as Interested, the Campaign Name is SSS Booking Promotion and contacts Email Address is populated</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
