//
//  RingView.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 24/09/2019.
//  Copyright © 2019 StethoMe. All rights reserved.
//

import UIKit

final class RingView: UIView {
    
    enum LineWidthType {
        case fixed(CGFloat)
        case relative(CGFloat)
        case relativeDefault
    }
    
    private var shapeLayer: CAShapeLayer = CAShapeLayer()
    private var lineWidth: LineWidthType = .relative(0.1)
    private let RING_ANIMATION_KEY = "RingViewAnimationKey"
    private let RING_ANIMATION_DURATION: CFTimeInterval = 0.2
    private let RING_DEFAULT_RELATIVE_WIDTH: CGFloat = 0.1
    
    var ringFillColor: UIColor = Constants.Colors.StethoMeAccent {
        didSet {
            shapeLayer.strokeColor = ringFillColor.cgColor
        }
    }
    
    private var _percentageFilled: Float = 0.0
    /// [0-100]
    var percentageFilled: Float {
        get {
            return _percentageFilled
        }
        set {
            if newValue == 0.0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                    self?.setProgress(progress: 0.0, animated: false)
                }
            } else {
                alpha = 1.0
                setProgress(progress: CGFloat(newValue / 100.0), animated: true)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round
        shapeLayer.strokeColor = Constants.Colors.StethoMeAccent.cgColor
        layer.addSublayer(shapeLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = self.bounds
        shapeLayer.path = layoutPath().cgPath
        
        switch lineWidth {
        case .relative(let scale):
            let shorterSide: CGFloat = frame.width < frame.height ? frame.width : frame.height
            shapeLayer.lineWidth = shorterSide * scale
        case .relativeDefault:
            let shorterSide: CGFloat = frame.width < frame.height ? frame.width : frame.height
            shapeLayer.lineWidth = shorterSide * RING_DEFAULT_RELATIVE_WIDTH
        default:
            break
        }
    }
    
    private func layoutPath() -> UIBezierPath {
        let shorterSide: CGFloat = frame.width < frame.height ? frame.width : frame.height
        let twoPi = CGFloat.pi * 2
        let startAngle = twoPi * 0.75
        let endAngle = startAngle + twoPi
        
        return UIBezierPath(arcCenter: CGPoint(x: frame.width / 2.0, y: frame.height / 2.0),
                            radius: shorterSide / 2.0 - shapeLayer.lineWidth / 2.0,
                            startAngle: startAngle,
                            endAngle: endAngle,
                            clockwise: true)
    }
}

// MARK: - Configuration
extension RingView {
    func configure(fillColor: UIColor, lineWidth: LineWidthType, percentageFilled: Float = 0.0) {
        self.lineWidth = lineWidth
        self.ringFillColor = fillColor
        self._percentageFilled = percentageFilled
        setProgress(progress: CGFloat(percentageFilled), animated: false)
        
        switch lineWidth {
        case .fixed(let fixedLineWidth):
            shapeLayer.lineWidth = fixedLineWidth
        case .relative(let scale):
            let shorterSide: CGFloat = frame.width < frame.height ? frame.width : frame.height
            shapeLayer.lineWidth = shorterSide * scale
        case .relativeDefault:
            let shorterSide: CGFloat = frame.width < frame.height ? frame.width : frame.height
            shapeLayer.lineWidth = shorterSide * RING_DEFAULT_RELATIVE_WIDTH
        }
        
        if percentageFilled == 0.0 {
            alpha = 0.0
        }
    }
}

// MARK: - Animation
private extension RingView {
    func setProgress(progress: CGFloat, animated: Bool) {
        let newProgress = max(min(progress, 1.0), 0.0)
        guard newProgress != CGFloat(self._percentageFilled) else { return }
        
        if animated {
            animateToProgress(newProgress)
        } else {
            stopAnimation()
            self._percentageFilled = Float(newProgress)
            updateProgress(newProgress)
        }
    }
    
    func animateToProgress(_ progress: CGFloat) {
        stopAnimation()
        
        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.timingFunction = CAMediaTimingFunction(name: .linear)
        anim.isRemovedOnCompletion = false
        anim.fillMode = .forwards
        anim.duration = RING_ANIMATION_DURATION
        anim.fromValue = CGFloat(self._percentageFilled)
        anim.toValue = progress
        shapeLayer.add(anim, forKey: RING_ANIMATION_KEY)
        
        self._percentageFilled = Float(progress)
    }
    
    func stopAnimation() {
        shapeLayer.removeAnimation(forKey: RING_ANIMATION_KEY)
    }
    
    func updateProgress(_ value: CGFloat) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        shapeLayer.strokeEnd = value
        CATransaction.commit()
    }
}
