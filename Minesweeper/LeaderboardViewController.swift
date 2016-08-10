//
//  LeaderboardViewController.swift
//  Minesweeper
//
//  Created by Jake on 11/08/16.
//  Copyright © 2016 jrb. All rights reserved.
//

import UIKit

class LeaderboardViewController: UITableViewController {
    
    var leaderboard: Leaderboard = .shared
    
    lazy var timeFormatter: NSDateComponentsFormatter = {
        let formatter = NSDateComponentsFormatter()
        formatter.unitsStyle = .Abbreviated
        formatter.allowedUnits = [.Minute, .Second]
        return formatter
    }()
    
    func entries(difficulty board: GameController.Board) -> [LeaderboardEntry] {
        return leaderboard.entries.filter { $0.board == board }
    }
    
    var otherBoardSizeEntries: [LeaderboardEntry] {
        return leaderboard.entries.filter { $0.board != .easy && $0.board != .medium && $0.board != .hard }
    }
    
    var empties: [Bool] {
        return [
            entries(difficulty: .easy),
            entries(difficulty: .medium),
            entries(difficulty: .hard),
            otherBoardSizeEntries
            ].map { $0.isEmpty }
    }
    
    func entries(forSection section: Int) -> [LeaderboardEntry] {
        func _entries(section: Int) -> [LeaderboardEntry] {
            switch section {
            case 0:
                let easy = entries(difficulty: .easy)
                return !easy.isEmpty ? easy : _entries(section + 1)
            case 1:
                let medium = entries(difficulty: .medium)
                return !medium.isEmpty ? medium : _entries(section + 1)
            case 2:
                let hard = entries(difficulty: .hard)
                return !hard.isEmpty ? hard : _entries(section + 1)
            case 3:
                return otherBoardSizeEntries
            default:
                return []
            }
        }
        
        /* Skip over sections with empty elements */
        let baseOffset = empties.reduce((0, true)) { !$0.1 ? $0 : $1 ? ($0.0 + 1, true) : ($0.0, false) }.0
        let offset = empties[baseOffset...(section + baseOffset)].reduce(0) { $1 ? $0 + 1 : $0 }
        return _entries(section + baseOffset + offset)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return empties.reduce(0) { $1 ? $0 + 1 : $0 }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries(forSection: section).count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch entries(forSection: section).first?.board {
        case nil:                          return nil
        case GameController.Board.easy?:   return GameViewController.Text.changeDifficultyEasy
        case GameController.Board.medium?: return GameViewController.Text.changeDifficultyMedium
        case GameController.Board.hard?:   return GameViewController.Text.changeDifficultyHard
        default: return NSLocalizedString("leaderboards.custom_board_size", value: "Custom", comment: "A non standard board size")
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LeaderboardCell", forIndexPath: indexPath)
        let entry = entries(forSection: indexPath.section)[indexPath.row]
        
        cell.textLabel?.text = entry.name
        cell.detailTextLabel?.text = timeFormatter.stringFromTimeInterval(entry.duration)
        
        return cell
    }
}
