/**
* File Name   :    BookingLineItemTriggerHelperTest.cls
* Description :    
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 08/09/2014 Klea Kolaric	Initial Version TNT-1604
* 0.2 23/10/2015 Darryl Hopper	Added and amended code where DH comments to turn off new duplicate checks
*/
@isTest
private class BookingLineItemTriggerHelperTest {

	static Booking__c createBaseBooking(String id)
	{
		//DH added 23/10/15 to allow duplicates whilst testing
        Database.DMLOptions dml = new Database.DMLOptions();
		dml.DuplicateRuleHeader.AllowSave = true; 
        //
        
        Account a = TestUtil.createAccountClient();
		insert a;
		Account_Address__c aaCol = TestUtil.createAccountAddress(a.Id,null);
		aaCol.Default__c = true;
		insert aaCol;
		Contact con = TestUtil.createContact(a.Id);
		con.FirstName = con.FirstName + id;
		//Modified by DH to use database method instead of insert to alow turn off duplicate checking for testing
        database.insert(con,dml);
        //insert con;
		Account depot = TestUtil.createAccountDepot();
		insert depot;
		
		Booking__c bo = new Booking__c();
		bo.Name = 'test book';
		bo.Account__c = a.Id;
		bo.Order_Contact__c = con.Id;
		bo.Collection_Contact__c = con.Id;
		bo.Coll_Account_Address__c = aaCol.id;
		bo.Collection_Depot__c = depot.id;
		bo.Commodity__c = 'SACK';
		bo.Status__c = ConstantUtil.PLVAL_BOOKING_STATUS_CONFIRMED;
		return bo;
	}
	
	// trigger coverage
    static testMethod void quickRun()
    {
		Booking__c bo = createBaseBooking(null);
		insert bo;
		
		Booking_Line_Item__c bli = new Booking_Line_Item__c(Booking__c = bo.id);
		bli.Weight__c = 20;
		bli.Number_of_Items__c = 1;
		bli.Height__c = 100;
		bli.Length__c = 100;
		bli.Width__c = 100;
		
		Test.startTest();
		insert bli;
		update bli;
		delete bli;
		Test.stopTest();
    }
    
    static testMethod void testUpdateBookingTotals()
    {
		//Added by DH 23/10/15 
        Database.DMLOptions dml = new Database.DMLOptions();
		dml.DuplicateRuleHeader.AllowSave = true; 
        Booking__c bo1 = createBaseBooking(null);	// will ovewrite null
		bo1.Total_Items__c = null;
		bo1.Total_Weight__c = null;
		Booking__c bo2 = createBaseBooking('c1');	// will overwrite less
		bo2.Total_Items__c = 1;
		bo2.Total_Weight__c = 1;
		Booking__c bo3 = createBaseBooking('c2');	// will not overwrite more
		bo3.Total_Items__c = 1000;
		bo3.Total_Weight__c = 1000;
		insert new List<Booking__c>{bo1,bo2,bo3};
		
		Double weight = 20;
		Double noItems = 3;
		List<Booking_Line_Item__c> blis = new List<Booking_Line_Item__c>();
		
		blis.add(new Booking_Line_Item__c(Booking__c = bo1.id, Weight__c = weight, Number_of_Items__c = noItems, 
					Length__c = 10, Width__c = 10, Height__c = 10, Booking_Line_Item_Id__c = '000'));
		blis.add(new Booking_Line_Item__c(Booking__c = bo2.id, Weight__c = weight, Number_of_Items__c = noItems, 
					Length__c = 10, Width__c = 10, Height__c = 10, Booking_Line_Item_Id__c = '001'));
		blis.add(new Booking_Line_Item__c(Booking__c = bo3.id, Weight__c = weight, Number_of_Items__c = noItems, 
					Length__c = 10, Width__c = 10, Height__c = 10, Booking_Line_Item_Id__c = '010'));
		blis.add(new Booking_Line_Item__c(Booking__c = bo1.id, Weight__c = weight, Number_of_Items__c = 0, 
					Booking_Line_Item_Id__c = '011'));
		blis.add(new Booking_Line_Item__c(Booking__c = bo2.id, Weight__c = weight, Number_of_Items__c = 0, 
					Length__c = 10, Width__c = 10, Height__c = 10, Booking_Line_Item_Id__c = '100'));
		blis.add(new Booking_Line_Item__c(Booking__c = bo3.id, Weight__c = weight, Number_of_Items__c = 0, 
					Length__c = 10, Width__c = 10, Height__c = 10, Booking_Line_Item_Id__c = '101'));
		blis.add(new Booking_Line_Item__c(Booking__c = bo1.id, Weight__c = null, Number_of_Items__c = noItems, 
					Length__c = 10, Width__c = 10, Height__c = 10, Booking_Line_Item_Id__c = '111'));
		blis.add(new Booking_Line_Item__c(Booking__c = bo2.id, Weight__c = null, Number_of_Items__c = noItems, 
					Length__c = 10, Width__c = 10, Height__c = 10, Booking_Line_Item_Id__c = '222'));
		blis.add(new Booking_Line_Item__c(Booking__c = bo3.id, Weight__c = null, Number_of_Items__c = noItems, 
					Length__c = 10, Width__c = 10, Height__c = 10, Booking_Line_Item_Id__c = '333'));
		
		User u = TestUtil.createIntegrationUser();	// avoid all validation rules
		insert u;
		
		Test.startTest();
		System.runAs(u) { insert blis; }
		Test.stopTest();
		
		Double vol = 10*10*10*noItems*2;
		system.assertEquals(1,[select count() from Booking__c
			where id = :bo1.id and Total_Items__c = :2*noItems and Total_Weight__c = :noItems*weight and Total_Volume__c = :vol]);
		system.assertEquals(1,[select count() from Booking__c 
			where id = :bo2.id and Total_Items__c = :2*noItems and Total_Weight__c = :noItems*weight and Total_Volume__c = :vol]);
		system.assertEquals(1,[select count() from Booking__c 
			where id = :bo3.id and Total_Items__c = :bo3.Total_Items__c and Total_Weight__c = :bo3.Total_Weight__c and Total_Volume__c = :vol]);
    }
}