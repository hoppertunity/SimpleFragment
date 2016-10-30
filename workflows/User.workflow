<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_Chatter_User</fullName>
        <description>New Chatter User</description>
        <protected>false</protected>
        <recipients>
            <recipient>curtis.longland@tnt.co.uk</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Chatter_New_User</template>
    </alerts>
    <rules>
        <fullName>Test</fullName>
        <active>false</active>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update me When invited to Chatter</fullName>
        <actions>
            <name>New_Chatter_User</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>Chatter Free</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
