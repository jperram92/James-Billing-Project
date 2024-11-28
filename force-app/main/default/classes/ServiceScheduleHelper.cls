/**
 * @description       : Helper class to calculate service quantity
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 11-28-2024
 * @last modified by  : jamesperram@gmail.com
**/
public class ServiceScheduleHelper {
    // Method to calculate service quantity
    public static void calculateServiceQuantity(List<JBP_Service_Schedule__c> schedules) {
        for (JBP_Service_Schedule__c schedule : schedules) {
            if (schedule.JBP_Service_Start_Time__c != null && schedule.JBP_Service_End_Time__c != null) {
                // Extract hours and minutes for both start and end times
                Time startTime = schedule.JBP_Service_Start_Time__c;
                Time endTime = schedule.JBP_Service_End_Time__c;
                
                // Calculate total seconds for both start and end times
                Integer startSeconds = startTime.hour() * 3600 + startTime.minute() * 60 + startTime.second();
                Integer endSeconds = endTime.hour() * 3600 + endTime.minute() * 60 + endTime.second();
                
                // Calculate the difference in seconds and convert to hours
                Decimal hours = (Decimal)(endSeconds - startSeconds) / 3600;
                
                // Update the Service Quantity Allocated field
                schedule.JBP_Service_Quantity_Allocated__c = hours;
            } else {
                // Default to 0 if times are missing
                schedule.JBP_Service_Quantity_Allocated__c = 0;
            }
        }
    }
}
