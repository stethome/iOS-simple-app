//
//  ConsentsViewModel.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 29/07/2019.
//  Copyright © 2019 StethoMe. All rights reserved.
//

import Foundation
import StethoMeSDK

final class ConsentsViewModel {
    
    let input = Input()
    var output = Output()
    
    let consents: SMConsents
    var itemsToAccept: [SMConsentsElement]
    var dontShowAgain = false
    
    init() {
        consents = SMManager.getConsents()
        itemsToAccept = consents.items
        
        setupTexts()
        setupObservers()
    }
    
    private func setupTexts() {
        let smConsents = SMManager.getConsents()
        let stringRes = SMStringResource(locale: Locale.current)
        let headerText = stringRes.getString(for: smConsents.headerStringKey)
        let subHeaderText = stringRes.getString(for: smConsents.subHeaderStringKey)
        let bodytext = stringRes.getString(for: smConsents.bodyStringKey)
        
        output.view.headerText = headerText
        output.view.subHeaderText = subHeaderText
        output.view.bodyText = bodytext
    }
}

// MARK: - Setup Observers
private extension ConsentsViewModel {
    func setupObservers() {
        input.view.userTappedSwitchIndex.action = { [weak self] indexTapped in
            guard var items = self?.itemsToAccept else { return }
            items[indexTapped].isAccepted = !items[indexTapped].isAccepted
            self?.itemsToAccept = items
            self?.checkConsents()
        }
        
        input.view.dontShowAgainTapped.action = { [weak self] dontShowAgain in
            self?.dontShowAgain = dontShowAgain
        }
        
        input.view.confirmTapped.action = { [weak self] _ in
            guard var consents = self?.consents, let items = self?.itemsToAccept, let dontShowAgain = self?.dontShowAgain else { return }
            consents.items = items
            self?.output.viewModel.confirmedConsents.onNext((consents, dontShowAgain))
        }
    }
    
    /// Check if all required consents are accepted and unlock 'I AGREE' button.
    func checkConsents() {
        if !itemsToAccept.contains(where: { $0.isRequired && !$0.isAccepted }) {
            output.view.isConfirmButtonEnabled.onNext(true)
        } else {
            output.view.isConfirmButtonEnabled.onNext(false)
        }
    }
}

// MARK: - Input/Output
extension ConsentsViewModel {
    struct ViewInput {
        let userTappedSwitchIndex = PublishSubject<Int>()
        let dontShowAgainTapped = PublishSubject<Bool>()
        let confirmTapped = PublishSubject<Void>()
    }
    
    struct Input {
        let view = ViewInput()
    }
    
    struct ViewOutput {
        var headerText: String?
        var subHeaderText: String?
        var bodyText: String?
        var itemsToAccept: [SMConsentsElement] = []
        let buttonTitle = "disclaimer_button_title".localized.uppercased()
        let dontShowAgainTitle = "consents_check_dont_show_again".localized
        let isConfirmButtonEnabled = PublishSubject<Bool>()
    }
    
    struct ViewModelOutput {
        let confirmedConsents = PublishSubject<(consents: SMConsents, dontShowAgain: Bool)>()
    }
    
    struct Output {
        var view = ViewOutput()
        let viewModel = ViewModelOutput()
    }
}
