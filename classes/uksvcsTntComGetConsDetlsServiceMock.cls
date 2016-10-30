/**
* File Name   :    uksvcsTntComGetConsDetlsServiceMock.cls
* Description :    Mock class to test uksvcsTntComGetConsignmentDetailsService service
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 27/08/2014 Liza Romanenko Initial version, TNT-547
* 0.2 03/09/2014 James Melville Updated for new WSDL
*/
@isTest
global class uksvcsTntComGetConsDetlsServiceMock implements WebServiceMock{
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
        
        uksvcsTntComSearchConsignment.ResponseMessage_MasterType respElement = new uksvcsTntComSearchConsignment.ResponseMessage_MasterType();  
        respElement.con = new uksvcsTntComSearchConsignment.ConsignmentResponse_MasterType();
        respElement.con.unqConNum = '12345';
        respElement.con.tntConNum = '12345';
        respElement.con.orgConNum = '12345';
        
        respElement.con.pod = new uksvcsTntComSearchConsignment.DetailProofOfDelivery_MasterType();
        respElement.con.pod.podSts = 'Status';
        respElement.con.pod.sosInd = true;
        
        respElement.con.conStss = new uksvcsTntComSearchConsignment.ConsignmentStatusHistory_ContainerType();
        respElement.con.conStss.conSts = new List<uksvcsTntComSearchConsignment.DetailConsignmentStatusHistory_MasterType>();
        
        uksvcsTntComSearchConsignment.DetailConsignmentStatusHistory_MasterType conH = new uksvcsTntComSearchConsignment.DetailConsignmentStatusHistory_MasterType();
        conH.stsDtTm = DateTime.now();
        
        respElement.con.act = new  uksvcsTntComSearchConsignment.Account_MasterType();
        respElement.con.addr = new  uksvcsTntComSearchConsignment.DetailAddress_MasterType();
        respElement.con.rtng = new  uksvcsTntComSearchConsignment.ConsignmentRating_MasterType();
        respElement.con.dscrps = new  uksvcsTntComSearchConsignment.ConsignmentDiscrepancy_ContainerType();
        respElement.con.dscrps.dscrp = new List<uksvcsTntComSearchConsignment.ConsignmentDiscrepancy_MasterType>();
        uksvcsTntComSearchConsignment.ConsignmentDiscrepancy_MasterType dscrp = new uksvcsTntComSearchConsignment.ConsignmentDiscrepancy_MasterType();
        
        respElement.con.dscrps.dscrp.add(dscrp);        
        respElement.con.conStss.conSts.add(conH);
        response.put('response_x', respElement);
    }
}