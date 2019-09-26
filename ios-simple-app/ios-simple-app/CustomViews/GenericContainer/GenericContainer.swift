//
//  GenericContainer.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 25/06/2019.
//  Copyright © 2019 StethoMe. All rights reserved.
//

import UIKit

class GenericContainer: UIView, NibLoadableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
}

// MARK: - Setup
private extension GenericContainer {
    func setupUI() {
        layer.cornerRadius = 5.0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 10)
    }
}
