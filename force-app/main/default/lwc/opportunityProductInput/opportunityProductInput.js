import { LightningElement, api, track } from 'lwc';
import getOpportunityDetails from '@salesforce/apex/OpportunityProductController.getOpportunityDetails';
import getAvailableProducts from '@salesforce/apex/OpportunityProductController.getAvailableProducts';
import getPricebooks from '@salesforce/apex/OpportunityProductController.getPricebooks';
import createOpportunityProducts from '@salesforce/apex/OpportunityProductController.createOpportunityProducts';

export default class OpportunityProductInput extends LightningElement {
    @api recordId; // Current Opportunity ID
    @track opportunityName = '';
    @track customerName = '';
    @track contactName = 'N/A';
    @track pricebookOptions = [];
    @track selectedPricebook = '';
    @track productData = [];
    @track selectedProducts = [];
    @track errorMessage = ''; // Error message for UI display

    serviceDate = '';
    serviceStartTime = '';
    serviceEndTime = '';
    description = '';
    quantity = 1;
    discount = 0;

    columns = [
        { label: 'Product Name', fieldName: 'productName' },
        { label: 'Product Code', fieldName: 'productCode' },
        { label: 'Unit Price', fieldName: 'unitPrice', type: 'currency' }
    ];

    connectedCallback() {
        console.log('Record ID:', this.recordId); // Check if recordId is populated
        if (this.recordId) {
            this.fetchOpportunityDetails();
            this.loadProducts();
        } else {
            console.error('No recordId passed to the component.');
            this.errorMessage = 'Error: No recordId available. Please add this component to an Opportunity record page.';
        }
    }

    fetchOpportunityDetails() {
        getOpportunityDetails({ opportunityId: this.recordId })
            .then((data) => {
                this.opportunityName = data.Name;
                this.customerName = data.Account ? data.Account.Name : 'No Account';
                this.contactName = data.Pre_Check_Form__r?.Contact__r?.Name || 'No Contact';
            })
            .catch((error) => {
                console.error('Error fetching Opportunity details:', error);
                this.errorMessage = 'Error fetching Opportunity details: ' + (error.body?.message || error.message);
            });
    }

    loadPricebooks() {
        getPricebooks()
            .then((data) => {
                this.pricebookOptions = data.map((pricebook) => ({
                    label: pricebook.Name,
                    value: pricebook.Id
                }));
            })
            .catch((error) => {
                console.error('Error loading Pricebooks:', error);
                this.errorMessage = 'Error loading Pricebooks: ' + (error.body?.message || error.message);
            });
    }

    handlePricebookChange(event) {
        this.selectedPricebook = event.target.value;
        this.loadProducts();
    }

    loadProducts() {
        getAvailableProducts({ opportunityId: this.recordId })
            .then((data) => {
                console.log('Fetched Products:', data);
                this.productData = data.map((entry) => ({
                    id: entry.Id,
                    productId: entry.Product2Id,
                    productName: entry.Product2.Name,
                    productCode: entry.Product2.ProductCode,
                    unitPrice: entry.UnitPrice
                }));
                this.errorMessage = ''; // Clear any previous error
            })
            .catch((error) => {
                console.error('Error loading Products:', error);
                this.errorMessage = error.body?.message || 'Unknown error loading Products.';
            });
    }

    handleRowSelection(event) {
        this.selectedProducts = event.detail.selectedRows;
    }

    handleInputChange(event) {
        const field = event.target.dataset.field;
        this[field] = event.target.value;
    }

    createOpportunityProducts() {
        const opportunityProducts = this.selectedProducts.map((product) => ({
            OpportunityId: this.recordId,
            PricebookEntryId: product.id,
            Quantity: this.quantity,
            UnitPrice: product.unitPrice * (1 - this.discount / 100),
            ServiceDate: this.serviceDate,
            Description: this.description,
            JBP_Service_Offering_Start_Time__c: this.serviceStartTime,
            JBP_Service_Offering_End_Time__c: this.serviceEndTime
        }));

        console.log('Opportunity Products Payload:', opportunityProducts);

        createOpportunityProducts({ opportunityProducts })
            .then(() => {
                console.log('Opportunity Products Created Successfully');
                this.errorMessage = ''; // Clear any previous errors
            })
            .catch((error) => {
                console.error('Error creating Opportunity Products:', error);
                this.errorMessage = 'Error creating Opportunity Products: ' + (error.body?.message || error.message);
            });
    }
}
