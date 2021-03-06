//
//  CustomExaminationViewController.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 16/07/2020.
//  Copyright © 2020 StethoMe. All rights reserved.
//

import UIKit
import StethoMeSDK

class CustomExaminationViewController: UIViewController, Presenter {
    
    @IBOutlet weak var recordingStateContainer: UIView!
    @IBOutlet weak var recordingIndicatorTopLabel: UILabel!
    @IBOutlet weak var recordingIndicatorBottomLabel: UILabel!
    @IBOutlet weak var examinationViewContainer: UIView!
    @IBOutlet weak var bodySideSwitchButton: UIView!
    @IBOutlet weak var endExaminationButtonContainer: UIView!
    
    let deviceSearchingIndicator = DeviceSearchingIndicator.fromNib()
    let uploadingIndicator = UploadingIndicator.fromNib()
    weak var recordingIndicatorView: SMRecordingIndicatorView!
    weak var customExaminationView: ExaminationView! //our custom view
    weak var bodySideSwitch: BodySwitchButton!
    let invalidPointsSummaryView = InvalidPointsSummaryView.fromNib()
    
    weak var endExaminationButtonVM: ExaminationEndButtonViewModel?
    
    var smManager: SMManager!
    var smExamination: SMLungsExamination?
    var smExaminationResult: SMLungsExaminationResult?
    let patientAge = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleConsents()
    }
    
    func handleConsents() {
        print("Checking consents.")
        let smConsents = SMManager.getConsents()
        
        if let storedConsents = Database.instance.getConsents(),
            storedConsents.equals(smConsents),
            Database.instance.getDontShowAgain() {
            print("Consents previously accepted and set to not show again. Starting SMManager.")
            setupStethoMe()
            return
        }
        
        print("Consents view must be shown.")
        if let consentsVC = UIStoryboard(name: "Consents", bundle: nil).instantiateViewController(withIdentifier: "ConsentsViewController") as? ConsentsViewController {
            let consentsVM = ConsentsViewModel()
            consentsVM.output.viewModel.confirmedConsents.action = { [weak consentsVC] result in
                Database.instance.storeConsents(result.consents)
                Database.instance.storeDontShowAgain(result.dontShowAgain)
                
                consentsVC?.dismiss(animated: false, completion: { [weak self] in
                    self?.setupStethoMe()
                })
            }
            
            consentsVC.configure(withViewModel: consentsVM)
            consentsVC.modalPresentationStyle = .overCurrentContext
            consentsVC.modalTransitionStyle = .coverVertical
            present(consentsVC, animated: true, completion: nil)
        }
    }
}

// MARK: - Examination
extension CustomExaminationViewController {
    
    func setupStethoMe() {
        smManager = SMManager(authDelegate: self, logger: self, loggerVerbosity: .debug)
        smManager.delegate = self
        smManager.searchForDevices()
        showSearchingIndicator(true)
        print("Searching for stetethoscopes...")
    }
    
    func setupExamination() {
        guard smExamination == nil, let consents = Database.instance.getConsents() else { return }
        
        let patient = SMPatient(age: Float(patientAge), sex: .male, weight: 80, height: 180, birthDateTs: nil)
        let config = SMLungsExaminationConfig(auscultationMode: .simple,
                                              serverMode: .resultSimple,
                                              patient: patient,
                                              consents: consents,
                                              flags: SMLungsExaminationConfig.Flags(presentationMode: false, gestures: false),
                                              audioHandler: nil,
                                              delegate: self)
        do {
            let examination = try smManager.startLungsExamination(withConfiguration: config)
            smExamination = examination
            //do setup of custom view when device is ready
            customExaminationView.setup(controller: examination)
            
            examination.setRecordingIndicatorUIListener(recordingIndicatorView)
            bodySideSwitch.configure(withExamination: examination)
            print("We're ready to start recording points now.")
        } catch {
            print("Error while trying to get examination object: \(error)")
        }
    }
    
    func handleEndExamination() {
        guard let examination = smExamination, !examination.isRecording, examination.haveRecordings() else { return }
        print("Sending examination for analysis...")
        
        showUploadingIndicator(true)
        examination.sendPoints { [weak self] result in
            self?.showUploadingIndicator(false)
            
            switch result {
            case .success(let result):
                print("Analysis done with general state: \(result.state).")
                
                if result.invalidPoints.count == 0 {
                    self?.openResultsView(withResult: result)
                } else {
                    self?.smExaminationResult = result
                    self?.handleShowingInvalidPoints(result.invalidPoints)
                }
            case .failure(let error):
                self?.showSendingFailure()
                print("Sending examination error. Try again later. \(error)")
            }
        }
    }
    
    func showSendingFailure() {
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil)
        let retryAction = UIAlertAction(title: "retry".localized, style: .default) { [weak self] _ in
            self?.handleEndExamination()
        }
        let alertVC = UIAlertController(title: "upload_failed_title".localized, message: "upload_failed_message".localized, preferredStyle: .alert)
        alertVC.addAction(cancelAction)
        alertVC.addAction(retryAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func resetExaminationState() {
        smExamination?.endExamination()
        smExamination = nil
        setupExamination()
    }
}

// MARK: - Invalid points
extension CustomExaminationViewController {
    func handleShowingInvalidPoints(_ invalidPoints: [Int: SMExaminationPointFailedReason]) {
        invalidPointsSummaryView.configure(withInvalidPoints: invalidPoints.map({ $0.1 }))
        invalidPointsSummaryView.embed(inView: self.view)
        self.view.bringSubviewToFront(invalidPointsSummaryView)
        
        invalidPointsSummaryView.yesTappedHandler = { [weak self] in
            self?.showUploadingIndicator(true)
            self?.smExamination?.recordInvalidPointsAgain({ result in
                self?.showUploadingIndicator(false)
                self?.hideInvalidPointsSummaryView()
                
                if self?.smExamination?.haveRecordings() == false {
                    self?.endExaminationButtonVM?.input.viewModel.setNewState.onNext(.disabled)
                }
                
                if case .failure(let error) = result {
                    switch error {
                    case .deletingInvalidRecordingsProblem:
                        print("Error while trying to delete recordings on StethoMe server.")
                    default:
                        break
                    }
                }
            })
            
        }
        invalidPointsSummaryView.noTappedHandler = { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                guard let result = self?.smExaminationResult else { return }
                self?.openResultsView(withResult: result)
            })
        }
        
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.invalidPointsSummaryView.alpha = 1.0
            }, completion: nil)
    }
    
    func hideInvalidPointsSummaryView() {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.invalidPointsSummaryView.alpha = 0.0
            }, completion: { [weak self] _ in
                self?.invalidPointsSummaryView.removeFromSuperview()
        })
    }
}

// MARK: - SetupUI
extension CustomExaminationViewController {
    func setupUI() {
        let recordingIndicatorView = SMRecordingIndicatorView.fromNib()
        recordingIndicatorView.embed(inView: recordingStateContainer)
        self.recordingIndicatorView = recordingIndicatorView
        
        recordingIndicatorTopLabel.text = "examination_header_not_recording".localized
        recordingIndicatorTopLabel.textColor = Constants.Colors.StethoMeAccent
        recordingIndicatorTopLabel.font = .systemFont(ofSize: 19, weight: .medium)
        
        recordingIndicatorBottomLabel.text = "examination_subheader".localized
        recordingIndicatorBottomLabel.textColor = Constants.Colors.StethoMeDarkText
        recordingIndicatorBottomLabel.font = .systemFont(ofSize: 15, weight: .light)
        
        //init custom view and embed into some container
        let customExaminationView = ExaminationView.fromNib()
        customExaminationView.embed(inView: examinationViewContainer)
        self.customExaminationView = customExaminationView
        
        let bodySideSwitch = BodySwitchButton.fromNib()
        bodySideSwitch.embed(inView: bodySideSwitchButton)
        self.bodySideSwitch = bodySideSwitch
        
        let endExaminationButton = ExaminationEndButton.fromNib()
        let endExaminationButtonVM = ExaminationEndButtonViewModel(dependencies: ExaminationEndButtonViewModel.Dependencies(state: .disabled, title: "examination_main_end_examination_button".localized))
        endExaminationButton.configure(with: endExaminationButtonVM)
        endExaminationButton.embed(inView: endExaminationButtonContainer)
        self.endExaminationButtonVM = endExaminationButtonVM
        
        endExaminationButtonVM.output.viewModel.tapped.action = { [weak self] _ in
            self?.handleEndExamination()
        }
    }
    
    func showSearchingIndicator(_ isSearching: Bool) {
        if isSearching {
            deviceSearchingIndicator.embed(inView: self.view)
            self.view.bringSubviewToFront(deviceSearchingIndicator)
            deviceSearchingIndicator.show()
        } else {
            deviceSearchingIndicator.hide { [weak self] in
                self?.deviceSearchingIndicator.removeFromSuperview()
            }
        }
    }
    
    func showUploadingIndicator(_ show: Bool) {
        if show {
            uploadingIndicator.embed(inView: self.view)
            self.view.bringSubviewToFront(uploadingIndicator)
            uploadingIndicator.show()
        } else {
            uploadingIndicator.hide { [weak self] in
                self?.uploadingIndicator.removeFromSuperview()
            }
        }
    }
}

// MARK: - SMAuthDelegate
extension CustomExaminationViewController: SMAuthDelegate {
    func provideAuthToken() -> SMAuthCredentials {
        return SMAuthCredentials(clientToken: Constants.clientToken, clientID: 42)
    }
    
    func provideNewAuthToken(completionHandler: @escaping (SMAuthCredentials?) -> Void) {
        // TODO (MJ): do proper request to retrieve new token
        completionHandler(provideAuthToken())
    }
    
    func authorized() {
        print("Authorized!")
    }
    
    func notAuthorized() {
        print("Not authorized!")
    }
}

// MARK: - SMManagerDelegate
extension CustomExaminationViewController: SMManagerDelegate {
    func stethoscopesFound(_ devices: [SMStethoscope]) {
        print("Found: \(devices)")
        guard let first = devices.first else { return }
        smManager.connectToDevice(first)
        print("Connecting to first found stethoscope...")
    }
    
    func stethoscopeConnected() {
        print("Successfully connected to stethoscope!")
        setupExamination()
    }
    
    func stethoscopeDisconnected() {
        print("Stethoscope disconnected.")
    }
    
    func stethoscopeLost(_ isSearchingForStethoscope: Bool) {
        showSearchingIndicator(isSearchingForStethoscope)
    }
    
    func updateNeeded(checkResult: SMUpdateCheckResult) {
        print("Update check result: \(checkResult.state)")
        showSearchingIndicator(false)
        
        switch checkResult.state {
        case .updateRequired, .recoveryNeeded:
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let updateAction = UIAlertAction(title: "Update", style: .default) { [weak checkResult] _ in
                checkResult?.startFirmwareUpdate(progressDelegate: self)
            }
            let alertVC = UIAlertController(title: "Update needed", message: "Please update stethoscope.", preferredStyle: .alert)
            alertVC.addAction(cancelAction)
            alertVC.addAction(updateAction)
            present(alertVC, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func error(_ error: SMError) {
        print(error)
    }
}

// MARK: - SMUpdateProgressDelegate
extension CustomExaminationViewController: SMUpdateProgressDelegate {
    func firmwareUpdate(progress: Float) {
        print("Firmware update progress: \(progress)%")
    }
    
    func firmwareUpdateSuccess() {
        print("Firmware upload success!")
        
    }
    
    func firmwareUpdateError() {
        print("Firmware update failure. Try again.")
    }
}

// MARK: - SMExaminationDelegate
extension CustomExaminationViewController: SMExaminationDelegate {
    func recordingStarted() {
        print("Started recording.")
    }
    
    func recordingProgress(percentage: Int) {
        print("Recording progress: \(percentage)")
    }
    
    func recordingFinished() {
        print("Recording finished.")
        guard let examination = smExamination else { return }
        if examination.haveRecordings() {
            endExaminationButtonVM?.input.viewModel.setNewState.onNext(.enabled)
        }
    }
    
    func recordingTooShort() {
        print("Recording too short.")
    }
    
    func recordingBadQuality() {
        print("Recording bad quality. Too much noise.")
    }
    
    func recordingFailed() {
        print("Recording failed!")
    }
    
    func examinationVisitID(_ visitID: String) {
        print("Got visitID: \(visitID)")
    }
    
    func examinationAllRecordingsFinished() {
        handleEndExamination()
    }
    
    func stethoscopeTooLoudDetected(_ isTooLoud: Bool) {
        //ignoring
    }
    
    func stethoscopeTooShakyDetected(_ isTooShaky: Bool) {
        //you can ignore this
    }
}

// MARK: - SMLoggerDelegate
extension CustomExaminationViewController: SMLoggerDelegate {
    func onLogReceive(logText: String) {
        print(logText)
    }
}
