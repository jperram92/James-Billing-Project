import { LightningElement, track, wire } from 'lwc';
import getServicesByDate from '@salesforce/apex/SchedulingController.getServicesByDate';
import updateServices from '@salesforce/apex/SchedulingController.updateServices';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CalendarView extends LightningElement {
    @track selectedMonth = '12'; // Default to December
    @track selectedYear = '2024'; // Default to 2024
    @track calendarDays = []; // Holds the days to render
    @track services = [];
    @track showModal = false;
    @track selectedDate = null;
    @track columns = [
        { label: 'Name', fieldName: 'Name', editable: false },
        { label: 'Status', fieldName: 'JBP_Service_Status__c', editable: true },
        { 
            label: 'Start Time', 
            fieldName: 'formattedStartTime', 
            type: 'text', 
            editable: true 
        },
        { 
            label: 'End Time', 
            fieldName: 'formattedEndTime', 
            type: 'text', 
            editable: true 
        },
        { label: 'Date', fieldName: 'JBP_Service_Date__c', type: 'date', editable: false }
    ];

    months = [
        { label: 'January', value: '1' },
        { label: 'February', value: '2' },
        { label: 'March', value: '3' },
        { label: 'April', value: '4' },
        { label: 'May', value: '5' },
        { label: 'June', value: '6' },
        { label: 'July', value: '7' },
        { label: 'August', value: '8' },
        { label: 'September', value: '9' },
        { label: 'October', value: '10' },
        { label: 'November', value: '11' },
        { label: 'December', value: '12' },
    ];

    dayHeaders = [
        { label: 'Sunday', key: 'sunday' },
        { label: 'Monday', key: 'monday' },
        { label: 'Tuesday', key: 'tuesday' },
        { label: 'Wednesday', key: 'wednesday' },
        { label: 'Thursday', key: 'thursday' },
        { label: 'Friday', key: 'friday' },
        { label: 'Saturday', key: 'saturday' },
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

        // Add empty days for the starting day of the month
        for (let i = 0; i < firstDayOfMonth; i++) {
            this.calendarDays.push({ key: `empty-${i}`, value: '', isToday: false });
        }

        // Add actual days
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
            // Format start and end times to human-readable strings
            this.services = serviceRecords.map(service => ({
                ...service,
                formattedStartTime: this.formatTime(service.JBP_Service_Start_Time__c),
                formattedEndTime: this.formatTime(service.JBP_Service_End_Time__c)
            }));
            this.showModal = true;
        } catch (error) {
            this.showToast('Error', 'Unable to fetch services', 'error');
        }
    }

    formatTime(milliseconds) {
        if (!milliseconds) return '';
        const date = new Date(milliseconds);
        const hours = date.getUTCHours();
        const minutes = date.getUTCMinutes();
        const ampm = hours >= 12 ? 'PM' : 'AM';
        const formattedHours = hours % 12 || 12; // Convert 24-hour to 12-hour format
        return `${formattedHours}:${minutes.toString().padStart(2, '0')} ${ampm}`;
    }

    async handleSave(event) {
        const updatedFields = event.detail.draftValues.map(draft => {
            const service = this.services.find(svc => svc.Id === draft.Id);
            return {
                Id: draft.Id,
                JBP_Service_Status__c: draft.JBP_Service_Status__c,
                JBP_Service_Start_Time__c: draft.formattedStartTime ? this.convertTimeToMilliseconds(draft.formattedStartTime) : service.JBP_Service_Start_Time__c,
                JBP_Service_End_Time__c: draft.formattedEndTime ? this.convertTimeToMilliseconds(draft.formattedEndTime) : service.JBP_Service_End_Time__c
            };
        });

        try {
            await updateServices({ services: updatedFields });
            this.showToast('Success', 'Services updated successfully', 'success');
            this.showModal = false;
            this.handleDayClick({ target: { textContent: new Date(this.selectedDate).getDate() } }); // Reload the services
        } catch (error) {
            this.showToast('Error', 'Error updating services', 'error');
        }
    }

    convertTimeToMilliseconds(timeString) {
        const [time, modifier] = timeString.split(' ');
        let [hours, minutes] = time.split(':').map(Number);
        if (modifier === 'PM' && hours < 12) hours += 12;
        if (modifier === 'AM' && hours === 12) hours = 0;
        return (hours * 60 + minutes) * 60 * 1000;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(event);
    }

    handleCloseModal() {
        this.showModal = false;
    }
}
