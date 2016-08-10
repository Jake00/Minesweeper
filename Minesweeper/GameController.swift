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
    private(set) var state: State = .Playing
    
    weak var delegate: GameControllerDelegate?
    
    enum State {
        case Won, Lost, Playing
    }
    
    init() {
        reset()
    }
    
    // MARK: Board
    
    var remainingCoveredCells: Int {
        return cells.reduce(0) { (remaining: Int, cell: GameCell) in
            cell.isCovered ? remaining + 1 : remaining
        }
    }
    
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
        state = .Playing
        cells = Array(count: board.squares, repeatedValue: GameCell())
        insertBombs()
    }
    
    func reveal(atIndex index: Int) -> [Int] {
        var cell = cells[index]
        
        guard cell.isCovered else {
            if cell.isBomb {
                state = .Lost
                delegate?.gameDidLose(self, byRevealingBombAtIndex: index)
            }
            return [index]
        }
        
        cell.state = .Revealed
        cells[index] = cell
        
        if remainingCoveredCells == 0 {
            state = .Won
            delegate?.gameDidWin(self)
            return [index]
        }
        
        /* Auto reveal cells when they have no adjacent bombs */
        guard cell.adjacentBombs == 0 else { return [index] }
        var indices = adjacentCellIndices(forIndex: index).flatMap {
            self.reveal(atIndex: $0)
        }
        indices.append(index)
        return Set(indices).sort()
    }
    
    // MARK: Private
    
    private func insertBombs() {
        for _ in 0..<board.bombs {
            func nextFreeIndex() -> Int {
                let index = Int(arc4random_uniform(UInt32(board.squares - 1)))
                return !cells[index].isBomb ? index : nextFreeIndex()
            }
            let index = nextFreeIndex()
            cells[index].state = .Bomb
            
            for adjacentIndex in adjacentCellIndices(forIndex: index) {
                cells[adjacentIndex].adjacentBombs += 1
            }
        }
    }
    
    private func adjacentCellIndices(forIndex index: Int, includeCorners: Bool = true) -> [Int] {
        let (row, column) = coordinate(forIndex: index)
        let isTopEdge    = row    == 0
        let isBottomEdge = row    == board.rows - 1
        let isLeftEdge   = column == 0
        let isRightEdge  = column == board.columns - 1
        let up           = index  -  board.columns
        let down         = index  +  board.columns
        let left         = index  -  1
        let right        = index  +  1
        
        var indices: [Int] = []
        indices.reserveCapacity(includeCorners ? 8 : 4)
        
        if !isTopEdge    && !isLeftEdge  && includeCorners { indices.append(up - 1)   }
        if !isTopEdge                                      { indices.append(up)       }
        if !isTopEdge    && !isRightEdge && includeCorners { indices.append(up + 1)   }
        if !isLeftEdge                                     { indices.append(left)     }
        if !isRightEdge                                    { indices.append(right)    }
        if !isBottomEdge && !isLeftEdge  && includeCorners { indices.append(down - 1) }
        if !isBottomEdge                                   { indices.append(down)     }
        if !isBottomEdge && !isRightEdge && includeCorners { indices.append(down + 1) }
        
        return indices
    }
}

extension GameController: CellProvider { }
