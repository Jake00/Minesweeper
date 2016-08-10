//
//  Leaderboard.swift
//  Minesweeper
//
//  Created by Jake on 11/08/16.
//  Copyright © 2016 jrb. All rights reserved.
//

import Foundation

struct LeaderboardEntry: Comparable {
    
    let name:     String
    let duration: NSTimeInterval
    let board:    GameController.Board
    
    init(name: String, duration: NSTimeInterval, board: GameController.Board) {
        self.name = name; self.duration = duration; self.board = board
    }
    
    init?(dictionary: [String: AnyObject]) {
        guard let name = dictionary["name"]     as? String,
            duration   = dictionary["duration"] as? NSTimeInterval,
            boardDict  = dictionary["board"]    as? [String: AnyObject],
            board      = GameController.Board(dictionary: boardDict)
            else { return nil }
        self.init(name: name, duration: duration, board: board)
    }
    
    var asDictionary: [String: AnyObject] {
        return ["name": name, "duration": duration, "board": board.asDictionary]
    }
}

func == (lhs: LeaderboardEntry, rhs: LeaderboardEntry) -> Bool {
    return lhs.name     == rhs.name
        && lhs.duration == rhs.duration
        && lhs.board    == rhs.board
}

func < (lhs: LeaderboardEntry, rhs: LeaderboardEntry) -> Bool {
    return lhs.duration < rhs.duration
}

final class Leaderboard {
    
    private(set) var entries: [LeaderboardEntry] = []
    
    static let shared: Leaderboard = {
        let leaderboard = Leaderboard()
        let store    = NSUserDefaults.standardUserDefaults()
        let entries  = store.arrayForKey("leaderboard") as? [[String: AnyObject]] ?? []
        leaderboard.entries = entries.flatMap { LeaderboardEntry(dictionary: $0) }
        return leaderboard
    }()
    
    func addEntry(entry: LeaderboardEntry) {
        entries.append(entry)
        
        if self === Leaderboard.shared {
            let store = NSUserDefaults.standardUserDefaults()
            store.setObject(entries.map { $0.asDictionary }, forKey: "leaderboard")
        }
    }
}
