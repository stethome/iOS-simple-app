//
//  ExaminationEndButtonViewModel.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 10/06/2019.
//  Copyright © 2019 StethoMe. All rights reserved.
//

import Foundation

final class ExaminationEndButtonViewModel {
    
    enum State {
        /// gray background, untouchable
        case disabled
        /// blue background
        case enabled
        /// green background
        case endExamination
    }
    
    struct Dependencies {
        let state: State
        let title: String
    }
    
    fileprivate let dependencies: Dependencies
    private var state: State
    let input = Input()
    let output = Output()
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.state = dependencies.state
        
        setupObservers()
    }
}

// MARK: - Setup observers
private extension ExaminationEndButtonViewModel {
    func setupObservers() {
        output.view.state.onNext(dependencies.state)
        output.view.title.onNext(dependencies.title)
        
        input.viewModel.setNewState.action = { [weak self] newState in
            self?.state = newState
            self?.output.view.state.onNext(newState)
        }
        input.viewModel.setNewTitle.action = { [weak self] newTitle in
            self?.output.view.title.onNext(newTitle)
        }
        
        input.view.tapped.action = { [weak self] _ in
            guard let state = self?.state, state != .disabled else { return }
            self?.output.viewModel.tapped.onNext(())
        }
    }
}

// MARK: - Input/Output
extension ExaminationEndButtonViewModel {
    struct ViewInput {
        let tapped = PublishSubject<Void>()
    }
    
    struct ViewModelInput {
        let setNewState = PublishSubject<State>()
        let setNewTitle = PublishSubject<String>()
    }
    
    struct Input {
        let view = ViewInput()
        let viewModel = ViewModelInput()
    }
    
    struct ViewOutput {
        let state = BehaviorSubject<State>(value: .disabled)
        let title = BehaviorSubject<String>(value: "")
    }
    
    struct ViewModelOutput {
        let tapped = PublishSubject<Void>()
    }
    
    struct Output {
        let view = ViewOutput()
        let viewModel = ViewModelOutput()
    }
}
