/**
* File Name   :    uksvcsTntComBookingServiceMock.cls
* Description :    Mock class to test uksvcsTntComBookingService service
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 01/09/2014 Liza Romanenko	Initial version, TNT-1414
*/
@isTest
global class uksvcsTntComBookingServiceMock implements WebServiceMock{
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
		
		uksvcsTntComBooking.ResponseMessage_MasterType respElement = new uksvcsTntComBooking.ResponseMessage_MasterType();
		respElement.bkng = new uksvcsTntComBooking.BookingResponse_MasterType();
       	respElement.bkng.ackInd = true;
      	
      	response.put('response_x', respElement);
    }

}