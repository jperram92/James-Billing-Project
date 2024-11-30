/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-01-2024
 * @last modified by  : jamesperram@gmail.com
**/
//This class checks whether a specific job or process is enabled using a custom setting. 
//The isJobEnabled method retrieves the organization-wide default setting 
//and returns true if the job is marked as enabled, allowing administrators to toggle job execution dynamically.
public class JobController {
    public static Boolean isJobEnabled() {
        // Fetch the organization-wide default value for the hierarchy custom setting
        CustomSetting__c orgDefaults = CustomSetting__c.getOrgDefaults();

        // Return true if the setting exists and IsEnabled is true
        return orgDefaults != null && orgDefaults.IsEnabled__c;
    }
}