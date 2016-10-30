global class BookingHistory_DataDeletion implements Schedulable 
{
   global void execute(SchedulableContext sc) 
   {
        BatchDelete BDel = new BatchDelete(); 
        Integer  no  = 0;  
        DataRetentionSettings__c myCS1 = DataRetentionSettings__c.getInstance('DayNumber'); 
        if (myCS1 != null)
        {       
            System.debug(logginglevel.ERROR, '££££££££££££££ no is' + myCS1.BookingHistoryRetentionPeriod__c);          
            no = myCS1.BookingHistoryRetentionPeriod__c.intValue();       
        }
        else
        {
            no = 180;
        }             

        datetime ddd = SYSTEM.NOW().addDays(-no);
        System.debug(logginglevel.ERROR, '££££££££££££££ ddd is' + ddd );  
   //     BDel.query = 'SELECT Id FROM Booking_History__c where Movement_Date_Time__c < 2015-04-22T13:31:00.00Z';
      
        BDel.query = 'SELECT Id FROM Booking_History__c where Movement_Date_Time__c < '+ddd.format('yyyy-MM-dd')+'T'+ ddd.format('HH:mm')+':00.000Z'; 
        ID batchprocessid = Database.executeBatch(BDel); 


        System.debug('************************** Returned batch process ID: ' + batchProcessId); 
   }
}