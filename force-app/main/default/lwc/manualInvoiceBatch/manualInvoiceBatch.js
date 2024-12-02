import { LightningElement, track } from 'lwc';
import triggerInvoiceBatch from '@salesforce/apex/ManualInvoiceBatchController.triggerInvoiceBatch';
export default class ManualInvoiceBatch extends LightningElement {
    @track startDate;
    @track endDate;
    @track message;
    handleStartDate(event) {
        this.startDate = event.target.value;
    }
    handleEndDate(event) {
        this.endDate = event.target.value;
    }
    async runBatch() {
        try {
            const result = await triggerInvoiceBatch({ startDate: this.startDate, endDate: this.endDate });
            this.message = result;
        } catch (error) {
            this.message = 'Error: ' + error.body.message;
        }
    }
}