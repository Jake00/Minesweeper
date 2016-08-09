//
//  GameCollectionViewCell.swift
//  Minesweeper
//
//  Created by Jake on 9/08/16.
//  Copyright © 2016 jrb. All rights reserved.
//

import UIKit

class GameCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var topBevel:    UIView!
    @IBOutlet weak var upperBevel:  UIView!
    @IBOutlet var bevels: [UIView]!
    
    var isRevealed: Bool = false {
        didSet {
            numberLabel.hidden = !isRevealed
            bevels.forEach { $0.hidden = isRevealed }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let aspectRatio = bounds.height / bounds.width
        let bevelWidth  = aspectRatio * 2
        let bevelHeight = aspectRatio * 2
        topBevel.translatesAutoresizingMaskIntoConstraints = true
        topBevel.frame = CGRect(
            x: bevelWidth,
            y: bevelHeight,
            width:  contentView.bounds.width  - bevelWidth  * 2,
            height: contentView.bounds.height - bevelHeight * 2.3)
        
        let mask = upperBevel.layer.mask as? CAShapeLayer ?? {
            let m = CAShapeLayer(); upperBevel.layer.mask = m; return m
            }()
        mask.path = trianglePath.CGPath
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
