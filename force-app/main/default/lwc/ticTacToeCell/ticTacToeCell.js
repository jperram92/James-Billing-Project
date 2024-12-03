import { LightningElement, api } from 'lwc';

export default class TicTacToeCell extends LightningElement {
    @api value; // Cell value ("X", "O", or "")
    @api row; // Row index
    @api col; // Column index

    handleClick() {
        console.log(`Cell clicked: Row ${this.row}, Col ${this.col}, Value: ${this.value}`);
        if (this.row !== undefined && this.col !== undefined) {
            this.dispatchEvent(
                new CustomEvent('click', {
                    detail: { row: this.row, col: this.col },
                })
            );
        }
    }

    connectedCallback() {
        console.log(`Cell initialized: Row ${this.row}, Col ${this.col}, Value: ${this.value}`);
    }
}
