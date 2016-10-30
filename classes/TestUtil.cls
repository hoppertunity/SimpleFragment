/**
* File Name   :    TestUtil.cls
* Description :    help for testing
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 03/07/2014 Klea Kolaric	Initial version
*
*
*/
@isTest
public with sharing class TestUtil {
	
	public static Id accountClientRTId = [select id from RecordType where DeveloperName = 'Client' and sObjectType = 'Account' limit 1].id;
	public static Id accountDepotRTId = [select id from RecordType where DeveloperName = 'Depot' and sObjectType = 'Account' limit 1].id;
	
	public static Account createAccountClient()
	{
		Account a = new Account();
		a.recordTypeId = accountClientRTId;
		a.Name = 'Test Class Account';
		a.AccountNumber = '111';
		return a;
	}
	
	public static Account createAccountDepot()
	{
		Account a = new Account();
		a.recordTypeId = accountDepotRTId;
		a.Name = 'Test Class Depot';
		a.AccountNumber = '222';
        //Added by DH 23/10/15 to accomodate new field filter restraint
        a.Operational_for_Bookings__c = true;
		return a;
        
	}
	
	public static Contact createContact(Id accountId)
	{
		
        Contact c = new Contact();
		c.AccountId = accountId;
		c.FirstName = 'Test Class';
		c.LastName = 'Contact';
		c.Email = 'test@email.com';
		c.Phone = '1234554321';
		return c;
	}
	
	public static Case createCase(Id accountId, Id contactId, Id depotId)
	{
		// parsing error if first line populated (?????????)
		Case c = createCase(accountId, contactId);
		c.Collection_Depot__c = depotId;
		return c;
	}
	
	public static Case createCase(Id accountId, Id contactId)
	{
		// parsing error if first line populated (?????????)
		Case c = new Case();
		c.Subject = 'Test Class Case';
		c.Description = 'test class';
		c.AccountId = accountId;
		c.ContactId = contactId;
		c.Exception__c = ConstantUtil.PLVAL_CASE_EXCEPTION_COLLECTION;
		return c;
	}
	
	public static Account_Address__c createAccountAddress(Id accountId, Id contactId)
	{
		Account_Address__c aa = new Account_Address__c();
		aa.Account__c = accountId;
		aa.Contact__c = contactId;
		aa.Org_Name__c = 'test address ' + Math.rint(Math.random()*1000);
		aa.Street_1__c = 'my test street';
		aa.Postcode__c = 'SW15 1TW';
		aa.City__c = 'Testville';
		aa.Country__c = ConstantUtil.ISOCODE_UK;
		return aa;
	}
	
	public static Campaign createCampaign()
	{
		Campaign c = new Campaign();
		c.isActive = true;
		c.Name = 'testCampaign';
		c.Status = 'In Progress';
		c.StartDate = Date.today().addDays(-7);
		c.EndDate = Date.today().addDays(7);
		c.Description = 'my test campaign';
		return c;
	}
	
	public static CampaignMember createCampaignMember(Id campaignId, Id contactId)
	{
		CampaignMember cm = new CampaignMember();
		cm.CampaignId = campaignId;
		cm.ContactId = contactId;
		cm.Status = 'Sent';
		return cm;
	}
	
	public static User createAgentUser() {

		Profile p = [SELECT Id FROM Profile WHERE Name='CS Agent']; 
		return createUser(p.Id,null);
	}
	
	public static User createAdminUser() {

		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
		return createUser(p.Id,null);
	}
	
	public static User createIntegrationUser() {

		Profile p = [SELECT Id FROM Profile WHERE Name='Integration User']; 
		return createUser(p.Id,null);
	}
	
	public static User createUser(Id profileId, Id roleId) {

		User u = new User(Alias = 'standt', Email='test@example.com', 
		EmailEncodingKey='UTF-8', LastName='Testing',  
		LocaleSidKey='en_US', LanguageLocaleKey='en_US', 
		ProfileId = profileId, UserRoleId = roleId, 
		TimeZoneSidKey='America/Los_Angeles', UserName='tntuser@example.com');

		return u;
	}
	
	public static List<sObject> proxyInsert(List<sObject> sobjs)	// use this to avoid mixing insert of setup and non-setup sobject
	{
		System.runAs(new User(Id = UserInfo.getUserId()))
		{
			insert sobjs;
		}
		return sobjs;
	}
	
	// create entry with working day and normal depot
	public static Account setupDepotRouting(Id lobId, Account_Address__c aa, Date collDate)
	{
		Account depot = createAccountDepot();
		Account dep1 = createAccountDepot();		// calendar linking depot
		dep1.AccountNumber = '999';
		dep1.Depot_Number__c = '999';
		dep1.Name += '999';
		insert new List<Account>{depot,dep1};

		Calendar__c cal = new Calendar__c();
		cal.Name = 'Default Calendar';
		insert cal;
		Day__c d = new Day__c();
		d.Calendar__c = cal.id;
		d.Date__c = collDate;
		d.Name = collDate.format();
		d.Day_Type__c = ConstantUtil.PLVAL_DAY_DAYTYPE_WORKING;
		insert d;

		dep1.Depot_Calendar__c = cal.id;
		update dep1;

		Routing_Table__c rt = new Routing_Table__c();
		rt.Depot__c = dep1.id;
		rt.Routing_Default__c = true;
		rt.District__c = aa.District__c;
		rt.Town__c = aa.City__c;
		rt.Part_Postcode__c = aa.Postcode__c.substring(0, aa.Postcode__c.length()-2);
		insert rt;

		Depot_Routing__c dr = new Depot_Routing__c();
		dr.Collection_Depot__c = depot.id;
		dr.Line_of_Business__c = lobId;
		dr.Round_Group__c = ConstantUtil.PLVAL_DEPOTROUTING_ROUNDGROUP_NORMAL;
		dr.Routing_Table__c = rt.Id;
		dr.Routing_Network__c = 'EXP';
		insert dr;

		return depot;
	}
	
	public static void setupBusinessHoursAndHolidays()
	{
		TimeUtil.bh = newBusinessHours();
		TimeUtil.holidays = newHolidays();
	}
	
	public static BusinessHours newBusinessHours()
	{
		return new BusinessHours(
						Name='Default',
						MondayStartTime=Time.newInstance(8,0,0,0), MondayEndTime=Time.newInstance(18,0,0,0),	// 8-18
						TuesdayStartTime=Time.newInstance(8,0,0,0), TuesdayEndTime=Time.newInstance(18,0,0,0), 	// 8-18
						WednesdayStartTime=Time.newInstance(0,0,0,0), WednesdayEndTime=Time.newInstance(0,0,0,0), 	// all day
						ThursdayStartTime=Time.newInstance(8,0,0,0), ThursdayEndTime=Time.newInstance(18,0,0,0),	// 8-18
						FridayStartTime=Time.newInstance(8,0,0,0), FridayEndTime=Time.newInstance(17,30,0,0), 	// 8-17:30
						SaturdayStartTime=Time.newInstance(9,0,0,0), SaturdayEndTime=Time.newInstance(17,30,0,0), 	// 9-17:30
						SundayStartTime=null, SundayEndTime=null, 	// not a work day
						IsDefault=true, 
						IsActive=true,
						TimeZoneSidKey='Europe/London');
	}
	
	public static List<Holiday> newHolidays()
	{
		List<Holiday> hds = new List<Holiday>();
		hds.add(new Holiday(
						Name='Random Holiday',
						ActivityDate=Date.newInstance(2014,4,2), 	// random holiday on April 2nd 2014 (Wednesday)
						IsRecurrence=false, 
						RecurrenceType=null, 
						RecurrenceMonthOfYear=null, 
						RecurrenceDayOfWeekMask=null, 
						RecurrenceDayOfMonth=null,
						RecurrenceInstance=null, 
						IsAllDay=true));
		hds.add(new Holiday(
						Name='First Friday in May Holiday',
						ActivityDate=Date.newInstance(2014,5,2), 	// holiday on May 2nd 2014 (Friday)
						IsRecurrence=true, 
						RecurrenceType=ConstantUtil.HOLIDAY_RECTYPE_YEARLYNTH, 
						RecurrenceMonthOfYear=ConstantUtil.MONTHS_I2S.get(5), 
						RecurrenceDayOfWeekMask=32, // Friday bitmask
						RecurrenceDayOfMonth=null,
						RecurrenceInstance=ConstantUtil.HOLIDAY_RECINSTANCE_FIRST, // first Friday in May
						IsAllDay=true));
		hds.add(new Holiday(
						Name='Second Friday in May Holiday',
						ActivityDate=Date.newInstance(2014,5,9), 	// holiday on May 9th 2014 (Friday)
						IsRecurrence=true, 
						RecurrenceType=ConstantUtil.HOLIDAY_RECTYPE_YEARLYNTH, 
						RecurrenceMonthOfYear=ConstantUtil.MONTHS_I2S.get(5), 
						RecurrenceDayOfWeekMask=32, // Friday bitmask
						RecurrenceDayOfMonth=null,
						RecurrenceInstance=ConstantUtil.HOLIDAY_RECINSTANCE_SECOND, // second Friday in May
						IsAllDay=true));
		hds.add(new Holiday(
						Name='Third Friday in May Holiday',
						ActivityDate=Date.newInstance(2014,5,16), 	// holiday on May 16th 2014 (Friday)
						IsRecurrence=true, 
						RecurrenceType=ConstantUtil.HOLIDAY_RECTYPE_YEARLYNTH, 
						RecurrenceMonthOfYear=ConstantUtil.MONTHS_I2S.get(5), 
						RecurrenceDayOfWeekMask=32, // Friday bitmask
						RecurrenceDayOfMonth=null,
						RecurrenceInstance=ConstantUtil.HOLIDAY_RECINSTANCE_THIRD, // third Friday in May
						IsAllDay=true));
		hds.add(new Holiday(
						Name='Fourth Friday in May Holiday',
						ActivityDate=Date.newInstance(2014,5,23), 	// holiday on May 23rd 2014 (Friday)
						IsRecurrence=true, 
						RecurrenceType=ConstantUtil.HOLIDAY_RECTYPE_YEARLYNTH, 
						RecurrenceMonthOfYear=ConstantUtil.MONTHS_I2S.get(5), 
						RecurrenceDayOfWeekMask=32, // Friday bitmask
						RecurrenceDayOfMonth=null,
						RecurrenceInstance=ConstantUtil.HOLIDAY_RECINSTANCE_FOURTH, // fourth Friday in May
						IsAllDay=true));
		hds.add(new Holiday(
						Name='Last Friday in May Holiday',
						ActivityDate=Date.newInstance(2014,5,30), 	// holiday on May 30th 2014 (Friday)
						IsRecurrence=true, 
						RecurrenceType=ConstantUtil.HOLIDAY_RECTYPE_YEARLYNTH, 
						RecurrenceMonthOfYear=ConstantUtil.MONTHS_I2S.get(5), 
						RecurrenceDayOfWeekMask=32, // Friday bitmask
						RecurrenceDayOfMonth=null,
						RecurrenceInstance=ConstantUtil.HOLIDAY_RECINSTANCE_LAST, // last Friday in May
						IsAllDay=true));
		hds.add(new Holiday(
						Name='Christmas',
						ActivityDate=Date.newInstance(2014,12,25), 	// holiday on Dec 25th (Thursday)
						IsRecurrence=true, 
						RecurrenceType=ConstantUtil.HOLIDAY_RECTYPE_YEARLY, 
						RecurrenceMonthOfYear=ConstantUtil.MONTHS_I2S.get(12), 
						RecurrenceDayOfWeekMask=null,
						RecurrenceDayOfMonth=25,
						RecurrenceInstance=null,
						IsAllDay=true));
		hds.add(new Holiday(
						Name='Boxing Day',
						ActivityDate=Date.newInstance(2014,12,26), 	// holiday on Dec 26th (Friday)
						IsRecurrence=true, 
						RecurrenceType=ConstantUtil.HOLIDAY_RECTYPE_YEARLY, 
						RecurrenceMonthOfYear=ConstantUtil.MONTHS_I2S.get(12), 
						RecurrenceDayOfWeekMask=null,
						RecurrenceDayOfMonth=26,
						RecurrenceInstance=null,
						IsAllDay=true));
		
		return hds;
	}
}