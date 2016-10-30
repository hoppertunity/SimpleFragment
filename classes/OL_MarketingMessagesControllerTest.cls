/**
* File Name   :    OL_MarketingMessagesControllerTest.cls
* Description :    
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 23/07/2014 Klea Kolaric	Initial version
*
*
*/
@isTest
private class OL_MarketingMessagesControllerTest {

    static testMethod void testQuickRun()
    {
        Account a = TestUtil.createAccountClient();
		insert a;
		Contact c = TestUtil.createContact(a.Id);
		insert c;
		
		Campaign cBlank = TestUtil.createCampaign();
		Campaign cYes = TestUtil.createCampaign();
		Campaign cNo = TestUtil.createCampaign();
		Campaign cFinished = TestUtil.createCampaign();
		cFinished.StartDate = Date.today().addDays(-14);
		cFinished.EndDate = Date.today().addDays(-7);
		cFinished.Status = 'Completed';
		Campaign cInactive = TestUtil.createCampaign();
		cInactive.IsActive = false;
		insert new List<Campaign>{cBlank,cYes,cNo,cFinished,cInactive};
		
		CampaignMember cmBlank = TestUtil.createCampaignMember(cBlank.Id,c.Id);
		CampaignMember cmYes = TestUtil.createCampaignMember(cYes.Id,c.Id);
		cmYes.Interested__c = 'Yes';
		CampaignMember cmNo = TestUtil.createCampaignMember(cNo.Id,c.Id);
		cmNo.Interested__c = 'no';
		CampaignMember cmFinished = TestUtil.createCampaignMember(cFinished.Id,c.Id);
		CampaignMember cmInactive = TestUtil.createCampaignMember(cInactive.Id,c.Id);
		insert new List<CampaignMember>{cmBlank,cmYes,cmNo,cmFinished,cmInactive};
		
		Apexpages.currentPage().getParameters().put(ConstantUtil.PAGEPARAM_CONTACT_ID,c.Id);
		Test.startTest();
		OL_MarketingMessagesController mmc = new OL_MarketingMessagesController();
		System.assert(mmc.getHasMarketingMessages());
		mmc.getMarketingMessagesURL();
		mmc.getMarketingMessageElement();
		System.assertEquals(1,mmc.con.CampaignMembers.size());
		for(CampaignMember cm : mmc.con.CampaignMembers)
		{
			system.assert(cm.Id == cmBlank.Id);	// no other campaign selected
		}
		mmc.saveList();
		Test.stopTest();
        
    }
}