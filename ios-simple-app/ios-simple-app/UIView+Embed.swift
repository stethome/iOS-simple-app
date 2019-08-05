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
}
