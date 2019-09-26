//
//  InvalidPointsSummaryView.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 08/08/2019.
//  Copyright © 2019 StethoMe. All rights reserved.
//

import UIKit
import StethoMeSDK

final class InvalidPointsSummaryView: UIView, NibLoadableView {
    
    @IBOutlet weak var shadow: UIView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var invalidPointsStackView: UIStackView!
    @IBOutlet weak var repeatPointsLabel: UILabel!
    @IBOutlet weak var repeatPointsHintLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var poweredByStethoMeLabel: UILabel!
    
    var yesTappedHandler: (() -> Void)?
    var noTappedHandler: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    @IBAction func yesTapped() {
        yesTappedHandler?()
    }
    
    @IBAction func noTapped() {
        noTappedHandler?()
    }
}

// MARK: - Setup
private extension InvalidPointsSummaryView {
    func setupUI() {
        setupLabels()
        bottomView.backgroundColor = Constants.Colors.StethoMeAccent
        container.backgroundColor = Constants.Colors.StethoMeSecondary
        container.layer.cornerRadius = 5.0
        container.layer.masksToBounds = true
        
        shadow.layer.cornerRadius = 5.0
        shadow.layer.shadowColor = UIColor.black.cgColor
        shadow.layer.shadowRadius = 5.0
        shadow.layer.shadowOpacity = 0.2
        shadow.layer.shadowOffset = CGSize(width: 0, height: 10)
    }
    
    func setupLabels() {
        poweredByStethoMeLabel.attributedText = PoweredByStethoMeLabel.getText()
        repeatPointsLabel.textColor = UIColor.white
        repeatPointsLabel.font = .systemFont(ofSize: 25, weight: .light)
        repeatPointsHintLabel.textColor = UIColor.white
        repeatPointsHintLabel.font = .systemFont(ofSize: 15, weight: .light)
    }
    
    func setupButtons() {
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: Constants.Colors.StethoMeAccent,
                                                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .light)]
        
        let yesTitle = NSAttributedString(string: "yes".localized.uppercased(), attributes: attributes)
        yesButton.setAttributedTitle(yesTitle, for: .normal)
        
        let noTitle = NSAttributedString(string: "no".localized.uppercased(), attributes: attributes)
        noButton.setAttributedTitle(noTitle, for: .normal)
    }
}

// MARK: - Configuration
extension InvalidPointsSummaryView {
    func configure(withInvalidPoints invalidPoints: [SMExaminationPointFailedReason]) {
        invalidPointsStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        
        repeatPointsLabel.text = "invalid_points_repeat".localized
        repeatPointsHintLabel.text = "invalid_points_hint".localized
        setupButtons()
        
        let invalidCount = invalidPoints.filter({ $0 == .notValid }).count
        let notRecordedCount = invalidPoints.filter({ $0 == .noRecording }).count
        
        if invalidCount > 0 {
            let countView = InvalidPointsCountView.fromNib()
            countView.configure(with: .invalid(String(format: "invalid_points_invalid_first_line".localized, invalidCount), "invalid_points_invalid_second_line".localized),
                                count: invalidCount)
            invalidPointsStackView.addArrangedSubview(countView)
        }
        
        if notRecordedCount > 0 {
            let countView = InvalidPointsCountView.fromNib()
            countView.configure(with: .noRecording(String(format: "invalid_points_no_recordings".localized, notRecordedCount)),
                                count: notRecordedCount)
            invalidPointsStackView.addArrangedSubview(countView)
        }
    }
}
