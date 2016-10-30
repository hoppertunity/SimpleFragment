/**
Test class for CS_Claims_Form_Controller class and CS_Claims_Form_PDF_Controller class
 */
@isTest
private class CS_Claims_Test {

    TestMethod static void test_Claim_form_excpetion_scenario_closed_stage(){
        	try{
        		
        			Account a = TestUtil.createAccountClient();
			    	insert a;
			    	Account d = TestUtil.createAccountDepot();
			    	insert d;
			    	
        			CS_Claims__c testClaim = new CS_Claims__c(Depot_no__c='067', Reference_no__c='45678999', TNT_account_no__c='203456789',	Sender_Email_Address__c='test@test.com',Claims_Stage__c = 'Closed',Declarant_Full_Name_of__c='test',Declarant_Date__c= Date.today());
        			testClaim.Account__c = a.Id;
        			testClaim.Depot__c = d.Id; 
	
	        		insert testClaim;
        		
        		ApexPages.CurrentPage().getParameters().put('cid',testClaim.Id);
        		Test.StartTest();
        		CS_Claims_Form_Controller claimForm = new CS_Claims_Form_Controller(new ApexPages.StandardController(testClaim));
        		claimForm.claim.Declarant_Date__c = Date.today();        		
        		claimForm.save_m();    
        		Test.stopTest();
        	}catch(Exception ex){
        		system.debug(ex);
        	}        		        		
        }
       TestMethod static void test_Claim_form_excpetion_scenario_no_id(){
       		try{
       				Account a = TestUtil.createAccountClient();
			    	insert a;
			    	Account d = TestUtil.createAccountDepot();
			    	insert d;
			    	
        			CS_Claims__c testClaim = new CS_Claims__c(Depot_no__c='067', Reference_no__c='45678999', TNT_account_no__c='203456789',	Sender_Email_Address__c='test@test.com',Claims_Stage__c = 'In Progress',Declarant_Full_Name_of__c='test',Declarant_Date__c= Date.today());        			
        			testClaim.Account__c = a.Id;
        			testClaim.Depot__c = d.Id;  
	
	        		insert testClaim;
        		
        		ApexPages.CurrentPage().getParameters().put('cid','');
        		Test.StartTest();
        		CS_Claims_Form_Controller claimForm = new CS_Claims_Form_Controller(new ApexPages.StandardController(testClaim));
        		claimForm.claim.Declarant_Full_Name_of__c = 'test';        		
        		claimForm.save_m();    
        		Test.stopTest();
        	}catch(Exception ex){
        		system.debug(ex);
        	}        		        		
        }
       TestMethod static void test_Claim_form_excpetion_scenario_check_validation(){
       		try{
       				Account a = TestUtil.createAccountClient();
			    	insert a;
			    	Account d = TestUtil.createAccountDepot();
			    	insert d;
			    	
        			CS_Claims__c testClaim = new CS_Claims__c(Depot_no__c='067', Reference_no__c='45678999', TNT_account_no__c='203456789',	Sender_Email_Address__c='test@test.com',Claims_Stage__c = 'In Progress');
        			testClaim.Account__c = a.Id;
        			testClaim.Depot__c = d.Id;  
	
	        		insert testClaim;
        		
        		ApexPages.CurrentPage().getParameters().put('cid','');
        		Test.StartTest();
        		CS_Claims_Form_Controller claimForm = new CS_Claims_Form_Controller(new ApexPages.StandardController(testClaim));
        		
        		claimForm.claim.Declarant_Date__c = Date.today();
        		claimForm.claim.Declarant_Full_Name_of__c = 'test';        		        		
        		claimForm.claim.cheque__c = true;
        		claimForm.claim.Credit_your_TNT_account__c = true;
		
        		claimForm.save_m();    
        		Test.stopTest();
        	}catch(Exception ex){
        		system.debug(ex);
        	}        		        		
        }
       TestMethod static void test_Claim_form_excpetion_scenario_check_validation_2(){
       		try{
       				Account a = TestUtil.createAccountClient();
			    	insert a;
			    	Account d = TestUtil.createAccountDepot();
			    	insert d;
			    	
        			CS_Claims__c testClaim = new CS_Claims__c(Depot_no__c='067', Reference_no__c='45678999', TNT_account_no__c='203456789',	Sender_Email_Address__c='test@test.com',Claims_Stage__c = 'In Progress');
        			testClaim.Account__c = a.Id;
        			testClaim.Depot__c = d.Id;  
	
	        		insert testClaim;
        		
        		ApexPages.CurrentPage().getParameters().put('cid','');
        		Test.StartTest();
        		CS_Claims_Form_Controller claimForm = new CS_Claims_Form_Controller(new ApexPages.StandardController(testClaim));        		        		
        		claimForm.claim.Declarant_Date__c = Date.today();
        		claimForm.claim.Declarant_Full_Name_of__c = 'test';        		
        		claimForm.claim.Lost__c = true;
        		claimForm.claim.Damaged__c = true;        		
        		claimForm.save_m();    
        		claimForm.getClaims(null);
          		Test.stopTest();
        	}catch(Exception ex){
        		system.debug(ex);
        	}        		          		
       }
       
       TestMethod static void test_pdf_controller(){
        try{
        		Account a = TestUtil.createAccountClient();
		    	insert a;
		    	Account d = TestUtil.createAccountDepot();
		    	insert d;
		    	
                CS_Claims__c testClaim = new CS_Claims__c(Depot_no__c='067', Reference_no__c='45678999', TNT_account_no__c='203456789', Sender_Email_Address__c='test@test.com',Claims_Stage__c = 'In Progress',Declarant_Full_Name_of__c='test',Declarant_Date__c= Date.today());
                testClaim.Account__c = a.Id;
        		testClaim.Depot__c = d.Id;
        		  
                insert testClaim;
                
                ApexPages.CurrentPage().getParameters().put('id',testClaim.Id);             
                Test.StartTest();
                CS_Claims_Form_PDF_Controller claimForm = new CS_Claims_Form_PDF_Controller();
                claimForm.getClaims(null);
                claimForm.getClaims(testClaim.Id);                                              
                system.debug(claimForm.address);                
                system.debug(claimForm.check_list_opt_1);
                system.debug(claimForm.check_list_opt_2);
                system.debug(claimForm.check_list_opt_3);
                system.debug(claimForm.check_list_opt_4);
                system.debug(claimForm.Claims_damaged_section_title);
                system.debug(claimForm.Claims_type_details_section_content);
                system.debug(claimForm.Claims_type_details_section_title);
                system.debug(claimForm.Claims_type_fieldset_label);
                system.debug(claimForm.Cost_value_of_consignment_label);
                system.debug(claimForm.Cost_value_of_items_label);
                system.debug(claimForm.Declaration_section_title);
                system.debug(claimForm.damaged_items_inspection_label);
                system.debug(claimForm.emailId);      
                system.debug(claimForm.header);
                system.debug(claimForm.payment_method_label);
                system.debug(claimForm.Recipient_section_title);
                system.debug(claimForm.replacement_consignement_no_label);
                system.debug(claimForm.Sender_section_title);               
                Test.stopTest(); 
        	}catch(Exception ex){
        		system.debug(ex);
        	}        		                           
    }
}