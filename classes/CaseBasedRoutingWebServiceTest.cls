@isTest

public class CaseBasedRoutingWebServiceTest 
{
  static testMethod void testCaseBasedRoutingServiceWithUserWithAvayaID()
  {
      //Create USER with Avaya ID
      User u = TestUtil.createAgentUser();
      u.Avaya_ID__c = '1234';
      insert u;
      
      //Create A Case
      Account a = TestUtil.createAccountClient();
      insert a;
      Account d = TestUtil.createAccountDepot();
      insert d;
      Contact con = TestUtil.createContact(a.Id);
      insert con;
      Case c = TestUtil.createCase(a.id,con.id,d.id);
      c.OwnerId = u.id;
      insert c;
     
      Case testCase = [Select CaseNumber from Case where id =: c.Id];
      system.assertEquals('1234',CaseBasedRoutingWebService.getCaseOwnerAvayaID(testCase.CaseNumber));
                
         
  }
   
  static testMethod void testCaseBasedRoutingServiceWithUserWithOUTAvayaID()
  {
      //Create USER with Avaya ID
      User u = TestUtil.createAgentUser();
      
      insert u;
      
      //Create A Case
      Account a = TestUtil.createAccountClient();
      insert a;
      Account d = TestUtil.createAccountDepot();
      insert d;
      Contact con = TestUtil.createContact(a.Id);
      insert con;
      Case c = TestUtil.createCase(a.id,con.id,d.id);
      c.OwnerId = u.id;
      insert c;
     
      Case testCase = [Select CaseNumber from Case where id =: c.Id];
      system.assertEquals('Not Found',CaseBasedRoutingWebService.getCaseOwnerAvayaID(testCase.CaseNumber));
                
         
  }
    
  static testMethod void testCaseBasedRoutingServiceWithQueueOwner()
  {
      //Create Queue
      Group queue = [Select Id from Group where Name = 'Atherstone MAD 1' limit 1];
            
      //Create A Case
      Account a = TestUtil.createAccountClient();
      insert a;
      Account d = TestUtil.createAccountDepot();
      insert d;
      Contact con = TestUtil.createContact(a.Id);
      insert con;
      Case c = TestUtil.createCase(a.id,con.id,d.id);
      c.OwnerId = queue.id;
      insert c;
     
      Case testCase = [Select CaseNumber from Case where id =: c.Id];
      system.assertEquals('Not Found',CaseBasedRoutingWebService.getCaseOwnerAvayaID(testCase.CaseNumber));
                
         
  }
    //Test Exception case numbers
  
  static testMethod void testCaseBasedRoutingServiceWithWhiteSpaceCaseNumber()
  {
      
      system.assertEquals('ERROR:INVALID CASE NUMBER',CaseBasedRoutingWebService.getCaseOwnerAvayaID(' '));
 
  }
    
  static testMethod void testCaseBasedRoutingServiceWithTooLong()
  {
      
      system.assertEquals('ERROR:INVALID CASE NUMBER',CaseBasedRoutingWebService.getCaseOwnerAvayaID('123456789'));
 
  }
    
  static testMethod void testCaseBasedRoutingServiceWithNonNumber()
  {
      
      system.assertEquals('ERROR:INVALID CASE NUMBER',CaseBasedRoutingWebService.getCaseOwnerAvayaID('00A123'));
 
  }
  

}