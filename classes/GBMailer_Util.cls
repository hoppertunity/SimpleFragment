/**
* File Name   :    GBMailer_Util.cls
* Description :    
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 05/08/2014 Klea Kolaric	Initial version (TNT-549)
*
*/
public with sharing class GBMailer_Util {
	
	// packages
	public static final String WS_ACCELERATOR_NAMES = 'WS-AcceleratorAddress';
	 
	// login details
	public static String GBMAILER_USERNAME { get{ return GB_Mailer_Settings__c.getInstance().Username__c; }}
	public static String GBMAILER_PASSWORD { get{ return GB_Mailer_Settings__c.getInstance().Password__c; }}
	
	// codes used to identify address parts by the system
	public static final String CODE_POSTCODE = 'PCOD';
	public static final String CODE_TOWN = 'TOWN';
	public static final String CODE_COUNTY = 'CNTY';
	public static final String CODE_ORGANISATION = 'ORGN';
	public static final String CODE_BUILDINGNAME = 'BNAM';
	public static final String CODE_BUILDINGNUMBER = 'BNUM';
	public static final String CODE_STREET = 'THOR';			// Thorofare
	public static final String CODE_SUBPREMISE = 'SUBB';
	//public static final String CODE_? = 'DPTH';
	public static final String CODE_DEPLOC = 'DPLO';			// Dependent Locality
	public static final String CODE_DUBDEPLOC = 'DDLO';			// Double Dependent Locality
	
	public static final Integer GBMAILER_SYSTEM_LIMIT = 200;
	
	public static GBMailer_Service.GBPortalWSSoap wsCall = new GBMailer_Service.GBPortalWSSoap();
    public static GBMailer_Service.AcceleratorSearchReturn results;
    public static String sessionId;
    
    public static List<Map<String, String>> getAddresses(String postcode) 
    {
        GBMailer_Service.AcceleratorAddress searchAddress = new GBMailer_Service.AcceleratorAddress();
        searchAddress.text = postcode;
        LIST<MAP<String, String>> addresses = new LIST<MAP<String, String>>();
        
        sessionId = createSession();
        results = callGBMailerServicePinpoint(sessionId, postcode);
        wsCall.TerminateSession(sessionId);
        System.debug('===> results = ' + results);
        addresses = splitAddress(results);
        
        return addresses;
    }
    
    public static String createSession()
    {
        return wsCall.CreateSession();
    }
    
    public static GBMailer_Service.AcceleratorSearchReturn callGBMailerServicePinpoint(String sId, String pc)
    {
        return wsCall.Pinpoint(WS_ACCELERATOR_NAMES,	// name of the GBPortal package to run your search
        						sId,	 				// your session handle
        						GBMAILER_USERNAME, 		// your username
        						GBMAILER_PASSWORD, 		// your password
        						pc, 					// full or partial postcode for the search
        						'', 					// building name, number, company, or PO Box
        						'Three address lines, town, county and postcode',	// name of the GBPortal address format to use
        						'', 					// list of related-data mnemonics to be returned with the data
        						0, 						// 	offset
        						0);						// if >0, presents limit
    }
    
    public static List<Map<String, String>> splitAddress(GBMailer_Service.AcceleratorSearchReturn sreturn)
    {
        try {
            LIST<MAP<String, String>> addresses = new LIST<MAP<String, String>>();
            Set<String> existingNumbers = new Set<String>();
            
            for (GBMailer_Service.AcceleratorAddress address : sreturn.Addresses.AcceleratorAddress) 
            {
                GBMailer_Service.ArrayOfAcceleratorItem items = address.Items;
                MAP<String, String> addressItems = new MAP<String, String>();
                
                if (!existingNumbers.contains(address.Text)){
                    for (GBMailer_Service.AcceleratorItem item : items.AcceleratorItem) {
                        addressItems.put(item.Key, item.Value);
                    }
                    
                    existingNumbers.add(address.Text);
                    system.debug('==> addressItems ' + addressItems);
                    addresses.add(addressItems);
                } 
            }
            
            return addresses;
        } catch (Exception ex) {
            return null;
        }
    }

}