//
//  UploadingIndicator.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 25/06/2019.
//  Copyright © 2019 StethoMe. All rights reserved.
//

import UIKit

final class UploadingIndicator: View, NibLoadableView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    
    private var isAnimating = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        logoImageView.image = UIImage(named: "logo")?.withRenderingMode(.alwaysTemplate)
        logoImageView.tintColor = Constants.Colors.StethoMeSecondary
        self.alpha = 0.0
    }
    
    private func animate() {
        guard isAnimating else { return }
        
        UIView.animate(withDuration: 1.0, delay: 0, options: [.curveLinear], animations: { [weak self] in
            self?.imageView.transform = self?.imageView.transform.rotated(by: CGFloat.pi) ?? CGAffineTransform.identity
        }, completion: { [weak self] _ in
            self?.animate()
        })
    }
    
    override func show() {
        isAnimating = true
        animate()
        
        super.show()
    }
    
    /// Animates hiding and call completion handler when finished.
    override func hide(completionHandler: (() -> Void)?) {
        isAnimating = false
        super.hide(completionHandler: completionHandler)
    }
}
