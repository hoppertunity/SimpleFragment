/**
* File Name   :    OL_BookingIntegrationUtil.cls
* Description :    
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 03/09/2014 Liza Romanenko TNT-1414
* 0.2 15/01/2015 Liza Romanenko	TNT-2038 add Invoice Address mapping
*/
global without sharing class OL_BookingIntegrationUtil {
	
	WebService static String saveBookingToUniverse(String bkId){
		String res;
		String qry;
		qry = OL_BookingQuoteHelper.getAllFieldsForObject(Booking__c.sObjectType.getDescribe())
					+ ', Account__r.Account_Number__c, Routing_Table__r.Routing_Table__c' 
					+ ', Line_of_Business__r.Line_of_Business_Reference__c, Service__r.Service_Code__c, Collection_Depot__r.Depot_Number__c,' 
					+ ' (Select Movement_Type__c From Booking_History_Records__r) FROM Booking__c WHERE Id ' + ' = \''+bkId+'\'';
		Booking__c bookWithData = Database.query(qry);
		
		uksvcsTntComBookingService.createOrUpdatebookingPort  port = new uksvcsTntComBookingService.createOrUpdatebookingPort();
    
        port.inputHttpHeaders_x = new map<string,string> {'Username' => TNT_Integration__c.getInstance().Username__c, 
                                                          'Password' => TNT_Integration__c.getInstance().Password__c};

        uksvcsTntComGenericPayloadHeader.payloadHeader 
            hdr = new uksvcsTntComGenericPayloadHeader.payloadHeader();
        uksvcsTntComBooking.bookingRequest_MasterType 
            bk = generateBookingRequest_MasterType(bookWithData);
    	
    	
    	bk.bkngItms = generateBookingItems(bookWithData.Id);
    	
    	Booking_History__c bh = getBookingHistory(bookWithData);
    	
        bk.bkngUpds = generateBookingHistory(bh);
        
        uksvcsTntComBooking.ResponseMessage_MasterType resp;
        
        try{
        	if(!ConstantUtil.INTEGRATION_ACCESS) throw new ConstantUtil.IntegrationAccessDeniedException(ConstantUtil.INTEGRATION_EXMSG);
        	port.timeout_x = ConstantUtil.INTEGRATION_TIMEOUT;
	        resp = port.createOrUpdateBooking(hdr, bk);
	        bookWithData.Is_Synchronisation_Failed__c = false;
        } catch(Exception ex) {
        	if(ex instanceof System.CalloutException || ex instanceof ConstantUtil.IntegrationAccessDeniedException)
        	{
        		bookWithData.Is_Synchronisation_Failed__c = true;
        		bookWithData.Synchronisation_Error_Message__c = ex.getMessage();
        		res = 'Synchronisation failed "' + ex.getMessage() + '"';
        	}
        	else
        	{
        		throw ex;
        	}
        }
        	       
        update bookWithData;
        if(bh.Id == null){
        	insert bh;
        }
		
		return res;
	}
	
	private static uksvcsTntComBooking.bookingRequest_MasterType generateBookingRequest_MasterType(Booking__c bookWithData){
		uksvcsTntComBooking.bookingRequest_MasterType bk = new uksvcsTntComBooking.bookingRequest_MasterType();
	        
	        bk.bkngNum = bookWithData.booking_Id__c;
        	bk.actNum = bookWithData.Account__r.Account_Number__c;
        	bk.orgn = bookWithData.Origin__c;
        	bk.colAddrOrgNm = bookWithData.Coll_Org_Name__c;
        	bk.colAddrSubPrem = bookWithData.Coll_Sub_Premise__c;
        	bk.colAddrPremNum = bookWithData.Coll_Premise_Number__c;
        	bk.colAddrPremNm = bookWithData.Coll_Premise_Name__c;
        	bk.colAddrStrAddr1 = bookWithData.Coll_Street_1__c;
        	bk.colAddrStrAddr2 = bookWithData.Coll_Street_2__c;
        	//bk.colAddrStrAddr3 = bookWithData.Coll_Street_3__c;	// fields removed
        	//bk.colAddrStrAddr4 = bookWithData.Coll_Street_4__c;	// fields removed
        	bk.colAddrDstct = bookWithData.Coll_District__c;
        	bk.colAddrTwn = bookWithData.Coll_City__c;
        	bk.colAddrCnty = bookWithData.Coll_County__c;
        	bk.colAddrCntry = bookWithData.Coll_Country__c;
        	bk.colAddrPstCd = bookWithData.Coll_Postcode__c;
        	bk.ordConTtl = bookWithData.OC_Title__c;
        	bk.ordConFstNm = bookWithData.OC_First_Name__c;
        	bk.ordConMidIntls = bookWithData.OC_Middle_Initials__c;
        	bk.ordConLstNm = bookWithData.OC_Last_Name__c;
        	bk.ordConPhNum = bookWithData.OC_Phone_Number__c;
        	bk.ordConPhNumExt = bookWithData.OC_Phone_Extension__c;
        	bk.ordConFaxNum = bookWithData.OC_Fax_Number__c;
        	bk.ordConMobNum = bookWithData.OC_Mobile_Phone_Number__c;
        	bk.ordConEmailAddr = bookWithData.OC_Email_Address__c;
        	bk.colConTtl = bookWithData.CC_Title__c;
        	bk.colConFstNm = bookWithData.CC_First_Name__c;
        	bk.colConMidIntls = bookWithData.CC_Middle_Initials__c;
        	bk.colConLstNm = bookWithData.CC_Last_Name__c;
        	bk.colConPhNum = bookWithData.CC_Phone_Number__c;
        	bk.colConPhNumExt = bookWithData.CC_Phone_Extension__c;
        	bk.colConFaxNum = bookWithData.CC_Fax_Number__c;
        	bk.colConMobNum = bookWithData.CC_Mobile_Phone_Number__c;
        	bk.colConEmailAddr = bookWithData.CC_Email_Address__c;
        	bk.colDep = (bookWithData.Collection_Depot__c != null ? bookWithData.Collection_Depot__r.Depot_Number__c : null);
        	bk.custRef = bookWithData.Customer_Reference__c;
        	bk.lobRef = (bookWithData.Line_of_Business__c != null ? bookWithData.Line_of_Business__r.Line_of_Business_Reference__c : null);
        	bk.mstrRnd = String.valueOf((bookWithData.Master_Round_Number__c != null ? bookWithData.Master_Round_Number__c : 0));
        	bk.ordNum = bookWithData.Reg_Order_Number__c;
        	bk.svcCd = (bookWithData.Service__c != null ? bookWithData.Service__r.Service_Code__c : null);
        	bk.bkngSts = bookWithData.Status__c;
        	bk.cmm = bookWithData.Commodity__c;
        	bk.crgFwd = bookWithData.Carriage_Forward__c;
        	bk.clsTm = bookWithData.Close_Time__c;
        	bk.colRdyTm = bookWithData.Collection_Ready_Time__c;
        	bk.lnchStTm = bookWithData.Lunch_Start__c;
        	bk.lnchEndTm = bookWithData.Lunch_End__c;
        	bk.numItms = String.valueOf((bookWithData.Total_Items__c != null ? bookWithData.Total_Items__c : 0));
        	bk.totWght = String.valueOf(bookWithData.Total_Weight__c);
        	bk.wghtUOM = 'KG';
        	bk.numCons = String.valueOf((bookWithData.Number_of_Consignments__c != null ? bookWithData.Number_of_Consignments__c : 1));
        	bk.trnsLiabLvl = bookWithData.Enhanced_Liability__c;
        	bk.dgInd = bookWithData.Dangerous_Goods__c;
        	bk.hazChemCd1 = bookWithData.Hazchem_1_UN_Number__c;
	//     	bk.dgSeq1 = bookWithData.;
        	bk.hazChemPck1 = bookWithData.Hazchem_1_Packing_Class__c;
        	bk.hazChemQty1 = String.valueOf(bookWithData.Hazchem_1_Quantity__c);
        	bk.hazChemUOM1 = bookWithData.Hazchem_1_UOM__c;
        	bk.hazChemTechNm1 = bookWithData.Hazchem_1_Technical_Name__c;
        	bk.hazChemCd2 = bookWithData.Hazchem_2_UN_Number__c;
    //    	bk.dgSeq2 = bookWithData.;
        	bk.hazChemPck2 = bookWithData.Hazchem_2_Packing_Class__c;
        	bk.hazChemQty2 = String.valueOf(bookWithData.Hazchem_2_Quantity__c);
        	bk.hazChemUOM2 = bookWithData.Hazchem_2_UOM__c;
        	bk.hazChemTechNm2 = bookWithData.Hazchem_2_Technical_Name__c;
        	bk.hazChemCd3 = bookWithData.Hazchem_3_UN_Number__c;
    //   	bk.dgSeq3 = bookWithData.;
        	bk.hazChemPck3 = bookWithData.Hazchem_3_Packing_Class__c;
        	bk.hazChemQty3 = String.valueOf(bookWithData.Hazchem_3_Quantity__c);
        	bk.hazChemUOM3 = bookWithData.Hazchem_3_UOM__c;
        	bk.hazChemTechNm3 = bookWithData.Hazchem_3_Technical_Name__c;
        	bk.pprWrkInd = bookWithData.Paperwork_Required__c;
        	bk.colIns = bookWithData.Collection_Instructions__c;
        	bk.noLOBAct = bookWithData.No_LOB_Ind__c;
        	bk.gdsDesc = bookWithData.Goods_Description__c != null ? bookWithData.Goods_Description__c : null;
        	bk.totColVol = String.valueOf(bookWithData.Total_Volume__c != null ? bookWithData.Total_Volume__c.intValue() : null);
        	bk.comInvReq = bookWithData.Commercial_Invoice_Required__c;
    //   	bk.delDepBndryRef = bookWithData.;
        	bk.colDepBndryRef = (bookWithData.Routing_Table__c != null ? bookWithData.Routing_Table__r.Routing_Table__c : null);
        	bk.delIns = bookWithData.Delivery_Instructions__c;
        	bk.tntConsNum = bookWithData.Consignment_Number__c;
        	bk.delAddrOrgNm = bookWithData.Del_Org_Name__c;
        	bk.delAddrSubPrem = bookWithData.Del_Sub_Premise__c;
        	bk.delAddrPremNum = bookWithData.Del_Premise_Number__c;
        	bk.delAddrPremNm = bookWithData.Del_Premise_Name__c;
        	bk.delAddrStrAddr1 = bookWithData.Del_Street_1__c;
        	bk.delAddrStrAddr2 = bookWithData.Del_Street_2__c;
        	//bk.delAddrStrAddr3 = bookWithData.Del_Street_3__c;	// fields removed
        	//bk.delAddrStrAddr4 = bookWithData.Del_Street_4__c;	// fields removed
        	bk.delAddrDstct = bookWithData.Del_District__c;
        	bk.delAddrTwn = bookWithData.Del_City__c;
        	bk.delAddrCnty = bookWithData.Del_County__c;
        	bk.delAddrCntry = bookWithData.Del_Country__c;
        	bk.delAddrPstCd = bookWithData.Del_Postcode__c;
        	bk.delConTtl = bookWithData.DC_Title__c;
        	bk.delConFstNm = bookWithData.DC_First_Name__c;
        	bk.delConMidIntls = bookWithData.DC_Middle_Initials__c;
        	bk.delConLstNm = bookWithData.DC_Last_Name__c;
        	bk.delConPhNum = bookWithData.DC_Phone_Number__c;
        	bk.delConPhNumExt = bookWithData.DC_Phone_Extension__c;
        	bk.delConFaxNum = bookWithData.DC_Fax_Number__c;
        	bk.delConMobNum = bookWithData.DC_Mobile_Phone_Number__c;
        	bk.delConEmailAddr = bookWithData.DC_Email_Address__c;
        	bk.crtDtTm = bookWithData.CreatedDate;
        	//Invoice Address mapping
        	bk.invAddrOrgNm = bookWithData.Inv_Org_Name__c;
			bk.invAddrSubPrem = bookWithData.Inv_Sub_Premise__c;
			bk.invAddrPremNm = bookWithData.Inv_Premise_Name__c;
			bk.invAddrPremNum = bookWithData.Inv_Premise_Number__c;
			bk.invAddrStrAddr1 = bookWithData.Inv_Street_1__c;
			bk.invAddrStrAddr2 = bookWithData.Inv_Street_2__c;
			bk.invAddrTwn = bookWithData.Inv_City__c;
			bk.invAddrDstct = bookWithData.Inv_District__c;
			bk.invAddrCnty = bookWithData.Inv_County__c;
			bk.invAddrPstCd = bookWithData.Inv_Postcode__c;
			bk.invAddrPhone = bookWithData.Inv_Phone__c;
			bk.invAddrEmail = bookWithData.Inv_Email__c;
        return bk;
	}
	
	private static uksvcsTntComBooking.BookingItems_ContainerType generateBookingItems(String bkId){
		
		List<uksvcsTntComBooking.BookingItem_MasterType> items = new List<uksvcsTntComBooking.BookingItem_MasterType>();
    	for(Booking_Line_Item__c bli : [SELECT Booking_Line_Item_Id__c, Number_of_Items__c, Length__c,
    										Width__c, Height__c FROM Booking_Line_Item__c WHERE Booking__c = : bkId
    										ORDER BY Serial_number__c]){
    		if(bli.Id != null){
        		uksvcsTntComBooking.BookingItem_MasterType itm = new uksvcsTntComBooking.BookingItem_MasterType();
        		
        		itm.itmId = bli.Booking_Line_Item_Id__c;
        		itm.numItms = String.valueOf(bli.Number_of_Items__c);
        		itm.len = bli.Length__c != null ? String.valueOf(bli.Length__c) : '0';
        		itm.wdth = bli.Width__c != null ? String.valueOf(bli.Width__c) : '0';
        		itm.hght = bli.Height__c != null ? String.valueOf(bli.Height__c) : '0';
        		itm.lenUOM = 'CM';
        		items.add(itm);
    		}
    	}
    	uksvcsTntComBooking.BookingItems_ContainerType bkngItms = new uksvcsTntComBooking.BookingItems_ContainerType();
    	bkngItms.bkngItm = items;
    	
    	return bkngItms;
	}
	
	private static Booking_History__c getBookingHistory(Booking__c book){
		Booking_History__c bh;
		if(book.Is_Synchronisation_Failed__c){
			//get last history line 
			bh = [SELECT User_Id__c, Movement_Type__c, Movement_Sub_Type__c, Movement_Round__c, Movement_Date_Time__c, 
    									Depot__c, Depot__r.AccountNumber, Call_Centre__c, Change_Details__c, Collection_Comments__c
    								FROM Booking_History__c 
    								WHERE Booking__c = : book.Id AND (Movement_Type__c = : ConstantUtil.PLVAL_BOOKING_HISTORY_MOVEMENT_TYPE_RAISED 
    									OR Movement_Type__c = : ConstantUtil.PLVAL_BOOKING_HISTORY_MOVEMENT_TYPE_AMENDED)
    								ORDER BY CreatedDate DESC LIMIT 1];
		} else {
			//create new one
			bh = new Booking_History__c();
			bh.Booking__c = book.Id;
			bh.Call_Centre__c = true;
			bh.Movement_Date_Time__c = DateTime.now();
			bh.User_Id__c = getUserAlias(UserInfo.getUserId());
			if(book.Booking_History_Records__r != null && !book.Booking_History_Records__r.isEmpty()){
				bh.Movement_Type__c = ConstantUtil.PLVAL_BOOKING_HISTORY_MOVEMENT_TYPE_AMENDED;
			} else {
				bh.Movement_Type__c = ConstantUtil.PLVAL_BOOKING_HISTORY_MOVEMENT_TYPE_RAISED;
				book.Status__c = String.isBlank(book.Status__c) ? ConstantUtil.PLVAL_BOOKING_STATUS_CONFIRMED : book.Status__c;
			}
		}
		
		return bh;
	}
	
	private static uksvcsTntComBooking.BookingUpdates_ContainerType generateBookingHistory(Booking_History__c bh){
		
		List<uksvcsTntComBooking.BookingUpdate_MasterType> bh_items = new List<uksvcsTntComBooking.BookingUpdate_MasterType>();
    	
		uksvcsTntComBooking.BookingUpdate_MasterType itm = new uksvcsTntComBooking.BookingUpdate_MasterType();
		
		itm.mvntDtTm = bh.Movement_Date_Time__c;
		itm.mvntDep = Label.Salesforce_Start_Depot;
		itm.mvntTypCd = bh.Movement_Type__c;
		itm.callCntr = bh.Call_Centre__c;
		itm.lstUpdBy = bh.User_Id__c;
		
		bh_items.add(itm);
			
        uksvcsTntComBooking.BookingUpdates_ContainerType bkngUpds = new uksvcsTntComBooking.BookingUpdates_ContainerType();
    	bkngUpds.bkngUpd = bh_items;
    	
    	return bkngUpds;
	}
	
	private static String getUserAlias(Id uId){
		String res;
		User u = [Select Alias From User WHERE Id = : uId];
		res = u.Alias;
		return res;
	} 
}