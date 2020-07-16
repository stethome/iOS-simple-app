//
//  NibLoadableView.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 23/09/2019.
//  Copyright © 2019 StethoMe. All rights reserved.
//

import UIKit

public protocol NibLoadableView: class {
    static func fromNib() -> Self
}

extension NibLoadableView where Self: UIView {
    public static func fromNib() -> Self {
        let view = Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)
        return view?[0] as! Self
    }
}
