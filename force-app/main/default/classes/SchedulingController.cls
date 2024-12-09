/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-09-2024
 * @last modified by  : jamesperram@gmail.com
**/
public with sharing class SchedulingController {
    @AuraEnabled(cacheable=true)
    public static List<OpportunityLineItem> getOpportunityProducts() {
        return [SELECT Id, Name, Quantity, UnitPrice FROM OpportunityLineItem WHERE Opportunity.IsClosed = false];
    }

    @AuraEnabled
    public static void saveServiceSchedule(String serviceId, Date serviceDate, Time startTime, Time endTime) {
        JBP_Service_Schedule__c schedule = new JBP_Service_Schedule__c(
            JBP_Service__c = serviceId,
            JBP_Service_Date__c = serviceDate,
            JBP_Service_Start_Time__c = startTime,
            JBP_Service_End_Time__c = endTime
        );
        insert schedule;
    }
}
