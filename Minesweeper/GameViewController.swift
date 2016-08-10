//
//  GameViewController.swift
//  Minesweeper
//
//  Created by Jake on 8/08/16.
//  Copyright © 2016 jrb. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!
    @IBOutlet var dataSource: GameCollectionViewDataSource!
    
    struct Text {
        static let changeDifficultyTitle  = NSLocalizedString("change_difficulty_action_sheet.title",         value: "Change difficulty", comment: "Title of an action sheet displayed for changing the difficulty setting of the game.")
        static let changeDifficultyHard   = NSLocalizedString("change_difficulty_action_sheet.action.hard",   value: "Hard",   comment: "Set game to 'Hard' difficulty setting.")
        static let changeDifficultyMedium = NSLocalizedString("change_difficulty_action_sheet.action.medium", value: "Medium", comment: "Set game to 'Medium / moderate' difficulty setting.")
        static let changeDifficultyEasy   = NSLocalizedString("change_difficulty_action_sheet.action.easy",   value: "Easy",   comment: "Set game to 'Easy' difficulty setting.")
        static let changeDifficultyCancel = NSLocalizedString("change_difficulty_action_sheet.action.Cancel", value: "Cancel", comment: "Cancel action which will not set a new difficulty setting.")
    }
    
    // MARK: - Game controller
    
    let controller = GameController()
    
    var difficulty: GameController.Board {
        get { return controller.board }
        set { reset(usingNewBoard: newValue) }
    }
    
    func reset(usingNewBoard board: GameController.Board?) {
        if let board = board {
            controller.resetBoard(difficulty: board)
        } else {
            controller.reset()
        }
        dataSource.reset()
        collectionView.reloadData()
    }
    
    // MARK: - View controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.provider = controller
        controller.delegate = self
    }
    
    // MARK: - Interface actions
    
    @IBAction func newGameButtonPressed(sender: UIBarButtonItem) {
        reset(usingNewBoard: nil)
    }
    
    @IBAction func changeDifficultyButtonPressed(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: Text.changeDifficultyTitle, message: nil, preferredStyle: .ActionSheet)
        let addAction: (GameController.Board?, String) -> Void = { difficulty, title in
            alertController.addAction(UIAlertAction(title: title, style: .Default) { _ in
                _ = difficulty.map { self.difficulty = $0 }
                })
        }
        addAction(.easy,   Text.changeDifficultyEasy)
        addAction(.medium, Text.changeDifficultyMedium)
        addAction(.hard,   Text.changeDifficultyHard)
        alertController.addAction(UIAlertAction(title: Text.changeDifficultyCancel, style: .Cancel, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
}

// MARK: - Collection view delegate flow layout

extension GameViewController: UICollectionViewDelegateFlowLayout {
    
    var collectionViewContentSize: CGSize {
        return CGSize(
            width: collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right,
            height: collectionView.frame.height - collectionView.contentInset.top - collectionView.contentInset.bottom)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(
            width:  floor(collectionViewContentSize.width  / CGFloat(controller.board.columns)),
            height: floor(collectionViewContentSize.height / CGFloat(controller.board.rows)))
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let cellWidth = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0)).width
        let underlap = collectionViewContentSize.width - CGFloat(Int(cellWidth) * controller.board.columns)
        return UIEdgeInsets(top: 0, left: underlap / 2, bottom: 0, right: underlap / 2)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        controller.reveal(atIndex: indexPath.row)
            .map     { NSIndexPath(forItem: $0, inSection: 0) }
            .flatMap { collectionView.cellForItemAtIndexPath($0) as? GameCollectionViewCell }
            .forEach { cell in
                cell.isRevealed = true
        }
    }
}

// MARK: - Game controller delegate

extension GameViewController: GameControllerDelegate {
    
    func gameDidWin(controller: GameController) {
        
    }
    
    func gameDidLose(controller: GameController, byRevealingBombAtIndex index: Int) {
        dataSource.losingIndex = index
        dataSource.revealBombs = true
    }
}
