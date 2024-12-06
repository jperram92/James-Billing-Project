/**
 * @description       : 
 * @author            : Keri Perram
 * @group             : 
 * @last modified on  : 12-06-2024
 * @last modified by  : jamesperram@gmail.com
**/
public class AccountRatingJobScheduler {
    public static void scheduleJob() {
        String cronExpression = '0 0 0 * * ?'; // This cron expression schedules it to run daily at midnight
        System.schedule('Daily Account Rating Job', cronExpression, new AccountRatingProcessor());
    }
}
