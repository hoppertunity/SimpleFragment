/**
* File Name   :    OL_SearchConsignmentControllerTest.cls
* Description :    Test class for OL_SearchConsignmentController.cls
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 09/09/2014 Liza Romanenko	Initial version, TNT-546
*/
@isTest
private class OL_SearchConsignmentControllerTest {

    static testMethod void testData() {
    	Account d = TestUtil.createAccountDepot();
    	d.Depot_Number__c = '123';
    	insert d;
    	Service__c svc = new Service__c(Name='Test Svc', Service_Code__c='01');
    	insert svc;
    	Option_Settings__c os = new Option_Settings__c(Name='01', SF_Description__c='Test Opt');
    	insert os;
    	Note_Type_Settings__c nts = new Note_Type_Settings__c(Name='01', SF_Description__c='Test Nt Type');
    	insert nts;
    	Con_Status_Settings__c css = new Con_Status_Settings__c(Name='01', SF_Description__c='Test Con Stattus');
    	insert css;
    	Con_Sub_Status_Settings__c csss = new Con_Sub_Status_Settings__c(Name='01', SF_Description__c='Test Con Sub Status');
    	insert csss;
    	Line_of_Business__c lob = new Line_of_Business__c(Name='Test Lob', Line_of_Business_Reference__c='01');
    	insert lob;
    	
        OL_SearchConsignmentController cntr = new OL_SearchConsignmentController();
        
        system.assertEquals(1, cntr.getConSubStatusItems().size());
        system.assertEquals(1, cntr.getConStatusItems().size());
        system.assertEquals(1, cntr.getNoteTypeItems().size());
        system.assertEquals(1, cntr.getOptionItems().size());
        system.assertEquals(1, cntr.getServiceItems().size());
        system.assertEquals(1, cntr.getDepotItems().size());
        system.assertEquals(1, cntr.getLobItems().size());
        
        system.assertEquals(1, cntr.lobMap.size());
        system.assertEquals(1, cntr.serviceMap.size());
                
    }
    
    static testMethod void testService() {
        OL_SearchConsignmentController cntr = new OL_SearchConsignmentController();
        cntr.consReq.stsHstry.negStsInd = false;
        cntr.consReq.stsHstry.negSubStsInd = true;
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new uksvcsTntComSearchConsignmentServiceMock());
        	cntr.consReq.tntConNum = '12345678';
        	cntr.searchAdvanced();
        	
        	cntr.next();
        	system.assertEquals(2, cntr.pageNumber);
        	
        	cntr.prew();
        	system.assertEquals(1, cntr.pageNumber);
        	
        Test.stopTest();
        
        system.assertEquals('111', cntr.cons.con[0].unqConNum);
    }
    
    static testMethod void test_checkSearchData() {
    	
    	OL_SearchConsignmentController cntr = new OL_SearchConsignmentController();
    	
    	system.assert(!cntr.checkSearchData());
    	
    	cntr.consReq.tntConNum = '12345678';
    	
    	system.assert(cntr.checkSearchData());
    	
    	cntr.consReq.tntConNum = null;
    	cntr.isAdvanced = true;
    	
    	cntr.quote.Collection_Date__c = Date.today() - 8;
    	system.assert(!cntr.checkSearchData());
    	
    	cntr.quoteTo.Collection_Date__c = Date.today() - 10;
    	system.assert(!cntr.checkSearchData());
    	
    	cntr.quoteTo.Collection_Date__c = null;
    	system.assert(!cntr.checkSearchData());
    	
    	cntr.quoteTo.Collection_Date__c = Date.today() - 4;
    	
    	cntr.consReq.colRnd = '2';
    	system.assert(!cntr.checkSearchData());
    	
    	cntr.consReq.colDep = '123';
    	system.assert(cntr.checkSearchData());
    	
    	cntr.consReq.delRnd = '2';
    	system.assert(!cntr.checkSearchData());
    	
    	cntr.consReq.delDep = '123';
    	system.assert(cntr.checkSearchData());
    	
    }
    
    static testMethod void testInitSaerch() {
        OL_SearchConsignmentController cntr = new OL_SearchConsignmentController();
        ApexPages.currentPage().getParameters().put('bNum', '123456');
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new uksvcsTntComSearchConsignmentServiceMock());
        	cntr.initSearch();
        Test.stopTest();
        
        system.assertEquals('111', cntr.cons.con[0].unqConNum);
    }
    
    //***** tests for Detail part
    static testMethod void test_searchConsignment() {
        OL_SearchConsignmentController cnt = new OL_SearchConsignmentController();
        cnt.consignmentId = '1234';
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new uksvcsTntComGetConsDetlsServiceMock());
        
        cnt.searchConsignment();
        
        Test.stopTest();
        
        system.assertNotEquals(null, cnt.consignment);
    }
    
    static testMethod void test_searchConsignmentItems() {
        OL_SearchConsignmentController cnt = new OL_SearchConsignmentController();
        cnt.consignment = new uksvcsTntComSearchConsignment.ConsignmentResponse_MasterType();
    	cnt.consignment.unqConNum = '1234';
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new uksvcsTntGetItemsForConsignmentSvcMock());
        
        cnt.searchConsignmentItems();
        
        Test.stopTest();
        
        system.assertNotEquals(null, cnt.consignmentItems);
    }
    
    static testMethod void cover_other(){
    	Account a = TestUtil.createAccountDepot();
    	a.Depot_Number__c = '111';
		insert a;
		
		Service__c svc = new Service__c(Name='Test Svc', Service_Code__c='01');
    	insert svc;
    	
    	Line_of_Business__c lob = new Line_of_Business__c(Name='Test Lob', Line_of_Business_Reference__c='01');
    	insert lob;
		
    	OL_SearchConsignmentController cnt = new OL_SearchConsignmentController();
    	cnt.setSelectedItemRaw();
    	uksvcsTntComGenericPayloadHeader.search_x s = new uksvcsTntComGenericPayloadHeader.search_x();
    	
    	system.assertEquals('*111*', cnt.depotKeys);
    }
    
    static testMethod void test_CaseCreation(){
    	Account a = TestUtil.createAccountClient();
    	a.Account_Number__c = '111';
		insert a;
		Account depot = TestUtil.createAccountDepot();
		depot.Depot_Number__c = '010';
		insert depot;
    	
    	OL_SearchConsignmentController cnt = new OL_SearchConsignmentController();
    	cnt.consignment = new uksvcsTntComSearchConsignment.ConsignmentResponse_MasterType();
    	cnt.consignment.tntConNum = '123';
    	cnt.consignment.unqConNum = '321';
    	cnt.consignment.orgnDep = depot.Depot_Number__c;
    	cnt.consignment.act = new uksvcsTntComSearchConsignment.Account_MasterType();
    	cnt.consignment.act.actNum = '111';
    	cnt.fillDepots();
    	
    	cnt.runCreateAndSaveCase();
    	
    	Case c = [SELECT  AccountId, Type, Status, Delivery_Depot__c FROM Case LIMIT 1];
    	system.assertEquals(a.Id, c.AccountId);
    	system.assertEquals(ConstantUtil.PLVAL_CASE_STATUS_CLOSED, c.Status);
    	system.assertEquals(ConstantUtil.PLVAL_CASE_TYPE_RECORD_TRACK, c.Type);//MODIFIED by DH 24/09/15
    	system.assertEquals(depot.Id, c.Delivery_Depot__c);
    	
    	cnt.runCreateAndOpenCase();
    	system.assertEquals(null, cnt.caseToOpen);
    	
    	cnt.createAndOpenCase();
    	c = [SELECT  AccountId, Type, Status, Delivery_Depot__c FROM Case where Id = :cnt.caseToOpen.Id];
    	system.assertEquals(a.Id, c.AccountId);
    	system.assertEquals(ConstantUtil.PLVAL_CASE_STATUS_WORKING_ON, c.Status);
    	system.assertEquals(ConstantUtil.PLVAL_CASE_TYPE_TRACK, c.Type);
    	system.assertEquals(depot.Id, c.Delivery_Depot__c);
    	
    }
}