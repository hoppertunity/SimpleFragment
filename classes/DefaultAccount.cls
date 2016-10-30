public with sharing class DefaultAccount {

    private final Account acct;
    public Account_Address__c defAdd {get; set;}
    public boolean isDefault {get; set;}
    
    public DefaultAccount(ApexPages.StandardController controller) {
        this.acct = (Account)controller.getRecord();
        try{
            defAdd = [Select Legacy_Address_Id__c,Org_Name__c,Premise_Name__c,Street_1__c,Street_2__c,City__c,District__c,County__c,Postcode__c,Contact__c,Last_Used__c,Comments_on_account_address__c
                        from Account_Address__c where Account__c =: acct.Id and Default__c =: true limit 1];
            isDefault = true;
        }
        catch(exception e) {
            isDefault = false;
        }
    }
}