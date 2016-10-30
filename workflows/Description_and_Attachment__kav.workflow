<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Approval_Descriptions</fullName>
        <description>Approval - Descriptions</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Knowledge_Email_Templates/Knowledge_Descriptions_Approval_process</template>
    </alerts>
    <alerts>
        <fullName>Description_Rejection</fullName>
        <description>Description - Rejection</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Knowledge_Email_Templates/Knowledge_Descriptions_Rejection</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Descriptions_validation_status</fullName>
        <field>ValidationStatus</field>
        <literalValue>Validated</literalValue>
        <name>Update Descriptions validation status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
