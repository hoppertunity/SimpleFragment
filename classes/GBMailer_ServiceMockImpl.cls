@isTest
global class GBMailer_ServiceMockImpl implements WebServiceMock{
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
        
        Object respElement;   	
        if(responseType == 'GBMailer_Service.CreateSessionResponse_element'){
        	GBMailer_Service.CreateSessionResponse_element res = new GBMailer_Service.CreateSessionResponse_element();
        	res.CreateSessionResult = 'TestCode';
        	respElement = res;
        }
        
        if(responseType == 'GBMailer_Service.PinpointResponse_element'){
        	GBMailer_Service.PinpointResponse_element res = new GBMailer_Service.PinpointResponse_element();
        	res.PinpointResult = new GBMailer_Service.AcceleratorSearchReturn();
        	res.PinpointResult.Addresses = new GBMailer_Service.ArrayOfAcceleratorAddress();
        	res.PinpointResult.Addresses.AcceleratorAddress = new List<GBMailer_Service.AcceleratorAddress>();
        	GBMailer_Service.AcceleratorAddress address = new GBMailer_Service.AcceleratorAddress();
        	address.Items = new GBMailer_Service.ArrayOfAcceleratorItem();
        	address.Items.AcceleratorItem = new List<GBMailer_Service.AcceleratorItem>();
        	
        	GBMailer_Service.AcceleratorItem item = new GBMailer_Service.AcceleratorItem();
        	item.Key = GBMailer_Util.CODE_ORGANISATION;
        	item.Value = 'Address Name';
        	address.Items.AcceleratorItem.add(item);
        	
        	item = new GBMailer_Service.AcceleratorItem();
        	item.Key = GBMailer_Util.CODE_SUBPREMISE;
        	item.Value = 'FLAT 1-2';
        	address.Items.AcceleratorItem.add(item);
        	
        	item = new GBMailer_Service.AcceleratorItem();
        	item.Key = GBMailer_Util.CODE_BUILDINGNUMBER;
        	item.Value = '11';
        	address.Items.AcceleratorItem.add(item);
        	
        	item = new GBMailer_Service.AcceleratorItem();
        	item.Key = GBMailer_Util.CODE_STREET;
        	item.Value = 'ONE ROAD';
        	address.Items.AcceleratorItem.add(item);
        	
        	item = new GBMailer_Service.AcceleratorItem();
        	item.Key = GBMailer_Util.CODE_TOWN;
        	item.Value = 'LONDON';
        	address.Items.AcceleratorItem.add(item);
        	
        	item = new GBMailer_Service.AcceleratorItem();
        	item.Key = GBMailer_Util.CODE_POSTCODE;
        	item.Value = 'SW15 1TW';
        	address.Items.AcceleratorItem.add(item);
        	
        	res.PinpointResult.Addresses.AcceleratorAddress.add(address);
        	respElement = res;
        }
        
        if(responseType == 'GBMailer_Service.TerminateSessionResponse_element'){
        	GBMailer_Service.TerminateSessionResponse_element res = new GBMailer_Service.TerminateSessionResponse_element();
        	res.TerminateSessionResult = true;
        	respElement = res;
        }
		
		
      	
      	response.put('response_x', respElement);
    }
}