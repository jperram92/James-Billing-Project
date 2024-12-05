/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-05-2024
 * @last modified by  : jamesperram@gmail.com
**/
@isTest
public class ApexLearningTemplateTest {
    @isTest
    static void testExecuteApexLearningTemplate() {
        // Step 1: Create a Test Account
        Account testAccount = new Account(Name = 'Test Account', Industry = 'Finance');
        insert testAccount;

        // Step 2: Call the Method to Test
        ApexLearningTemplate.executeApexLearningTemplate();

        // Step 3: Validate the Results
        // Query Case records created during the test
        List<Case> testCases = [SELECT Id, AccountId, Subject, Description, Priority, Status 
                                FROM Case 
                                WHERE Subject = 'Test Case for ApexLearningTemplate'];
        
        // Assertions
        System.assert(!testCases.isEmpty(), 'A Case should have been created.');
        System.assertEquals(1, testCases.size(), 'Only one Case should have been created.');
        System.assertEquals('High', testCases[0].Priority, 'Priority mismatch.');
        System.assertEquals('New', testCases[0].Status, 'Status mismatch.');
    }
}