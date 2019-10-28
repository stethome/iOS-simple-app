//
//  DeviceSearchingIndicator.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 12/06/2019.
//  Copyright © 2019 StethoMe. All rights reserved.
//

import UIKit

final class DeviceSearchingIndicator: View, NibLoadableView {
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func show() {
        indicator.startAnimating()
        super.show()
    }
    
    override func hide(completionHandler: (() -> Void)?) {
        super.hide { [weak self] in
            self?.indicator.stopAnimating()
            completionHandler?()
        }
    }
}

// MARK: - Setup
private extension DeviceSearchingIndicator {
    func setupUI() {
        self.alpha = 0.0
        setupTitle()
    }
    
    func setupTitle() {
        title.font = .systemFont(ofSize: 18, weight: .light)
        title.textColor = Constants.Colors.StethoMeDarkText
        title.text = "dialog_connect_in_progress_title".localized
    }
}
