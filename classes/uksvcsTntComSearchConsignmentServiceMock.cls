/**
* File Name   :    uksvcsTntComSearchConsignmentServiceMock.cls
* Description :    Mock class to test Search service
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 09/09/2014 Liza Romanenko	Initial version, TNT-546
*/
@isTest
global class uksvcsTntComSearchConsignmentServiceMock implements WebServiceMock{
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
		respElement.consearch = new uksvcsTntComSearchConsignment.ConsignmentResponse_ContainerType();
		respElement.consearch.con = new List<uksvcsTntComSearchConsignment.Consignment_MasterType>();
		uksvcsTntComSearchConsignment.Consignment_MasterType con = new uksvcsTntComSearchConsignment.Consignment_MasterType();
		con.unqConNum = '111';
		con.delAddr = new uksvcsTntComSearchConsignment.ShortAddress_MasterType();
		con.pod = new uksvcsTntComSearchConsignment.ShortProofOfDelivery_MasterType();
		con.curConSts = new uksvcsTntComSearchConsignment.CurrentConsignmentStatus_MasterType();
		respElement.consearch.con.add(con);
       	      	
      	response.put('response_x', respElement);
    }
}