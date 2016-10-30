//Generated by wsdl2apex

public class uksvcsTntGetQuotePricing {
    public class RequestMessage_MasterType {
        public uksvcsTntComGenericPayloadHeader.payloadHeader hdr;
        public uksvcsTntGetQuotePricing.QuoteRequest_MasterType qt;
        private String[] hdr_type_info = new String[]{'hdr','http://express.tnt.com/service/schema/gpdfq/v1',null,'1','1','false'};
        private String[] qt_type_info = new String[]{'qt','http://express.tnt.com/service/schema/gpdfq/v1',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://express.tnt.com/service/schema/gpdfq/v1','false','false'};
        private String[] field_order_type_info = new String[]{'hdr','qt'};
    }
    public class QuoteRequest_MasterType {
        public String qtNum;
        public String actNum;
        public Date rqstdColDt;
        public String colPstCd;
        public String delPstCd;
        public String totItms;
        public String totVol;
        public String totActWght;
        public String wghtUOM;
        public Boolean hazGdInd;
        public Boolean plltInd;
        public Boolean crrgFwdInd;
        public Boolean enhLbltyInd;
        public String fuelSrchrg;
        public String LongLengths;
        private String[] qtNum_type_info = new String[]{'qtNum','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','1','false'};
        private String[] actNum_type_info = new String[]{'actNum','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','1','false'};
        private String[] rqstdColDt_type_info = new String[]{'rqstdColDt','http://express.tnt.com/service/schema/gpdfq/v1',null,'1','1','false'};
        private String[] colPstCd_type_info = new String[]{'colPstCd','http://express.tnt.com/service/schema/gpdfq/v1',null,'1','1','false'};
        private String[] delPstCd_type_info = new String[]{'delPstCd','http://express.tnt.com/service/schema/gpdfq/v1',null,'1','1','false'};
        private String[] totItms_type_info = new String[]{'totItms','http://express.tnt.com/service/schema/gpdfq/v1',null,'1','1','false'};
        private String[] totVol_type_info = new String[]{'totVol','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','1','false'};
        private String[] totActWght_type_info = new String[]{'totActWght','http://express.tnt.com/service/schema/gpdfq/v1',null,'1','1','false'};
        private String[] wghtUOM_type_info = new String[]{'wghtUOM','http://express.tnt.com/service/schema/gpdfq/v1',null,'1','1','false'};
        private String[] hazGdInd_type_info = new String[]{'hazGdInd','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','1','false'};
        private String[] plltInd_type_info = new String[]{'plltInd','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','1','false'};
        private String[] crrgFwdInd_type_info = new String[]{'crrgFwdInd','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','1','false'};
        private String[] enhLbltyInd_type_info = new String[]{'enhLbltyInd','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','1','false'};
        private String[] fuelSrchrg_type_info = new String[]{'fuelSrchrg','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','1','false'};
        private String[] LongLengths_type_info = new String[]{'LongLengths','http://express.tnt.com/service/schema/gpdfq/v1',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://express.tnt.com/service/schema/gpdfq/v1','false','false'};
        private String[] field_order_type_info = new String[]{'qtNum','actNum','rqstdColDt','colPstCd','delPstCd','totItms','totVol','totActWght','wghtUOM','hazGdInd','plltInd','crrgFwdInd','enhLbltyInd','fuelSrchrg','LongLengths'};
    }
    public class Surcharge_MasterType {
        public String srchrgTypCd {get; set;}
        public String srchrgTypNm {get; set;}
        public String chrgAmt {get; set;}
        public String curCd {get; set;}
        public String chrgPrcnt {get; set;}
        private String[] srchrgTypCd_type_info = new String[]{'srchrgTypCd','http://express.tnt.com/service/schema/gpdfq/v1',null,'1','1','false'};
        private String[] srchrgTypNm_type_info = new String[]{'srchrgTypNm','http://express.tnt.com/service/schema/gpdfq/v1',null,'1','1','false'};
        private String[] chrgAmt_type_info = new String[]{'chrgAmt','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','1','false'};
        private String[] curCd_type_info = new String[]{'curCd','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','1','false'};
        private String[] chrgPrcnt_type_info = new String[]{'chrgPrcnt','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://express.tnt.com/service/schema/gpdfq/v1','false','false'};
        private String[] field_order_type_info = new String[]{'srchrgTypCd','srchrgTypNm','chrgAmt','curCd','chrgPrcnt'};
    }
    public class DeliveryServices_ContainerType {
        public uksvcsTntGetQuotePricing.DeliveryService_MasterType[] delSvc {get; set;}
        private String[] delSvc_type_info = new String[]{'delSvc','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://express.tnt.com/service/schema/gpdfq/v1','false','false'};
        private String[] field_order_type_info = new String[]{'delSvc'};
    }
    public class DeliveryService_MasterType {
    	public Boolean selected {get; set;}
        public String svcCd {get; set;}
        public String cmm {get; set;}
        public String qtAmt {get; set;}
        public String curCd {get; set;}
        public Boolean prSvcInd {get; set;}
        public Boolean guarSvcInd {get; set;}
        public String discAmt {get; set;}
        public uksvcsTntGetQuotePricing.Surcharges_ContainerType srchrgs {get; set;}
        private String[] svcCd_type_info = new String[]{'svcCd','http://express.tnt.com/service/schema/gpdfq/v1',null,'1','1','false'};
        private String[] cmm_type_info = new String[]{'cmm','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','1','false'};
        private String[] qtAmt_type_info = new String[]{'qtAmt','http://express.tnt.com/service/schema/gpdfq/v1',null,'1','1','false'};
        private String[] curCd_type_info = new String[]{'curCd','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','1','false'};
        private String[] prSvcInd_type_info = new String[]{'prSvcInd','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','1','false'};
        private String[] guarSvcInd_type_info = new String[]{'guarSvcInd','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','1','false'};
        private String[] discAmt_type_info = new String[]{'discAmt','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','1','false'};
        private String[] srchrgs_type_info = new String[]{'srchrgs','http://express.tnt.com/service/schema/gpdfq/v1',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://express.tnt.com/service/schema/gpdfq/v1','false','false'};
        private String[] field_order_type_info = new String[]{'svcCd','cmm','qtAmt','curCd','prSvcInd','guarSvcInd','discAmt','srchrgs'};
    }
    public class Deliveries_ContainerType {
        public uksvcsTntGetQuotePricing.Delivery_MasterType[] del {get; set;}
        private String[] del_type_info = new String[]{'del','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://express.tnt.com/service/schema/gpdfq/v1','false','false'};
        private String[] field_order_type_info = new String[]{'del'};
    }
    public class Delivery_MasterType {
    	public Boolean selected {get; set;}
        public Date delDt {get; set;}
        public uksvcsTntGetQuotePricing.DeliveryServices_ContainerType delSvcs {get; set;}
        private String[] delDt_type_info = new String[]{'delDt','http://express.tnt.com/service/schema/gpdfq/v1',null,'1','1','false'};
        private String[] delSvcs_type_info = new String[]{'delSvcs','http://express.tnt.com/service/schema/gpdfq/v1',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://express.tnt.com/service/schema/gpdfq/v1','false','false'};
        private String[] field_order_type_info = new String[]{'delDt','delSvcs'};
    }
    public class QuoteResponse_MasterType {
        public String qtNum;
        public String actNm;
        public Date avlColDt;
        public DateTime qtRqstdDtTm;
        public String colDpt;
        public String lobRef;
        public Boolean enhLbltyInd;
        public Boolean hazGdsAlwdInd;
        public String ntTyp;
        public String options;
        public String wghtTyp;
        public String rtngDep;
        public String rtGrpDesc;
        public String pstCdCat;
        public uksvcsTntGetQuotePricing.Deliveries_ContainerType dels;
        private String[] qtNum_type_info = new String[]{'qtNum','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','1','false'};
        private String[] actNm_type_info = new String[]{'actNm','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','1','false'};
        private String[] avlColDt_type_info = new String[]{'avlColDt','http://express.tnt.com/service/schema/gpdfq/v1',null,'1','1','false'};
        private String[] qtRqstdDtTm_type_info = new String[]{'qtRqstdDtTm','http://express.tnt.com/service/schema/gpdfq/v1',null,'1','1','false'};
        private String[] colDpt_type_info = new String[]{'colDpt','http://express.tnt.com/service/schema/gpdfq/v1',null,'1','1','false'};
        private String[] lobRef_type_info = new String[]{'lobRef','http://express.tnt.com/service/schema/gpdfq/v1',null,'1','1','false'};
        private String[] enhLbltyInd_type_info = new String[]{'enhLbltyInd','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','1','false'};
        private String[] hazGdsAlwdInd_type_info = new String[]{'hazGdsAlwdInd','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','1','false'};
        private String[] ntTyp_type_info = new String[]{'ntTyp','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','1','false'};
        private String[] options_type_info = new String[]{'options','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','1','false'};
        private String[] wghtTyp_type_info = new String[]{'wghtTyp','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','1','false'};
        private String[] rtngDep_type_info = new String[]{'rtngDep','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','1','false'};
        private String[] rtGrpDesc_type_info = new String[]{'rtGrpDesc','http://express.tnt.com/service/schema/gpdfq/v1',null,'1','1','false'};
        private String[] pstCdCat_type_info = new String[]{'pstCdCat','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','1','false'};
        private String[] dels_type_info = new String[]{'dels','http://express.tnt.com/service/schema/gpdfq/v1',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://express.tnt.com/service/schema/gpdfq/v1','false','false'};
        private String[] field_order_type_info = new String[]{'qtNum','actNm','avlColDt','qtRqstdDtTm','colDpt','lobRef','enhLbltyInd','hazGdsAlwdInd','ntTyp','options','wghtTyp','rtngDep','rtGrpDesc','pstCdCat','dels'};
    }
    public class Surcharges_ContainerType {
        public uksvcsTntGetQuotePricing.Surcharge_MasterType[] srchrg {get; set;}
        private String[] srchrg_type_info = new String[]{'srchrg','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://express.tnt.com/service/schema/gpdfq/v1','false','false'};
        private String[] field_order_type_info = new String[]{'srchrg'};
    }
    public class ResponseMessage_MasterType {
        public uksvcsTntComGenericPayloadHeader.payloadHeader hdr;
        public uksvcsTntGetQuotePricing.QuoteResponse_MasterType qt;
        private String[] hdr_type_info = new String[]{'hdr','http://express.tnt.com/service/schema/gpdfq/v1',null,'1','1','false'};
        private String[] qt_type_info = new String[]{'qt','http://express.tnt.com/service/schema/gpdfq/v1',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://express.tnt.com/service/schema/gpdfq/v1','false','false'};
        private String[] field_order_type_info = new String[]{'hdr','qt'};
    }
}