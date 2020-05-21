//
//  ConsentsViewController.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 29/07/2019.
//  Copyright © 2019 StethoMe. All rights reserved.
//

import UIKit

final class ConsentsViewController: UIViewController {
    
    @IBOutlet weak var textViewBackground: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var consentsContainer: UIView!
    @IBOutlet weak var consentsStackView: UIStackView!
    @IBOutlet weak var acceptButton: UIButton!
    
    private var viewModel: ConsentsViewModel!
    private var switches: [UISwitch] = [] //keeping references to switches to know which was tapped
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        switches = [] //preventing holding strong references after view disappears
    }
    
    @IBAction func acceptTapped() {
        viewModel.input.view.confirmTapped.onNext(())
    }
}

// MARK: - Setup
private extension ConsentsViewController {
    func setupUI() {
        setupTextView()
        setupButton()
        setupConsentsStack()
        
        consentsContainer.backgroundColor = Constants.Colors.StethoMeAccent
        consentsContainer.layer.cornerRadius = 5.0
        consentsContainer.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    func setupTextView() {
        guard let header = viewModel.output.view.headerText else { return }
        guard let subHeader = viewModel.output.view.subHeaderText else { return }
        guard let bodyText = viewModel.output.view.bodyText else { return }
        
        let headerAttr = NSMutableAttributedString(string: "\n\(header)", attributes: [
            NSAttributedString.Key.foregroundColor: Constants.Colors.StethoMeAccent,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .light)])
        let subHeaderAttr = NSAttributedString(string: "\n\n\(subHeader)", attributes: [
            NSAttributedString.Key.foregroundColor: Constants.Colors.StethoMeDarkText,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .light)])
        let bodyTextAttr = NSAttributedString(string: "\n\n\(bodyText)\n", attributes: [
            NSAttributedString.Key.foregroundColor: Constants.Colors.StethoMeDarkText,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .light)])
        
        headerAttr.append(subHeaderAttr)
        headerAttr.append(bodyTextAttr)
        
        textView.attributedText = headerAttr
        textView.isEditable = false
        textView.dataDetectorTypes = [.link]
        textView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        textView.layer.cornerRadius = 5.0
        
        textViewBackground.layer.cornerRadius = 5.0
        textViewBackground.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func setupButton() {
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: Constants.Colors.StethoMeAccent,
                                                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .light)]
        let buttonTitle = viewModel.output.view.buttonTitle
        let buttonTitleAttr = NSAttributedString(string: buttonTitle, attributes: attributes)
        acceptButton.setAttributedTitle(buttonTitleAttr, for: .normal)
        acceptButton.setTitleColor(Constants.Colors.StethoMeAccent, for: .normal)
        acceptButton.isEnabled = false
    }
    
    func setupConsentsStack() {
        let items = viewModel.itemsToAccept
        consentsStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        
        for index in 0..<items.count {
            addNewConsent(accepted: items[index].isAccepted, text: items[index].acceptStringKeyResource.getString(for: Locale.current, forDoctor: false))
        }
        
        addNewConsent(accepted: false, text: viewModel.output.view.dontShowAgainTitle ?? "")
    }
    
    func addNewConsent(accepted: Bool, text: String) {
        let consentSwitch = UISwitch()
        consentSwitch.translatesAutoresizingMaskIntoConstraints = false //needed to use constraints programmatically
        consentSwitch.widthAnchor.constraint(equalToConstant: 50).isActive = true
        consentSwitch.isOn = accepted
        consentSwitch.addTarget(self, action: #selector(consentSwitchTapped(_:)), for: .valueChanged)
        self.switches.append(consentSwitch)
        let label = UILabel()
        label.numberOfLines = 3
        label.text = text
        label.textColor = Constants.Colors.StethoMeDarkText
        label.font = .systemFont(ofSize: 13)
        
        let innerStackView = UIStackView(arrangedSubviews: [consentSwitch, label])
        innerStackView.axis = .horizontal
        innerStackView.spacing = 8
        innerStackView.distribution = .fill
        innerStackView.alignment = .center
        consentsStackView.addArrangedSubview(innerStackView)
    }
    
    @objc func consentSwitchTapped(_ sender: UISwitch) {
        //switches have same order as consents in view model
        for index in 0..<switches.count {
            guard switches[index] === sender else { continue }
            if index < viewModel.itemsToAccept.count { //user tapped one of SMConsents switches
                viewModel.input.view.userTappedSwitchIndex.onNext(index)
            } else { //user tapped 'don't show again' switch
                viewModel.input.view.dontShowAgainTapped.onNext(sender.isOn)
            }
        }
    }
}

// MARK: - Configuration
extension ConsentsViewController {
    func configure(withViewModel viewModel: ConsentsViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - Setup observers
private extension ConsentsViewController {
    func setupObservers() {
        let viewOutput = viewModel.output.view
        viewOutput.isConfirmButtonEnabled.action = { [weak self] enabled in
            self?.handleConfirmButtonEnableChange(enabled)
        }
    }
    
    func handleConfirmButtonEnableChange(_ enabled: Bool) {
        acceptButton.isEnabled = enabled
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.acceptButton.backgroundColor = UIColor.white.withAlphaComponent(enabled ? 1.0 : 0.2)
        }
    }
}
