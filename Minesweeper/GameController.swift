//
//  GameController.swift
//  Minesweeper
//
//  Created by Jake on 8/08/16.
//  Copyright © 2016 jrb. All rights reserved.
//

import Foundation

// MARK: Game controller delegate

protocol GameControllerDelegate: class {
    
    func gameDidWin(controller: GameController)
    
    func gameDidLose(controller: GameController, byRevealingBombAtIndex index: Int)
}

// MARK: -

final class GameController: CellProvider {
    
    private(set) var cells: [BoardCell] = []
    private(set) var board: Board = .easy
    private(set) var state: State = .Playing
    
    weak var delegate: GameControllerDelegate?
    
    var remainingCoveredCells: Int {
        return cells.reduce(0) { $1.isCovered ? $0 + 1 : $0 }
    }
    
    var remainingMarkers: Int {
        return cells.reduce(board.bombs) { $1.isMarked ? $0 - 1 : $0 }
    }
    
    enum State {
        case Won, Lost, Playing
    }
    
    init() {
        reset()
    }
    
    // MARK: Mutating
    
    /**
     Resets the game board.
     
     - parameter board: The new board to use. If nil the board is not updated.
     */
    func reset(board board: Board? = nil) {
        if let board = board {
            self.board = board
        }
        state = .Playing
        cells = Array(count: self.board.squares, repeatedValue: BoardCell())
        insertBombs()
    }
    
    /**
     Reveals a cell at a given position, and then adjacent cells only if there are no adjacent bombs.
     
     The game will lose if this cell is a bomb, or win if it reveals the last covered cell (ie. no moves remaining).
     
     - parameter index: The index of the cell to reveal.
     
     - returns: An array of indices of the cells that were revealed by this move.
     */
    func reveal(at index: Int) -> [Int] {
        let cell = cells[index]
        
        guard cell.isCovered else {
            /* Lose condition */
            if cell.isBomb {
                state = .Lost
                delegate?.gameDidLose(self, byRevealingBombAtIndex: index)
            }
            return [index]
        }
        
        if !cell.isMarked {
            var cell = cell
            cell.state = .Revealed
            cells[index] = cell
        }
        
        /* Win condition */
        if remainingCoveredCells == 0 {
            state = .Won
            delegate?.gameDidWin(self)
            return [index]
        }
        
        /* Auto reveal cells when they have no adjacent bombs */
        guard cell.adjacentBombs == 0 else { return [index] }
        var indices = board.adjacentIndices(for: index).flatMap {
            self.reveal(at: $0)
        }
        indices.append(index)
        return Set(indices).sort()
    }
    
    /**
     Toggles a cell as marked for having a bomb only if it is not already revealed. If it is already marked, it removes the marking.
     */
    func mark(at index: Int) {
        guard !cells[index].isRevealed else { return }
        cells[index].isMarked = !cells[index].isMarked
    }
    
    // MARK: Private
    
    private func insertBombs() {
        func nextFreeIndex() -> Int {
            let index = Int(arc4random_uniform(UInt32(board.squares - 1)))
            return !cells[index].isBomb ? index : nextFreeIndex()
        }
        for _ in 0..<board.bombs {
            let index = nextFreeIndex()
            cells[index].state = .Bomb
            
            for adjacentIndex in board.adjacentIndices(for: index) {
                cells[adjacentIndex].adjacentBombs += 1
            }
        }
    }
}
