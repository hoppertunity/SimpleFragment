/**
* File Name   :    TimeUtilTest.cls
* Description :    test time methods
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 03/07/2014 Klea Kolaric	Initial version
*
*
*/
@isTest
private class TimeUtilTest {
	
	static Date monday = Date.newInstance(2014,6,30);	// June 30th, 2014 (Monday)
		
    static testMethod void testWorkdaysEarlyMorning()
    {
    	TestUtil.setupBusinessHoursAndHolidays();
    	
    	// cycle through the week trying out days
    	Integer hrs = 2;
    	Datetime mondayDT = Datetime.newInstance(monday.year(),monday.month(),monday.day(),hrs,0,0);
    	system.assertEquals(ConstantUtil.MONDAY_ABRV,TimeUtil.getDayOfWeek(mondayDT));
    	
    	for(Integer i = 0; i < ConstantUtil.DAYS_IN_WEEK; i++)
    	{
    		Datetime dt = mondayDT.addDays(i);
    		system.assert(i != 6 ? TimeUtil.isWorkDay(dt.date()) : !TimeUtil.isWorkDay(dt.date()),
    						'Only Sunday should be a non working day: ' + TimeUtil.getDayOfWeek(dt));
    		system.assert(i == 2 ? TimeUtil.isAllday(dt.date()) : !TimeUtil.isAllday(dt.date()),
    						'Only Wednesday should be all day: ' + TimeUtil.getDayOfWeek(dt));
    		system.assert(i == 2 ? TimeUtil.isWithinWorkHours(dt) : !TimeUtil.isWithinWorkHours(dt), 
    						'02:00h should not be within working hours except on Wednesday: ' + TimeUtil.getDayOfWeek(dt));
    	}
    }
    
    static testMethod void testWorkdaysMidday()
    {
    	TestUtil.setupBusinessHoursAndHolidays();
    	
    	// cycle through the week trying out days
    	Integer hrs = 12;
    	Datetime mondayDT = Datetime.newInstance(monday.year(),monday.month(),monday.day(),hrs,0,0);
    	system.assertEquals(ConstantUtil.MONDAY_ABRV,TimeUtil.getDayOfWeek(mondayDT));
    	
    	for(Integer i = 0; i < ConstantUtil.DAYS_IN_WEEK; i++)
    	{
    		Datetime dt = mondayDT.addDays(i);
    		system.assert(i != 6 ? TimeUtil.isWorkDay(dt.date()) : !TimeUtil.isWorkDay(dt.date()),
    						'Only Sunday should be a non working day: ' + TimeUtil.getDayOfWeek(dt));
    		system.assert(i == 2 ? TimeUtil.isAllday(dt.date()) : !TimeUtil.isAllday(dt.date()),
    						'Only Wednesday should be all day: ' + TimeUtil.getDayOfWeek(dt));
    		system.assert(i != 6 ? TimeUtil.isWithinWorkHours(dt) : !TimeUtil.isWithinWorkHours(dt), 
    						'12:00h should be within working hours except on Sunday: ' + TimeUtil.getDayOfWeek(dt));
    	}
    }
    
    static testMethod void testHolidays()
    {
    	TestUtil.setupBusinessHoursAndHolidays();
    	
    	// assert that holidays really are detected as such
    	for(Holiday hd : TimeUtil.holidays)
    	{
    		system.assert(TimeUtil.isHoliday(hd.ActivityDate),'TimeUtil.isHoliday() returned false for holiday: ' + hd.ActivityDate);
    	}
    }
    
    static testMethod void testResumeDates()
    {
    	TestUtil.setupBusinessHoursAndHolidays();
    	
    	Test.startTest();
    	Time t;
    	// DT before usual work hours
    	t = Time.newInstance(2,0,0,0);
    	system.assertEquals(Datetime.newInstance(monday,TimeUtil.bh.MondayStartTime),
    						TimeUtil.getWorkingDayResumeDT(Datetime.newInstance(monday,t)));
    	system.assertEquals(Datetime.newInstance(monday.addDays(1),TimeUtil.bh.TuesdayStartTime),
    						TimeUtil.getWorkingDayResumeDT(Datetime.newInstance(monday.addDays(1),t)));
    	system.assertEquals(Datetime.newInstance(monday.addDays(2),t),
    						TimeUtil.getWorkingDayResumeDT(Datetime.newInstance(monday.addDays(2),t)));	// Wed is all day
    	system.assertEquals(Datetime.newInstance(monday.addDays(3),TimeUtil.bh.ThursdayStartTime),
    						TimeUtil.getWorkingDayResumeDT(Datetime.newInstance(monday.addDays(3),t)));
    	system.assertEquals(Datetime.newInstance(monday.addDays(4),TimeUtil.bh.FridayStartTime),
    						TimeUtil.getWorkingDayResumeDT(Datetime.newInstance(monday.addDays(4),t)));
    	system.assertEquals(Datetime.newInstance(monday.addDays(5),TimeUtil.bh.SaturdayStartTime),
    						TimeUtil.getWorkingDayResumeDT(Datetime.newInstance(monday.addDays(5),t)));
    	system.assertEquals(Datetime.newInstance(monday.addDays(7),TimeUtil.bh.MondayStartTime),
    						TimeUtil.getWorkingDayResumeDT(Datetime.newInstance(monday.addDays(6),t)));	// Sun is not work day
    						
    	// DT during usual work hours
    	t = Time.newInstance(12,0,0,0);
    	system.assertEquals(Datetime.newInstance(monday,t),
    						TimeUtil.getWorkingDayResumeDT(Datetime.newInstance(monday,t)));
    	system.assertEquals(Datetime.newInstance(monday.addDays(1),t),
    						TimeUtil.getWorkingDayResumeDT(Datetime.newInstance(monday.addDays(1),t)));
    	system.assertEquals(Datetime.newInstance(monday.addDays(2),t),
    						TimeUtil.getWorkingDayResumeDT(Datetime.newInstance(monday.addDays(2),t)));	// Wed is all day
    	system.assertEquals(Datetime.newInstance(monday.addDays(3),t),
    						TimeUtil.getWorkingDayResumeDT(Datetime.newInstance(monday.addDays(3),t)));
    	system.assertEquals(Datetime.newInstance(monday.addDays(4),t),
    						TimeUtil.getWorkingDayResumeDT(Datetime.newInstance(monday.addDays(4),t)));
    	system.assertEquals(Datetime.newInstance(monday.addDays(5),t),
    						TimeUtil.getWorkingDayResumeDT(Datetime.newInstance(monday.addDays(5),t)));
    	system.assertEquals(Datetime.newInstance(monday.addDays(7),TimeUtil.bh.MondayStartTime),
    						TimeUtil.getWorkingDayResumeDT(Datetime.newInstance(monday.addDays(6),t)));	// Sun is not work day
    	
    	// DT after usual work hours
    	t = Time.newInstance(20,0,0,0);
    	system.assertEquals(Datetime.newInstance(monday.addDays(1),TimeUtil.bh.TuesdayStartTime),
    						TimeUtil.getWorkingDayResumeDT(Datetime.newInstance(monday,t)));
    	system.assertEquals(Datetime.newInstance(monday.addDays(2),TimeUtil.bh.WednesdayStartTime),
    						TimeUtil.getWorkingDayResumeDT(Datetime.newInstance(monday.addDays(1),t)));
    	system.assertEquals(Datetime.newInstance(monday.addDays(2),t),
    						TimeUtil.getWorkingDayResumeDT(Datetime.newInstance(monday.addDays(2),t)));	// Wed is all day
    	system.assertEquals(Datetime.newInstance(monday.addDays(4),TimeUtil.bh.FridayStartTime),
    						TimeUtil.getWorkingDayResumeDT(Datetime.newInstance(monday.addDays(3),t)));
    	system.assertEquals(Datetime.newInstance(monday.addDays(5),TimeUtil.bh.SaturdayStartTime),
    						TimeUtil.getWorkingDayResumeDT(Datetime.newInstance(monday.addDays(4),t)));
    	system.assertEquals(Datetime.newInstance(monday.addDays(7),TimeUtil.bh.MondayStartTime),
    						TimeUtil.getWorkingDayResumeDT(Datetime.newInstance(monday.addDays(5),t)));	// Sun is not work day
    	system.assertEquals(Datetime.newInstance(monday.addDays(7),TimeUtil.bh.MondayStartTime),
    						TimeUtil.getWorkingDayResumeDT(Datetime.newInstance(monday.addDays(6),t)));	// Sun is not work day
    						
    	// holidays
    	t = Time.newInstance(12,0,0,0);
    	system.assertEquals(Datetime.newInstance(Date.newInstance(2014,4,3),TimeUtil.bh.ThursdayStartTime),
    						TimeUtil.getWorkingDayResumeDT(Datetime.newInstance(Date.newInstance(2014,4,2),t)));
    	system.assertEquals(Datetime.newInstance(Date.newInstance(2013,12,27),TimeUtil.bh.FridayStartTime),	// Xmas 2013 was Wed
    						TimeUtil.getWorkingDayResumeDT(Datetime.newInstance(Date.newInstance(2013,12,25),t)));
    	t = Time.newInstance(20,0,0,0);
    	system.assertEquals(Datetime.newInstance(Date.newInstance(2014,4,3),TimeUtil.bh.ThursdayStartTime),
    						TimeUtil.getWorkingDayResumeDT(Datetime.newInstance(Date.newInstance(2014,4,1),t)));
    	system.assertEquals(Datetime.newInstance(Date.newInstance(2013,12,27),TimeUtil.bh.FridayStartTime),	// Xmas 2013 was Wed
    						TimeUtil.getWorkingDayResumeDT(Datetime.newInstance(Date.newInstance(2013,12,24),t)));
    						
    	Test.stopTest();
    }
    
    static testMethod void testAddWorkHours()
    {
    	TestUtil.setupBusinessHoursAndHolidays();
    	
    	Test.startTest();
    	Time t;
    	// DT before usual work hours
    	t = Time.newInstance(2,0,0,0);
    	system.assertEquals(Datetime.newInstance(monday.addDays(2),Time.newInstance(4,0,0,0)),
    						TimeUtil.addWorkHours(Datetime.newInstance(monday,t),24));
    	system.assertEquals(Datetime.newInstance(monday.addDays(2),Time.newInstance(14,0,0,0)),
    						TimeUtil.addWorkHours(Datetime.newInstance(monday.addDays(1),t),24));
    	system.assertEquals(Datetime.newInstance(monday.addDays(3),Time.newInstance(10,0,0,0)),
    						TimeUtil.addWorkHours(Datetime.newInstance(monday.addDays(2),t),24));	// Wed is all day
    	system.assertEquals(Datetime.newInstance(monday.addDays(5),Time.newInstance(13,30,0,0)),
    						TimeUtil.addWorkHours(Datetime.newInstance(monday.addDays(3),t),24));
    	system.assertEquals(Datetime.newInstance(monday.addDays(7),Time.newInstance(14,0,0,0)),
    						TimeUtil.addWorkHours(Datetime.newInstance(monday.addDays(4),t),24));
    	system.assertEquals(Datetime.newInstance(monday.addDays(8),Time.newInstance(13,30,0,0)),
    						TimeUtil.addWorkHours(Datetime.newInstance(monday.addDays(5),t),24));
    	system.assertEquals(Datetime.newInstance(monday.addDays(9),Time.newInstance(4,0,0,0)),
    						TimeUtil.addWorkHours(Datetime.newInstance(monday.addDays(6),t),24));	// Sun is not work day
    						
    	// DT during usual work hours
    	t = Time.newInstance(12,0,0,0);
    	system.assertEquals(Datetime.newInstance(monday.addDays(2),Time.newInstance(8,0,0,0)),
    						TimeUtil.addWorkHours(Datetime.newInstance(monday,t),24));
    	system.assertEquals(Datetime.newInstance(monday.addDays(2),Time.newInstance(18,0,0,0)),
    						TimeUtil.addWorkHours(Datetime.newInstance(monday.addDays(1),t),24));
    	system.assertEquals(Datetime.newInstance(monday.addDays(4),Time.newInstance(10,0,0,0)),
    						TimeUtil.addWorkHours(Datetime.newInstance(monday.addDays(2),t),24));	// Wed is all day
    	system.assertEquals(Datetime.newInstance(monday.addDays(5),Time.newInstance(17,30,0,0)),
    						TimeUtil.addWorkHours(Datetime.newInstance(monday.addDays(3),t),24));
    	system.assertEquals(Datetime.newInstance(monday.addDays(7),Time.newInstance(18,0,0,0)),
    						TimeUtil.addWorkHours(Datetime.newInstance(monday.addDays(4),t),24));
    	system.assertEquals(Datetime.newInstance(monday.addDays(8),Time.newInstance(16,30,0,0)),
    						TimeUtil.addWorkHours(Datetime.newInstance(monday.addDays(5),t),24));
    	system.assertEquals(Datetime.newInstance(monday.addDays(9),Time.newInstance(4,0,0,0)),
    						TimeUtil.addWorkHours(Datetime.newInstance(monday.addDays(6),t),24));	// Sun is not work day
    	
    	// DT after usual work hours
    	t = Time.newInstance(20,0,0,0);
    	system.assertEquals(Datetime.newInstance(monday.addDays(2),Time.newInstance(14,0,0,0)),
    						TimeUtil.addWorkHours(Datetime.newInstance(monday,t),24));
    	system.assertEquals(Datetime.newInstance(monday.addDays(2),Time.newInstance(23,59,59,999)),
    						TimeUtil.addWorkHours(Datetime.newInstance(monday.addDays(1),t),24));
    	system.assertEquals(Datetime.newInstance(monday.addDays(5),Time.newInstance(9,30,0,0)),
    						TimeUtil.addWorkHours(Datetime.newInstance(monday.addDays(2),t),24));	// Wed is all day
    	system.assertEquals(Datetime.newInstance(monday.addDays(7),Time.newInstance(14,0,0,0)),
    						TimeUtil.addWorkHours(Datetime.newInstance(monday.addDays(3),t),24));
    	system.assertEquals(Datetime.newInstance(monday.addDays(8),Time.newInstance(13,30,0,0)),
    						TimeUtil.addWorkHours(Datetime.newInstance(monday.addDays(4),t),24));
    	system.assertEquals(Datetime.newInstance(monday.addDays(9),Time.newInstance(4,0,0,0)),
    						TimeUtil.addWorkHours(Datetime.newInstance(monday.addDays(5),t),24));
    	system.assertEquals(Datetime.newInstance(monday.addDays(9),Time.newInstance(4,0,0,0)),
    						TimeUtil.addWorkHours(Datetime.newInstance(monday.addDays(6),t),24));	// Sun is not work day
    						
    	// holidays
    	t = Time.newInstance(12,0,0,0);
    	system.assertEquals(Datetime.newInstance(Date.newInstance(2014,4,4),Time.newInstance(16,00,0,0)),
    						TimeUtil.addWorkHours(Datetime.newInstance(Date.newInstance(2014,4,1),t),24));
    	system.assertEquals(Datetime.newInstance(Date.newInstance(2013,12,30),Time.newInstance(14,0,0,0)),	// Xmas 2013 was Wed
    						TimeUtil.addWorkHours(Datetime.newInstance(Date.newInstance(2013,12,25),t),24));
    	t = Time.newInstance(20,0,0,0);
    	system.assertEquals(Datetime.newInstance(Date.newInstance(2014,4,5),Time.newInstance(13,30,0,0)),
    						TimeUtil.addWorkHours(Datetime.newInstance(Date.newInstance(2014,4,1),t),24));
    	system.assertEquals(Datetime.newInstance(Date.newInstance(2013,12,30),Time.newInstance(14,0,0,0)),	// Xmas 2013 was Wed
    						TimeUtil.addWorkHours(Datetime.newInstance(Date.newInstance(2013,12,24),t),24));
    						
    	Test.stopTest();
    }
    
    public static testMethod void testHMTime()
    {
    	Test.startTest();
    	TimeUtil.HMTime hmt = new TimeUtil.HMTime('12:30');
    	system.assertEquals('12',hmt.hour);
    	system.assertEquals('30',hmt.minute);
    	system.assertEquals(TimeUtil.hours.size()+1,hmt.getHourOptions().size());
    	system.assertEquals(TimeUtil.minutes.size()+1,hmt.getMinuteOptions().size());
    	system.assertEquals('12:30',hmt.getFormatedTime());
    	Test.stoptest();
    }
    
    static testMethod void testCalculateMinutesInBusinessHours()
    {
    	//Test calss is very sensetive to bussiness hours 
    	
    	Test.startTest();
    		DateTime startDT = DateTime.newInstance(Date.newInstance(2015, 4, 17), TimeUtil.bh.FridayEndTime.addMinutes(-30));
    		DateTime endDT = DateTime.newInstance(Date.newInstance(2015, 4, 20), TimeUtil.bh.MondayStartTime.addMinutes(90));
    		Decimal mins = TimeUtil.calculateMinutesInBusinessHours(startDT, endDT);
    		system.assertEquals(120, mins);
    		
    		mins = TimeUtil.calculateMinutesInBusinessHours(startDT, null);
    		system.assertEquals(0, mins);
    		
    		mins = TimeUtil.calculateMinutesInBusinessHours(null, endDT);
    		system.assertEquals(0, mins);
    		
    		endDT = DateTime.newInstance(Date.newInstance(2015, 4, 17), TimeUtil.bh.FridayEndTime.addMinutes(-10));
    		mins = TimeUtil.calculateMinutesInBusinessHours(startDT, endDT);
    		system.assertEquals(20, mins);
    		
    		startDT = DateTime.newInstance(Date.newInstance(2015, 4, 17), TimeUtil.bh.FridayEndTime.addMinutes(30));
    		endDT = DateTime.newInstance(Date.newInstance(2015, 4, 17), TimeUtil.bh.FridayEndTime.addMinutes(120));
    		mins = TimeUtil.calculateMinutesInBusinessHours(startDT, endDT);
    		system.assertEquals(0, mins);
    		
    		startDT = DateTime.newInstance(Date.newInstance(2015, 4, 17), TimeUtil.bh.FridayEndTime.addMinutes(120));
    		endDT = DateTime.newInstance(Date.newInstance(2015, 4, 17), TimeUtil.bh.FridayEndTime.addMinutes(-30));
    		mins = TimeUtil.calculateMinutesInBusinessHours(startDT, endDT);
    		system.assertEquals(-30, mins);
    		
    	Test.stopTest();
    }
}