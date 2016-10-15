//
//  GameCollectionViewDataSource.swift
//  Minesweeper
//
//  Created by Jake on 9/08/16.
//  Copyright © 2016 jrb. All rights reserved.
//

import UIKit

protocol CellProvider {
    var cells: [BoardCell] { get }
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
        revealBombs = false
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
        
        cell.numberLabel.textColor = cellModel.adjacentBombs.color
        cell.numberLabel.text = cellModel.isMarked ? flagSymbol
            : cellModel.isBomb ? bombSymbol
            : cellModel.adjacentBombs == 0 ? nil
            : formatter.stringFromNumber(cellModel.adjacentBombs)
        
        let isCovered = !cellModel.isRevealed && !(cellModel.isBomb && revealBombs)
        cell.isMarked = cellModel.isMarked
        cell.drawsBevel         = isCovered ||  cellModel.isMarked
        cell.numberLabel.hidden = isCovered && !cellModel.isMarked
        cell.backgroundColor    = indexPath.row == losingIndex ? .redColor() : .midGrayColor()
        
        return cell
    }
}

private extension Int {
    
    var color: UIColor {
        switch self {
        case 1:  return .blueColor()
        case 2:  return .greenColor()
        case 3:  return .redColor()
        case 4:  return .purpleColor()
        case 5:  return .orangeColor()
        case 6:  return .brownColor()
        case 7:  return .blackColor()
        case 8:  return .grayColor()
        default: return .blackColor()
        }
    }
}
