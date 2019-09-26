//
//  PoweredByStethoMeLabel.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 17/09/2019.
//  Copyright © 2019 StethoMe. All rights reserved.
//

import UIKit

struct PoweredByStethoMeLabel {
    static func getText() -> NSAttributedString {
        let fontSize: CGFloat = 10
        let attrText = NSMutableAttributedString(string: "Powered by ", attributes:
            [NSAttributedString.Key.foregroundColor: Constants.Colors.StethoMePoweredBy,
             NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize, weight: .light)])
        let attrText2 = NSAttributedString(string: "StethoMe®", attributes:
            [NSAttributedString.Key.foregroundColor: Constants.Colors.StethoMePoweredBy,
             NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize, weight: .light)])
        attrText.append(attrText2)
        return attrText
    }
}
