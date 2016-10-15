//
//  GameCell.swift
//  Minesweeper
//
//  Created by Jake on 8/08/16.
//  Copyright © 2016 jrb. All rights reserved.
//

import Foundation

struct GameCell {
    
    enum State {
        case Covered
        case Revealed
        case Bomb
    }
    
    var state: State = .Covered
    
    var adjacentBombs: Int = 0
    
    var canReveal: Bool {
        return state == .Covered
    }
    
    var isBomb: Bool {
        return state == .Bomb
    }
    
    var isRevealed: Bool {
        return state == .Revealed
    }
}
