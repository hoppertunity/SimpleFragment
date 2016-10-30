/**
* File Name   :    OL_DepotRoutingHelper.cls
* Description :    
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 04/09/2014 Klea Kolaric	TNT-542	find collection depot
*/
public with sharing class OL_DepotRoutingHelper {
	
	public static String errorMsg;
	public static Id routingTableId;
	public static Id depotRoutingId;
	public static String cutOffTime; 
	
	public static Account findCollectionDepot(String collPostcode, String collDistrict, String collTown, Id lobId, Datetime collTime)
	{
		// reset variables
		routingTableId = null;
		depotRoutingId = null;
		cutOffTime = null;
		
		errorMsg = '';
		errorMsg += String.isBlank(collPostcode) ? '- missing collection postcode<br/>' : '';
		errorMsg += String.isBlank(collTown) ? '- missing collection town<br/>' : '';
		errorMsg += lobId == null ? '- missing line of business<br/>' : '';
		errorMsg += collTime == null ? '- missing collection time<br/>' : '';
		if(String.isNotBlank(errorMsg))
		{
			errorMsg = 'Could not calculate depot:<br/>' + errorMsg;
			return null;
		}
		else
		{
			errorMsg = null;
		}
		
		Routing_Table__c rt = findRoutingTableEntry(collPostcode, collDistrict, collTown);
		
        if(rt == null)
		{
			errorMsg = 'No Routing Table entry found.';
			return null;
		}
		
		Day__c d = findDay(rt.Depot__r.Depot_Calendar__c,collTime);
		if(d == null)
		{
			errorMsg = 'No Calendar/Day entry found.';
			return null;
		}
		if(d.Day_Type__c.startsWith(ConstantUtil.PLVAL_DAY_DAYTYPE_NONWORKING))
		{
			errorMsg = 'Selected collection date is a non working day.';
			return null;
		}
		
		String roundGroup = d.Day_Type__c.startsWith(ConstantUtil.PLVAL_DAY_DAYTYPE_WORKING) 
			? ConstantUtil.PLVAL_DEPOTROUTING_ROUNDGROUP_NORMAL : ConstantUtil.PLVAL_DEPOTROUTING_ROUNDGROUP_SATURDAY;
		
		Account collDepot = findDepot(lobId, rt.Id, roundGroup);
		errorMsg = collDepot == null ? 'No depot found.' : null;
		routingTableId = collDepot == null ? null : rt.Id;
		return collDepot;
	}
	
	public static Routing_Table__c findRoutingTableEntry(String collPostcode, String collDistrict, String collTown)
	{
		if(String.isNotBlank(collPostcode) && collPostcode.length() > 3)
		{
			String pc = collPostcode;
	        pc = pc.substring(0, pc.length()-2);
			for(Routing_Table__c rtab : [select id, Depot__c, Depot__r.Depot_Calendar__c from Routing_Table__c 
											where Part_Postcode__c = :pc 
												and District__c = :collDistrict 
												and Town__c = :collTown 
											order by Routing_Default__c desc])	// default first
			{
				return rtab;
			}
		}
		return null;
	}
	
	public static Day__c findDay(Id calId, Datetime collTime)
	{
		for(Day__c d : [select Id, Day_Type__c from Day__c where Date__c = :collTime.date() and Calendar__c = :calId])
		{
			return d;
		}
		return null;
	}
	
	public static Account findDepot(Id lobId, Id rtId, String roundGroup)
	{
		String network = lobId == null ? null : [select Routing_Network__c from Line_of_Business__c where Id = :lobId limit 1].Routing_Network__c;
		for(Depot_Routing__c dr : [select Collection_Cut_Off_Time__c, Collection_Depot__c, Collection_Depot__r.Name, Collection_Depot__r.Depot_Number__c
									from Depot_Routing__c
									where Routing_Table__c = :rtId and Collection_Depot__c != null
										and (Line_Of_Business__c = :lobId or Line_Of_Business__c = null)
										and (Round_Group__c = :roundGroup or Round_Group__c = :ConstantUtil.PLVAL_DEPOTROUTING_ROUNDGROUP_ALL)
										and Routing_Network__c =:network
									order by Line_Of_Business__c asc nulls last])	// exact matches have precedence over nulls
		{
			depotRoutingId = dr.Id;
			cutOffTime = dr.Collection_Cut_Off_Time__c;
			return dr.Collection_Depot__r;
		}
		return null;
	}

}