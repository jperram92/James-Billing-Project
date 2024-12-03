import { LightningElement, track } from 'lwc';

export default class TicTacToe extends LightningElement {
    @track board = [
        ['', '', ''],
        ['', '', ''],
        ['', '', '']
    ]; // Initial board
    @track currentPlayer = 'X'; // Tracks current player
    @track statusMessage = 'Player X\'s turn'; // Tracks game status

    handleCellClick(event) {
        const { row, col } = event.detail;

        // Update the board if the cell is empty
        if (!this.board[row][col]) {
            this.board[row][col] = this.currentPlayer;

            if (this.checkWin()) {
                this.statusMessage = `Player ${this.currentPlayer} wins!`;
            } else if (this.checkDraw()) {
                this.statusMessage = 'It\'s a draw!';
            } else {
                this.currentPlayer = this.currentPlayer === 'X' ? 'O' : 'X'; // Switch turn
                this.statusMessage = `Player ${this.currentPlayer}'s turn`;
            }
        }
    }

    checkWin() {
        const winPatterns = [
            // Rows
            [this.board[0][0], this.board[0][1], this.board[0][2]],
            [this.board[1][0], this.board[1][1], this.board[1][2]],
            [this.board[2][0], this.board[2][1], this.board[2][2]],
            // Columns
            [this.board[0][0], this.board[1][0], this.board[2][0]],
            [this.board[0][1], this.board[1][1], this.board[2][1]],
            [this.board[0][2], this.board[1][2], this.board[2][2]],
            // Diagonals
            [this.board[0][0], this.board[1][1], this.board[2][2]],
            [this.board[0][2], this.board[1][1], this.board[2][0]],
        ];

        return winPatterns.some(pattern =>
            pattern.every(cell => cell === this.currentPlayer)
        );
    }

    checkDraw() {
        return this.board.every(row => row.every(cell => cell !== ''));
    }

    resetGame() {
        this.board = [
            ['', '', ''],
            ['', '', ''],
            ['', '', '']
        ];
        this.currentPlayer = 'X';
        this.statusMessage = 'Player X\'s turn';
    }
}
