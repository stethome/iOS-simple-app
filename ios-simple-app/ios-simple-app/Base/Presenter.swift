//
//  Presenter.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 16/07/2020.
//  Copyright © 2020 StethoMe. All rights reserved.
//

import UIKit
import StethoMeSDK

protocol Presenter {
    var navigationController: UINavigationController? { get }
    
    func openLungsExamination()
    func openCustomExamination()
    
    func openResultsView(withResult result: SMLungsExaminationResult)
}

extension Presenter {
    func openLungsExamination() {
        let vc = UIStoryboard(.Main).instantiateViewController(withIdentifier: "LungsExaminationViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func openCustomExamination() {
        let vc = UIStoryboard(.Main).instantiateViewController(withIdentifier: "CustomExaminationViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func openResultsView(withResult result: SMLungsExaminationResult) {
        if let resultVC = UIStoryboard(.Main).instantiateViewController(withIdentifier: "ResultViewController") as? ResultViewController {
            resultVC.lungsExaminationResult = result
            resultVC.patientAge = Int(result.patientAge ?? 1)
            
            navigationController?.pushViewController(resultVC, animated: true)
        }
    }
}
