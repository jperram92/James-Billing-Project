/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-10-2024
 * @last modified by  : jamesperram@gmail.com
**/
public with sharing class ServiceScheduleController {
    @AuraEnabled(cacheable=true)
    public static List<JBP_Service_Schedule__c> getServicesByDate(Date serviceDate) {
        return [
            SELECT 
                Id, 
                Name, 
                JBP_Service__r.Service_Schedule__r.Opportunity_Product__c, 
                JBP_Service_Type__c, 
                JBP_Service_Start_Time__c, 
                JBP_Service_End_Time__c
            FROM JBP_Service_Schedule__c
            WHERE JBP_Service__r.JBP_Service_Date__c = :serviceDate
        ];
    }
}
