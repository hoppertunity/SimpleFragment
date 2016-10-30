global with sharing class CaseBasedRoutingWebService
{
 
    webService static string getCaseOwnerAvayaID(String caseNumber) 
    {
        String paddedCaseNumber;
        
         if(caseNumber == null || caseNumber == '' || caseNumber.length() > 8)
         {
             system.debug('**ERROR** Case Number null, empty or > 8 chrs: ' + caseNumber);
             return 'ERROR:INVALID CASE NUMBER';
         }
         try
         {
             integer caseInt = integer.valueOf(caseNumber);
             if(caseInt < 0) return 'ERROR:INVALID CASE NUMBER';
             paddedCaseNumber = String.valueOf(caseInt);
             while (paddedCaseNumber.length() < 8)  
             { 
                paddedCaseNumber = '0' + paddedCaseNumber; 
             }
         }
         catch(Exception ex)
         {
             system.debug('**ERROR** Case Number not an integer: ' + caseNumber);
             return 'ERROR:INVALID CASE NUMBER';
         }
          
        System.debug('*** Getting Case ***');
          List<Case> selectedCase = [Select ownerID from case where isclosed = false and caseNumber =:paddedCaseNumber and owner.type = 'User' and owner.isActive = true limit 1];
          if(selectedCase.size() == 0) return 'Not Found';
        
          System.DEBUG('***Case Found***');
          string avayaID = ([Select AVAYA_ID__c from user where id=:selectedCase[0].OwnerID limit 1]).AVAYA_ID__c;
          return avayaID != null ? avayaID : 'Not Found';
    }
   
   
}