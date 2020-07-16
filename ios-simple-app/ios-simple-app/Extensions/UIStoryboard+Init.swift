//
//  UIStoryboard+Init.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 16/07/2020.
//  Copyright © 2020 StethoMe. All rights reserved.
//

import UIKit

enum StoryboardType: String {
    case Main
}

extension UIStoryboard {
    convenience init(_ type: StoryboardType) {
        self.init(name: type.rawValue, bundle: nil)
    }
}
