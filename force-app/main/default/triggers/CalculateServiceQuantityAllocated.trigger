/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 11-28-2024
 * @last modified by  : jamesperram@gmail.com
**/
trigger CalculateServiceQuantityAllocated on JBP_Service_Schedule__c (before insert, before update) {
    ServiceScheduleHelper.calculateServiceQuantity(Trigger.new);
}
