import { LightningElement, track } from 'lwc';
import getServicesByDate from '@salesforce/apex/SchedulingController.getServicesByDate';
import updateServices from '@salesforce/apex/SchedulingController.updateServices';
import addService from '@salesforce/apex/SchedulingController.addService';
import deleteServices from '@salesforce/apex/SchedulingController.deleteServices';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CalendarView extends LightningElement {
    @track selectedMonth = '12'; // Default to December
    @track selectedYear = '2024'; // Default to 2024
    @track calendarDays = [];
    @track services = [];
    @track selectedServices = []; // Holds IDs of selected services
    @track showAddServiceModal = false;
    @track selectedDate = null;

    @track newService = {
        Name: '',
        JBP_Service_Start_Time__c: '',
        JBP_Service_End_Time__c: '',
        JBP_Service_Date__c: ''
    };

    @track columns = [
        { label: 'Name', fieldName: 'Name', editable: false },
        { label: 'Status', fieldName: 'JBP_Service_Status__c', editable: true },
        { label: 'Start Time', fieldName: 'formattedStartTime', type: 'text', editable: true },
        { label: 'End Time', fieldName: 'formattedEndTime', type: 'text', editable: true },
        { label: 'Date', fieldName: 'JBP_Service_Date__c', type: 'date', editable: false }
    ];

    months = [
        { label: 'January', value: '1' }, { label: 'February', value: '2' }, { label: 'March', value: '3' },
        { label: 'April', value: '4' }, { label: 'May', value: '5' }, { label: 'June', value: '6' },
        { label: 'July', value: '7' }, { label: 'August', value: '8' }, { label: 'September', value: '9' },
        { label: 'October', value: '10' }, { label: 'November', value: '11' }, { label: 'December', value: '12' }
    ];

    connectedCallback() {
        this.generateCalendar();
    }

    handleMonthChange(event) {
        this.selectedMonth = event.target.value;
        this.generateCalendar();
    }

    handleYearChange(event) {
        this.selectedYear = event.target.value;
        this.generateCalendar();
    }

    generateCalendar() {
        const daysInMonth = new Date(this.selectedYear, this.selectedMonth, 0).getDate();
        const firstDayOfMonth = new Date(this.selectedYear, this.selectedMonth - 1, 1).getDay();
        const today = new Date();
        this.calendarDays = [];

        for (let i = 0; i < firstDayOfMonth; i++) {
            this.calendarDays.push({ key: `empty-${i}`, value: '', isToday: false });
        }

        for (let day = 1; day <= daysInMonth; day++) {
            const isToday =
                day === today.getDate() &&
                parseInt(this.selectedMonth) === today.getMonth() + 1 &&
                parseInt(this.selectedYear) === today.getFullYear();
            this.calendarDays.push({ key: `day-${day}`, value: day, isToday });
        }
    }

    async handleDayClick(event) {
        const clickedDay = event.target.textContent;
        this.selectedDate = `${this.selectedYear}-${this.selectedMonth.padStart(2, '0')}-${clickedDay.padStart(2, '0')}`;
        try {
            const serviceRecords = await getServicesByDate({ serviceDate: this.selectedDate });
            this.services = serviceRecords.map(service => ({
                ...service,
                formattedStartTime: this.formatTime(service.JBP_Service_Start_Time__c),
                formattedEndTime: this.formatTime(service.JBP_Service_End_Time__c)
            }));
        } catch (error) {
            this.showToast('Error', 'Unable to fetch services', 'error');
        }
    }

    handleRowSelection(event) {
        // Capture selected rows
        this.selectedServices = event.detail.selectedRows.map(row => row.Id);
    }

    openAddServiceModal() {
        this.showAddServiceModal = true;
    }

    closeAddServiceModal() {
        this.showAddServiceModal = false;
    }

    handleInputChange(event) {
        const field = event.target.name;
        this.newService[field] = event.target.value;
    }

    async saveNewService() {
        const { Name, JBP_Service_Start_Time__c, JBP_Service_End_Time__c, JBP_Service_Date__c } = this.newService;

        if (!Name || !JBP_Service_Start_Time__c || !JBP_Service_End_Time__c || !JBP_Service_Date__c) {
            this.showToast('Error', 'All fields are required to add a service.', 'error');
            return;
        }

        if (JBP_Service_Start_Time__c >= JBP_Service_End_Time__c) {
            this.showToast('Error', 'Start Time must be earlier than End Time.', 'error');
            return;
        }

        try {
            await addService({ newService: this.newService });
            this.showToast('Success', 'Service added successfully.', 'success');
            this.closeAddServiceModal();
            this.handleDayClick({ target: { textContent: new Date(this.selectedDate).getDate() } });
            this.newService = { Name: '', JBP_Service_Start_Time__c: '', JBP_Service_End_Time__c: '', JBP_Service_Date__c: '' };
        } catch (error) {
            this.showToast('Error', `Failed to add service: ${error.body.message}`, 'error');
        }
    }

    async handleDeleteServices() {
        if (this.selectedServices.length === 0) {
            this.showToast('Error', 'Please select services to delete.', 'error');
            return;
        }

        try {
            await deleteServices({ serviceIds: this.selectedServices });
            this.showToast('Success', 'Selected services deleted successfully.', 'success');
            this.handleDayClick({ target: { textContent: new Date(this.selectedDate).getDate() } });
            this.selectedServices = [];
        } catch (error) {
            this.showToast('Error', `Failed to delete services: ${error.body.message}`, 'error');
        }
    }

    formatTime(milliseconds) {
        if (!milliseconds) return '';
        const date = new Date(milliseconds);
        const hours = date.getUTCHours();
        const minutes = date.getUTCMinutes();
        const ampm = hours >= 12 ? 'PM' : 'AM';
        const formattedHours = hours % 12 || 12;
        return `${formattedHours}:${minutes.toString().padStart(2, '0')} ${ampm}`;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(event);
    }
}
