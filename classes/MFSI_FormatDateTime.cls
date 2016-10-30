// from: http://mindfiresfdcprofessionals.wordpress.com/2013/10/25/how-to-dispaly-locale-formatted-datetime-in-visual-force/
// used to format date
public with sharing class MFSI_FormatDateTime {
	public DateTime dateTimeValue { get; set; }
    public String getTimeZoneValue() {
        if( dateTimeValue != null ) {
            String localeFormatDT = dateTimeValue.format('HH:mm, dd MMM yyyy z');
            return localeFormatDT;
        }
        return null;
    }
}