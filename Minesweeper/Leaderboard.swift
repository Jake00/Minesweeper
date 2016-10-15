//
//  Leaderboard.swift
//  Minesweeper
//
//  Created by Jake on 11/08/16.
//  Copyright © 2016 jrb. All rights reserved.
//

import Foundation

final class Leaderboard {
    
    private(set) var entries: [LeaderboardEntry] = []
    
    static let shared: Leaderboard = {
        let leaderboard = Leaderboard()
        let store = NSUserDefaults.standardUserDefaults()
        let entries = store.arrayForKey("leaderboard") as? [[String: AnyObject]] ?? []
        leaderboard.entries = entries.flatMap { LeaderboardEntry(dictionary: $0) }
        return leaderboard
    }()
    
    func addEntry(entry: LeaderboardEntry) {
        entries.append(entry)
        
        if self === Leaderboard.shared {
            let store = NSUserDefaults.standardUserDefaults()
            store.setObject(entries.map { $0.serialized }, forKey: "leaderboard")
        }
    }
}

// MARK: -

struct LeaderboardEntry {
    
    let name:     String
    let duration: NSTimeInterval
    let board:    Board
    
    init(name: String, duration: NSTimeInterval, board: Board) {
        self.name = name; self.duration = duration; self.board = board
    }
    
    init?(dictionary: [String: AnyObject]) {
        guard let name = dictionary["name"]     as? String,
            duration   = dictionary["duration"] as? NSTimeInterval,
            boardDict  = dictionary["board"]    as? [String: AnyObject],
            board      = Board(dictionary: boardDict)
            else { return nil }
        
        self.init(name: name, duration: duration, board: board)
    }
    
    var serialized: [String: AnyObject] {
        return ["name": name, "duration": duration, "board": board.serialized]
    }
}

// MARK: Equatable

extension LeaderboardEntry: Equatable { }

func == (lhs: LeaderboardEntry, rhs: LeaderboardEntry) -> Bool {
    return lhs.name     == rhs.name
        && lhs.duration == rhs.duration
        && lhs.board    == rhs.board
}

// MARK: Comparable

extension LeaderboardEntry: Comparable { }

func < (lhs: LeaderboardEntry, rhs: LeaderboardEntry) -> Bool {
    return lhs.duration < rhs.duration
}
