//
//  ExaminationPointCell.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 15/07/2020.
//  Copyright © 2020 StethoMe. All rights reserved.
//

import UIKit
import StethoMeSDK

/// Example custom point that reflects state of point in SDK. You have to position it according to your body image.
final class ExaminationPointCell: UICollectionViewCell {
    
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var tooLoudIndicator: UIView!
    @IBOutlet weak var pointNumberLabel: UILabel!
    
    private weak var point: SMExaminationPointProtocol?
    
    func setup(point: SMExaminationPointProtocol) {
        self.point = point
        point.delegate = self //get info about point events in SDK
        onSelected(isSelected: point.isSelected)
        pointNumberLabel.text = "\(point.pointID)"
        
        percentLabel.text = ""
        percentLabel.isHidden = true
        tooLoudIndicator.isHidden = true
    }
    
    private func updatePercentLabel(_ percent: Float) {
        percentLabel.text = "\(Int(percent))%"
    }
}

// MARK: - SMExaminationPointDelegate - handle this and you have basic connection between stethoscope - SDK - your app.
extension ExaminationPointCell: SMExaminationPointDelegate {
    func onSelected(isSelected: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.percentLabel.isHidden = !isSelected
            self?.backgroundColor = isSelected ? UIColor.blue : UIColor.clear
            
            if self?.point?.state == .recorded {
                self?.pointNumberLabel.textColor = .green
            }
        }
    }
    
    func onTouchChanged(isTouchDetected: Bool, noiseLevel: SMNoiseLevel) {
        DispatchQueue.main.async { [weak self] in
            self?.tooLoudIndicator.isHidden = noiseLevel == .noNoise
        }
    }
    
    func onProgressChanged(percent: Float) {
        DispatchQueue.main.async { [weak self] in
            self?.updatePercentLabel(percent)
        }
    }
    
    func onNoiseLevelChanged(value: SMNoiseLevel) {
        DispatchQueue.main.async { [weak self] in
            self?.tooLoudIndicator.isHidden = value == .noNoise
        }
    }
}
