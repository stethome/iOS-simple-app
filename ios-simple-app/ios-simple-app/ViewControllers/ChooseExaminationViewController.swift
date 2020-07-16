//
//  ChooseExaminationViewController.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 16/07/2020.
//  Copyright © 2020 StethoMe. All rights reserved.
//

import UIKit

final class ChooseExaminationViewController: UIViewController, Presenter {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Choose example"
    }
    
    @IBAction func lungsExaminationTapped() {
        openLungsExamination()
    }
    
    @IBAction func customExaminationTapped() {
        openCustomExamination()
    }
}
