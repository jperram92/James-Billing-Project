/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-01-2024
 * @last modified by  : jamesperram@gmail.com
**/
public class JobController {
    public static Boolean isJobEnabled() {
        // Fetch the organization-wide default value for the hierarchy custom setting
        CustomSetting__c orgDefaults = CustomSetting__c.getOrgDefaults();

        // Return true if the setting exists and IsEnabled is true
        return orgDefaults != null && orgDefaults.IsEnabled__c;
    }
}