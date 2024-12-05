import { LightningElement, api, wire } from 'lwc';
import getOpportunityProductBalances from '@salesforce/apex/CostBalanceController.getOpportunityProductBalances';

export default class OpportunityProductBalances extends LightningElement {
    @api recordId; // Automatically receives the Opportunity ID from the record page
    data;
    error;

    @wire(getOpportunityProductBalances, { opportunityId: '$recordId' })
    wiredData({ error, data }) {
        if (data) {
            this.data = data.map((row) => {
                // Add currency formatting
                const formatter = new Intl.NumberFormat('en-US', {
                    style: 'currency',
                    currency: 'USD'
                });

                const totalAllocated = row.totalAllocated || 0;
                const totalSpent = row.totalSpent || 0;

                // Calculate percentage spent
                const percentageSpent = totalAllocated > 0
                    ? Math.round((totalSpent / totalAllocated) * 100)
                    : 0;

                // Determine styling class based on percentage spent
                const percentageClass =
                    percentageSpent > 80
                        ? 'slds-text-color_error'
                        : 'slds-text-color_success';

                return {
                    ...row,
                    unitPriceFormatted: formatter.format(row.unitPrice),
                    totalAllocatedFormatted: formatter.format(row.totalAllocated),
                    totalSpentFormatted: formatter.format(row.totalSpent),
                    balanceFormatted: formatter.format(row.balance),
                    percentageSpent,
                    percentageClass
                };
            });
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.data = undefined;
        }
    }
}
