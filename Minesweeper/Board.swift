//
//  Board.swift
//  Minesweeper
//
//  Created by Jake on 22/08/16.
//  Copyright © 2016 jrb. All rights reserved.
//

struct Board {
    let rows:    Int
    let columns: Int
    let bombs:   Int
    var squares: Int { return rows * columns }
    
    // MARK: Indices
    
    func index(for row: Int, column: Int) -> Int {
        return row * columns + column
    }
    
    func coordinate(for index: Int) -> (row: Int, column: Int) {
        return (index / rows, index % columns)
    }
    
    func adjacentIndices(for index: Int) -> [Int] {
        let (row, column) = coordinate(for: index)
        let isTopEdge    = row    == 0
        let isBottomEdge = row    == rows - 1
        let isLeftEdge   = column == 0
        let isRightEdge  = column == columns - 1
        let up           = index  -  columns
        let down         = index  +  columns
        let left         = index  -  1
        let right        = index  +  1
        
        var indices: [Int] = []
        indices.reserveCapacity(8)
        
        /*
         1 2 3
         4   5
         6 7 8
         */
        if !isTopEdge    && !isLeftEdge  { indices.append(up - 1)   } /* 1 */
        if !isTopEdge                    { indices.append(up)       } /* 2 */
        if !isTopEdge    && !isRightEdge { indices.append(up + 1)   } /* 3 */
        if !isLeftEdge                   { indices.append(left)     } /* 4 */
        if !isRightEdge                  { indices.append(right)    } /* 5 */
        if !isBottomEdge && !isLeftEdge  { indices.append(down - 1) } /* 6 */
        if !isBottomEdge                 { indices.append(down)     } /* 7 */
        if !isBottomEdge && !isRightEdge { indices.append(down + 1) } /* 8 */
        
        return indices
    }
    
    // MARK: Predefined
    
    static let easy   = Board(rows: 8,  columns: 8,  bombs: 5)
    static let medium = Board(rows: 8,  columns: 8,  bombs: 10)
    static let hard   = Board(rows: 12, columns: 12, bombs: 40)
    
    // MARK: Init
    
    init(rows: Int, columns: Int, bombs: Int) {
        self.rows = rows; self.columns = columns; self.bombs = bombs
    }
    
    init?(dictionary: [String: AnyObject]) {
        guard let rows = dictionary["rows"]    as? Int,
            columns    = dictionary["columns"] as? Int,
            bombs      = dictionary["bombs"]   as? Int
            else { return nil }
        
        self.init(rows: rows, columns: columns, bombs: bombs)
    }
    
    var serialized: [String: AnyObject] {
        return ["rows": rows, "columns": columns, "bombs": bombs]
    }
}

// MARK: Equatable

extension Board: Equatable { }

func == (lhs: Board, rhs: Board) -> Bool {
    return lhs.rows    == rhs.rows
        && lhs.columns == rhs.columns
        && lhs.bombs   == rhs.bombs
}
