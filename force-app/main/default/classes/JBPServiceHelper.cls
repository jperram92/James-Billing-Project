/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-01-2024
 * @last modified by  : jamesperram@gmail.com
**/
public class JBPServiceHelper {
    public static String validateService(JBP_Service__c service) {
        List<String> errors = new List<String>();

        // Query the related Service Schedule
        JBP_Service_Schedule__c schedule;
        try {
            schedule = [
                SELECT JBP_Service_Quantity_Allocated__c, 
                       JBP_Service_Date__c, 
                       Opportunity_Product__r.JBP_Service_Offering_Start_Time__c, 
                       Opportunity_Product__r.JBP_Service_Offering_End_Time__c
                FROM JBP_Service_Schedule__c
                WHERE Id = :service.Service_Schedule__c
                LIMIT 1
            ];
        } catch (Exception e) {
            schedule = null; // If query fails, set schedule to null
        }

        // Validation logic
        if (schedule == null) {
            errors.add('Service Schedule is missing or invalid. Please link the service to a valid schedule.');
        } else {
            if (schedule.JBP_Service_Quantity_Allocated__c <= 0) {
                errors.add('Allocated quantity is invalid. Ensure the service has a positive allocated quantity.');
            }
            if (schedule.JBP_Service_Date__c == null) {
                errors.add('Service date is missing. Please specify a valid service date.');
            } else {
                Date oppStartDate = schedule.Opportunity_Product__r.JBP_Service_Offering_Start_Time__c;
                Date oppEndDate = schedule.Opportunity_Product__r.JBP_Service_Offering_End_Time__c;
                if (schedule.JBP_Service_Date__c < oppStartDate || schedule.JBP_Service_Date__c > oppEndDate) {
                    errors.add('Service date is out of range. Ensure the service date falls within the opportunity start and end dates.');
                }
            }
        }

        // Combine error messages and actionable steps
        if (!errors.isEmpty()) {
            return String.join(errors, '\n') + 
                   '\n\nSteps to Fix:\n' + 
                   '- Link the service to a valid schedule.\n' +
                   '- Ensure the allocated quantity is greater than zero.\n' +
                   '- Provide a valid service date within the opportunity range.';
        }

        return null; // No errors
    }
}