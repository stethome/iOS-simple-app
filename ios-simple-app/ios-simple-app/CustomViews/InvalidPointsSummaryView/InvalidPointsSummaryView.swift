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
        
        let yesTitle = NSAttributedString(string: "button_agree".localized.uppercased(), attributes: attributes)
        yesButton.setAttributedTitle(yesTitle, for: .normal)
        
        let noTitle = NSAttributedString(string: "button_disagree".localized.uppercased(), attributes: attributes)
        noButton.setAttributedTitle(noTitle, for: .normal)
    }
}

// MARK: - Configuration
extension InvalidPointsSummaryView {
    public func configure(withInvalidPoints invalidPoints: [SMExaminationPointFailedReason]) {
        invalidPointsStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        
        repeatPointsLabel.text = "summary_title_redo_wrong_points".localized
        repeatPointsHintLabel.text = "summary_subtitle_redo_wrong_points".localized
        setupButtons()
        
        let invalidCount = invalidPoints.filter({ $0 == .notValid }).count
        let notRecordedCount = invalidPoints.filter({ $0 == .noRecording }).count
        
        if invalidCount > 0 {
            let countView = InvalidPointsCountView.fromNib()
            let text: String
            switch invalidCount {
            case 1:
                text = String(format: "summary_error_rr_or_noise_one".localized, invalidCount)
            case 2...4:
                text = String(format: "summary_error_rr_or_noise_few".localized, invalidCount)
            default:
                text = String(format: "summary_error_rr_or_noise_other".localized, invalidCount)
            }
            countView.configure(with: .invalid(text, "summary_error_rr_or_noise2".localized),
                                count: invalidCount)
            invalidPointsStackView.addArrangedSubview(countView)
        }
        
        if notRecordedCount > 0 {
            let countView = InvalidPointsCountView.fromNib()
            let text: String
            switch notRecordedCount {
            case 1:
                text = String(format: "summary_error_not_recorded_one".localized, notRecordedCount)
            case 2...4:
                text = String(format: "summary_error_not_recorded_few".localized, notRecordedCount)
            default:
                text = String(format: "summary_error_not_recorded_other".localized, notRecordedCount)
            }
            
            countView.configure(with: .noRecording(text),
                                count: notRecordedCount)
            invalidPointsStackView.addArrangedSubview(countView)
        }
    }
}

