@isTest//(SeeAllData=true)
private class BookingHistory_DataDeletion_Tests
{                                   
    static testMethod void DataDeletionTest()
    {                 
          Booking__c myBooking = new Booking__c(); 
          myBooking.Commodity__c = 'Envelope';
          insert myBooking;  
           
          List<Booking__c> value = [Select id from Booking__c]; 
          string bookingID;
          for (Booking__c record : value )
          {
             if (record.Id != null)
             {
                bookingID = record.Id;
             }
          }    

          Booking_History__c myBookingHistory = new Booking_History__c(); 
          myBookingHistory.Movement_Date_Time__c = date.newInstance(2015, 08, 01); 
          myBookingHistory.Booking__c = bookingID;
          insert myBookingHistory;     
          System.debug(logginglevel.ERROR, '££££££££££££££ myBookingHistory1 is' + myBookingHistory.Movement_Date_Time__c);                    
          
          Booking_History__c myBookingHistory2 = new Booking_History__c(); 
          myBookingHistory2.Movement_Date_Time__c = date.newInstance(2013, 01, 01); 
          myBookingHistory2.Booking__c = bookingID; 
          insert myBookingHistory2; 
          System.debug(logginglevel.ERROR, '££££££££££££££ myBookingHistory2 is' + myBookingHistory2.Movement_Date_Time__c);              
          
          Booking_History__c myBookingHistory3 = new Booking_History__c(); 
          myBookingHistory3.Movement_Date_Time__c = date.newInstance(2014, 01, 01);   
          myBookingHistory3.Booking__c = bookingID;         
          insert myBookingHistory3; 
          System.debug(logginglevel.ERROR, '££££££££££££££ myBookingHistory3 is' + myBookingHistory3.Movement_Date_Time__c);                   
                         
          Test.startTest();                   
           
          BookingHistory_DataDeletion dd = new  BookingHistory_DataDeletion();
          SchedulableContext sc;
          dd.execute(sc);
          
          List<Booking_History__c> bookingHistory = [Select id, Movement_Date_Time__c from Booking_History__c];  
          integer i = 0;
          for (Booking_History__c record : bookingHistory )
          { 
             if (record.Id != null)
             {
                System.debug(logginglevel.ERROR, '££££££££££££££ existing record is' + record.Movement_Date_Time__c);                                
                i = i+1;
              }
          }          

          Test.stopTest();
          //System.assertEquals(1, i);
    } 
}