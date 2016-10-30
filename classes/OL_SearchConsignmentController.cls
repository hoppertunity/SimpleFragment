/**
* File Name   :    OL_SearchConsignmentController.cls
* Description :    Controller for OL_SearchConsignment Page
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 09/09/2014 Liza Romanenko Initial version, TNT-546
* D0.1 14/08/2014 Liza Romanenko        Initial version, TNT-547
* D0.2 10/09/2014 Liza Romanenko        create cases, TNT-1593
* D 0.2 10/09/2014 Klea Kolaric open from case, TNT-1594
* 0.3 20/01/2015 Liza Romanenko merge with OL_SearchConsignmentControllerById
* 0.4 21/01/2015 Liza Romanenko check if related cases already exist TNT-2297
* 0.5 24/09/2015 Darryl Hopper amended to create Case type (constutil.PLVAL_CASE_TYPE_RECORD_TRACK)'FCR - Track' for !runCreateAndSaveCase and removed check for exisiting cases for that scenario
*/
public with sharing class OL_SearchConsignmentController {
        //Properties for Advanced Search Page
        public uksvcsTntComSearchConsignment.ConsignmentRequest_MasterType consReq {get; set;}
        public Quote__c quote {get; set;}
        public Quote__c quoteTo {get; set;}
        public Integer pageNumber {get; set;}
        public uksvcsTntComSearchConsignment.ConsignmentResponse_ContainerType cons {get; set;}
        public String conId {get; set;}
        
        public Map<String, String> lobMap {get; set;}
        public Map<String, String> serviceMap {get; set;}
        public String delimitedServiceCodes {get; set;}
        public String delimitedLobCodes {get; set;}
        public Integer pageSize {get; set;}
        public Boolean isAdvanced {get; set;}
        public Boolean showDetails {get; set;}
        
        public uksvcsTntComSearchConsignment.ResponseMessage_MasterType resp {get; set;}
        
        //Properties for Detail Page
        public String consignmentId {get; set;}
        public uksvcsTntComSearchConsignment.ConsignmentResponse_MasterType consignment {get; set;}
        public List<uksvcsTntGetItemsForConsignment.Item_MasterType> consignmentItems {get; set;}
        public Integer rowItemForTracking {get; set;}
        public Case caseToOpen {get; set;}
        public Map<String, Account> depots {get; set;}
        public String depotKeys {get; set;}
        public Map<String, Service__c> services {get; set;}
        public String serviceKeys {get; set;}
        public Map<String, Line_of_Business__c> lobs {get; set;}
        public String lobKeys {get; set;}
        public Boolean isFromSearch {get; set;}
        public List<Case> recentCases {get; set;}
        public Boolean createAndSave {get; set;}
        public Boolean createAndOpen {get; set;}
        
        public OL_SearchConsignmentController(){
                //Logic for Advanced Search Page
                resetFilters();
                
                pageSize = (TNT_Integration__c.getInstance() != null && TNT_Integration__c.getInstance().Search_Consignment_Page_Size__c != null) ? 
                        (Integer)TNT_Integration__c.getInstance().Search_Consignment_Page_Size__c : 25;
                
                lobMap = OL_CodeForObjectUtil.getLineOfBusinesMap();
                serviceMap = OL_CodeForObjectUtil.getServiceMap();
                delimitedServiceCodes = OL_CodeForObjectUtil.delimitedServiceCodes;
                delimitedLobCodes = OL_CodeForObjectUtil.delimitedLobCodes;
                
                isAdvanced = false;
                isFromSearch = false;
                
                //Logic for Detail Page
                fillDepots();
                fillServices();
                fillLobs();
                hideCasePanel();
        }
        
        //Methods for Advanced Search Page
        
        public PageReference initSearch(){
                if(ApexPages.currentPage().getParameters().get('bNum') != null){
                        consReq.bkgNum = ApexPages.currentPage().getParameters().get('bNum');
                        return search();
                }
                
                return null;
        }
        
        public PageReference search(){
                isAdvanced = false;
                return searchAction();
        }
        
        public PageReference searchAdvanced(){
                isAdvanced = true;
                return searchAction();
        }
        
        public PageReference searchAction(){
                cons = null;
                pageNumber = 1;
                searchConsignments();
                
                PageReference res; 
                                
                return res;
        }
        
        public void prew(){
                pageNumber--;
                searchConsignments();
        }
        
        public void next(){
                pageNumber++;
                searchConsignments();
        }
        
        public void searchConsignments(){
                showDetails = false; 
                resp = new uksvcsTntComSearchConsignment.ResponseMessage_MasterType();
                //check requered data for search
                if(checkSearchData()){
                        
                        uksvcsTntComSearchConsignmentService.searchConsignment2Port  
                                port = new uksvcsTntComSearchConsignmentService.searchConsignment2Port();
                        
                port.inputHttpHeaders_x = new map<string,string> {'Username' => TNT_Integration__c.getInstance().Username__c, 
                                                              'Password' => TNT_Integration__c.getInstance().Password__c};
            
                        uksvcsTntComGenericPayloadHeader.payloadHeader 
                    hdr = new uksvcsTntComGenericPayloadHeader.payloadHeader();
                hdr.srch = new uksvcsTntComGenericPayloadHeader.search_x();
                hdr.srch.pgNum = String.valueOf(pageNumber);
                if(isAdvanced){
                        hdr.srch.dtFrom = quote.Collection_Date__c;
                        hdr.srch.dtTo = quoteTo.Collection_Date__c;
                }
                
                uksvcsTntComSearchConsignment.ConsignmentRequest_MasterType newReq = new uksvcsTntComSearchConsignment.ConsignmentRequest_MasterType();
                
                newReq.unqConNum = (!String.isBlank(consReq.unqConNum) ? consReq.unqConNum.toUpperCase() : null);
                newReq.tntConNum = (!String.isBlank(consReq.tntConNum) ? consReq.tntConNum.toUpperCase() : null);
                newReq.bkgNum = (!String.isBlank(consReq.bkgNum) ? consReq.bkgNum.toUpperCase() : null);
                newReq.custRef = (!String.isBlank(consReq.custRef) ? consReq.custRef.toUpperCase().trim() : null);
                
                if(isAdvanced){
                        newReq.actNum = (!String.isBlank(consReq.actNum) ? consReq.actNum.toUpperCase() : null);
                        newReq.sndrNm = (!String.isBlank(consReq.sndrNm) ? consReq.sndrNm.toUpperCase().trim() : null);
                        newReq.delToNm = (!String.isBlank(consReq.delToNm) ? consReq.delToNm.toUpperCase().trim() : null);
                        newReq.colDep = (!String.isBlank(consReq.colDep) ? consReq.colDep.toUpperCase() : null);
                        newReq.delDep = (!String.isBlank(consReq.delDep) ? consReq.delDep.toUpperCase() : null);
                        newReq.colRnd = (!String.isBlank(consReq.colRnd) ? consReq.colRnd.toUpperCase() : (!String.isBlank(consReq.colDep) ? '0' : null));
                        newReq.delRnd = (!String.isBlank(consReq.delRnd) ? consReq.delRnd.toUpperCase() : (!String.isBlank(consReq.delDep) ? '0' : null));
                        newReq.delDt = (quote.Delivery_Date__c != null ? quote.Delivery_Date__c : null);
                        newReq.bayNum = (!String.isBlank(consReq.bayNum) ? consReq.bayNum.toUpperCase() : null);
                        newReq.orgDep = (!String.isBlank(consReq.orgDep) ? consReq.orgDep : null);
                        newReq.ntTyp = (!String.isBlank(consReq.ntTyp) ? consReq.ntTyp : null);
                        newReq.lobRef = (!String.isBlank(consReq.lobRef) ? consReq.lobRef : null);
                        newReq.svcCd = (!String.isBlank(consReq.svcCd) ? consReq.svcCd : null);
                        newReq.options = (!String.isBlank(consReq.options) ? consReq.options : null);
                        
                        if(!String.isBlank(consReq.delAddr.pstCd) || !String.isBlank(consReq.delAddr.twn)){
                                newReq.delAddr = new uksvcsTntComSearchConsignment.ShortAddress_MasterType();
                                newReq.delAddr.pstCd = (!String.isBlank(consReq.delAddr.pstCd) ? consReq.delAddr.pstCd.toUpperCase().trim() : null);
                                newReq.delAddr.twn = (!String.isBlank(consReq.delAddr.twn) ? consReq.delAddr.twn.toUpperCase().trim() : null);
                        }
                        
                        if(!String.isBlank(consReq.stsHstry.sts) || !String.isBlank(consReq.stsHstry.subSts) ||
                                                consReq.stsHstry.negStsInd || consReq.stsHstry.negSubStsInd){
                                newReq.stsHstry = new uksvcsTntComSearchConsignment.ShortConsignmentStatusHistory_MasterType();
                                newReq.stsHstry.sts = (!String.isBlank(consReq.stsHstry.sts) ? consReq.stsHstry.sts : null);
                                newReq.stsHstry.subSts = (!String.isBlank(consReq.stsHstry.subSts) ? consReq.stsHstry.subSts : null);
                                newReq.stsHstry.negStsInd = (consReq.stsHstry.negStsInd ? consReq.stsHstry.negStsInd : null);
                                newReq.stsHstry.negSubStsInd = (consReq.stsHstry.negSubStsInd ? consReq.stsHstry.negSubStsInd : null);
                        }
                }
                
                    try{
                        if(!ConstantUtil.INTEGRATION_ACCESS) throw new ConstantUtil.IntegrationAccessDeniedException(ConstantUtil.INTEGRATION_EXMSG);
                        port.timeout_x = ConstantUtil.INTEGRATION_TIMEOUT;
                        resp = port.searchConsignment2(newReq, hdr);
                        
                        if(resp.con != null){
                                consignment = resp.con;
                                consignment.addDiscrepCommentsToHistoryRecords();
                                showDetails = true;
                        }
                        
                        cons = resp.consearch;
                        
                        if(resp.hdr != null && !String.isBlank(resp.hdr.infoMsg)){
                                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, resp.hdr.infoMsg));
                        }
                } catch(Exception ex) {
                                if(ex instanceof System.CalloutException || ex instanceof ConstantUtil.IntegrationAccessDeniedException)
                                {
                                        Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                                }
                                else
                                {
                                        throw ex;
                                }
                        }
                }
        }
        
        public PageReference viewRes(){
                isFromSearch = true;
                PageReference res;
                if(consignment != null){
                        res = Page.OL_SearchConsignmentById;
                        res.setRedirect(false);
                }
                return res;
        }
        
        public PageReference backToSearch(){
                return Page.OL_SearchConsignment;
        }
        
        public Boolean checkSearchData(){
                Boolean res = true;
                
                //check unic numbers
                if(String.isBlank(consReq.tntConNum) && String.isBlank(consReq.bkgNum) && String.isBlank(consReq.custRef)){
                        
                        if(!isAdvanced){
                                res = false;
                                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 
                                        'You should specify Con Number or Coll Req Number or Cust Ref Number or use Advanced Search.'));
                        }
                
                        //Check date from and date to
                        if(quoteTo.Collection_Date__c == null){
                                res = false;
                                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'You must select Date To.'));
                        }
                        
                        if(quote.Collection_Date__c == null){
                                res = false;
                                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'You must select Date From.'));
                        }
                        
                        if(res && (quote.Collection_Date__c > quoteTo.Collection_Date__c)){
                                res = false;
                                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Date From must be before Date To.'));
                        }
                        
                        if(res && (quote.Collection_Date__c.daysBetween(quoteTo.Collection_Date__c) > 7)){
                                res = false;
                                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 
                                        'It should not be more than week between Date From and Date To.'));
                        }
                        
                        // Check Collection Depot and Collection Round Num
                        if(!String.isBlank(consReq.colRnd) && String.isBlank(consReq.colDep)){
                                res = false;
                                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 
                                        'If Coll Round No is entered, Coll Depot should be entered as well.'));
                        }
                        
                        if((!String.isBlank(consReq.delRnd) || quote.Delivery_Date__c != null ) && String.isBlank(consReq.delDep)){
                                res = false;
                                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 
                                        'If Del Round No or Del Date is entered, Del Depot should be entered as well.'));
                        }
                
                }
                
                return res;
        }
        
        public void resetFilters(){
                consReq = new uksvcsTntComSearchConsignment.ConsignmentRequest_MasterType();
                consReq.delAddr = new uksvcsTntComSearchConsignment.ShortAddress_MasterType();
                consReq.stsHstry = new uksvcsTntComSearchConsignment.ShortConsignmentStatusHistory_MasterType();
                
                quote = new Quote__c();
                quoteTo = new Quote__c();
                quoteTo.Collection_Date__c = Date.today();
                quote.Collection_Date__c = Date.today() - 1;
                
                pageNumber = 1;
        }
        
        //GET ITEMS FOR PICKLISTS
        public List<SelectOption> getDepotItems() {
                List<SelectOption> options = new List<SelectOption>();
                
                for(Account a : [SELECT Name, Depot_Number__c FROM Account 
                                WHERE Depot_Number__c != null AND RecordTypeId = : TestUtil.accountDepotRTId ORDER BY Name]){
                        options.add(new SelectOption(a.Depot_Number__c, a.Name + ' ('+a.Depot_Number__c+')'));
                }       
                return options;
        }
        
        public List<SelectOption> getServiceItems() {
                List<SelectOption> options = new List<SelectOption>();
                
                for(Service__c s : [SELECT Name, Service_Code__c FROM Service__c WHERE Service_Code__c != null ORDER BY Name]){
                        options.add(new SelectOption(s.Service_Code__c, s.Name + ' ('+s.Service_Code__c+')'));
                }       
                return options;
        }
        
        public List<SelectOption> getOptionItems() {
                List<SelectOption> options = new List<SelectOption>();
                
                for(Option_Settings__c os : [SELECT Name, SF_Description__c FROM Option_Settings__c ORDER BY Name]){
                        options.add(new SelectOption(os.SF_Description__c, os.SF_Description__c + ' ('+os.Name+')'));
                }       
                return options;
        }
        
        public List<SelectOption> getNoteTypeItems() {
                List<SelectOption> options = new List<SelectOption>();
                
                for(Note_Type_Settings__c os : [SELECT Name, SF_Description__c FROM Note_Type_Settings__c ORDER BY Name]){
                        options.add(new SelectOption(os.SF_Description__c, os.SF_Description__c + ' ('+os.Name+')'));
                }       
                return options;
        }
        
        public List<SelectOption> getConStatusItems() {
                List<SelectOption> options = new List<SelectOption>();
                
                for(Con_Status_Settings__c cs : [SELECT Name, SF_Description__c FROM Con_Status_Settings__c ORDER BY Name]){
                        options.add(new SelectOption(cs.SF_Description__c, cs.SF_Description__c + ' ('+cs.Name+')'));
                }       
                return options;
        }
        
        public List<SelectOption> getConSubStatusItems() {
                List<SelectOption> options = new List<SelectOption>();
                
                for(Con_Sub_Status_Settings__c css : [SELECT Name, SF_Description__c FROM Con_Sub_Status_Settings__c ORDER BY Name]){
                        options.add(new SelectOption(css.SF_Description__c, css.SF_Description__c + ' ('+css.Name+')'));
                }       
                return options;
        }
        
        public List<SelectOption> getLobItems() {
                List<SelectOption> options = new List<SelectOption>();
                
                for(Line_of_Business__c l : [SELECT Name, Line_of_Business_Reference__c FROM Line_of_Business__c WHERE Line_of_Business_Reference__c != null ORDER BY Name]){
                        options.add(new SelectOption(l.Line_of_Business_Reference__c, l.Name + ' ('+l.Line_of_Business_Reference__c+')'));
                }       
                return options;
        }
        
        //Methods for Detail Page
        public void searchConsignment() {
                if(consignmentId == null){
                        consignmentId = ApexPages.currentPage().getParameters().get('conId');
                }
                
                consignmentItems = null;
        rowItemForTracking = null;
        caseToOpen = null;
        
        if(consignmentId != null){
                uksvcsTntComSearchConsignmentService.searchConsignment2Port  
                                port = new uksvcsTntComSearchConsignmentService.searchConsignment2Port();
                        
                port.inputHttpHeaders_x = new map<string,string> {'Username' => TNT_Integration__c.getInstance().Username__c, 
                                                              'Password' => TNT_Integration__c.getInstance().Password__c};
            
                        uksvcsTntComGenericPayloadHeader.payloadHeader 
                    hdr = new uksvcsTntComGenericPayloadHeader.payloadHeader();
                
                uksvcsTntComSearchConsignment.ConsignmentRequest_MasterType newReq = new uksvcsTntComSearchConsignment.ConsignmentRequest_MasterType();
                
                newReq.unqConNum = consignmentId;
                
                try{
                        if(!ConstantUtil.INTEGRATION_ACCESS) throw new ConstantUtil.IntegrationAccessDeniedException(ConstantUtil.INTEGRATION_EXMSG);
                        port.timeout_x = ConstantUtil.INTEGRATION_TIMEOUT;
                        resp = port.searchConsignment2(newReq, hdr);
                        
                        if(resp.con != null){
                                consignment = resp.con;
                                consignment.addDiscrepCommentsToHistoryRecords();
                        }
                        
                        if(resp.hdr != null && !String.isBlank(resp.hdr.infoMsg)){
                                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, resp.hdr.infoMsg));
                        }
                } catch(Exception ex) {
                                if(ex instanceof System.CalloutException || ex instanceof ConstantUtil.IntegrationAccessDeniedException)
                                {
                                        Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                                        consignment = null;
                                }
                                else
                                {
                                        throw ex;
                                }
                        }
        }
        }
        
        public void searchConsignmentItems() {
                uksvcsTntGetItemsForConsignmentService.getItemsForConsignmentPort port = new uksvcsTntGetItemsForConsignmentService.getItemsForConsignmentPort();
        

        port.inputHttpHeaders_x = new map<string,string> {'Username' => TNT_Integration__c.getInstance().Username__c, 
                                                          'Password' => TNT_Integration__c.getInstance().Password__c};
        
        uksvcsTntComGenericPayloadHeader.payloadHeader 
            hdr = new uksvcsTntComGenericPayloadHeader.payloadHeader();
        uksvcsTntGetItemsForConsignment.ItemRequest_MasterType  
            con = new uksvcsTntGetItemsForConsignment.ItemRequest_MasterType ();
        con.unqConNum = consignment.unqConNum;
        
        uksvcsTntGetItemsForConsignment.ResponseMessage_MasterType resp;
        
        try{
                if(!ConstantUtil.INTEGRATION_ACCESS) throw new ConstantUtil.IntegrationAccessDeniedException(ConstantUtil.INTEGRATION_EXMSG);
                port.timeout_x = ConstantUtil.INTEGRATION_TIMEOUT;
                resp = port.getItemsForConsignment (hdr, con);
                consignmentItems = resp.itms.itm;
        } catch(System.NullPointerException ex) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'No Consignment Items found.'));
                consignmentItems = null;
        }
        catch(Exception ex) {
                        if(ex instanceof System.CalloutException || ex instanceof ConstantUtil.IntegrationAccessDeniedException)
                        {
                                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                        consignmentItems = null;
                        }
                        else
                        {
                                throw ex;
                        }
                }
        }
        
        public void setSelectedItemRaw(){
                //rowItemForTracking = rowNum;
        }
        
        public void runCreateAndSaveCase(){
               //if(!anyRecentCases()){
                        createAndSaveCase();//DH modified and commented out
               //} else {
               //         createAndSave = true;
               //         createAndOpen = false;
               //}
        }
        
        public void runCreateAndOpenCase(){
                if(!anyRecentCases()){
                        createAndOpenCase();
                } else {
                        createAndSave = false;
                        createAndOpen = true;
                }
        }
        
        public void hideCasePanel(){
                createAndSave = false;
                createAndOpen = false;
        }
        
        public void createAndSaveCase(){
                hideCasePanel();
                Case c = createCase();
                c.Type = ConstantUtil.PLVAL_CASE_TYPE_RECORD_TRACK;//Modified by DH 24/09/15 for Kish
                c.Status = ConstantUtil.PLVAL_CASE_STATUS_CLOSED;
                
                
                try{
                        insert c;
                        Case tCase = [SELECT CaseNumber, AccountId, Type, Status FROM Case WHERE Id = : c.Id];
                        Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, 'Case ' + tCase.CaseNumber + 
                                ' has been created successfully. <a href="#" onclick="openObject(\'' + 
                                tCase.Id +'\', \''+ tCase.CaseNumber + '\');">Open Case</a>'));
                } catch(Exception ex){
                        Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                }
        }
        
        public void createAndOpenCase(){
                hideCasePanel();
                caseToOpen = null;
                Case c = createCase();
                c.Type = ConstantUtil.PLVAL_CASE_TYPE_TRACK;
                c.Status = ConstantUtil.PLVAL_CASE_STATUS_WORKING_ON;
                
                try{
                        insert c;
                        caseToOpen = [SELECT CaseNumber, AccountId, Type, Status FROM Case WHERE Id = : c.Id];
                        Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, 'Case ' + caseToOpen.CaseNumber + 
                                ' has been created successfully. <a href="#" onclick="openObject(\'' + 
                                caseToOpen.Id +'\', \''+ caseToOpen.CaseNumber + '\');">Open Case</a>'));
                } catch(Exception ex){
                        Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                }
        }
        
        
        public Boolean anyRecentCases(){
                Date sixWeeks = Date.today().addDays(-42);
                recentCases = new List<Case>([SELECT Id, CaseNumber FROM Case WHERE CreatedDate > : sixWeeks AND Consignment_Number__c = : consignment.tntConNum]);
                return !recentCases.isEmpty();
        }

        public Account account{
                get{
                        if(consignment.act != null && consignment.act.actNum != null){
                                List<Account> accounts = [SELECT Name FROM Account WHERE Account_Number__c = : consignment.act.actNum];
                                if(!accounts.isEmpty()){
                                        account = accounts[0];
                                } else {
                                        account = new Account();
                                }
                        } else {
                                account = null;
                        }
                        return account;
                }
                private set;
        }
        
        private Case createCase(){
                Case c = new Case();
                c.Consignment_Number__c = consignment.tntConNum;
                c.UUCN_Number__c = consignment.unqConNum;
                c.Exception__c = ConstantUtil.PLVAL_CASE_EXCEPTION_DELIVERY;
                if(consignment.act != null){
                        c.AccountId = account.Id;
                }
                c.Delivery_Depot__c = String.isNotBlank(consignment.orgnDep) && depots.containsKey(consignment.orgnDep)
                        ? depots.get(consignment.orgnDep).Id : null;
                return c;
        }
        
        public void fillDepots() {
                depots = new Map<String, Account>();
                depotKeys = '';
                
                for(Account a : [SELECT Name, Depot_Number__c FROM Account 
                                WHERE Depot_Number__c != null AND RecordTypeId = : TestUtil.accountDepotRTId ORDER BY Name]){
                        depots.put(a.Depot_Number__c, a);
                        depotKeys += '*' + a.Depot_Number__c + '*';
                }
        }
        
        public void fillServices() {
                services = new Map<String, Service__c>();
                serviceKeys = '';
                
                for(Service__c s : [SELECT Name, Service_Code__c FROM Service__c WHERE Service_Code__c != null ORDER BY Name]){
                        services.put(s.Service_Code__c, s);
                        serviceKeys += '*' + s.Service_Code__c + '*';
                }
        }
        
        public void fillLobs() {
                lobs = new Map<String, Line_of_Business__c>();
                lobKeys = '';
                
                for(Line_of_Business__c l : [SELECT Name, Line_of_Business_Reference__c FROM Line_of_Business__c WHERE Line_of_Business_Reference__c != null ORDER BY Name]){
                        lobs.put(l.Line_of_Business_Reference__c, l);
                        lobKeys += '*' + l.Line_of_Business_Reference__c + '*';
                }
        }

}