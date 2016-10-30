/**
* File Name   :    OL_CodeForObjectUtil.cls
* Description :    
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 09/09/2014 Liza Romanenko	Initial version, TNT-546
*/
public with sharing class OL_CodeForObjectUtil {
	
	public static String delimitedServiceCodes {get; set;}
	public static String delimitedLobCodes {get; set;}

	public static Map<String, String> getLineOfBusinesMap(){
		Map<String, String> res = new Map<String, String>();
		delimitedLobCodes = '';
		
		for(Line_of_Business__c lob : [SELECT Name, Line_of_Business_Reference__c FROM Line_of_Business__c]){
			res.put(lob.Line_of_Business_Reference__c, lob.Name);
			delimitedLobCodes += '*' + lob.Line_of_Business_Reference__c + '*';
		}
		
		return res;
	}
	
	public static Map<String, String> getServiceMap(){
		Map<String, String> res = new Map<String, String>();
		delimitedServiceCodes = '';
		
		for(Service__c s : [SELECT Name, Service_Code__c FROM Service__c]){
			res.put(s.Service_Code__c, s.Name);
			delimitedServiceCodes += '*' + s.Service_Code__c + '*';
		}
		
		return res;
	}
}