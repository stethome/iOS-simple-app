//
//  UIView+Embed.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 05/08/2019.
//  Copyright © 2019 StethoMe. All rights reserved.
//

import UIKit.UIView

extension UIView {
    func embed(inView view: UIView) {
        view.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func center(inView view: UIView, multiplier: CGFloat = 1.0) {
        view.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal,
                           toItem: view, attribute: .centerX,
                           multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal,
                           toItem: view, attribute: .centerY,
                           multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal,
                           toItem: view, attribute: .width,
                           multiplier: multiplier, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal,
                           toItem: view, attribute: .height,
                           multiplier: multiplier, constant: 0).isActive = true
    }
}
