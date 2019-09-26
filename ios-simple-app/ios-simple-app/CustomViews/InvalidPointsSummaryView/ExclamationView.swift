//
//  ExclamationView.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 17/09/2019.
//  Copyright © 2019 StethoMe. All rights reserved.
//

import UIKit

final class ExclamationView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.width / 2.0
    }
}

// MARK: - Setup
private extension ExclamationView {
    func setupUI() {
        backgroundColor = Constants.Colors.StethoMeRed
        layer.cornerRadius = frame.width / 2.0
        
        let image = UIImage(named: "exclamation_mark")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.center(inView: self, multiplier: 0.8)
    }
}
