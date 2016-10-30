<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Approval</fullName>
        <description>Approval</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Knowledge_Email_Templates/Knowledge_Approval</template>
    </alerts>
    <alerts>
        <fullName>Rejection</fullName>
        <description>Rejection</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Knowledge_Email_Templates/Knowledge_Rejection</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Validation_status_not_validated</fullName>
        <field>ValidationStatus</field>
        <literalValue>Not Validated</literalValue>
        <name>Update Validation status not validated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_validation_status</fullName>
        <field>ValidationStatus</field>
        <literalValue>Validated</literalValue>
        <name>Update validation status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
