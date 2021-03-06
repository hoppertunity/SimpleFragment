//Generated by wsdl2apex

public class uksvcsTntGetItemsForConsignmentService {
    public class getItemsForConsignmentPort {
        public String endpoint_x = TNT_Integration__c.getInstance().Consignment_Items_Service__c;
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://express.tnt.com/service/schema/getitmsforcon/v1', 'uksvcsTntGetItemsForConsignment', 'http://express.tnt.com/general/schema/enums/generic/v1', 'ukTntComGenericEnums', 'http://express.tnt.com/service/wsdl/getitmsforcon/v1', 'uksvcsTntGetItemsForConsignmentService', 'http://express.tnt.com/general/schema/tnterror/v1', 'uksvcsTntComError', 'http://express.tnt.com/general/schema/payloadheader/v1', 'uksvcsTntComGenericPayloadHeader', 'http://express.tnt.com/general/schema/objects/generic/v1', 'uksvcsTntComGenericObjects'};
        public uksvcsTntGetItemsForConsignment.ResponseMessage_MasterType getItemsForConsignment(uksvcsTntComGenericPayloadHeader.payloadHeader hdr,uksvcsTntGetItemsForConsignment.ItemRequest_MasterType itm) {
            uksvcsTntGetItemsForConsignment.RequestMessage_MasterType request_x = new uksvcsTntGetItemsForConsignment.RequestMessage_MasterType();
            request_x.hdr = hdr;
            request_x.itm = itm;
            uksvcsTntGetItemsForConsignment.ResponseMessage_MasterType response_x;
            Map<String, uksvcsTntGetItemsForConsignment.ResponseMessage_MasterType> response_map_x = new Map<String, uksvcsTntGetItemsForConsignment.ResponseMessage_MasterType>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'get',
              'http://express.tnt.com/service/schema/getitmsforcon/v1',
              'getItemsForConsignmentRequest',
              'http://express.tnt.com/service/schema/getitmsforcon/v1',
              'getItemsForConsignmentResponse',
              'uksvcsTntGetItemsForConsignment.ResponseMessage_MasterType'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
}