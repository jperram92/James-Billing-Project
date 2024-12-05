/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-05-2024
 * @last modified by  : jamesperram@gmail.com
**/
public class ApexLearningTemplate {
    // This is your main class to hold all the logic and variables.

    public static void executeApexLearningTemplate() {
        // Step 3: Understand Variable Types    
        // Variables for demonstration
        String field = 'Id, Name';
        String filter = 'WHERE Industry = \'Finance\'';
        String hello = 'Hello World';
        Integer Integerexample = 123;
        Double DecimalExample = 99.99;
        Boolean TrueFalse = true;
        List<String> CodingSalesforce = new List<String>{'Apex', 'SOQL', 'Visualforce', 'Lighting Components', 'Aura', 'LWC'};
        Set<Integer> Countto10wrong = new Set<Integer>{10, 1, 9, 2, 8, 3, 3, 7, 4, 6, 5}; // Duplicate 3 is ignored
        Map<String, Integer> TrafficLightExample = new Map<String, Integer>{
            'Red' => 100, 
            'Yellow' => 66, 
            'Green' => 33
        };
        Date ChristmasDay = Date.newInstance(2024, 12, 25); // Year, Month, Day
        Time ChristmasWakeup = Time.newInstance(2, 30, 0, 10); // 2:30 AM + 10 ms
        Datetime ChristmasDayWakeupnowexe = Datetime.newInstance(ChristmasDay, ChristmasWakeup);

        // Step 4: Create Dynamic Queries
        // Dynamic queries allow you to construct SOQL statements programmatically.
        // Corrected Query: Ensure space between field and FROM.
        String query = 'SELECT ' + field + ' FROM Account ' + filter; // Fixed missing space
        System.debug('Dynamic Query: ' + query); // Debug the constructed query
        List<Account> records = Database.query(query); // Execute the dynamic query
        System.debug('Returned Records here: ' + records);

        // Step 4: Create Static Queries - If SOQL is exact
        // This uses a predefined query to retrieve specific fields from Accounts.
        List<Account> results = [SELECT Id, Name FROM Account WHERE Industry = 'Finance'];
        System.debug('Static Query Results: ' + results);

        // Step 5: Create a Case against a Dummy Record with all the information above
        // Dummy Account creation for demonstration
        Account dummyAccount = new Account(Name = 'Dummy Account', Industry = 'Finance');
        insert dummyAccount; // Save the dummy Account in Salesforce
        System.debug('Dummy Account Created: ' + dummyAccount);

        // Case creation using the dummy Account
        Case newCase = new Case(
            AccountId = dummyAccount.Id, // Associate the Case with the dummy Account
            Subject = 'Test Case for ApexLearningTemplate',
            Description = 'This Case is created as part of learning Apex dynamic queries and data handling. '
                + 'Key values used in this process include: '
                + 'Field Names: ' + field + ', '
                + 'Filter Condition: ' + filter + ', '
                + 'Decimal Example: ' + DecimalExample + ', '
                + 'Boolean Value: ' + TrueFalse + ', '
                + 'List of Salesforce Concepts: ' + String.join(CodingSalesforce, ', ') + ', '
                + 'Traffic Light Values: ' + TrafficLightExample + ', '
                + 'Christmas Day: ' + ChristmasDay + ', '
                + 'Christmas Wakeup Time: ' + ChristmasWakeup + '.',
            Priority = 'High', // Example field value
            Status = 'New' // Example field value
        );
        insert newCase; // Save the Case record in Salesforce
        System.debug('New Case Created: ' + newCase);
    }
}