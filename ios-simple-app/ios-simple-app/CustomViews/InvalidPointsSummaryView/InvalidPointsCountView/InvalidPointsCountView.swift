//
//  InvalidPointsCountView.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 08/08/2019.
//  Copyright © 2019 StethoMe. All rights reserved.
//

import UIKit

final class InvalidPointsCountView: UIView, NibLoadableView {
    
    enum InvalidPointType {
        case invalid(String, String)
        case noRecording(String)
    }
    
    @IBOutlet weak var pointsCountContainer: UIView!
    @IBOutlet weak var pointsCountLabel: UILabel!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
}

// MARK: - Setup
private extension InvalidPointsCountView {
    func setupUI() {
        setupCountCircle()
        setupLabels()
    }
    
    func setupCountCircle() {
        let ring = RingView()
        ring.configure(fillColor: Constants.Colors.StethoMeDarkText,
                       lineWidth: .fixed(1.5),
                       percentageFilled: 100.0)
        ring.embed(inView: pointsCountContainer)
        
        pointsCountLabel.textColor = Constants.Colors.StethoMeDarkText
        pointsCountLabel.font = .systemFont(ofSize: 40, weight: .light)
        
        let exclamationMark = ExclamationView()
        exclamationMark.translatesAutoresizingMaskIntoConstraints = false
        pointsCountContainer.addSubview(exclamationMark)
        exclamationMark.topAnchor.constraint(equalTo: pointsCountContainer.topAnchor, constant: 5).isActive = true
        exclamationMark.trailingAnchor.constraint(equalTo: pointsCountContainer.trailingAnchor, constant: 5).isActive = true
        exclamationMark.widthAnchor.constraint(equalToConstant: 20).isActive = true
        exclamationMark.heightAnchor.constraint(equalTo: exclamationMark.widthAnchor, constant: 0).isActive = true
    }
    
    func setupLabels() {
        firstLabel.textColor = Constants.Colors.StethoMeDarkText
        firstLabel.font = .systemFont(ofSize: 15, weight: .light)
        secondLabel.textColor = Constants.Colors.StethoMeRed
        secondLabel.font = .systemFont(ofSize: 15, weight: .light)
    }
}

// MARK: - Configuration
extension InvalidPointsCountView {
    func configure(with pointType: InvalidPointType, count: Int) {
        pointsCountLabel.text = "\(count)"
        
        switch pointType {
        case .invalid(let firstLine, let secondLine):
            firstLabel.text = firstLine
            secondLabel.text = secondLine
        case .noRecording(let firstLine):
            firstLabel.text = firstLine
            secondLabel.isHidden = true
        }
    }
}
