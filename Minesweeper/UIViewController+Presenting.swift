//
//  UIViewController+Presenting.swift
//  Minesweeper
//
//  Created by Jake on 10/08/16.
//  Copyright © 2016 jrb. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentAlertController(title title: String? = nil, message: String? = nil, style: UIAlertControllerStyle = .Alert, configure: UIAlertController -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        configure(alertController)
        presentViewController(alertController, animated: true, completion: nil)
    }
}

extension UIAlertAction {
    
    @nonobjc static let cancelTitle = NSLocalizedString("cancel_action", value: "Cancel", comment: "Cancel action text shared by dialogs.")
    
    static var cancel: UIAlertAction {
        return UIAlertAction(title: cancelTitle, style: .Cancel, handler: nil)
    }
    
    convenience init(title: String?, handler: (() -> ())?) {
        self.init(title: title, style: .Default, handler: { _ in handler?() })
    }
}
