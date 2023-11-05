public class AccountToCSV1 {

    public static void exportAccountDataToCSV() {
        // Define the SOQL query to retrieve Dot Cases data
        String query = 'SELECT Case_No__c, Description__c, Status__c, Engineer_Name__c, Date_Assigned__c, Case_Resolved_Date__c, Case_Completed_Date__c, Remarks__c, Priority__c, No_Of_Days_For_Resolution__c, Severity__c, Duration__c, Month__c, Solved_on_own__c, Details_of_support_taken_from_Dot_team__c, Ceptes_Resolutions_comments__c, Dot_Resolution_comments__c FROM Dot_Cases__c';

        // Execute the query to retrieve Dot Cases records
        List<Dot_Cases__c> dotList = Database.query(query);

        // Define the CSV headers
        List<String> csvHeaders = new List<String>{
            'Case_No__c', 'Description__c', 'Status__c', 'Engineer_Name__c', 'Date_Assigned__c', 'Case_Resolved_Date__c', 'Case_Completed_Date__c', 'Remarks__c', 'Priority__c', 'No_Of_Days_For_Resolution__c', 'Severity__c', 'Duration__c', 'Month__c', 'Solved_on_own__c', 'Details_of_support_taken_from_Dot_team__c', 'Ceptes_Resolutions_comments__c', 'Dot_Resolution_comments__c'
        };

        // Define the title for the CSV file
        String title = 'Dot Cases';

        // Create a list to hold CSV rows
        List<String> csvRows = new List<String>();

        // Iterate through the Dot Cases records and create CSV rows
        for (Dot_Cases__c caseRecord : dotList) {
            String formattedDateAssigned = caseRecord.Date_Assigned__c != null ? caseRecord.Date_Assigned__c.format() : '';
            String formattedCaseResolvedDate = caseRecord.Case_Resolved_Date__c != null ? caseRecord.Case_Resolved_Date__c.format() : '';
            String formattedCaseCompletedDate = caseRecord.Case_Completed_Date__c != null ? caseRecord.Case_Completed_Date__c.format() : '';

            String csvRow = String.join(new List<String>{
                String.valueOf(caseRecord.Case_No__c),
                '"' + stripHtml(caseRecord.Description__c) + '"',
                caseRecord.Status__c,
                caseRecord.Engineer_Name__c,
                formattedDateAssigned,
                formattedCaseResolvedDate,
                formattedCaseCompletedDate,
                '"' + stripHtml(caseRecord.Remarks__c) + '"',
                caseRecord.Priority__c,
                String.valueOf(caseRecord.No_Of_Days_For_Resolution__c),
                caseRecord.Severity__c,
                caseRecord.Duration__c,
                caseRecord.Month__c,
                caseRecord.Solved_on_own__c,
                '"' + stripHtml(caseRecord.Details_of_support_taken_from_Dot_team__c) + '"',
                '"' + stripHtml(caseRecord.Ceptes_Resolutions_comments__c) + '"',
                '"' + stripHtml(caseRecord.Dot_Resolution_comments__c) + '"'
            }, ',');

            csvRows.add(csvRow);
        }

        // Create the CSV file
        createCSV(csvHeaders, csvRows, title);
    }

    // Method to create a CSV file
    public static void createCSV(List<String> csvHeaders, List<String> csvRowList, String title) {
        String headerRow = String.join(csvHeaders, ',') + '\n';
        String concatenatedStr = headerRow;
        Integer i = 0;
        Integer rowListSize = csvRowList.size();
        for (String row : csvRowList) {
            i++;
            concatenatedStr += (String)row + ((i != rowListSize) ? '\n' : ''); // add a new line
        }
        title += '.csv';

        // Create a Content Version and insert it to save the file in Salesforce
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S'; // denotes it resides on Salesforce
        cv.Title = title; // title of the file
        cv.PathOnClient = title; // full path within Salesforce; this can just be the name of the file in the library
        cv.VersionData = Blob.valueOf(concatenatedStr); // file data
        insert cv;
    }

    // Helper method to remove HTML tags from rich text fields
    public static String stripHtml(String input) {
        if (String.isNotBlank(input)) {
            return input.replaceAll('<[^>]+>', '');
        } else {
            return '';
        }
    }
}