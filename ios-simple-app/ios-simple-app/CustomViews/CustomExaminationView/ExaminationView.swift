//
//  ExaminationView.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 15/07/2020.
//  Copyright © 2020 StethoMe. All rights reserved.
//

import UIKit
import StethoMeSDK

/// Custom examination view. Shows how to make your own examination while stethoscope handling is still on SDK side.
final class ExaminationView: UIView, NibLoadableView {
    
    @IBOutlet weak var bodySideLabel: UILabel!
    @IBOutlet weak var bodyImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView! //ugly but it's just example
    
    private var allPoints: [SMExaminationPointProtocol] = []
    
    func setup(controller: SMLungsExaminationController) {
        onBodySideChanged(newBodySide: controller.currentSelectedPoint.bodySide)
        controller.setLungsExaminationUIListener(self)
        allPoints = controller.allPoints
        
        let body = UIImage(named: "logo")?.withRenderingMode(.alwaysTemplate) //changing rendering mode to alwaysTemplate allows for changing colors of image via 'tintColor'. Usefull for icons.
        bodyImageView.image = body //set your image for body
        bodyImageView.tintColor = UIColor.blue //just for visibility of logo, you body image don't need this
        
        // With custom view, you have to provide points positions yourself.
        // UICollectionView here is just shortcut for example purposes.
        let nib = UINib.init(nibName: "ExaminationPointCell", bundle: .main)
        collectionView.register(nib, forCellWithReuseIdentifier: "ExaminationPointCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
}

// MARK: - SMLungsExaminatonUIListener
extension ExaminationView: SMLungsExaminatonUIListener {
    func onBodySideChanged(newBodySide: SMBodySide) {
        DispatchQueue.main.async { [weak self] in
            switch newBodySide {
            case .front:
                self?.bodySideLabel.text = "FRONT"
    //            bodyImageView.image //set image for front side of body
            case .back:
                self?.bodySideLabel.text = "BACK"
    //            bodyImageView.image //set image for back side of body
            }
        }
    }
}

// MARK: - UICollectionViewDelegate UICollectionViewDataSource
extension ExaminationView: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        allPoints.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: ExaminationPointCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExaminationPointCell", for: indexPath) as? ExaminationPointCell else {
            return UICollectionViewCell()
        }
        cell.setup(point: allPoints[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        allPoints[indexPath.row].select() //you can send selection event to point from app side and stethoscope will reflect that
    }
}
