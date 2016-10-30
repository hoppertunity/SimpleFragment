/**
* File Name   :    BookingLineItemTriggerHelper.cls
* Description :    
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 08/09/2014 Klea Kolaric	Initial Version TNT-1604
*/
public with sharing class BookingLineItemTriggerHelper {
	
	public static void onAfterInsertHandler(List<Booking_Line_Item__c> triggerNew)
	{
		updateBookingTotals(triggerNew);
	}
	
	public static void onAfterUpdateHandler(List<Booking_Line_Item__c> triggerNew, Map<Id,Booking_Line_Item__c> triggerOldMap)
	{
		updateBookingTotals(triggerNew);
	}
	
	public static void onAfterDeleteHandler(List<Booking_Line_Item__c> triggerOld)
	{
		updateBookingTotals(triggerOld);
	}

	public static void updateBookingTotals(List<Booking_Line_Item__c> blis)
	{
		Set<Id> bookIds = new Set<Id>();
		for(Booking_Line_Item__c bli : blis)
		{
			bookIds.add(bli.Booking__c);
		}
		
		// tried to retrieve all info in aggregate query, but can't group on double fields
		Map<Id,Booking__c> books = new Map<Id,Booking__c>([select id, Total_Items__c, Total_Weight__c, Total_Volume__c 
															from Booking__c where id in :bookIds]);
		
		AggregateResult[] bookTotals = [select Booking__c, SUM(Number_of_Items__c), SUM(Total_Item_Weight__c), SUM(Volume__c)
		      							from Booking_Line_Item__c
		      							where Booking__c in :bookIds
										group by Booking__c];
		
		for(AggregateResult ar : bookTotals)
		{
			Booking__c b = books.get((id) ar.get('Booking__c'));
			Double totalItems = (Double) ar.get('expr0');
			Double totalWeight = (Double) ar.get('expr1');
			Double totalVolume = (Double) ar.get('expr2');
			Boolean hasChanged = false;
			
			if(b.Total_Items__c == null || totalItems > b.Total_Items__c)
			{
				b.Total_Items__c = totalItems;
				hasChanged = true;
			}
			if(b.Total_Weight__c == null || totalWeight > b.Total_Weight__c)
			{
				b.Total_Weight__c = totalWeight;
				hasChanged = true;
			}
			if(b.Total_Volume__c != totalVolume)
			{
				b.Total_Volume__c = totalVolume;
				hasChanged = true;
			}
			if(!hasChanged)	// if there is a need for an update
			{
				books.remove(b.id);
			}
		}
		if(!books.isEmpty())
		{
			try{
				update books.values();
			} catch (System.DmlException ex){
				blis[0].addError(ex.getDmlMessage(0));
			}
		}
	}

}