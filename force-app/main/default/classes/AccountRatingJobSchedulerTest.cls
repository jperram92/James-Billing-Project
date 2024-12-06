/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-06-2024
 * @last modified by  : jamesperram@gmail.com
**/
@isTest
public class AccountRatingJobSchedulerTest {
    @isTest
    static void testScheduleJob() {
        // Start test context
        Test.startTest();
        
        // Schedule the job
        AccountRatingJobScheduler.scheduleJob();
        
        // Retrieve the scheduled job
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger
                          WHERE CronJobDetail.Name = 'Daily Account Rating Job'
                          LIMIT 1];
        
        // Assert that the job is scheduled correctly
        System.assertEquals('0 0 0 * * ?', ct.CronExpression, 'Cron expression does not match.');
        System.assertEquals(0, ct.TimesTriggered, 'Job should not have triggered yet.');
        System.assertNotEquals(null, ct.NextFireTime, 'Next fire time should be set.');
        
        // End test context
        Test.stopTest();
    }
}
