//
//  String+Localized.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 24/09/2019.
//  Copyright © 2019 StethoMe. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
