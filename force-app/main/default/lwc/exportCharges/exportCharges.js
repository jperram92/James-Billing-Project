import { LightningElement } from 'lwc';
import exportCharges from '@salesforce/apex/ChargeExportController.exportCharges';

export default class ChargeExport extends LightningElement {
    startDate;
    endDate;
    message;
    debugLog = []; // Reactive by default
    isLoading = false;

    handleStartDate(event) {
        this.startDate = event.target.value;
    }

    handleEndDate(event) {
        this.endDate = event.target.value;
    }

    logDebug(message) {
        console.log(message); // Logs to browser console
        this.debugLog.push(message); // Keeps a history of logs
    }

    async exportToCSV() {
        try {
            this.isLoading = true;
            this.message = '';
            this.debugLog = []; // Clear previous logs

            this.logDebug('Export triggered with Start Date: ' + this.startDate + ' and End Date: ' + this.endDate);

            if (!this.startDate || !this.endDate) {
                this.message = 'Please select both start and end dates.';
                this.logDebug('Error: Missing dates');
                return;
            }

            const csvContent = await exportCharges({ startDate: this.startDate, endDate: this.endDate });
            this.logDebug('CSV Response: ' + csvContent);

            if (csvContent.startsWith('Error:')) {
                this.message = csvContent; // Display error message from Apex
                this.logDebug('Apex Error: ' + csvContent);
                return;
            }

            if (csvContent === 'No data found for the selected date range.') {
                this.message = csvContent;
                this.logDebug('No data found for the provided date range.');
                return;
            }

            // Encode CSV content into a data URI
            const csvDataUri = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvContent);

            // Create a download link with the data URI
            const link = document.createElement('a');
            link.href = csvDataUri;
            link.setAttribute('download', 'exported_charges.csv'); // Set download attribute
            document.body.appendChild(link); // Required for Firefox compatibility
            link.click();
            document.body.removeChild(link); // Clean up the DOM

            this.message = 'Export successful!';
            this.logDebug('CSV file downloaded successfully.');
        } catch (error) {
            this.message = 'An unexpected error occurred.';
            this.logDebug('Error in exportToCSV: ' + (error.body?.message || error.message));
            console.error('Export Error:', error);
        } finally {
            this.isLoading = false;
        }
    }
}
