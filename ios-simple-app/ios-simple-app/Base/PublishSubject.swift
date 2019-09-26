//
//  Action.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 24/09/2019.
//  Copyright © 2019 StethoMe. All rights reserved.
//

import Foundation

/// Updates it's subscriber when 'onNext' event is fired. Mimics 'PublishSubject' from RxSwift library.
class PublishSubject<T> {
    
    var action: ((T) -> Void)?
    
    init() {}
    
    func onNext(_ param: T) {
        action?(param)
    }
}
