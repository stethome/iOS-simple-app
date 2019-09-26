//
//  LegendItemView.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 16/09/2019.
//  Copyright © 2019 StethoMe. All rights reserved.
//

import UIKit

final class LegendItemView: UIView, NibLoadableView {
    
    @IBOutlet weak var pointContainer: UIView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
}

// MARK: - Setup
private extension LegendItemView {
    func setupUI() {
        label.textColor = Constants.Colors.StethoMeDarkText
        label.font = .systemFont(ofSize: 15, weight: .light)
    }
}

// MARK: - Configuration
extension LegendItemView {
    func configure(withView view: UIView, text: String) {
        label.text = text
        view.embed(inView: pointContainer)
    }
}
