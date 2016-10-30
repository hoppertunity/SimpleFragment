/**
* File Name   :    TimeUtil.cls
* Description :    Class for working with business hours etc
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 03/07/2014 Klea Kolaric	Initial version
*
*
*/
public with sharing class TimeUtil {
	
	public static final String DATETIMEPICKER_FORMAT = 'dd/MM/yyyy HH:mm';
	
	public static BusinessHours bh = [select Id, Name,
										MondayStartTime, MondayEndTime, 
										TuesdayStartTime, TuesdayEndTime, 
										WednesdayStartTime, WednesdayEndTime, 
										ThursdayStartTime, ThursdayEndTime,
										FridayStartTime, FridayEndTime, 
										SaturdayStartTime, SaturdayEndTime, 
										SundayStartTime, SundayEndTime, 
										IsDefault, 
										IsActive,
										TimeZoneSidKey 
									from BusinessHours
									where IsDefault = true and IsActive = true limit 1];
									
	public static List<Holiday> holidays = [select Name,
												ActivityDate, 
												IsRecurrence, 
												RecurrenceType, 
												RecurrenceMonthOfYear, 
												RecurrenceDayOfWeekMask, 
												RecurrenceDayOfMonth,
												RecurrenceInstance, 
												IsAllDay
											from Holiday h];
									
	// get next work day with preserved time component							
	public static Datetime getNextWorkingDay(Datetime dt)
	{
		Datetime nextDay = getNextWorkingDayStartDT(dt.date());
		return Datetime.newInstance(nextDay.date(),dt.time());
	}
	
	// get next work day with start time for that day
	public static Datetime getNextWorkingDayStartDT(Date d)
	{
		d = d.addDays(1);
		while(!isWorkingDay(d))
		{
			d = d.addDays(1);
		}
		return Datetime.newInstance(d,getDayStartTime(d));
	}
	
	// get next datetime when work can resume - if dateime is within working hours then will return dt
	public static Datetime getWorkingDayResumeDT(Datetime dt)
	{
		Datetime startWorkDT;
		
		if(isWorkingDay(dt.date()))	// now check if the time falls into work hours
		{
			startWorkDT = dt;
			if(!isAllDay(startWorkDT.date()))
			{
				if(startWorkDT.time() < getDayStartTime(startWorkDT.date()))	// if too early, move to start time
				{
					startWorkDT = Datetime.newInstance(startWorkDT.date(),getDayStartTime(startWorkDT.date()));
				}
				else
				{
					if(startWorkDT.time() > getDayEndTime(startWorkDT.date()))	// if too late, move to other day start time
					{
						startWorkDT = getNextWorkingDayStartDT(startWorkDT.date());
					}
				}
			}
		}
		else
		{
			startWorkDT = getNextWorkingDayStartDT(dt.date()); // if you had to move to next day rewind to start hours
		}
		return startWorkDT;
	}

	// format hh:mm
	public static Time parseTime(String ts)
	{
		Time t ;
		if(String.isNotBlank(ts) && ts.contains(':'))
		{
			String[] ls = ts.split(':');
			//if(ls.size() == 2 && String.isNumeric(ls.get(0)) && String.isNumeric(ls.get(1)))
			if(ls.size() == 2)
			{
				t = Time.newInstance(Integer.valueOf(ls.get(0)),Integer.valueOf(ls.get(1)),0,0);
			}
		}
		return t;
	}
	
	public static Datetime addWorkHours(Datetime dt, Integer addHours)
	{
		system.debug(dt + ' + ' + addHours);
		// make sure begining is workday
		Datetime startWorkDT = getWorkingDayResumeDT(dt);
		
		// now that we have start datetime, we need end datetime
		Datetime endWorkDT = startWorkDT;
		for(Integer i = addHours; i > 0; i--)
		{
			Time currentEndTime = isAllDay(endWorkDT.date()) ? Time.newInstance(23,59,59,999) : getDayEndTime(endWorkDT.date());
			
			Datetime endWorkOldDT = endWorkDT;	// in case we pass midnight
			endWorkDT = endWorkDT.addHours(1);
			
			system.debug(currentEndTime);
			system.debug(endWorkDT);
			
			// if you surpassed end time for that day or if we passed midnight, split the hour between this and next day
			if(endWorkDT.time() > currentEndTime || !endWorkOldDT.isSameDay(endWorkDT))	
			{
				Datetime nextWorkingDT = getNextWorkingDayStartDT(endWorkOldDT.date());
				
				// find the difference between the workday end time and the endWorkDT time
				Long diff = endWorkDT.getTime() - Datetime.newInstance(endWorkOldDT.date(),currentEndTime).getTime();
				endWorkDT = Datetime.newInstance(nextWorkingDT.getTime() + diff);
			}
			
			// handle special case if final result is at midnigt (23:59+) on allDay - don't carry over to next day, but keep in same day
			// more consistent with how other if statement sets time
			if(i == 1 && !endWorkOldDT.isSameDay(endWorkOldDT.addHours(1)) 
				&& endWorkOldDT.addHours(1).time() == Time.newInstance(0,0,0,0) && currentEndTime == Time.newInstance(23,59,59,999))
			{
				endWorkDT = Datetime.newInstance(endWorkOldDT.date(),currentEndTime);
			}
		}
		
		return endWorkDT;
	}
	
	public static Boolean isWithinWorkHours(Datetime dt)
	{
		Time startTime = getDayStartTime(dt.date());
		Time endTime = getDayEndTime(dt.date());
		Time t = dt.time();
		return isWorkDay(startTime,endTime) && !isHoliday(dt.date()) && (isAllDay(startTime,endTime) || (t >= startTime && t <= endTime));
	}
	
	public static Boolean isWorkingDay(Date d)
	{
		return !isHoliday(d) && isWorkDay(d);
	}
	
	public static Boolean isWorkDay(Date d)
	{
		Time startTime = getDayStartTime(d);
		Time endTime = getDayEndTime(d);
		return isWorkDay(startTime, endTime);
	}
	
	public static Boolean isWorkDay(Time startTime, Time endTime)
	{
		
		return startTime != null && endTime != null;
	}
	
	public static Boolean isAllDay(Date d)
	{
		Time startTime = getDayStartTime(d);
		Time endTime = getDayEndTime(d);
		return isAllDay(startTime, endTime);
	}
	
	public static Boolean isAllDay(Time startTime, Time endTime)
	{
		return startTime == endTime && endTime == Time.newInstance(0,0,0,0);	// if something is 24h, it will be 00:00-00:00
	}
	
	public static Boolean isHoliday(Date d)
	{
		Boolean isHoliday = false;	// if at least on holiday is a match, it will return true
		for(Holiday hd : holidays)	// expecting all holidays to be all day with yearly intervals if recurring
		{
			// TODO put int constants
			if(hd.IsRecurrence)
			{
				if(d.month() == ConstantUtil.MONTHS_S2I.get(hd.RecurrenceMonthOfYear))
				{
					if(hd.RecurrenceType == 'RecursYearly')
					{
						isHoliday |= d.day() == hd.RecurrenceDayOfMonth;
					}
					if(hd.RecurrenceType == 'RecursYearlyNth')
					{
						final Integer INT7 = ConstantUtil.DAYS_IN_WEEK;
						// resolve bitmask - expecting only one day per week
						Integer dayOfWeek = 1;
						while(Math.pow(2,dayOfWeek-1) < hd.RecurrenceDayOfWeekMask)
						{
							dayOfWeek++;
						}
						dayOfWeek = dayOfWeek == 1 ? INT7 : dayOfWeek-1;	// they use Sunday as first day, and I use Monday
						
						if(getDayOfWeek(d) == ConstantUtil.WEEKDAYS_ABRV_I2S.get(dayOfWeek))
						{
							Integer numOfWeeks = hd.RecurrenceInstance == ConstantUtil.HOLIDAY_RECINSTANCE_FIRST ? 1 : 
													(hd.RecurrenceInstance == ConstantUtil.HOLIDAY_RECINSTANCE_SECOND ? 2 : 
														(hd.RecurrenceInstance == ConstantUtil.HOLIDAY_RECINSTANCE_THIRD ? 3 : 
															(hd.RecurrenceInstance == ConstantUtil.HOLIDAY_RECINSTANCE_FOURTH ? 4 : 0)));
							if(numOfWeeks != 0)
							{
								isHoliday |= d.day() >= (numOfWeeks-1)*INT7 + 1 && d.day() <= numOfWeeks*INT7;
							}
							else	// handle last in month - has to occur within last 7 days of month
							{
								isHoliday |= d.day() >= Date.daysInMonth(d.year(),d.month())- INT7 + 1 
											&& d.day() <= Date.daysInMonth(d.year(),d.month());
							}
						}
					}
				}
			}
			else
			{
				isHoliday |= d.isSameDay(hd.ActivityDate);
			}
		}
		return isHoliday;
	}
	
	public static Time getDayStartTime(Date d)
	{
		String weekday = getDayOfWeek(d);
		return weekday == ConstantUtil.MONDAY_ABRV ? bh.MondayStartTime : 
				(weekday == ConstantUtil.TUESDAY_ABRV ? bh.TuesdayStartTime : 
					(weekday == ConstantUtil.WEDNESDAY_ABRV ? bh.WednesdayStartTime : 
						(weekday == ConstantUtil.THURSDAY_ABRV ? bh.ThursdayStartTime : 
							(weekday == ConstantUtil.FRIDAY_ABRV ? bh.FridayStartTime : 
								(weekday == ConstantUtil.SATURDAY_ABRV ? bh.SaturdayStartTime : 
									(weekday == ConstantUtil.SUNDAY_ABRV ? bh.SundayStartTime : null))))));
	}
	
	public static Time getDayEndTime(Date d)
	{
		String weekday = getDayOfWeek(d);
		return weekday == ConstantUtil.MONDAY_ABRV ? bh.MondayEndTime : 
				(weekday == ConstantUtil.TUESDAY_ABRV ? bh.TuesdayEndTime : 
					(weekday == ConstantUtil.WEDNESDAY_ABRV ? bh.WednesdayEndTime : 
						(weekday == ConstantUtil.THURSDAY_ABRV ? bh.ThursdayEndTime : 
							(weekday == ConstantUtil.FRIDAY_ABRV ? bh.FridayEndTime : 
								(weekday == ConstantUtil.SATURDAY_ABRV ? bh.SaturdayEndTime : 
									(weekday == ConstantUtil.SUNDAY_ABRV ? bh.SundayEndTime : null))))));
	}
	
	// return first three letters of the weekday name
	public static String getDayOfWeek(Date d)
	{
		return getDayOfWeek(Datetime.newInstance(d,Time.newInstance(2,0,0,0)));
	}
	
	public static String getDayOfWeek(Datetime dt)
	{
		return dt.format('E');
	}
	
	public static final List<String> hours = 
		new List<String>{'00','01','02','03','04','05','06','07','08','09','10','11',
						'12','13','14','15','16','17','18','19','20','21','22','23'};
	public static final List<String> minutes = new List<String>{'00','15','30','45'};
	
	//method calculates amount of minutes in business hours for time span
	public static Decimal calculateMinutesInBusinessHours(DateTime startDT, DateTime endDT){
		Decimal res = 0;
		if(startDT != null && endDT != null){ 
			res = BusinessHours.diff(bh.id, startDT, endDT) / 60000.00;
		}
		
		return res;
	}
	
	
	// class used for storing time and minutes
	public class HMTime
	{
		public String hour {get; set;}
		public String minute {get; set;}
		public String separator = ':';
		
		public HMTime(String val)
		{
			 if(String.isNotBlank(val) && val.length() == 5 && val.contains(separator))
			 {
			 	String[] t = val.split(separator);
			 	hour = t.get(0);
			 	minute = t.get(1);
			 }
		}
		
		public List<Selectoption> getHourOptions()
		{
			List<Selectoption> sos = new List<Selectoption>();
			sos.add(new selectoption('','--'));
			for(String h : hours)
			{
				sos.add(new selectoption(h,h));
			}
			return sos;
		}
		
		public List<Selectoption> getMinuteOptions()
		{
			List<Selectoption> sos = new List<Selectoption>();
			sos.add(new selectoption('','--'));
			for(String m : minutes)
			{
				sos.add(new selectoption(m,m));
			}
			return sos;
		}
		
		public String getFormatedTime()
		{
			return String.isNotBlank(hour) && String.isNotBlank(minute) ? (hour + separator + minute) : '';
		}
	}

}