import { LightningElement, track } from 'lwc';
import getServicesByDate from '@salesforce/apex/ServiceScheduleController.getServicesByDate';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ServiceScheduler extends LightningElement {
    @track services;
    @track selectedService;
    @track error;

    columns = [
        { label: 'Service Name', fieldName: 'Name' },
        { label: 'Opportunity Product', fieldName: 'JBP_Service__r.Service_Schedule__r.Opportunity_Product__c' },
        { label: 'Service Type', fieldName: 'JBP_Service_Type__c' },
        { label: 'Start Time', fieldName: 'JBP_Service_Start_Time__c', type: 'time' },
        { label: 'End Time', fieldName: 'JBP_Service_End_Time__c', type: 'time' },
        {
            type: 'button',
            typeAttributes: { label: 'Select', name: 'select', variant: 'brand' },
        },
    ];

    handleDateChange(event) {
        const selectedDate = event.target.value;
        this.selectedService = null; // Reset selected service when date changes
        getServicesByDate({ serviceDate: selectedDate })
            .then((result) => {
                this.services = result;
                this.error = undefined;
            })
            .catch((error) => {
                this.services = undefined;
                this.error = error.body.message;
            });
    }

    handleServiceSelect(event) {
        const row = event.detail.row;
        this.selectedService = row;
    }

    handleSuccess(event) {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'Service Schedule created successfully!',
            variant: 'success',
        });
        this.dispatchEvent(evt);
        this.selectedService = null; // Reset after successful creation
    }
}
