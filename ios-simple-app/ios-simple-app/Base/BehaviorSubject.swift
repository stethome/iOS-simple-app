//
//  BehaviorSubject.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 24/09/2019.
//  Copyright © 2019 StethoMe. All rights reserved.
//

import Foundation

/// Updates it's subscriber on assigning of 'action' and when 'onNext' event is fired. Mimics 'BehaviourSubject' from RxSwift library.
class BehaviorSubject<T> {
    private var _value: T
    var value: T {
        return _value
    }
    
    var action: ((T) -> Void)? {
        didSet {
            action?(value)
        }
    }
    
    init(value: T) {
        self._value = value
    }
    
    func onNext(_ param: T) {
        _value = param
        action?(param)
    }
}
