//
//  GameCollectionViewDataSource.swift
//  Minesweeper
//
//  Created by Jake on 9/08/16.
//  Copyright © 2016 jrb. All rights reserved.
//

import UIKit

protocol CellProvider {
    var cells: [GameCell] { get }
}

class GameCollectionViewDataSource: NSObject {
    
    var provider: CellProvider?
    let formatter = NSNumberFormatter()
    let bombSymbol = NSLocalizedString("bomb_symbol", value: "💣", comment: "The bomb character displayed when the game has been lost.")
    let flagSymbol = NSLocalizedString("marked_symbol", value: "🚩", comment: "The flag character displayed when a square has been marked as a bomb.")
    
    var losingIndex: Int? = nil
    var revealBombs: Bool = false
    
    func reset() {
        losingIndex = nil
        revealBombs = true
    }
}

extension GameCollectionViewDataSource: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return provider?.cells.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(GameCollectionViewCell), forIndexPath: indexPath) as! GameCollectionViewCell
        guard let controller = provider else { return cell }
        let cellModel = controller.cells[indexPath.item]
        
        cell.numberLabel.text = cellModel.isBomb ? bombSymbol
            : cellModel.adjacentBombs == 0 ? nil
            : formatter.stringFromNumber(cellModel.adjacentBombs)
        cell.isRevealed         = cellModel.isRevealed || (cellModel.isBomb && revealBombs)
        cell.backgroundColor    = indexPath.row == losingIndex ? .redColor() : .midGrayColor()
        return cell
    }
}

extension UIColor {
    
    class func midGrayColor() -> UIColor {
        return UIColor(white: 0.69, alpha: 1)
    }
}
