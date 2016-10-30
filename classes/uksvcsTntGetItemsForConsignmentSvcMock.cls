/**
* File Name   :    uksvcsTntGetItemsForConsignmentSvcMock.cls
* Description :    Mock class to test uksvcsTntGetItemsForConsignmentService service
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 27/08/2014 Liza Romanenko Initial version, TNT-547
* 0.2 03/09/2014 James Melville Updated for new WSDL
*/
@isTest
global class uksvcsTntGetItemsForConsignmentSvcMock implements WebServiceMock{
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
        
        uksvcsTntGetItemsForConsignment.ResponseMessage_MasterType respElement = new uksvcsTntGetItemsForConsignment.ResponseMessage_MasterType();  
        respElement.itms = new uksvcsTntGetItemsForConsignment.ItemsResponse_MasterType();
        respElement.itms.itm = new List<uksvcsTntGetItemsForConsignment.Item_MasterType>();
        
        uksvcsTntGetItemsForConsignment.Item_MasterType itm = new uksvcsTntGetItemsForConsignment.Item_MasterType();
        itm.itmNum = '1111';
        itm.itmstrck = new uksvcsTntGetItemsForConsignment.ItemsTracking_MasterType();
        itm.itmstrck.itmtrck = new List<uksvcsTntGetItemsForConsignment.ItemTracking_MasterType>();
        
        uksvcsTntGetItemsForConsignment.ItemTracking_MasterType itTr = new uksvcsTntGetItemsForConsignment.ItemTracking_MasterType();
        itTr.locCd = '123';
        itTr.scnDtTm = DateTime.now();
        
        itm.itmstrck.itmtrck.add(itTr);
        
        respElement.itms.itm.add(itm);
        
        response.put('response_x', respElement);
    }
}