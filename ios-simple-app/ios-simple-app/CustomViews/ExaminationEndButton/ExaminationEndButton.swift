//
//  ExaminationEndButton.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 10/06/2019.
//  Copyright © 2019 StethoMe. All rights reserved.
//

import UIKit

final class ExaminationEndButton: UIView, NibLoadableView {
    
    @IBOutlet weak var title: UILabel!
    
    private var viewModel: ExaminationEndButtonViewModel!
}

// MARK: - Setup
private extension ExaminationEndButton {
    func setupUI() {
        title.font = .systemFont(ofSize: 22, weight: .light)
        title.textColor = UIColor.white
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tapRecognizer)
        
        setAsDisabled()
    }
    
    @objc func tapped() {
        viewModel.input.view.tapped.onNext(())
    }
    
    func setAsDisabled() {
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.backgroundColor = Constants.Colors.StethoMeSecondary
        }
    }
    
    func setAsEnabled() {
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.backgroundColor = Constants.Colors.StethoMeAccent
        }
    }
    
    func setAsEndExamination() {
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.backgroundColor = Constants.Colors.StethoMeGreen
        }
    }
}

// MARK: - Configuration
extension ExaminationEndButton {
    func configure(with viewModel: ExaminationEndButtonViewModel) {
        self.viewModel = viewModel
        setupUI()
        
        viewModel.output.view.title.action = { [weak self] newTitle in
            self?.title.text = newTitle
        }
        viewModel.output.view.state.action = { [weak self] newState in
            self?.setNewState(newState)
        }
    }
    
    private func setNewState(_ state: ExaminationEndButtonViewModel.State) {
        switch state {
        case .disabled:
            setAsDisabled()
        case .enabled:
            setAsEnabled()
        case .endExamination:
            setAsEndExamination()
        }
    }
}
