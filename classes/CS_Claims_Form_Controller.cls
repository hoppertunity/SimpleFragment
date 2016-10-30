/*********************************************************************************************************************************************************
        This controller is used for building the claims form visual force page. (TNT Claims UK)
**********************************************************************************************************************************************************
**********************************************************************************************************************************************************
	This Apex class is build for the Apex page and it was build by Makepositive - Mohammed - +44 (0)20 7960 4197
**********************************************************************************************************************************************************/
public without sharing class CS_Claims_Form_Controller {
        
	  public CS_Claims__c claim {get; set;} 
	
	  public Boolean Editable {get; set;}
	   
	  public Id id {get; set;}
	  

	  public String fax1 {
	            get{
	                    return CS_TNT_Claims__c.getInstance().Fax_1__c; 
	            }
	  } 
	  public String fax2 {
	            get{
	                    return CS_TNT_Claims__c.getInstance().Fax_2__c; 
	            }
	   }
	   public String Tele {
	            get{
	                    return CS_TNT_Claims__c.getInstance().Telephone__c; 
	            }
	   }  
	   public String emailId {
	            get{
	                    return CS_TNT_Claims__c.getInstance().Email_Id__c; 
	            }
	   } 
	   public String address {
	            get{
	                    return CS_TNT_Claims__c.getInstance().Claims_postal_address__c; 
	            }
	   }
	   public String header {
	            get{
	                    return CS_TNT_Claims__c.getInstance().Header__c;
	            }
	   }        
	   
	   public String Sender_section_title{
	            get{
	                    return CS_TNT_Claims__c.getInstance().Sender_section_title__c;
	            }
	   }
	   public String Recipient_section_title{
	            get{
	                    return CS_TNT_Claims__c.getInstance().Recipient_Section_title__c;
	            }
	   }
	   public String Claims_type_fieldset_label{
	            get{
	                    return CS_TNT_Claims__c.getInstance().Claims_type_fieldset_label__c;
	            }
	   }                                                 
	   public String Claims_type_details_section_title{
	            get{
	                    return CS_TNT_Claims__c.getInstance().Claims_type_details_section_title__c;
	            }
	   }
	   public String Claims_type_details_section_content{
	            get{
	                    return CS_TNT_Claims__c.getInstance().Claims_type_details_section_content__c;
	            }
	   }
	   public String Claims_damaged_section_title{
	            get{
	                    return CS_TNT_Claims__c.getInstance().Claims_damaged_section_title__c;
	            }
	   }       
	   public String damaged_items_inspection_label{
	            get{
	                    return CS_TNT_Claims__c.getInstance().damaged_items_inspection_label__c;
	            }
	   }
	   public String payment_method_label{
	            get{
	                    return CS_TNT_Claims__c.getInstance().Method_of_payment_fieldset_label__c;
	            }
	   }
	   
	   public String Declaration_section_title{
	            get{
	                    return CS_TNT_Claims__c.getInstance().Declaration_section_title__c;
	            }
	   }
	   public String Cost_value_of_consignment_label{
	            get{
	                            return CS_TNT_Claims__c.getInstance().Cost_value_of_consignment_label__c;
	            }
	   }
	   public String Cost_value_of_items_label{
	            get{
	                    return CS_TNT_Claims__c.getInstance().Cost_value_of_items_label__c;
	            }
	   }
	   
	   public String check_list_opt_1{
	            get{
	                            return CS_TNT_Claims__c.getInstance().Check_list_opt_1__c;
	            }
	   }
	   public String check_list_opt_2{
	            get{
	                            return CS_TNT_Claims__c.getInstance().Check_list_opt_2__c;
	            }
	   }
	   public String check_list_opt_3{
	            get{
	                            return CS_TNT_Claims__c.getInstance().Check_list_opt_3__c;
	            }
	   }
	   public String check_list_opt_4{
	            get{
	                            return CS_TNT_Claims__c.getInstance().Check_list_opt_4__c;
	            }
	   }
	   public String replacement_consignement_no_label{
	            get{
	                    return CS_TNT_Claims__c.getInstance().Replacement_consignment_no_Label__c;
	            }
	   }	        		                	                  
                
       public CS_Claims_Form_Controller(ApexPages.StandardController controller){
        			try{
        				Decimal VisitCounter;                        
                        claim = new CS_Claims__c();
                        
                        Editable= false;                                        	
                		
                		id = ApexPages.currentPage().getParameters().get('cid');                              	                                                     
	                        
                                claim = getClaims(id);                         
                                       		                                
					            VisitCounter = claim.Form_Visit_Counter__c;							            
					            
					            if(VisitCounter == null){
					            	VisitCounter = 0;
					            }					            
					            claim.Form_Visit_Counter__c = VisitCounter + 1;
					                                            		                              
                                if(!ApexPages.hasMessages()){
                                	                                	                                                              
	                                if(claim.Claims_Stage__c != 'Returned' && claim.Claims_Stage__c != 'Closed' ){
	                                        claim.Claims_Stage__c = 'In Progress';
	                                        Editable = true;
	                                                                                                        
	                                }else if(claim.Claims_Stage__c == 'Closed'){
											ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Your claim form has been expired as it has been more than 21 days from the date of issue. Please contact TNT Customer care for more details.'));
											Editable= false;											                                	
	                                }	                       	                        
                        		}                                                                             
                        
        			}catch(Exception ex){
        				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Access Denied. Please contact TNT customer care for further assistance.'));
        			}
        }
        
        public PageReference updateCounter(){
        	if(id != null){
        		
	           update claim;
        	}                      
	           return null;                                
        }
        
        public PageReference quickSave(){
                
                        claim.Claims_Stage__c = 'In Progress';

                        update claim;
                        if(!ApexPages.hasMessages()){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Your form has been saved, to complete it later please click on the same link from your mail.'));                            
                        }
                        return null;
                        
        }
        
        public Pagereference sendLink(){
                
                Id id = ApexPages.CurrentPage().getParameters().get('id');
                claim = getClaims(id);
                
                if(claim.Claims_Stage__c != 'Returned' && claim.Claims_Stage__c != 'Closed' ){
	                claim.Claims_Stage__c = 'Sent to Customer';             
	                update claim;
                }
                Schema.DescribeSObjectResult r = CS_Claims__c.sObjectType.getDescribe();
				String keyPrefix = r.getKeyPrefix();
                PageReference pg = new PageReference('/' + keyPrefix + '/o');              
                pg.setRedirect(true);
                
                return pg;
        }
        
        public PageReference save_m(){                
                Boolean valid = true;
                Boolean sendEmail = false;
                 if(claim.Declarant_Full_Name_of__c == null){
                        
                        valid = false;                  
                        claim.Declarant_Full_Name_of__c.addError('Please complete the Full name of the Declerant.');
                        
                }else if(claim.Declarant_Date__c == null){
                        
                        valid = false;                  
                        claim.Declarant_Date__c.addError('Date is a required field.');
                }else if(claim.Lost__c == true && claim.Damaged__c == true){
                 		
                 		valid = false;
                 		claim.Lost__c.addError('only one option can be selected either "Lost" or "Damaged".');
                 		claim.Damaged__c.addError('only one option can be selected either "Lost" or "Damaged".');
                }else if (claim.cheque__c == true && claim.Credit_your_TNT_account__c == true ){
                 		valid = false;
                 		claim.cheque__c.addError('only one option can be selected "Cheque" or "Credit your TNT account".');
                 		claim.Credit_your_TNT_account__c.addError('only one option can be selected "Cheque" or "Credit your TNT account".');                 	
                }
                
                if(valid){
                        
                        claim.Claims_Stage__c = 'Returned';
                        
                        Map<String, Schema.RecordTypeInfo> ClaimsTypes = CS_Claims__c.SObjectType.getDescribe().getRecordTypeInfosByName();
						claim.RecordTypeId = ClaimsTypes.get('CS Sent to Customer').getRecordTypeId();
						try{
                        	upsert claim;
                        	sendEmail = true;
						}catch(exception e){
							sendEmail = false;
						}                                                  
                        Editable = false;                       
                }
                PageReference pg = Page.CS_Claim_Form_View_Page;
                pg.getParameters().put('cid',(String) claim.Id);
                if(sendEmail){                	        
			       pg.setRedirect(true);
			       return pg; 
                }else{
                	return null;
                }                                                       
        }
        public PageReference sendEmail(){
         // send email to the Claims Lotus system once the record is returned from the customer
			         try{
			         		CS_Claims__c cl = getClaims(claim.Id);
			         		system.debug('==>CLAIMS '+ cl);
			         		if(cl.ClaimReturnMailSent__c == false){
			         			system.debug('===inIFCondition=== '+ cl.ClaimReturnMailSent__c);
				         		Pagereference pdf = Page.CS_Claim_Form_PDF;
				         		pdf.getParameters().put('cid',(String)cl.id);
				         		pdf.setRedirect(true);
				         		
				         		Blob body = pdf.getContent();
				         		
				                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                                                
				                              				            
				                mail.setSaveAsActivity(false);                            
								
		                 		String[] toAddresses = new String[1];
		                 		system.debug('=====cl.Lotus_Notes_Claims_Email_ID__c=====' +cl.Lotus_Notes_Claims_Email_ID__c);
                            	toAddresses[0] = cl.Lotus_Notes_Claims_Email_ID__c; //& Uncommment this line in production    
                            	/*
	                            * To test this in Sandbox comment above two lines and add the below given line and uncoment below three line as well
	                            * String[] toAddresses = new String[3];
                              	*/                                        
	                            //String[] toAddresses = new String[3]; 
	                            //toAddresses[0] = 'mohammed.haseeb@makepositive.com'; //& Comment this line in production
	                            //toAddresses[1] = 'lucia.gascoigne@tnt.com';
	                            //toAddresses[2]='nina.hannon@tnt.com';
	                            mail.setToAddresses(toAddresses);
				                mail.setHtmlBody('<p>Attached is Claim  ' + cl.Name + '  returned by  '+ cl.Sender_Contact_Name__c +'</p><p> Reference  No: '+ cl.Reference_no__c+'</p>');			              
				                
				                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
				                efa.setFileName(cl.Reference_no__c +'.pdf');
				                efa.setBody(body);			                
				                mail.setFileAttachments(new Messaging.Emailfileattachment[] {efa});
				                mail.setSubject('TNT Claim Return. Claim Reference no: '+ cl.Reference_no__c +' Consignment no: '+ cl.Consignment_no__c +' Depot code: ' + cl.Depot_no__c);
				                mail.setReplyTo(cl.Sender_Email_Address__c);
				                mail.setSenderDisplayName(cl.Sender_Email_Address__c);
				                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
				                cl.ClaimReturnMailSent__c = true;
				                update cl;
			         		}
				        }catch(Exception e){	           
				            system.debug('==>emialTrigger' + e);
				        }
				        return null;
        }
        public CS_Claims__c getClaims(Id id){
                CS_Claims__c cl = new CS_Claims__c();
                try{
                cl = [SELECT
                		Name,
                        Copy_of_relevant_commercial_invoice__c, 
                        Copy_of_repair_estimate__c,
                        Sender_Address_1__c,
                        Recipient_Address_1__c,
                        Sender_Address_2__c,
                        Recipient_Address_2__c,
                        Sender_Address_3__c,
                        Recipient_Address_3__c,
                        All_requested_information__c,
                        cheque__c,
                        Claims_Stage__c,
                        Sender_company_name__c,
                        Consignment_no__c,
                        Sender_Contact_Name__c,
                        Recipient_Contact_Name__c,
                        Cost_of_consignment_exclcuding_VAT__c,
                        Cost_of_items_exclcuding_VAT__c,
                        Credit_your_TNT_account__c,
                        Sender_Email_Address__c,
                        Damaged__c,
                        Declarant_Date__c,
                        Date_of_dispatch__c,
                        Depot_no__c,
                        Detail_description_of_items__c,
                        Declarant_Full_Name_of__c,
                        damaged_packing_inspection__c,
                        Lost__c,
                        photographs_of_the_items__c,
                        Sender_Postcode__c,
                        Recipient_Postcode__c,
                        Reference_no__c,
                        Salvage_value__c,
                        Sender_Telephone_no__c,
                        Recipient_Telephone_no__c,
                        TNT_account_no__c,
                        Weight_of_items__c,
                        Repair_cost__c,
                        Replacement_Consignment_No__c,
                        Form_Visit_Counter__c,
                        Lotus_Notes_Claims_Email_ID__c, 
                        ClaimReturnMailSent__c                                                                                    
                        FROM CS_Claims__c 
                                WHERE 
                                id=: id
                        ];
                }catch(Exception e){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'If this error persists please contact TNT Customer care for further help. ERROR:' + e.getMessage()));
                }
                        
                        return cl;              
        }
              
}