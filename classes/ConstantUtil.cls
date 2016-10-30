public with sharing class ConstantUtil {
	
	// days of week
	public static final String MONDAY_ABRV = 'Mon';
	public static final String TUESDAY_ABRV = 'Tue';
	public static final String WEDNESDAY_ABRV = 'Wed';
	public static final String THURSDAY_ABRV = 'Thu';
	public static final String FRIDAY_ABRV = 'Fri';
	public static final String SATURDAY_ABRV = 'Sat';
	public static final String SUNDAY_ABRV = 'Sun';
	public static final Integer DAYS_IN_WEEK = 7;
	
	public static Map<Integer,String> WEEKDAYS_ABRV_I2S {
		get {
			if(WEEKDAYS_ABRV_I2S == null) {
				WEEKDAYS_ABRV_I2S = new Map<Integer,String>{
					1 => MONDAY_ABRV, 
					2 => TUESDAY_ABRV, 
					3 => WEDNESDAY_ABRV, 
					4 => THURSDAY_ABRV, 
					5 => FRIDAY_ABRV,
					6 => SATURDAY_ABRV, 
					7 => SUNDAY_ABRV
				};
			}
			return WEEKDAYS_ABRV_I2S;
		}
		private set;
	}
	// months
	public static final String JANUARY = 'January';
	public static final String FEBRUARY = 'February';
	public static final String MARCH = 'March';
	public static final String APRIL = 'April';
	public static final String MAY = 'May';
	public static final String JUNE = 'June';
	public static final String JULY = 'July';
	public static final String AUGUST = 'August';
	public static final String SEPTEMBER = 'September';
	public static final String OCTOBER = 'October';
	public static final String NOVEMBER = 'November';
	public static final String DECEMBER = 'December';
	
	public static Map<Integer,String> MONTHS_I2S {
		get {
			if(MONTHS_I2S == null) {
				MONTHS_I2S = new Map<Integer,String>{
					1 => JANUARY,
					2 => FEBRUARY,
					3 => MARCH,
					4 => APRIL,
					5 => MAY,
					6 => JUNE,
					7 => JULY,
					8 => AUGUST,
					9 => SEPTEMBER,
					10 => OCTOBER,
					11 => NOVEMBER,
					12 => DECEMBER
				};
			}
			return MONTHS_I2S;
		}
		private set;
	}
																
	public static Map<String,Integer> MONTHS_S2I {
		get {
			if(MONTHS_S2I == null) {
				MONTHS_S2I = new Map<String,Integer>{
					JANUARY => 1,
					FEBRUARY => 2,
					MARCH => 3,
					APRIL => 4,
					MAY => 5,
					JUNE => 6,
					JULY => 7,
					AUGUST => 8,
					SEPTEMBER => 9,
					OCTOBER => 10,
					NOVEMBER => 11,
					DECEMBER => 12
				};
			}
			return MONTHS_S2I;
		}
		private set;
	}
																
	// holiday constants
	public static final String HOLIDAY_RECTYPE_YEARLYNTH = 'RecursYearlyNth';
	public static final String HOLIDAY_RECTYPE_YEARLY = 'RecursYearly';
	public static final String HOLIDAY_RECINSTANCE_FIRST = 'First';
	public static final String HOLIDAY_RECINSTANCE_SECOND = 'Second';
	public static final String HOLIDAY_RECINSTANCE_THIRD = 'Third';
	public static final String HOLIDAY_RECINSTANCE_FOURTH = 'Fourth';
	public static final String HOLIDAY_RECINSTANCE_LAST = 'Last';

	// object names
	public static final String OBJ_ACCOUNTADDRESS_APINAME = 'Account_Address__c';
	public static final String OBJ_ACCOUNT_APINAME = 'Account';
	
	// field names
	public static final String FLD_ACCOUNT_APINAME = 'Account__c';
	public static final String FLD_CONTACT_APINAME = 'Contact__c';
	public static final String FLD_ACCOUNTADDRESS_APINAME = OBJ_ACCOUNTADDRESS_APINAME;
	
	// picklist values
	public static final String PLVAL_CASE_EXCEPTION_COLLECTION = 'Collection';
	public static final String PLVAL_CASE_EXCEPTION_DELIVERY = 'Delivery';
	public static final String PLVAL_CASE_ORIGIN_PHONE = 'Phone';
	public static final String PLVAL_CASE_ORIGIN_SYSTEM = 'System';
	public static final String PLVAL_CASE_STATUS_NEW = 'New';
	public static final String PLVAL_CASE_STATUS_WAITING_FOR_CUSTOMER = 'Waiting for customer';
	public static final String PLVAL_CASE_STATUS_CLOSED = 'Closed';
	public static final String PLVAL_CASE_STATUS_WORKING_ON = 'In Progress';
	public static final String PLVAL_CASE_TYPE_BOOKINGS = 'Bookings';
	public static final String PLVAL_CASE_TYPE_BOOKING_ADN_QUOTES = 'Bookings and Quotes';
	public static final String PLVAL_CASE_TYPE_TRACK = 'Track';
    public static final String PLVAL_CASE_TYPE_RECORD_TRACK = 'FCR - Record Track';//Added by DH 24/09/15 for Kish
	public static final String PLVAL_CASE_TYPE_SERVICE_CASE = 'Service Case';
	public static final String PLVAL_CASE_TYPE_LAVEL1_CS_FAILED_COLLECTION = 'CS - Failed collection';
	public static final String PLVAL_CASE_PRIORITY_MEDIUM = 'Medium';
	public static final String PLVAL_ACCOUNTADDRESS_COUNTRY_UK = 'United Kingdom';
	public static final String PLVAL_QUOTE_ENHANCED_LIABILITY_OPTION_NONE = '0 - None';
	public static final String PLVAL_CTH_CATEGORY_OWNER = 'Owner';
	public static final String PLVAL_CTH_CATEGORY_TYPE = 'Type';
	public static final String PLVAL_CTH_CATEGORY_REASON = 'Reason';
	public static final String PLVAL_CTH_CATEGORY_STATUS = 'Status';
	public static final String PLVAL_CTH_CATEGORY_PRIORITY = 'Priority';
	public static final String PLVAL_CTH_CATEGORY_APPROVAL = 'Approval';
	public static final String PLVAL_BOOKING_RECORD_TYPE_NEW = 'New Booking';
	public static final String PLVAL_BOOKING_RECORD_TYPE_BLOCKED = 'Blocked Booking';
	public static final String PLVAL_BOOKING_STATUS_CANCELLED = 'Cancelled';
	public static final String PLVAL_BOOKING_STATUS_COLLECTED = 'Collected';
	public static final String PLVAL_BOOKING_STATUS_CONFIRMED = 'Confirmed';
	public static final String PLVAL_BOOKING_STATUS_REJECTED_TO_CS = 'Rejected to Customer Services';
	public static final String PLVAL_BOOKING_LIABILITY_ACCOUNTLEVEL = 'Account Level';
	public static final String PLVAL_BOOKING_HISTORY_MOVEMENT_TYPE_RAISED = 'Collection Request Raised';
	public static final String PLVAL_BOOKING_HISTORY_MOVEMENT_TYPE_AMENDED = 'Collection Request Amended';
	public static final String PLVAL_POSTCODE_CATEGORY_RESIDENTIAL = 'Residential';
	public static final String PLVAL_DAY_DAYTYPE_WORKING = 'Working';
	public static final String PLVAL_DAY_DAYTYPE_NONWORKING = 'Non-Working';
	public static final String PLVAL_DAY_DAYTYPE_SATURDAY = 'Saturday';
	public static final String PLVAL_DEPOTROUTING_ROUNDGROUP_NORMAL = 'Normal';
	public static final String PLVAL_DEPOTROUTING_ROUNDGROUP_SATURDAY = 'Saturday';
	public static final String PLVAL_DEPOTROUTING_ROUNDGROUP_ALL = 'All';
	public static final String PLVAL_TASK_ACTION_TYPE_CONTACT_ACTIONS = 'Contact Actions';
	public static final String PLVAL_TASK_ACTION_SUBTYPE_FIRST_CUSTOMER_CONTACT = 'First Customer Contact';
	public static final String PLVAL_TASK_ACTION_SUBTYPE_CUSTOMER_CONTACT = 'Customer Contact';
	public static final String PLVAL_TASK_STATUS_COMPLETED = 'Completed';
	
	// page parameters
	public static final String PAGEPARAM_CONTACT_ID = 'contactId';
	
	// queues
	public static final String MAJOR_ACCOUNTS_QUEUE = 'Major_Accounts';
	public static Id LOUNT_ADMIN_1_QUEUE_ID {
		get {
			if(LOUNT_ADMIN_1_QUEUE_ID == null) {
				LOUNT_ADMIN_1_QUEUE_ID = [select id from Group where Type = 'Queue' and DeveloperName = 'Lount_Admin_1' limit 1].id;
			}
			return LOUNT_ADMIN_1_QUEUE_ID;
		}
	}
	public static Id UNASSIGNED_QUEUE_ID {
		get {
			if(UNASSIGNED_QUEUE_ID == null) {
				return [select id from Group where Type = 'Queue' and Name = 'Unassigned' limit 1].id;
			}
			return UNASSIGNED_QUEUE_ID;
		}
	}
    
    //DH Added 19/01/2016
    public static Id MAURITIUS_QUEUE_ID {
		get {
			if(MAURITIUS_QUEUE_ID == null) {
				return [select id from Group where Type = 'Queue' and DEveloperName = 'Mauritius_Team' limit 1].id;
			}
			return MAURITIUS_QUEUE_ID;
		}
	}
	
	// ISO codes
	public static final String ISOCODE_UK = 'GBR';
	
	// custom settings
	public static Integer CS_ACCOUNTADDRESSROWLIMIT {
		get {
			Service_Settings__c ss = Service_Settings__c.getInstance();
			return ss != null && ss.Account_Address_Picklist_Size__c != null && ss.Account_Address_Picklist_Size__c > 0 
				?  ss.Account_Address_Picklist_Size__c.intValue() : 20;
		}
	}
	
	public static Integer INTEGRATION_TIMEOUT {
		get {
			TNT_Integration__c cs = TNT_Integration__c.getInstance();
			Decimal val = cs != null ? cs.Timeout__c : null;
			return val != null ? val.intValue() : 65000;
		}
	}
    
    //Added by DH 25/01/2016 
    public static Set<String> AutoRejectionCaseLOBList
    {
        get 
        {
            List<RejectionCaseLOBs__c> LOBs = RejectionCaseLOBs__c.getall().values();

            Set<String> LOBNames = new Set<String>();
        	for(RejectionCaseLOBs__c c:LOBs)
        	{
            	LOBNames.add(c.Name);
        	}
            return LOBNames;
        }        
        
    }
    
    //*********************
    
	
	// record types
	public static final String RT_ACCOUNT_DEPOT = 'Depot';
	
	// various
	public static final String TASK_SUBJECT_CALL_CLIENT_BACK = 'Contact';
	public static final String UNKNOWN_PREFIX = 'UNKNOWN';
	public static final Id PRODUCTION_ORGID = '00D20000000lDA7';
	public static final String INTEGRATION_USERNAME = 'SFSCPRD';
	public static Boolean INTEGRATION_ACCESS {
		get {
			return Test.isRunningTest() 
				|| UserInfo.getOrganizationId() == ConstantUtil.PRODUCTION_ORGID 
				|| (TNT_Integration__c.getInstance() != null 
						&& TNT_Integration__c.getInstance().Username__c != ConstantUtil.INTEGRATION_USERNAME);
		}
	}
	
	
	// exceptions
	public class IntegrationAccessDeniedException extends Exception {}
	public static final String INTEGRATION_EXMSG = 'Access is not allowed for this organisation with the production integration user.';
}