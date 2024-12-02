/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-02-2024
 * @last modified by  : jamesperram@gmail.com
**/
public class CSVGenerator {
    /**
     * @description       : Generate a CSV string from a list of map data
     * @param data        : List of maps representing CSV rows (key = column header, value = cell content)
     * @return            : Generated CSV content as a string
     **/
    public static String generateCSV(List<Map<String, String>> data) {
        if (data.isEmpty()) {
            System.debug('No data to generate CSV');
            return 'No data found.';
        }

        // Generate header
        Map<String, String> firstRow = data[0];
        List<String> headers = new List<String>(firstRow.keySet());
        String csvContent = String.join(headers, ',');

        System.debug('CSV Header: ' + csvContent);

        // Generate rows
        for (Map<String, String> row : data) {
            List<String> values = new List<String>();
            for (String header : headers) {
                values.add('"' + (row.get(header) != null ? row.get(header) : 'N/A') + '"'); // Handle null values
            }
            csvContent += '\n' + String.join(values, ',');
        }

        System.debug('Generated CSV Content: ' + csvContent);
        return csvContent;
    }
}
