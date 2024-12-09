/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-05-2024
 * @last modified by  : jamesperram@gmail.com
**/
@isTest
public class CSVGeneratorTest {

    @isTest
    static void testGenerateCSVWithValidData() {
        // Prepare mock data
        List<Map<String, String>> mockData = new List<Map<String, String>>{
            new Map<String, String>{'Name' => 'John Doe', 'Age' => '30', 'City' => 'New York'},
            new Map<String, String>{'Name' => 'Jane Smith', 'Age' => '25', 'City' => 'Los Angeles'}
        };

        // Generate CSV
        String csvContent = CSVGenerator.generateCSV(mockData);

        // Expected CSV content
        String expectedHeader = 'Name,Age,City';
        String expectedRow1 = '"John Doe","30","New York"';
        String expectedRow2 = '"Jane Smith","25","Los Angeles"';

        // Validate CSV output
        System.assert(csvContent.contains(expectedHeader), 'CSV should contain the correct header.');
        System.assert(csvContent.contains(expectedRow1), 'CSV should contain the correct first row.');
        System.assert(csvContent.contains(expectedRow2), 'CSV should contain the correct second row.');
    }

    @isTest
    static void testGenerateCSVWithEmptyData() {
        // Prepare empty mock data
        List<Map<String, String>> mockData = new List<Map<String, String>>();

        // Generate CSV
        String csvContent = CSVGenerator.generateCSV(mockData);

        // Validate CSV output
        System.assertEquals('No data found.', csvContent, 'CSV content should indicate no data found for empty input.');
    }

    @isTest
    static void testGenerateCSVWithNullValues() {
        // Prepare mock data with null values
        List<Map<String, String>> mockData = new List<Map<String, String>>{
            new Map<String, String>{'Name' => 'John Doe', 'Age' => null, 'City' => 'New York'},
            new Map<String, String>{'Name' => null, 'Age' => '25', 'City' => null}
        };

        // Generate CSV
        String csvContent = CSVGenerator.generateCSV(mockData);

        // Expected CSV content
        String expectedHeader = 'Name,Age,City';
        String expectedRow1 = '"John Doe","N/A","New York"';
        String expectedRow2 = '"N/A","25","N/A"';

        // Validate CSV output
        System.assert(csvContent.contains(expectedHeader), 'CSV should contain the correct header.');
        System.assert(csvContent.contains(expectedRow1), 'CSV should handle null values correctly in the first row.');
        System.assert(csvContent.contains(expectedRow2), 'CSV should handle null values correctly in the second row.');
    }

    @isTest
    static void testGenerateCSVWithSpecialCharacters() {
        // Prepare mock data with special characters
        List<Map<String, String>> mockData = new List<Map<String, String>>{
            new Map<String, String>{'Name' => 'John, Doe', 'Age' => '30', 'City' => 'New York'},
            new Map<String, String>{'Name' => 'Jane "Smith"', 'Age' => '25', 'City' => 'Los Angeles'}
        };

        // Generate CSV
        String csvContent = CSVGenerator.generateCSV(mockData);

        // Expected CSV content
        String expectedHeader = 'Name,Age,City';
        String expectedRow1 = '"John, Doe","30","New York"';
        String expectedRow2 = '"Jane ""Smith""","25","Los Angeles"';

        // Validate CSV output
        System.assert(csvContent.contains(expectedHeader), 'CSV should contain the correct header.');
        System.assert(csvContent.contains(expectedRow1), 'CSV should escape commas correctly in the first row.');
        System.assert(csvContent.contains(expectedRow2), 'CSV should escape quotes correctly in the second row.');
    }

    @isTest
    static void testGenerateCSVWithLargeDataset() {
        // Prepare large mock data
        List<Map<String, String>> mockData = new List<Map<String, String>>();
        for (Integer i = 0; i < 1000; i++) {
            mockData.add(new Map<String, String>{
                'ID' => String.valueOf(i),
                'Name' => 'User ' + i,
                'Email' => 'user' + i + '@example.com'
            });
        }

        // Generate CSV
        String csvContent = CSVGenerator.generateCSV(mockData);

        // Validate CSV output
        System.assert(csvContent.startsWith('ID,Name,Email'), 'CSV should contain the correct header.');
        System.assert(csvContent.contains('"0","User 0","user0@example.com"'), 'CSV should contain the first row of data.');
        System.assert(csvContent.contains('"999","User 999","user999@example.com"'), 'CSV should contain the last row of data.');
    }
}