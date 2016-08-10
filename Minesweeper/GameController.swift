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
    
    private(set) var cells: [GameCell] = []
    private(set) var board: Board = .easy
    private(set) var state: State = .Playing
    
    weak var delegate: GameControllerDelegate?
    
    enum State {
        case Won, Lost, Playing
    }
    
    init() {
        reset()
    }
    
    // MARK: Board
    
    struct Board {
        let rows:    Int
        let columns: Int
        let bombs:   Int
        var squares: Int { return rows * columns }
        
        static let easy   = Board(rows: 8,  columns: 8,  bombs: 5)
        static let medium = Board(rows: 8,  columns: 8,  bombs: 10)
        static let hard   = Board(rows: 12, columns: 12, bombs: 40)
    }
    
    var remainingCoveredCells: Int {
        return cells.reduce(0) { $1.isCovered ? $0 + 1 : $0 }
    }
    
    // MARK: Index conversion
    
    func index(for row: Int, column: Int) -> Int {
        return row * board.columns + column
    }
    
    func coordinate(for index: Int) -> (row: Int, column: Int) {
        return (index / board.rows, index % board.columns)
    }
    
    // MARK: Mutating
    
    func resetBoard(difficulty board: Board) {
        self.board = board
        reset()
    }
    
    func reset() {
        state = .Playing
        cells = Array(count: board.squares, repeatedValue: GameCell())
        insertBombs()
    }
    
    func reveal(at index: Int) -> [Int] {
        var cell = cells[index]
        
        guard cell.isCovered else {
            /* Lose condition */
            if cell.isBomb {
                state = .Lost
                delegate?.gameDidLose(self, byRevealingBombAtIndex: index)
            }
            return [index]
        }
        
        cell.state = .Revealed
        cells[index] = cell
        
        /* Win condition */
        if remainingCoveredCells == 0 {
            state = .Won
            delegate?.gameDidWin(self)
            return [index]
        }
        
        /* Auto reveal cells when they have no adjacent bombs */
        guard cell.adjacentBombs == 0 else { return [index] }
        var indices = adjacentCellIndices(forIndex: index).flatMap {
            self.reveal(at: $0)
        }
        indices.append(index)
        return Set(indices).sort()
    }
    
    func mark(at index: Int) {
        cells[index].state = cells[index].isMarked ? .Covered : .Marked
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
            
            for adjacentIndex in adjacentCellIndices(forIndex: index) {
                cells[adjacentIndex].adjacentBombs += 1
            }
        }
    }
    
    private func adjacentCellIndices(forIndex index: Int) -> [Int] {
        let (row, column) = coordinate(for: index)
        let isTopEdge    = row    == 0
        let isBottomEdge = row    == board.rows - 1
        let isLeftEdge   = column == 0
        let isRightEdge  = column == board.columns - 1
        let up           = index  -  board.columns
        let down         = index  +  board.columns
        let left         = index  -  1
        let right        = index  +  1
        
        var indices: [Int] = []
        indices.reserveCapacity(8)
        
        if !isTopEdge    && !isLeftEdge  { indices.append(up - 1)   }
        if !isTopEdge                    { indices.append(up)       }
        if !isTopEdge    && !isRightEdge { indices.append(up + 1)   }
        if !isLeftEdge                   { indices.append(left)     }
        if !isRightEdge                  { indices.append(right)    }
        if !isBottomEdge && !isLeftEdge  { indices.append(down - 1) }
        if !isBottomEdge                 { indices.append(down)     }
        if !isBottomEdge && !isRightEdge { indices.append(down + 1) }
        
        return indices
    }
}
