//
//  GameCollectionViewCell.swift
//  Minesweeper
//
//  Created by Jake on 9/08/16.
//  Copyright © 2016 jrb. All rights reserved.
//

import UIKit

@objc protocol GameCollectionViewCellTouchEvents {
    func gameCollectionCellLongPressed(cell: GameCollectionViewCell)
}

class GameCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var numberLabel: UILabel!
    
    var isMarked = false
    
    func reveal() {
        numberLabel.hidden = false
        drawsBevel = isMarked
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:))))
    }
    
    dynamic func longPressed(sender: UILongPressGestureRecognizer) {
        let sel = #selector(GameCollectionViewCellTouchEvents.gameCollectionCellLongPressed(_:))
        UIApplication.sharedApplication().sendAction(sel, to: nil, from: self, forEvent: nil)
    }
    
    override var highlighted: Bool {
        get { return super.highlighted }
        set {
            super.highlighted = newValue
            drawsBevel = !newValue
        }
    }
    
    var drawsBevel = true {
        didSet { setNeedsDisplay() }
    }
    
    override func drawRect(rect: CGRect) {
        guard drawsBevel else { return }
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, UIColor.bevelGrayColor().CGColor)
        CGContextFillRect(context, bounds)
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextAddPath(context, trianglePath.CGPath)
        CGContextFillPath(context)
        CGContextSetFillColorWithColor(context, UIColor.midGrayColor().CGColor)
        let bevel = bounds.height / bounds.width * 2
        CGContextFillRect(context, CGRect(
            x: bevel,
            y: bevel,
            width:  contentView.bounds.width  - bevel * 2.3,
            height: contentView.bounds.height - bevel * 2.3))
    }
    
    var trianglePath: UIBezierPath {
        /* ___
           | /
           |/  */
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: -1, y: -1))
        path.addLineToPoint(CGPoint(x: -1, y: contentView.bounds.height + 1))
        path.addLineToPoint(CGPoint(x: contentView.bounds.width, y: -1))
        path.closePath()
        return path
    }
}
