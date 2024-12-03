import { LightningElement, api, track } from 'lwc';

export default class TicTacToeBoard extends LightningElement {
    @track boardWithKeys = [];

    @api
    set board(value) {
        console.log('Setting board:', value); // Debugging the board input
        if (value && Array.isArray(value)) {
            this.boardWithKeys = this.addKeysToBoard(value);
        } else {
            console.error('Invalid board value:', value); // Log invalid values
            this.boardWithKeys = [];
        }
    }

    get board() {
        return this.boardWithKeys.map(row => row.cells.map(cell => cell.value));
    }

    handleCellClick(event) {
        try {
            const { row, col } = event.detail;

            // Check if row or col is undefined
            if (row === undefined || col === undefined) {
                throw new Error(`Invalid row or col: row=${row}, col=${col}`);
            }

            console.log('Dispatching cell click event:', { row, col }); // Debugging event details
            this.dispatchEvent(new CustomEvent('cellclick', { detail: { row, col } }));
        } catch (error) {
            console.error('Error in handleCellClick:', error); // Log any errors
        }
    }

    addKeysToBoard(board) {
        try {
            return board.map((row, rowIndex) => ({
                rowKey: `row-${rowIndex}`,
                cells: row.map((cell, colIndex) => ({
                    cellKey: `cell-${rowIndex}-${colIndex}`,
                    value: cell
                }))
            }));
        } catch (error) {
            console.error('Error in addKeysToBoard:', error); // Log mapping errors
            return [];
        }
    }
}
