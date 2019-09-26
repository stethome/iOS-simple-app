//
//  View.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 25/09/2019.
//  Copyright © 2019 StethoMe. All rights reserved.
//

import UIKit.UIView

/// Simple base class for views that show with nice alpha transition.
class View: UIView {
    
    func show() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.alpha = 1.0
        }
    }
    
    func hide(completionHandler: (() -> Void)?) {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.alpha = 0.0
            }, completion: { _ in
                completionHandler?()
        })
    }
}
