//
//  GameController.swift
//  Minesweeper
//
//  Created by Jake on 8/08/16.
//  Copyright © 2016 jrb. All rights reserved.
//

import Foundation

protocol GameControllerDelegate: class {
    
    func gameDidWin(controller: GameController)
    
    func gameDidLose(controller: GameController, byRevealingBombAtIndex index: Int)
}

final class GameController {
    
    private(set) var cells: [GameCell] = []
    private(set) var board: Board = .easy
    
    weak var delegate: GameControllerDelegate?
    
    var remainingCoveredCells: Int {
        return cells.reduce(0) { (remaining: Int, cell: GameCell) in
            cell.state == .Covered ? remaining + 1 : remaining
        }
    }
    
    // MARK: Board
    
    struct Board {
        let rows:    Int
        let columns: Int
        let bombs:   Int
        
        init(rows: Int, columns: Int, bombs: Int) {
            self.rows = rows; self.columns = columns; self.bombs = bombs
        }
        
        var squares: Int {
            return rows * columns
        }
        
        static let easy   = Board(rows: 8,  columns: 8,  bombs: 5)
        static let medium = Board(rows: 8,  columns: 8,  bombs: 10)
        static let hard   = Board(rows: 12, columns: 12, bombs: 40)
    }
    
    // MARK: Index conversion
    
    func index(forRow row: Int, column: Int) -> Int {
        return row * board.columns + column
    }
    
    func coordinate(forIndex index: Int) -> (row: Int, column: Int) {
        return (index / board.rows, index % board.columns)
    }
    
    // MARK: Mutating
    
    func resetBoard(difficulty board: Board) {
        self.board = board
        reset()
    }
    
    func reset() {
        cells = Array(count: board.squares, repeatedValue: GameCell())
        insertBombs()
    }
    
    func reveal(atIndex index: Int) -> [Int] {
        var cell = cells[index]
        
        guard cell.canReveal else {
            if cell.isBomb {
                delegate?.gameDidLose(self, byRevealingBombAtIndex: index)
            }
            return [index]
        }
        
        cell.state = .Revealed
        cells[index] = cell
        
        if remainingCoveredCells == 0 {
            delegate?.gameDidWin(self)
            return [index]
        }
        
        /* Auto reveal cells when they have no adjacent bombs */
        guard cell.adjacentBombs == 0 else { return [index] }
        return Set(adjacentCellIndexes(forIndex: index).flatMap {
            self.reveal(atIndex: $0)
            }).sort()
    }
    
    // MARK: Private
    
    private func insertBombs() {
        for _ in 0..<board.bombs {
            func nextFreeIndex() -> Int {
                let index = Int(arc4random_uniform(UInt32(board.squares - 1)))
                return cells[index].state != .Bomb ? index : nextFreeIndex()
            }
            let index = nextFreeIndex()
            cells[index].state = .Bomb
            
            for adjacentIndex in adjacentCellIndexes(forIndex: index) {
                cells[adjacentIndex].adjacentBombs += 1
            }
        }
    }
    
    private func adjacentCellIndexes(forIndex index: Int, includeCorners: Bool = true) -> [Int] {
        let (row, column) = coordinate(forIndex: index)
        let isTopEdge    = row    == 0
        let isBottomEdge = row    == board.rows - 1
        let isLeftEdge   = column == 0
        let isRightEdge  = column == board.columns - 1
        let up           = index  -  board.columns
        let down         = index  +  board.columns
        let left         = index  -  1
        let right        = index  +  1
        
        var indexes: [Int] = []
        indexes.reserveCapacity(includeCorners ? 8 : 4)
        
        if !isTopEdge    && !isLeftEdge  && includeCorners { indexes.append(up - 1)   }
        if !isTopEdge                                      { indexes.append(up)       }
        if !isTopEdge    && !isRightEdge && includeCorners { indexes.append(up + 1)   }
        if !isLeftEdge                                     { indexes.append(left)     }
        if !isRightEdge                                    { indexes.append(right)    }
        if !isBottomEdge && !isLeftEdge  && includeCorners { indexes.append(down - 1) }
        if !isBottomEdge                                   { indexes.append(down)     }
        if !isBottomEdge && !isRightEdge && includeCorners { indexes.append(down + 1) }
        
        return indexes
    }
}

extension GameController: CellProvider { }
