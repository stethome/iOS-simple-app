//
//  BodySwitchButton.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 09/08/2019.
//  Copyright © 2019 StethoMe. All rights reserved.
//

import UIKit
import StethoMeSDK

final class BodySwitchButton: UIView, NibLoadableView {
    
    @IBOutlet weak var bodySideLabel: UILabel!
    @IBOutlet weak var leftArrowImage: UIImageView!
    @IBOutlet weak var rightArrowImage: UIImageView!
    
    private weak var examination: SMLungsExamination?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
}

// MARK: - Setup
private extension BodySwitchButton {
    func setupUI() {
        setupLabel()
        setupImages()
        showSide(.front)
        
        backgroundColor = Constants.Colors.StethoMeAccent
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tapRecognizer)
    }
    
    @objc func viewTapped() {
        examination?.switchBodySides()
    }
    
    func setupLabel() {
        bodySideLabel.textColor = UIColor.white
        bodySideLabel.font = .systemFont(ofSize: 20, weight: .light)
    }
    
    func setupImages() {
        leftArrowImage.image = UIImage(named: "arrow_left")?.withRenderingMode(.alwaysTemplate)
        leftArrowImage.tintColor = UIColor.white
        rightArrowImage.image = UIImage(named: "arrow_right")?.withRenderingMode(.alwaysTemplate)
        rightArrowImage.tintColor = UIColor.white
    }
    
    func showSide(_ side: SMBodySide) {
        switch side {
        case .front:
            bodySideLabel.text = "body_side_front".localized
        case .back:
            bodySideLabel.text = "body_side_back".localized
        }
    }
}

// MARK: - Configuration
extension BodySwitchButton {
    func configure(withExamination examination: SMLungsExamination?) {
        self.examination = examination
        showSide(.front)
        
        examination?.bodySideChangedHandler.addEventListener(SMAction<SMBodySide>(action: { [weak self] newBodySide in
            DispatchQueue.main.async { [weak self] in
                self?.showSide(newBodySide)
            }
        }))
    }
}
