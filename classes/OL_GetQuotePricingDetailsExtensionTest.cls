/**
* File Name   :    OL_GetQuotePricingDetailsExtensionTest.cls
* Description :    
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 11/08/2014 Liza Romanenko	Initial version
*
*
*/
@isTest
private class OL_GetQuotePricingDetailsExtensionTest {
	
	static testMethod void testExceptions(){
		Account a = TestUtil.createAccountClient();
		insert a;
		Contact c = TestUtil.createContact(a.Id);
		insert c;
		
		Quote__c qt = new Quote__c();
		qt.Account__c = a.Id;
		qt.Contact__c = c.Id;
		qt.Email_Only__c = 'testmail@gdgfd.tst';
		qt.Collection_Postcode__c = 'aa111a';
		qt.Delivery_Postcode__c = 'aa111a';
    	insert qt;
    	
    	Quote_Line_Item__c qli = new Quote_Line_Item__c();
    	qli.Number_of_Items__c = 1;
		qli.Height__c = 10;
		qli.Length__c = 10;
		qli.Weight__c = 10;
		qli.Width__c = 10;
		qli.Quote__c = qt.Id;
		insert qli;
		
		Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(qt);
		OL_GetQuotePricingDetailsExtension cont = new OL_GetQuotePricingDetailsExtension(sc);
		
		cont.requestPrice();
		
		List<Apexpages.Message> msgs = ApexPages.getMessages();
		system.assertEquals(1, msgs.size());
		
		cont.savePrice();
		
		msgs = ApexPages.getMessages();
		system.assertEquals(2, msgs.size());
		
		cont.cancel();
    }
    
    static testMethod void testService(){
		Account a = TestUtil.createAccountClient();
		insert a;
		Contact c = TestUtil.createContact(a.Id);
		insert c;
		
		Quote__c qt = new Quote__c();
		qt.Account__c = a.Id;
		qt.Contact__c = c.Id;
		qt.Email_Only__c = 'testmail@gdgfd.tst';
		qt.Collection_Postcode__c = 'aa111a';
		qt.Delivery_Postcode__c = 'aa111a';
		
		Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(qt);
		OL_GetQuotePricingDetailsExtension cont = new OL_GetQuotePricingDetailsExtension(sc);
		
		Test.startTest();
		
		cont.quote = qt;
		
		Test.setMock(WebServiceMock.class, new uksvcsTntGetQuotePricingServiceMockImpl());
		
		cont.requestPrice();
		
		cont.savePrice();
	
		cont.responceData.del[0].selected = true;
		cont.responceData.del[0].delSvcs.delSvc[0].selected = true;
		
		cont.savePrice();
				
		Test.stopTest();
		
		qt = [SELECT Price__c FROM Quote__c LIMIT 1];
		system.assertEquals(50.45, qt.Price__c);
    }
    
    static testMethod void cover_uksvcsTntComGenericPayloadHeader(){
    	uksvcsTntComGenericPayloadHeader.search_x s = new uksvcsTntComGenericPayloadHeader.search_x();
    } 
    
}