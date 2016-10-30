/**
* File Name   :    uksvcsTntGetQuotePricingServiceMockImpl.cls
* Description :    Mock class to test Pricing service
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 11/08/2014 Liza Romanenko	Initial version, TNT-545
*/
@isTest
global class uksvcsTntGetQuotePricingServiceMockImpl implements WebServiceMock{
	global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
		
		uksvcsTntGetQuotePricing.ResponseMessage_MasterType respElement = new uksvcsTntGetQuotePricing.ResponseMessage_MasterType();  
       	respElement.qt = new uksvcsTntGetQuotePricing.QuoteResponse_MasterType();
       	respElement.qt.dels = new uksvcsTntGetQuotePricing.Deliveries_ContainerType();
       	respElement.qt.dels.del = new List<uksvcsTntGetQuotePricing.Delivery_MasterType>();
       	uksvcsTntGetQuotePricing.Delivery_MasterType del = new uksvcsTntGetQuotePricing.Delivery_MasterType();
       	del.delDt = Date.today();
       	del.delSvcs = new uksvcsTntGetQuotePricing.DeliveryServices_ContainerType();
       	del.delSvcs.delSvc = new List<uksvcsTntGetQuotePricing.DeliveryService_MasterType>();
       	
       	uksvcsTntGetQuotePricing.DeliveryService_MasterType delSvc = new uksvcsTntGetQuotePricing.DeliveryService_MasterType();
       	delSvc.svcCd = 'SC';
       	delSvc.cmm = 'ServName';
       	delSvc.qtAmt = '50.45';
       	delSvc.curCd = 'GPB';
       	delSvc.prSvcInd = false;
       	delSvc.guarSvcInd = true;
       	delSvc.srchrgs = new uksvcsTntGetQuotePricing.Surcharges_ContainerType();
       	delSvc.srchrgs.srchrg = new List<uksvcsTntGetQuotePricing.Surcharge_MasterType>();
       	uksvcsTntGetQuotePricing.Surcharge_MasterType srch = new uksvcsTntGetQuotePricing.Surcharge_MasterType();
       	srch.srchrgTypCd = 'Sch Code';
       	srch.srchrgTypNm = 'Sch Name';
       	srch.chrgAmt = '5.45';
       	srch.curCd = 'GBP';
       	srch.chrgPrcnt = '1.1';
       	
       	delSvc.srchrgs.srchrg.add(srch);
       	del.delSvcs.delSvc.add(delSvc);
       	respElement.qt.dels.del.add(del);
      	
      	response.put('response_x', respElement);
    }
}