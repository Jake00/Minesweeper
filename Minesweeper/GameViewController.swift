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
        static let winTitle = NSLocalizedString("win_alert.title", value: "You win!", comment: "Title of an alert presented when you win.")
        static let winMessage = NSLocalizedString("win_alert.message", value: "Enter your name to save your time.", comment: "Message of an alert presented when you win, prompting for your name to save your time.")
        static let winSave = NSLocalizedString("win_alert.action.save", value: "Save", comment: "Save your name and time alert action")
        static let winNamePlaceholder = NSLocalizedString("win_alert.name_text_field_placeholder", value: "Name", comment: "Placeholder text for the winning name you wish to save.")
    }
    
    // MARK: - Game controller
    
    let game = GameController()
    var leaderboard: Leaderboard = .shared
    
    var difficulty: Board {
        get { return game.board }
        set { reset(usingNewBoard: newValue) }
    }
    
    func reset(usingNewBoard board: Board? = nil) {
        game.reset(board: board)
        dataSource.reset()
        startTime = nil
        collectionView.reloadData()
        updateBombsRemaining()
    }
    
    // MARK: - Time counter
    
    lazy var timeFormatter: NSDateComponentsFormatter = {
        let formatter = NSDateComponentsFormatter()
        formatter.zeroFormattingBehavior = .Pad
        formatter.allowedUnits = [.Minute, .Second]
        return formatter
    }()
    
    @IBOutlet weak var timeLabel: UILabel!
    private var timeCounter: NSTimer?
    var startTime: NSDate?
    
    dynamic func updateTime() {
        guard game.state == .Playing else { return }
        let duration = startTime.map { -$0.timeIntervalSinceNow } ?? 0
        timeLabel.text = timeFormatter.stringFromTimeInterval(duration)
    }
    
    // MARK: - Bombs remaining
    
    @IBOutlet weak var bombsRemainingLabel: UILabel!
    
    func updateBombsRemaining() {
        bombsRemainingLabel.text = dataSource.formatter.stringFromNumber(game.remainingMarkers)
    }
    
    // MARK: - View controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.provider = game
        game.delegate = self
        updateTime()
        updateBombsRemaining()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        timeCounter = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        timeCounter?.tolerance = 0.5
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timeCounter?.invalidate()
        timeCounter = nil
    }
    
    private var previousLayoutSize: CGSize = .zero
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if view.bounds.size != previousLayoutSize {
            previousLayoutSize = view.bounds.size
            collectionView.reloadData()
        }
    }
    
    // MARK: - Interface actions
    
    @IBAction func newGameButtonPressed(sender: UIBarButtonItem) {
        reset()
    }
    
    @IBAction func changeDifficultyButtonPressed(sender: UIBarButtonItem) {
        presentAlertController(title: Text.changeDifficultyTitle, style: .ActionSheet) { controller in
            controller.addAction(UIAlertAction(title: Text.changeDifficultyEasy)   { self.difficulty = .easy   })
            controller.addAction(UIAlertAction(title: Text.changeDifficultyMedium) { self.difficulty = .medium })
            controller.addAction(UIAlertAction(title: Text.changeDifficultyHard)   { self.difficulty = .hard   })
            controller.addAction(.cancel)
        }
    }
}

extension GameViewController: GameCollectionViewCellTouchEvents {
    
    func gameCollectionCellLongPressed(cell: GameCollectionViewCell) {
        if let indexPath = collectionView.indexPathForCell(cell) {
            game.mark(at: indexPath.item)
            collectionView.reloadItemsAtIndexPaths([indexPath])
            updateBombsRemaining()
        }
    }
}

// MARK: - Collection view delegate flow layout

extension GameViewController: UICollectionViewDelegateFlowLayout {
    
    var collectionViewContentSize: CGSize {
        return CGSize(
            width:  collectionView.frame.width  - collectionView.contentInset.left - collectionView.contentInset.right,
            height: collectionView.frame.height - collectionView.contentInset.top  - collectionView.contentInset.bottom)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(
            width:  floor(collectionViewContentSize.width  / CGFloat(game.board.columns)),
            height: floor(collectionViewContentSize.height / CGFloat(game.board.rows)))
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let cellWidth = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0)).width
        let underlap = collectionViewContentSize.width - CGFloat(Int(cellWidth) * game.board.columns)
        return UIEdgeInsets(top: 0, left: underlap / 2, bottom: 0, right: underlap / 2)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if startTime == nil {
            startTime = NSDate()
        }
        
        game.reveal(at: indexPath.item)
            .map     { NSIndexPath(forItem: $0, inSection: 0) }
            .flatMap { collectionView.cellForItemAtIndexPath($0) as? GameCollectionViewCell }
            .forEach { $0.reveal() }
    }
    
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let cell = game.cells[indexPath.item]
        return game.state == .Playing && cell.canReveal && !cell.isMarked
    }
}

// MARK: - Game controller delegate

extension GameViewController: GameControllerDelegate {
    
    func gameDidWin(controller: GameController) {
        let duration = startTime.map { -$0.timeIntervalSinceNow } ?? 0
        presentAlertController(title: Text.winTitle, message: Text.winMessage) { controller in
            controller.addAction(UIAlertAction(title: Text.winSave) {
                guard let name = controller.textFields?.first?.text else { return }
                self.leaderboard.addEntry(LeaderboardEntry(name: name, duration: duration, board: self.game.board))
            })
            controller.addAction(.cancel)
            controller.addTextFieldWithConfigurationHandler { textField in
                textField.placeholder = Text.winNamePlaceholder
            }
        }
    }
    
    func gameDidLose(controller: GameController, byRevealingBombAtIndex index: Int) {
        dataSource.losingIndex = index
        dataSource.revealBombs = true
        collectionView.reloadData()
    }
}
