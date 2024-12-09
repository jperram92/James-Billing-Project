import { LightningElement, track } from 'lwc';
import getServicesByDate from '@salesforce/apex/ServiceScheduleController.getServicesByDate';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ServiceScheduler extends LightningElement {
    @track services; // List of services fetched from the server
    @track selectedService; // The service selected by the user
    @track error; // Error handling

    columns = [
        { label: 'Service Name', fieldName: 'Name' },
        { label: 'Opportunity Product', fieldName: 'Opportunity_Product__c' },
        { label: 'Service Type', fieldName: 'JBP_Service_Type__c' },
        { label: 'Service Date', fieldName: 'JBP_Service_Date__c', type: 'date' },
        { label: 'Start Time', fieldName: 'JBP_Service_Start_Time__c', type: 'time' },
        { label: 'End Time', fieldName: 'JBP_Service_End_Time__c', type: 'time' },
        {
            type: 'button',
            typeAttributes: { label: 'Select', name: 'select', variant: 'brand' },
        },
    ];

    // Handle date change to fetch available services
    handleDateChange(event) {
        const selectedDate = event.target.value;
        this.selectedService = null; // Reset selected service when date changes
        getServicesByDate({ serviceDate: selectedDate })
            .then((result) => {
                console.log('Fetched Services:', JSON.stringify(result));
                this.services = result; // Store the fetched services
                this.error = undefined;
            })
            .catch((error) => {
                console.error('Error fetching services:', error);
                this.services = undefined;
                this.error = error.body.message;
            });
    }

    // Handle service selection
    handleServiceSelect(event) {
        const row = event.detail.row;
        console.log('Selected Service:', JSON.stringify(row));
        this.selectedService = row; // Store the selected service
    }

    // Handle successful creation of a Service Schedule
    handleSuccess(event) {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'Service Schedule created successfully!',
            variant: 'success',
        });
        this.dispatchEvent(evt);
        this.selectedService = null; // Reset selected service after successful creation
    }
}
