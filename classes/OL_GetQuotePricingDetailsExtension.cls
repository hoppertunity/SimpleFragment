/**
* File Name   :    OL_GetQuotePricingDetailsExtension.cls
* Description :    
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 07/08/2014 Liza Romanenko Initial version, TNT-545
*/
public with sharing class OL_GetQuotePricingDetailsExtension {
    
    public Quote__c quote;
        
    public uksvcsTntGetQuotePricing.Deliveries_ContainerType responceData {get; set;}
    
    public Map<String, Service__c> services {get; set;}
    public String serviceKeys {get; set;}
    public Boolean errorOnLoad {get; private set;}
    private Apexpages.standardController sc;

    public OL_GetQuotePricingDetailsExtension(Apexpages.standardController stdCtrl){
        sc = stdCtrl;
        Id qId = stdCtrl.getRecord().Id;
        
        if(qId != null){
            quote = [SELECT Name, Price__c, Total_Number_of_Items__c, Total_Volume_Rounded__c, Total_Weight__c, Collection_Date__c, Collection_Postcode__c,
                    Delivery_Postcode__c, Account__r.Account_Number__c, Dangerous_Goods__c, Pallet_Pollicy__c, Carriage_Forward__c, Enhanced_Liability_Option__c,
                    Fuel_Supplement__c, Service_Name__c, Is_Guaranteed_Service__c, Is_Premium_Service__c, Delivery_Date__c, Supplements_Details__c, No_Long_Length_Items__c 
                FROM Quote__c WHERE Id = : qId];
        }
        errorOnLoad = false;
        
        fillServices();
    }
    
    public void requestPrice(){
        
        try{
            errorOnLoad = false;
            uksvcsTntGetQuotePricingService.getPricingDetailsForQuotePort port = new uksvcsTntGetQuotePricingService.getPricingDetailsForQuotePort();
            
            port.inputHttpHeaders_x = new map<string,string> {'Username' => TNT_Integration__c.getInstance().Username__c, 
                                                              'Password' => TNT_Integration__c.getInstance().Password__c};
            
            uksvcsTntComGenericPayloadHeader.payloadHeader 
                hdr = new uksvcsTntComGenericPayloadHeader.payloadHeader();
            uksvcsTntGetQuotePricing.QuoteRequest_MasterType
                con = new uksvcsTntGetQuotePricing.QuoteRequest_MasterType ();
            
            if(quote.Account__r.Account_Number__c != null) {
                con.actNum = quote.Account__r.Account_Number__c;
            }
            con.rqstdColDt = quote.Collection_Date__c;
            con.colPstCd = quote.Collection_Postcode__c;
            con.delPstCd = quote.Delivery_Postcode__c;
            con.totItms = String.valueOf(quote.Total_Number_of_Items__c);
            con.totVol = String.valueOf(quote.Total_Volume_Rounded__c);
            con.totActWght = String.valueOf(quote.Total_Weight__c);
            con.wghtUOM = 'KG';
            con.hazGdInd = quote.Dangerous_Goods__c;
            con.plltInd = quote.Pallet_Pollicy__c > 0 ? true : false;
            con.crrgFwdInd = quote.Carriage_Forward__c;
            con.enhLbltyInd = (quote.Enhanced_Liability_Option__c == ConstantUtil.PLVAL_QUOTE_ENHANCED_LIABILITY_OPTION_NONE || quote.Enhanced_Liability_Option__c == null) ? false : true;
            
            con.LongLengths = String.valueOf(quote.No_Long_Length_Items__c);
            
            if(quote.Fuel_Supplement__c != null) {
                con.fuelSrchrg = String.valueOf(quote.Fuel_Supplement__c);
            }
            
            uksvcsTntGetQuotePricing.ResponseMessage_MasterType resp;
            
            if(!ConstantUtil.INTEGRATION_ACCESS) throw new ConstantUtil.IntegrationAccessDeniedException(ConstantUtil.INTEGRATION_EXMSG);
            port.timeout_x = ConstantUtil.INTEGRATION_TIMEOUT;
            resp = port.getPricingDetailsForQuote(hdr, con);
            
            if(resp.qt != null && resp.qt.dels != null){
                responceData =  resp.qt.dels;
            } 
            else
            {
                errorOnLoad = true;
            }
            
            if(resp.hdr != null && resp.hdr.infoMsg != null){
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, resp.hdr.infoMsg));
            }
        } catch (Exception ex) {
            Apexpages.addMessages(ex);
            responceData = new uksvcsTntGetQuotePricing.Deliveries_ContainerType();
            errorOnLoad = true;
        }
        
    }
    
    public PageReference savePrice(){
        try{
            for(uksvcsTntGetQuotePricing.Delivery_MasterType dt : responceData.del) {
                if(dt.selected){
                    for(uksvcsTntGetQuotePricing.DeliveryService_MasterType ds : dt.delSvcs.delSvc){
                        if(ds.selected){
                            //get service Name
                            List<Service__c> service = [SELECT Name FROM Service__c WHERE Service_Code__c = : ds.svcCd]; 
                            quote.Delivery_Date__c = dt.delDt;
                            quote.Service_Name__c = (service != null && !service.isEmpty()) ? service[0].Name : ds.svcCd;
                            quote.Is_Guaranteed_Service__c = ds.guarSvcInd;
                            quote.Is_Premium_Service__c = ds.prSvcInd;
                            quote.Price__c = Decimal.valueOf(ds.qtAmt);
                            String supplementsDetails = '';
                            for(uksvcsTntGetQuotePricing.Surcharge_MasterType sd : ds.srchrgs.srchrg){
                                supplementsDetails += sd.srchrgTypCd + ' \t' + sd.srchrgTypNm;
                                supplementsDetails += String.isEmpty(sd.chrgAmt) ? '' : ' \t' + sd.chrgAmt + ' ' + sd.curCd;
                                supplementsDetails += String.isEmpty(sd.chrgPrcnt) ? '' : ' \t' + sd.chrgPrcnt + '%';
                                supplementsDetails += '\n';
                            }
                            quote.Supplements_Details__c = supplementsDetails;
                                                       
                            quote.Reason_for_Not_Booking__c = ((Quote__c)sc.getRecord()).Reason_for_Not_Booking__c;
                            
                            upsert quote;
                            return new PageReference('/' + quote.Id);
                        }
                    }
                    break;
                }
            }
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Please select service.'));
        } catch(Exception ex){
            Apexpages.addMessages(ex);
        }
        return null;
    }
    
    public PageReference cancel(){
        
        return new PageReference('/' + quote.Id);
    }
    
    public void fillServices() {
        services = new Map<String, Service__c>();
        serviceKeys = '';
            
        for(Service__c a : [SELECT Name, Service_Code__c FROM Service__c 
                WHERE Service_Code__c != null ORDER BY Name]){
            services.put(a.Service_Code__c, a);
            serviceKeys += '*' + a.Service_Code__c + '*';
        }       
        
    }
    

}