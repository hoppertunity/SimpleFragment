//Generated by wsdl2apex

public class uksvcsTntComSearchConsignment {
    public class DetailProofOfDelivery_MasterType {
        public String podSts {get; set;}
        public Boolean sosInd {get; set;}
        public String numItms {get; set;}
        public String file {get; set;}
        public String rcvrNm {get; set;}
        public String rcvrCmts {get; set;}
        public Boolean imgInd {get; set;}
        public String manSgnInd {get; set;}
        public DateTime podDtTm {get; set;}
        private String[] podSts_type_info = new String[]{'podSts','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] sosInd_type_info = new String[]{'sosInd','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] numItms_type_info = new String[]{'numItms','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] file_type_info = new String[]{'file','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] rcvrNm_type_info = new String[]{'rcvrNm','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] rcvrCmts_type_info = new String[]{'rcvrCmts','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] imgInd_type_info = new String[]{'imgInd','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] manSgnInd_type_info = new String[]{'manSgnInd','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] podDtTm_type_info = new String[]{'podDtTm','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://express.tnt.com/service/schema/srchcon/v2','false','false'};
        private String[] field_order_type_info = new String[]{'podSts','sosInd','numItms','file','rcvrNm','rcvrCmts','imgInd','manSgnInd','podDtTm'};
    }
    public class DetailConsignmentStatusHistory_MasterType {
        public DateTime stsDtTm {get; set;}
        public String dep {get; set;}
        public String rnd {get; set;}
        public String sts {get; set;}
        public String subSts {get; set;}
        public String dscrpCmmts {get; set;}
        public Boolean hasDscrp {get; set;}
        private String[] stsDtTm_type_info = new String[]{'stsDtTm','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] dep_type_info = new String[]{'dep','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] rnd_type_info = new String[]{'rnd','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] sts_type_info = new String[]{'sts','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] subSts_type_info = new String[]{'subSts','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://express.tnt.com/service/schema/srchcon/v2','false','false'};
        private String[] field_order_type_info = new String[]{'stsDtTm','dep','rnd','sts','subSts'};
    }
    public class RequestMessage_MasterType {
        public uksvcsTntComSearchConsignment.ConsignmentRequest_MasterType con;
        public uksvcsTntComGenericPayloadHeader.payloadHeader hdr;
        private String[] con_type_info = new String[]{'con','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] hdr_type_info = new String[]{'hdr','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://express.tnt.com/service/schema/srchcon/v2','false','false'};
        private String[] field_order_type_info = new String[]{'con','hdr'};
    }
    
    public class ConsignmentDiscrepancy_MasterType {
        public DateTime dscrpDt {get; set;}
        public String rnd {get; set;}
        public String dscrp {get; set;}
        public String cmmts {get; set;}
        private String[] dscrpDt_type_info = new String[]{'dscrpDt','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] rnd_type_info = new String[]{'rnd','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] dscrp_type_info = new String[]{'dscrp','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] cmmts_type_info = new String[]{'cmmts','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://express.tnt.com/service/schema/srchcon/v2','false','false'};
        private String[] field_order_type_info = new String[]{'dscrpDt','rnd','dscrp','cmmts'};
    }
    public class ConsignmentDiscrepancy_ContainerType {
        public uksvcsTntComSearchConsignment.ConsignmentDiscrepancy_MasterType[] dscrp {get; set;}
        private String[] dscrp_type_info = new String[]{'dscrp','http://express.tnt.com/service/schema/srchcon/v2',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://express.tnt.com/service/schema/srchcon/v2','false','false'};
        private String[] field_order_type_info = new String[]{'dscrp'};
    }
    public class DetailAddress_MasterType {
        public String orgNm {get; set;}
        public String subPrem {get; set;}
        public String premNum {get; set;}
        public String premNm {get; set;}
        public String strAddr1 {get; set;}
        public String strAddr2 {get; set;}
        public String strAddr3 {get; set;}
        public String strAddr4 {get; set;}
        public String dstct {get; set;}
        public String twn {get; set;}
        public String cnty {get; set;}
        public String cntry {get; set;}
        public String pstCd {get; set;}
        private String[] orgNm_type_info = new String[]{'orgNm','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] subPrem_type_info = new String[]{'subPrem','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] premNum_type_info = new String[]{'premNum','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] premNm_type_info = new String[]{'premNm','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] strAddr1_type_info = new String[]{'strAddr1','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] strAddr2_type_info = new String[]{'strAddr2','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] strAddr3_type_info = new String[]{'strAddr3','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] strAddr4_type_info = new String[]{'strAddr4','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] dstct_type_info = new String[]{'dstct','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] twn_type_info = new String[]{'twn','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] cnty_type_info = new String[]{'cnty','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] cntry_type_info = new String[]{'cntry','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] pstCd_type_info = new String[]{'pstCd','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://express.tnt.com/service/schema/srchcon/v2','false','false'};
        private String[] field_order_type_info = new String[]{'orgNm','subPrem','premNum','premNm','strAddr1','strAddr2','strAddr3','strAddr4','dstct','twn','cnty','cntry','pstCd'};
    }
    public class ShortProofOfDelivery_MasterType {
        public String podSts {get; set;}
        private String[] podSts_type_info = new String[]{'podSts','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://express.tnt.com/service/schema/srchcon/v2','false','false'};
        private String[] field_order_type_info = new String[]{'podSts'};
    }
    public class ConsignmentRating_MasterType {
        public String trnsLiabLvl {get; set;}
        public Date rtdDt {get; set;}
        public String rtngDep {get; set;}
        public String schRvAmt {get; set;}
        public String netRvAmt {get; set;}
        public Date invDt {get; set;}
        private String[] trnsLiabLvl_type_info = new String[]{'trnsLiabLvl','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] rtdDt_type_info = new String[]{'rtdDt','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] rtngDep_type_info = new String[]{'rtngDep','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] schRvAmt_type_info = new String[]{'schRvAmt','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] netRvAmt_type_info = new String[]{'netRvAmt','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] invDt_type_info = new String[]{'invDt','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://express.tnt.com/service/schema/srchcon/v2','false','false'};
        private String[] field_order_type_info = new String[]{'trnsLiabLvl','rtdDt','rtngDep','schRvAmt','netRvAmt','invDt'};
    }
    public class ConsignmentResponse_MasterType {
        public String unqConNum {get; set;} //Unique identifier for the consignment.
        public String tntConNum {get; set;} //Consignment number generated by a TNT con note system (e.g. express shipper).
        public String orgConNum {get; set;} //Unique identifier of another consignment that this consignment is linked to. -> Original
        public String bkgNum {get; set;} //Unique identifier of the booking that the consignment relates to. -> Col Req Num
        public String ntTyp {get; set;} //Type of documentation used for the consignment -> Type
        public String svcCd {get; set;} //Description of the TNT service that was used for the consignment. -> Service
        public String cmm {get; set;} //Description of the TNT commodity that the consignment relates to. -> Description
        public String delInst {get; set;} //Special delivery instructions provided by the customer. -> Del Instrc
        public String lobRef {get; set;} //Unique reference for the Line of Business linked to the consignment.
        public String options {get; set;} //Description of the TNT sub-service that was used for the consignment. -> Sub
        public String custRef {get; set;} //Customer provided reference for the consignment. -> Customer Ref
        public String colDep {get; set;} //Collection depot for the consignment. -> Coll Depot
        public String delDep {get; set;} //Delivery depot for the consignment. -> Del Depot
        public String orgnDep {get; set;} //Originating depot for the consignment. -> Orig Depot
        public Date colDt {get; set;} //Date consignment was collected. -> Coll Date
        public Date delDat {get; set;} //Date consignment was delivered. -> Del Date
        public DateTime dueDtTm {get; set;} //Date/time consignment is due to be delivered. -> Due Date
        public String dclItms {get; set;} //Number of items the customer has declared are in the consignment. -> Dec Items
        public String dclWght {get; set;} //Customer declared total weight of all items in the consignment. -> Dec Wgt
        public String chkItms {get; set;} //Number of items checked in at the collection depot. -> Check Items
        public String chkWght {get; set;} //Combined weight of all items in the consignment - TNT checked at collection depot.-> Check Wgt
        public String colRnd {get; set;} //Collection round used for collection of the consignment. -> Coll Round
        public String sqNum {get; set;} //Split of collection round consignment notes into sequences. Used for data entry. -> Seq
        public Boolean pdcInd {get; set;} //Indicates that the consignment was processed by a PDC.
        public String delRnd {get; set;} //Delivery round used for delivery of the consignment. -> Del Round
        public String uplMeth {get; set;} //Indicates how the consignment was uploaded onto the system. -> Upload
        public Boolean qryInd {get; set;} //Indicates if a query file has been logged for the consignment. -> Queries
        public Boolean clInd {get; set;} //Indicates if a claim has been raised for the consignment.
        public String bayNum {get; set;} //Code of the logical area in TNT where the consignment is currently allocated. -> Bay Number
        public String bayNm {get; set;} //Name of the logical area in TNT where the consignment is currently allocated.
        public String sndrNm {get; set;} //Name of sender
        public String delToNm {get; set;} //Name of recipient.
        public String delToCnt {get; set;} //Name of the person to deliver the item to. Also referred to as FAO on the consignment.
        public Boolean discInd {get; set;} //Indicates that a discrepancy has been logged against the consignment.
        public uksvcsTntComSearchConsignment.DetailProofOfDelivery_MasterType pod {get; set;}
        public uksvcsTntComSearchConsignment.DetailAddress_MasterType addr {get; set;}
        public uksvcsTntComSearchConsignment.ConsignmentStatusHistory_ContainerType conStss {get; set;}
        public uksvcsTntComSearchConsignment.ConsignmentRating_MasterType rtng {get; set;}
        public uksvcsTntComSearchConsignment.ConsignmentDiscrepancy_ContainerType dscrps {get; set;}
        public uksvcsTntComSearchConsignment.Account_MasterType act {get; set;}
        private String[] unqConNum_type_info = new String[]{'unqConNum','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] tntConNum_type_info = new String[]{'tntConNum','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] orgConNum_type_info = new String[]{'orgConNum','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] bkgNum_type_info = new String[]{'bkgNum','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] ntTyp_type_info = new String[]{'ntTyp','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] svcCd_type_info = new String[]{'svcCd','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] cmm_type_info = new String[]{'cmm','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] delInst_type_info = new String[]{'delInst','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] lobRef_type_info = new String[]{'lobRef','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] options_type_info = new String[]{'options','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] custRef_type_info = new String[]{'custRef','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] colDep_type_info = new String[]{'colDep','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] delDep_type_info = new String[]{'delDep','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] orgnDep_type_info = new String[]{'orgnDep','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] colDt_type_info = new String[]{'colDt','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] delDat_type_info = new String[]{'delDat','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] dueDtTm_type_info = new String[]{'dueDtTm','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] dclItms_type_info = new String[]{'dclItms','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] dclWght_type_info = new String[]{'dclWght','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] chkItms_type_info = new String[]{'chkItms','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] chkWght_type_info = new String[]{'chkWght','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] colRnd_type_info = new String[]{'colRnd','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] sqNum_type_info = new String[]{'sqNum','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] pdcInd_type_info = new String[]{'pdcInd','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] delRnd_type_info = new String[]{'delRnd','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] uplMeth_type_info = new String[]{'uplMeth','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] qryInd_type_info = new String[]{'qryInd','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] clInd_type_info = new String[]{'clInd','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] bayNum_type_info = new String[]{'bayNum','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] bayNm_type_info = new String[]{'bayNm','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] sndrNm_type_info = new String[]{'sndrNm','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] delToNm_type_info = new String[]{'delToNm','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] delToCnt_type_info = new String[]{'delToCnt','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] discInd_type_info = new String[]{'discInd','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] pod_type_info = new String[]{'pod','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] addr_type_info = new String[]{'addr','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] conStss_type_info = new String[]{'conStss','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] rtng_type_info = new String[]{'rtng','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] dscrps_type_info = new String[]{'dscrps','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] act_type_info = new String[]{'act','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://express.tnt.com/service/schema/srchcon/v2','false','false'};
        private String[] field_order_type_info = new String[]{'unqConNum','tntConNum','orgConNum','bkgNum','ntTyp','svcCd','cmm','delInst','lobRef','options','custRef','colDep','delDep','orgnDep','colDt','delDat','dueDtTm','dclItms','dclWght','chkItms','chkWght','colRnd','sqNum','pdcInd','delRnd','uplMeth','qryInd','clInd','bayNum','bayNm','sndrNm','delToNm','delToCnt','discInd','pod','addr','conStss','rtng','dscrps','act'};
	    public void addDiscrepCommentsToHistoryRecords(){
	    	if(conStss != null && dscrps != null && dscrps.dscrp != null){
		    	List<DetailConsignmentStatusHistory_MasterType> historyLines = conStss.conSts;
		    	List<ConsignmentDiscrepancy_MasterType> dscrpLines = dscrps.dscrp;
		    	Integer j = historyLines.size() - 1;
		    	for(Integer i = dscrpLines.size() - 1; i >= 0; i--){
		    		ConsignmentDiscrepancy_MasterType dscrp = dscrpLines[i];
		    		DetailConsignmentStatusHistory_MasterType firstHist;
		    		DetailConsignmentStatusHistory_MasterType histWithSubType;
		    		for(Integer k = j; k >= 0; k--){
		    			DetailConsignmentStatusHistory_MasterType stHist = historyLines[k];
		    			if(stHist.stsDtTm <= dscrp.dscrpDt && firstHist == null){
		    				firstHist = stHist;
		    				j = k - 1;
		    			}
		    			if(stHist.stsDtTm <= dscrp.dscrpDt && !String.isEmpty(stHist.subSts) && histWithSubType == null && (dscrp.dscrpDt.getTime() - stHist.stsDtTm.getTime())/1000*60 < 5){
		    				histWithSubType = stHist;
		    				firstHist = stHist;
		    				j = k - 1;
		    			}
		    			
		    			if(histWithSubType != null || (firstHist != null && (dscrp.dscrpDt.getTime() - stHist.stsDtTm.getTime())/1000*60 > 5)){
		    				firstHist.dscrpCmmts = dscrp.cmmts;
		    				firstHist.hasDscrp = true;
		    				break;
		    			}
		    		}
		    	}
	    	}
	    }
    }
    public class Account_MasterType {
        public String actNum {get; set;}
        public String actNm {get; set;}
        public String phNum {get; set;}
        private String[] actNum_type_info = new String[]{'actNum','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] actNm_type_info = new String[]{'actNm','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] phNum_type_info = new String[]{'phNum','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://express.tnt.com/service/schema/srchcon/v2','false','false'};
        private String[] field_order_type_info = new String[]{'actNum','actNm','phNum'};
    }
    public class ResponseMessage_MasterType {
        public uksvcsTntComSearchConsignment.ConsignmentResponse_MasterType con;
        public uksvcsTntComSearchConsignment.ConsignmentResponse_ContainerType consearch;
		public uksvcsTntComGenericPayloadHeader.payloadHeader hdr;
		private String[] con_type_info = new String[]{'con','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] consearch_type_info = new String[]{'consearch','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
		private String[] hdr_type_info = new String[]{'hdr','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://express.tnt.com/service/schema/srchcon/v2','false','false'};
        private String[] field_order_type_info = new String[]{'con','consearch','hdr'};
    }
    public class ConsignmentStatusHistory_ContainerType {
        public uksvcsTntComSearchConsignment.DetailConsignmentStatusHistory_MasterType[] conSts {get; set;}
        private String[] conSts_type_info = new String[]{'conSts','http://express.tnt.com/service/schema/srchcon/v2',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://express.tnt.com/service/schema/srchcon/v2','false','false'};
        private String[] field_order_type_info = new String[]{'conSts'};
    }
    public class Consignment_MasterType {
        public String unqConNum {get; set;}
        public String tntConNum {get; set;}
        public String bkgNum {get; set;}
        public String custRef {get; set;}
        public String actNum {get; set;}
        public String sndrNm {get; set;}
        public String delToNm {get; set;}
        public Date colDt {get; set;}
        public Date delDt {get; set;}
        public String ntTypCd {get; set;}
        public String lobRef {get; set;}
        public String svcCd {get; set;}
        public Boolean discInd {get; set;}
        public uksvcsTntComSearchConsignment.CurrentConsignmentStatus_MasterType curConSts {get; set;}
        public uksvcsTntComSearchConsignment.ShortProofOfDelivery_MasterType pod {get; set;}
        public uksvcsTntComSearchConsignment.ShortAddress_MasterType delAddr {get; set;}
        private String[] unqConNum_type_info = new String[]{'unqConNum','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] tntConNum_type_info = new String[]{'tntConNum','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] bkgNum_type_info = new String[]{'bkgNum','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] custRef_type_info = new String[]{'custRef','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] actNum_type_info = new String[]{'actNum','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] sndrNm_type_info = new String[]{'sndrNm','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] delToNm_type_info = new String[]{'delToNm','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] colDt_type_info = new String[]{'colDt','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] delDt_type_info = new String[]{'delDt','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] ntTypCd_type_info = new String[]{'ntTypCd','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] lobRef_type_info = new String[]{'lobRef','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] svcCd_type_info = new String[]{'svcCd','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] discInd_type_info = new String[]{'discInd','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] curConSts_type_info = new String[]{'curConSts','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] pod_type_info = new String[]{'pod','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
	private String[] delAddr_type_info = new String[]{'delAddr','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://express.tnt.com/service/schema/srchcon/v2','false','false'};
        private String[] field_order_type_info = new String[]{'unqConNum','tntConNum','bkgNum','custRef','actNum','sndrNm','delToNm','colDt','delDt','ntTypCd','lobRef','svcCd','discInd','curConSts','pod','delAddr'};
    }
    public class ShortConsignmentStatusHistory_MasterType {
        public Boolean negStsInd {get; set;}
        public Boolean negSubStsInd {get; set;}
        public String sts {get; set;}
        public String subSts {get; set;}
        private String[] negStsInd_type_info = new String[]{'negStsInd','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] negSubStsInd_type_info = new String[]{'negSubStsInd','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] sts_type_info = new String[]{'sts','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] subSts_type_info = new String[]{'subSts','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://express.tnt.com/service/schema/srchcon/v2','false','false'};
        private String[] field_order_type_info = new String[]{'negStsInd','negSubStsInd','sts','subSts'};
    }
    public class ConsignmentResponse_ContainerType {
        public uksvcsTntComSearchConsignment.Consignment_MasterType[] con {get; set;}
        private String[] con_type_info = new String[]{'con','http://express.tnt.com/service/schema/srchcon/v2',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://express.tnt.com/service/schema/srchcon/v2','false','false'};
        private String[] field_order_type_info = new String[]{'con'};
    }
    public class CurrentConsignmentStatus_MasterType {
        public DateTime stsDtTm;
        public String dep;
        public String rnd;
        public String sts {get; set;}
        public String subSts;
        private String[] stsDtTm_type_info = new String[]{'stsDtTm','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] dep_type_info = new String[]{'dep','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] rnd_type_info = new String[]{'rnd','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] sts_type_info = new String[]{'sts','http://express.tnt.com/service/schema/srchcon/v2',null,'1','1','false'};
        private String[] subSts_type_info = new String[]{'subSts','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://express.tnt.com/service/schema/srchcon/v2','false','false'};
        private String[] field_order_type_info = new String[]{'stsDtTm','dep','rnd','sts','subSts'};
    }
    public class ConsignmentRequest_MasterType {
        public String unqConNum {get; set;}
        public String tntConNum {get; set;}
        public String bkgNum {get; set;}
        public String custRef {get; set;}
        public String actNum {get; set;}
        public String sndrNm {get; set;}
        public String delToNm {get; set;}
        public String colDep {get; set;}
        public String delDep {get; set;}
        public String colRnd {get; set;}
        public String delRnd {get; set;}
        public Date delDt {get; set;}
        public String bayNum {get; set;}
        public String orgDep {get; set;}
        public String ntTyp {get; set;}
        public String lobRef {get; set;}
        public String svcCd {get; set;}
        public String options {get; set;}
        public uksvcsTntComSearchConsignment.ShortAddress_MasterType delAddr {get; set;}
        public uksvcsTntComSearchConsignment.ShortConsignmentStatusHistory_MasterType stsHstry {get; set;}
        private String[] unqConNum_type_info = new String[]{'unqConNum','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] tntConNum_type_info = new String[]{'tntConNum','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] bkgNum_type_info = new String[]{'bkgNum','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] custRef_type_info = new String[]{'custRef','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] actNum_type_info = new String[]{'actNum','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] sndrNm_type_info = new String[]{'sndrNm','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] delToNm_type_info = new String[]{'delToNm','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] colDep_type_info = new String[]{'colDep','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] delDep_type_info = new String[]{'delDep','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] colRnd_type_info = new String[]{'colRnd','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] delRnd_type_info = new String[]{'delRnd','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] delDt_type_info = new String[]{'delDt','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] bayNum_type_info = new String[]{'bayNum','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] orgDep_type_info = new String[]{'orgDep','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] ntTyp_type_info = new String[]{'ntTyp','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] lobRef_type_info = new String[]{'lobRef','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] svcCd_type_info = new String[]{'svcCd','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] options_type_info = new String[]{'options','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] delAddr_type_info = new String[]{'delAddr','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] stsHstry_type_info = new String[]{'stsHstry','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://express.tnt.com/service/schema/srchcon/v2','false','false'};
        private String[] field_order_type_info = new String[]{'unqConNum','tntConNum','bkgNum','custRef','actNum','sndrNm','delToNm','colDep','delDep','colRnd','delRnd','delDt','bayNum','orgDep','ntTyp','lobRef','svcCd','options','delAddr','stsHstry'};
    }
    public class ShortAddress_MasterType {
        public String pstCd {get; set;}
        public String twn {get; set;}
        private String[] pstCd_type_info = new String[]{'pstCd','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] twn_type_info = new String[]{'twn','http://express.tnt.com/service/schema/srchcon/v2',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://express.tnt.com/service/schema/srchcon/v2','false','false'};
        private String[] field_order_type_info = new String[]{'pstCd','twn'};
    }
}