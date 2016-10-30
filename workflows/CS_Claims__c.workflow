<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CS_Agent_reminder_mail</fullName>
        <description>CS Agent reminder mail</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>customer.service.domestic@tnt.co.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>TNT_Claims/CS_Created_not_sent_reminder_email</template>
    </alerts>
    <alerts>
        <fullName>CS_Confirmation_email_to_customer</fullName>
        <description>CS Confirmation email to customer</description>
        <protected>false</protected>
        <recipients>
            <field>Sender_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>customer.service.domestic@tnt.co.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>TNT_Claims/CS_Confirmation_to_customer</template>
    </alerts>
    <alerts>
        <fullName>CS_Email_to_Customer_with_link_to_Claims_form</fullName>
        <description>CS_Email to Customer with link to Claims form</description>
        <protected>false</protected>
        <recipients>
            <field>Sender_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>TNT_Claims/CS_Email_with_claim_form_link_to_cust</template>
    </alerts>
    <alerts>
        <fullName>CS_Send_email_to_the_TNT_Claims_UK</fullName>
        <description>CS Send email to the TNT Claims UK</description>
        <protected>false</protected>
        <recipients>
            <field>Lotus_Notes_Claims_Email_ID__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>customer.service.domestic@tnt.co.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>TNT_Claims/CS_Email_to_TNT_UK_Claims</template>
    </alerts>
    <fieldUpdates>
        <fullName>CS_Update_Claim_Stage_to_In_progress</fullName>
        <field>Claims_Stage__c</field>
        <literalValue>In Progress</literalValue>
        <name>CS Update Claim Stage to In progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CS_update_Stage_to_Closed</fullName>
        <field>Claims_Stage__c</field>
        <literalValue>Closed</literalValue>
        <name>CS update Stage to Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Account_No</fullName>
        <field>TNT_account_no__c</field>
        <formula>Account__r.Account_Number__c</formula>
        <name>Update Account No</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Contact_Email</fullName>
        <field>Sender_Email_Address__c</field>
        <formula>Contact__r.Email</formula>
        <name>Update Contact Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Depot_No</fullName>
        <field>Depot_no__c</field>
        <formula>Depot__r.Depot_Number__c</formula>
        <name>Update Depot No</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sent_To_Customer</fullName>
        <field>Sent_To_Customer__c</field>
        <literalValue>1</literalValue>
        <name>Update Sent To Customer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CS Change Claim Stage to Closed</fullName>
        <active>true</active>
        <criteriaItems>
            <field>CS_Claims__c.Claims_Stage__c</field>
            <operation>notEqual</operation>
            <value>Returned,Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>CS_Claims__c.Sent_To_Customer__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Set the status of the claims to Closed if the Claims is not submited by the user within 21 days of after the form was sent.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>CS_update_Stage_to_Closed</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>21</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CS Reminder to CS Agent</fullName>
        <active>true</active>
        <criteriaItems>
            <field>CS_Claims__c.Claims_Stage__c</field>
            <operation>equals</operation>
            <value>Created</value>
        </criteriaItems>
        <description>A time based workflow to the CS Agent, if the claims was created and not sent to user within 24 hrs.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>CS_Agent_reminder_mail</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>CS_Claims__c.CreatedDate</offsetFromField>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CS Send Email to Customer</fullName>
        <actions>
            <name>CS_Email_to_Customer_with_link_to_Claims_form</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Sent_To_Customer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CS_Claims__c.Claims_Stage__c</field>
            <operation>equals</operation>
            <value>Sent to Customer</value>
        </criteriaItems>
        <description>When Stage is set to &apos;Sent to Customer&apos; this sends a claim form email to the customer with link to the VF page to complete and return. Also sets the Sent to Customer check box to true.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CS Send Email to TNT Claims UK</fullName>
        <actions>
            <name>CS_Confirmation_email_to_customer</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CS_Claims__c.Claims_Stage__c</field>
            <operation>equals</operation>
            <value>Returned</value>
        </criteriaItems>
        <description>When Claim Stage is set to &apos;Returned&apos; an email is sent to the customer (using Customer Email Address field) to confirm receipt. The email is sent from &lt;customer.service.domestic@tnt.co.uk&gt; saying its being processed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Copy Account Number</fullName>
        <actions>
            <name>Update_Account_No</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Copy the Account Number from the Account the user looks up</description>
        <formula>OR(ISBLANK(  TNT_account_no__c ),ISCHANGED( Account__c  ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Copy Depot Num</fullName>
        <actions>
            <name>Update_Depot_No</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Copies the Depot No from the Depot that is looked up by the user</description>
        <formula>OR(ISBLANK(Depot_no__c ),ISCHANGED(Depot__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Copy Email from Contact</fullName>
        <actions>
            <name>Update_Contact_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Copies the Email Address from the Contact the user looks up but only if that field is not blank on the contact record.</description>
        <formula>AND(ISCHANGED( Contact__c  ),  !ISBLANK( Contact__r.Email ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
