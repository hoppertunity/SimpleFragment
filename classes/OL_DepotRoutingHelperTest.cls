/**
* File Name   :    OL_DepotRoutingHelperTest.cls
* Description :    
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 04/09/2014 Klea Kolaric	
*/
@isTest
public class OL_DepotRoutingHelperTest {

    static testMethod void findNormalDepotForWorkingDay()
    {
    	Line_Of_Business__c lob = new Line_Of_Business__c();
		lob.Name = 'LOB1';
		lob.Line_Of_Business_Reference__c = '10';
		lob.Routing_Network__c = 'EXP';
		insert lob;
		Account_Address__c aa = TestUtil.createAccountAddress(null,null);
		Date collDate = Date.newInstance(2014,9,1);	// Monday
		
    	Account depot = TestUtil.setupDepotRouting(lob.id,aa,collDate);

    	Test.startTest();
    	system.assertEquals(depot.id,OL_DepotRoutingHelper.findCollectionDepot(aa.Postcode__c,aa.District__c,aa.City__c,lob.id,collDate).id);
    	Test.stopTest();
    }
    
    static testMethod void findSaturdayDepotForSaturdayDay()
    {
    	Line_Of_Business__c lob = new Line_Of_Business__c();
		lob.Name = 'LOB1';
		lob.Line_Of_Business_Reference__c = '10';
		lob.Routing_Network__c = 'EXP';
		insert lob;
		Account_Address__c aa = TestUtil.createAccountAddress(null,null);
		Date collDate = Date.newInstance(2014,8,30);	// Saturday
		
    	Account depot = TestUtil.setupDepotRouting(lob.id,aa,collDate);
    	
    	// set saturday
    	Day__c d = [select id, Day_Type__c from Day__c limit 1];
		d.Day_Type__c = ConstantUtil.PLVAL_DAY_DAYTYPE_SATURDAY;
		update d;
		Depot_Routing__c dr = [select id, Round_Group__c from Depot_Routing__c limit 1];
		dr.Round_Group__c = ConstantUtil.PLVAL_DEPOTROUTING_ROUNDGROUP_SATURDAY;
		update dr;

    	Test.startTest();
    	system.assertEquals(depot.id,OL_DepotRoutingHelper.findCollectionDepot(aa.Postcode__c,aa.District__c,aa.City__c,lob.id,collDate).id);
    	Test.stopTest();
    }
    
    static testMethod void nonWorkingDay()
    {
    	Line_Of_Business__c lob = new Line_Of_Business__c();
		lob.Name = 'LOB1';
		lob.Line_Of_Business_Reference__c = '10';
		lob.Routing_Network__c = 'EXP';
		insert lob;
		Account_Address__c aa = TestUtil.createAccountAddress(null,null);
		Date collDate = Date.newInstance(2014,8,31);	// Sunday
		
    	Account depot = TestUtil.setupDepotRouting(lob.id,aa,collDate);
    	
    	// set sunday
    	Day__c d = [select id, Day_Type__c from Day__c limit 1];
		d.Day_Type__c = ConstantUtil.PLVAL_DAY_DAYTYPE_NONWORKING;
		update d;
		Depot_Routing__c dr = [select id, Round_Group__c from Depot_Routing__c limit 1];
		dr.Round_Group__c = ConstantUtil.PLVAL_DEPOTROUTING_ROUNDGROUP_ALL;
		update dr;

    	Test.startTest();
    	system.assertEquals(null,OL_DepotRoutingHelper.findCollectionDepot(aa.Postcode__c,aa.District__c,aa.City__c,lob.id,collDate));
    	system.assertNotEquals(null,OL_DepotRoutingHelper.errorMsg);
    	Test.stopTest();
    }
    
    static testMethod void failSaturdayDepotForWorkingDay()
    {
    	Line_Of_Business__c lob = new Line_Of_Business__c();
		lob.Name = 'LOB1';
		lob.Line_Of_Business_Reference__c = '10';
		lob.Routing_Network__c = 'EXP';
		insert lob;
		Account_Address__c aa = TestUtil.createAccountAddress(null,null);
		Date collDate = Date.newInstance(2014,9,1);	// Monday
		
    	Account depot = TestUtil.setupDepotRouting(lob.id,aa,collDate);
    	
		Depot_Routing__c dr = [select id, Round_Group__c from Depot_Routing__c limit 1];
		dr.Round_Group__c = ConstantUtil.PLVAL_DEPOTROUTING_ROUNDGROUP_SATURDAY;
		update dr;

    	Test.startTest();
    	system.assertEquals(null,OL_DepotRoutingHelper.findCollectionDepot(aa.Postcode__c,aa.District__c,aa.City__c,lob.id,collDate));
    	system.assertNotEquals(null,OL_DepotRoutingHelper.errorMsg);
    	Test.stopTest();
    }
    
    static testMethod void failNormalDepotForSaturdayDay()
    {
    	Line_Of_Business__c lob = new Line_Of_Business__c();
		lob.Name = 'LOB1';
		lob.Line_Of_Business_Reference__c = '10';
		lob.Routing_Network__c = 'EXP';
		insert lob;
		Account_Address__c aa = TestUtil.createAccountAddress(null,null);
		Date collDate = Date.newInstance(2014,8,30);	// Saturday
		
    	Account depot = TestUtil.setupDepotRouting(lob.id,aa,collDate);
    	
    	// set saturday
    	Day__c d = [select id, Day_Type__c from Day__c limit 1];
		d.Day_Type__c = ConstantUtil.PLVAL_DAY_DAYTYPE_SATURDAY;
		update d;

    	Test.startTest();
    	system.assertEquals(null,OL_DepotRoutingHelper.findCollectionDepot(aa.Postcode__c,aa.District__c,aa.City__c,lob.id,collDate));
    	system.assertNotEquals(null,OL_DepotRoutingHelper.errorMsg);
    	Test.stopTest();
    }
    
    static testMethod void allFail()
    {
    	Line_Of_Business__c lob = new Line_Of_Business__c();
		lob.Name = 'LOB1';
		lob.Line_Of_Business_Reference__c = '10';
		lob.Routing_Network__c = 'EXP';
		insert lob;
		Account_Address__c aa = TestUtil.createAccountAddress(null,null);
		Date collDate = Date.newInstance(2014,9,1);	// Monday
		
    	Account depot = TestUtil.setupDepotRouting(lob.id,aa,collDate);
    	
    	Test.startTest();
    	system.assertEquals(null,OL_DepotRoutingHelper.findCollectionDepot(null,null,null,null,null));
    	system.assertNotEquals(null,OL_DepotRoutingHelper.errorMsg);
    	delete [select id from Depot_Routing__c];
    	system.assertEquals(null,OL_DepotRoutingHelper.findCollectionDepot(aa.Postcode__c,aa.District__c,aa.City__c,lob.id,collDate));
    	system.assertNotEquals(null,OL_DepotRoutingHelper.errorMsg);
    	delete [select id from Day__c];
    	system.assertEquals(null,OL_DepotRoutingHelper.findCollectionDepot(aa.Postcode__c,aa.District__c,aa.City__c,lob.id,collDate));
    	system.assertNotEquals(null,OL_DepotRoutingHelper.errorMsg);
    	delete [select id from Routing_Table__c];
    	system.assertEquals(null,OL_DepotRoutingHelper.findCollectionDepot(aa.Postcode__c,aa.District__c,aa.City__c,lob.id,collDate));
    	system.assertNotEquals(null,OL_DepotRoutingHelper.errorMsg);
    	Test.stopTest();
    }
}