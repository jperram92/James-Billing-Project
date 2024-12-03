import { LightningElement, api } from 'lwc';

export default class TicTacToeCell extends LightningElement {
    @api value = ''; // Default value is an empty string
    @api row;
    @api col;

    handleClick() {
        console.log(`Cell clicked: Row ${this.row}, Col ${this.col}, Value: ${this.value}`);

        // Hardcode the value for testing
        if (!this.value) {
            this.value = 'X'; // Default hardcoded value
        }

        this.dispatchEvent(
            new CustomEvent('click', {
                detail: { row: this.row, col: this.col },
            })
        );
    }

    connectedCallback() {
        console.log(`Cell initialized: Row ${this.row}, Col ${this.col}, Value: ${this.value}`);
    }
}
