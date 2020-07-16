//
//  Constants.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 23/09/2019.
//  Copyright © 2019 StethoMe. All rights reserved.
//

import UIKit.UIColor

struct Constants {
    // TODO (MJ): IN PRODUCTION APP, PUT 'YOUR' TOKEN HERE. THIS IS JUST FOR TESTING PURPOSES. ANY VISITS MADE USING THIS TOKEN COULD BE REMOVED AT ANY TIME.
    static let clientToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpYXQiOjE1OTQ4OTM3OTQsInJvbGVzIjpbIlJPTEVfQ0xJRU5UIl0sInZlbmRvcl9pZCI6IjVjOWNlNTI5N2QyY2MiLCJ2ZW5kb3IiOiJTdGV0aG9NZSIsInR5cGUiOiJjbGllbnQiLCJqdGkiOiI1ZjEwMjVlMmMzZTMwOS4wNDIzMjY2NSIsImNsYWltcyI6W10sImV4cCI6MTU5NDg5NzM5NH0.6Ehpw_XIWMOpu0UWIuvGZgQ5O7mTbiuEnmLhD1I1mfIPLrbZwITXt5v43Q7TK-jk6KkFlpWfVflSHIRxw73ZtA"
    
    struct Colors {
        static let StethoMeAccent = UIColor(red: 0, green: 159.0 / 255.0, blue: 227.0 / 255.0, alpha: 1.0)
        static let StethoMeSecondary = UIColor(red: 237.0 / 255.0, green: 237.0 / 255.0, blue: 237.0 / 255.0, alpha: 1.0)
        static let StethoMeRed = UIColor(red: 205.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
        static let StethoMeGreen = UIColor(red: 0.0 / 255.0, green: 205.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
        static let StethoMeDarkText = UIColor(white: 74.0 / 255, alpha: 1.0)
        static let StethoMePoweredBy = UIColor(white: 150.0 / 255.0, alpha: 1.0)
    }
}
