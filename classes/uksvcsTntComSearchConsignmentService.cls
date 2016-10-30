//Generated by wsdl2apex

public class uksvcsTntComSearchConsignmentService {
    public class searchConsignmentPort {
        public String endpoint_x = TNT_Integration__c.getInstance().Search_Consignment_Service__c;
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://express.tnt.com/service/schema/srchcon/v1', 'uksvcsTntComSearchConsignment', 'http://express.tnt.com/service/wsdl/srchcon/v1', 'uksvcsTntComSearchConsignmentService', 'http://express.tnt.com/general/schema/tnterror/v1', 'uksvcsTntComError', 'http://express.tnt.com/general/schema/payloadheader/v1', 'uksvcsTntComGenericPayloadHeader', 'http://express.tnt.com/general/schema/objects/generic/v1', 'uksvcsTntComGenericObjects'};
        public uksvcsTntComSearchConsignment.ResponseMessage_MasterType searchConsignment(uksvcsTntComGenericPayloadHeader.payloadHeader hdr,uksvcsTntComSearchConsignment.ConsignmentRequest_MasterType con) {
            uksvcsTntComSearchConsignment.RequestMessage_MasterType request_x = new uksvcsTntComSearchConsignment.RequestMessage_MasterType();
            request_x.hdr = hdr;
            request_x.con = con;
            uksvcsTntComSearchConsignment.ResponseMessage_MasterType response_x;
            Map<String, uksvcsTntComSearchConsignment.ResponseMessage_MasterType> response_map_x = new Map<String, uksvcsTntComSearchConsignment.ResponseMessage_MasterType>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'search',
              'http://express.tnt.com/service/schema/srchcon/v1',
              'searchConsignmentRequest',
              'http://express.tnt.com/service/schema/srchcon/v1',
              'searchConsignmentResponse',
              'uksvcsTntComSearchConsignment.ResponseMessage_MasterType'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
    
    public class searchConsignment2Port {
        public String endpoint_x = TNT_Integration__c.getInstance().Search_Consignment_Service__c;
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://express.tnt.com/service/wsdl/srchcon/v2', 'uksvcsTntComSearchConsignment', 'http://express.tnt.com/service/schema/srchcon/v2', 'uksvcsTntComSearchConsignmentService', 'http://express.tnt.com/general/schema/tnterror/v1', 'uksvcsTntComError', 'http://express.tnt.com/general/schema/payloadheader/v1', 'uksvcsTntComGenericPayloadHeader', 'http://express.tnt.com/general/schema/objects/generic/v1', 'uksvcsTntComGenericObjects'};
        public uksvcsTntComSearchConsignment.ResponseMessage_MasterType searchConsignment2(uksvcsTntComSearchConsignment.ConsignmentRequest_MasterType con,uksvcsTntComGenericPayloadHeader.payloadHeader hdr) {
            uksvcsTntComSearchConsignment.RequestMessage_MasterType request_x = new uksvcsTntComSearchConsignment.RequestMessage_MasterType();
            request_x.con = con;
            request_x.hdr = hdr;
            uksvcsTntComSearchConsignment.ResponseMessage_MasterType response_x;
            Map<String, uksvcsTntComSearchConsignment.ResponseMessage_MasterType> response_map_x = new Map<String, uksvcsTntComSearchConsignment.ResponseMessage_MasterType>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'search',
              'http://express.tnt.com/service/schema/srchcon/v2',
              'searchConsignment2Request',
              'http://express.tnt.com/service/schema/srchcon/v2',
              'searchConsignment2Response',
              'uksvcsTntComSearchConsignment.ResponseMessage_MasterType'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
}