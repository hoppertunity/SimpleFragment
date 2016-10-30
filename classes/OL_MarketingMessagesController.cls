/**
* File Name   :    OL_MarketingMessagesController.cls
* Description :    Show marketing messages to agent
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 22/07/2014 Klea Kolaric   Initial version
*
*
*/
public without sharing class OL_MarketingMessagesController {
    
    public Contact con {get; private set;}
    public Id compContactId {get; set;}
    
    public OL_MarketingMessagesController()
    {
        getInit();
    }
    
    public void getInit()
    {
        Id contactId = String.isBlank(compContactId) ? 
                        (Id) Apexpages.currentPage().getParameters().get(ConstantUtil.PAGEPARAM_CONTACT_ID) : 
                        compContactId;
        con = String.isNotBlank(contactId) ? findMarketingMessages(contactId) : new Contact();
    }
    
    public void saveList()
    {
        try
        {
            update con.CampaignMembers;
        }
        catch(exception e)
        {
            Apexpages.addMessages(e);
        }
    }
    
    public Boolean getHasMarketingMessages()
    {
        return con.Id != null && !con.CampaignMembers.isEmpty();
    }
    
    public String getMarketingMessagesURL()
    {
        return Page.OL_MarketingMessages.getUrl() + '?' + ConstantUtil.PAGEPARAM_CONTACT_ID + '=' + con.Id;
    }
    
    public String getMarketingMessageElement()
    {
        return '<a href="#" style="color:white;"'
            + 'onClick="window.open(\'' + getMarketingMessagesURL() +'\',\'\',\'width=700,height=450\');return false;">'
            + 'There are Marketing Messages</a>';
    }
    
    public static Contact findMarketingMessages(Id contactId)
    {
        return [select Id, Name, Email, AccountId, 
                    (select Campaign.Name, Campaign.Description, Campaign.StartDate, Campaign.EndDate, Interested__c, Response__c 
                    from CampaignMembers
                    where Campaign.isActive = true and Campaign.StartDate <= :Date.today() and Campaign.EndDate >= :Date.today()
                    and Interested__c = null
                    order by Campaign.EndDate asc)
                from Contact
                where Id = :contactId limit 1];
        // pick up campaigns that are active and in progress
        // sort by Campaigns ending the soonest
    }

}