//
//  ViewController.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 05/08/2019.
//  Copyright © 2019 StethoMe. All rights reserved.
//

import UIKit
import StethoMeSDK

class ViewController: UIViewController {
    
    @IBOutlet weak var deviceSearchingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var recordingStateContainer: UIView!
    @IBOutlet weak var examinationViewContainer: UIView!
    @IBOutlet weak var updateProgressView: UIProgressView!
    @IBOutlet weak var pointsAnalysisIndicatorView: UIStackView!
    weak var recordingStateView: SMRecordingStateView?
    weak var examinationView: SMExaminationView?
    private let invalidPointsSummaryView = SMInvalidPointsSummaryView.fromNib()
    
    var smManager: SMManager!
    var smExamination: SMExamination?
    let patientAge = 11

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupStethoMe()
        setupUI()
    }

    func setupStethoMe() {
        smManager = SMManager(authDelegate: self)
        smManager.delegate = self
        smManager.searchForDevices(mode: .normal)
        deviceSearchingIndicator.startAnimating()
        print("Searching for stetethoscopes...")
    }
    
    func setupExamination() {
        guard smExamination == nil else { return }
        let disclaimer = SMDisclaimer(locale: Locale.current) //normally disclaimer have to be shown to user
        disclaimer.getItemsToAccept().forEach({ $0.isAccepted = true })
        let patient = SMPatient(age: Float(patientAge), sex: .male, weight: 80)
        
        guard let examination = smManager.startExamination(delegate: self, options: [], disclaimer: disclaimer, patient: patient) else {
            print("Error: did not get SMExamination object!")
            return
        }
        smExamination = examination
        examinationView?.configure(with: examination, locale: Locale.current, customButton: nil)
        recordingStateView?.configure(withExamination: examination, locale: Locale.current)
    }
    
    func handleEndExamination() {
        guard let examination = smExamination, !examination.isRecording, examination.haveRecordings() else { return }
        
        pointsAnalysisIndicatorView.isHidden = false
        examination.analysePoints { [weak self] result in
            self?.pointsAnalysisIndicatorView.isHidden = true
            switch result {
            case .success(let invalidPoints):
                if invalidPoints.count == 0 {
                    self?.showSendingSuccess()
                } else {
                    self?.handleShowingInvalidPoints(invalidPoints)
                }
            case .failure(let error):
                self?.showSendingFailure()
                print("Sending examination error. Try again later. \(error)")
            }
        }
    }
    
    func showSendingFailure() {
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let retryAction = UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.handleEndExamination()
        }
        let alertVC = UIAlertController(title: "Sending error", message: "Error occured during sending points for analysis. Try again later.", preferredStyle: .alert)
        alertVC.addAction(cancelAction)
        alertVC.addAction(retryAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func showSendingSuccess() {
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.resetExaminationState()
        })
        let alertVC = UIAlertController(title: "Sending success", message: "You can now download detailed results from StethoMe API through your endpoint and show them on SMExaminationResultsView.", preferredStyle: .alert)
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func handleShowingInvalidPoints(_ invalidPoints: [(SMExaminationPoint, SMExaminationPointFailedReason)]) {
        invalidPointsSummaryView.configure(withInvalidPoints: invalidPoints, locale: Locale.current)
        invalidPointsSummaryView.embed(inView: self.view)
        self.view.bringSubviewToFront(invalidPointsSummaryView)
        
        invalidPointsSummaryView.yesTappedHandler = { [weak self] in
            self?.smExamination?.recordInvalidPointsAgain()
            self?.hideInvalidPointsSummaryView()
        }
        invalidPointsSummaryView.noTappedHandler = { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                self?.showSendingSuccess()
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
    
    func resetExaminationState() {
        smExamination?.closeExamination(removeFiles: true)
        smExamination = nil
        setupExamination()
    }
    
    @IBAction func endExaminationTapped() {
        handleEndExamination()
    }
}

// MARK: - SetupUI
extension ViewController {
    func setupUI() {
        let recordingStateView = SMRecordingStateView.fromNib()
        recordingStateView.configure(withLocale: Locale.current)
        recordingStateView.embed(inView: recordingStateContainer)
        self.recordingStateView = recordingStateView
        
        let examinationView = SMExaminationView.fromNib()
        examinationView.configureAsPlaceholder(patientAge: patientAge, locale: Locale.current, customButton: nil)
        examinationView.embed(inView: examinationViewContainer)
        self.examinationView = examinationView
        
        updateProgressView.isHidden = true
        pointsAnalysisIndicatorView.isHidden = true
    }
}

// MARK: - SMAuthDelegate
extension ViewController: SMAuthDelegate {
    func provideAuthToken() -> SMAuthCredentials {
        return SMAuthCredentials(clientToken: "put-your-token-here", clientID: 42)
    }
    
    func provideNewAuthToken(completionHandler: @escaping (SMAuthCredentials?) -> Void) {
        completionHandler(provideAuthToken()) // TODO (MJ): do proper request to retrieve new token
    }
    
    func authorized() {
        print("Authorized!")
    }
    
    func notAuthorized() {
        print("Not authorized!")
    }
}

// MARK: - SMManagerDelegate
extension ViewController: SMManagerDelegate {
    func stethoscopesFound(_ devices: [SMStethoscope]) {
        print("Found: \(devices)")
        guard let first = devices.first else { return }
        smManager.connectToDevice(first)
        print("Connecting to first found stethoscope...")
    }
    
    func stethoscopeConnected() {
        deviceSearchingIndicator.stopAnimating()
        print("Successfully connected to stethoscope!")
        smManager.setFilter(.lungs) { [weak self] error in
            if let error = error {
                print(error)
                return
            }
            self?.setupExamination()
        }
    }
    
    func stethoscopeDisconnected() {
        print("Stethoscope disconnected.") //no need to take any action, SDK automatically search for device to connect to.
    }
    
    func stethoscopeLost(_ isSearchingForStethoscope: Bool) {
        if isSearchingForStethoscope {
            deviceSearchingIndicator.startAnimating()
        } else {
            deviceSearchingIndicator.stopAnimating()
        }
    }
    
    func updateNeeded(checkResult: SMUpdateCheckResult) {
        print("Update check result: \(checkResult.state)")
        
        switch checkResult.state {
        case .updateNeeded:
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let updateAction = UIAlertAction(title: "Update", style: .default) { [weak checkResult] _ in
                checkResult?.startFirmwareUpdate(progressDelegate: self)
                self.updateProgressView.isHidden = false
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
extension ViewController: SMUpdateProgressDelegate {
    func firmwareUpdate(progress: Float) {
        updateProgressView.progress = progress / 100.0
        print("Firmware update progress: \(progress)%")
    }
    
    func firmwareUpdateSuccess() {
        updateProgressView.progress = 0.0
        updateProgressView.isHidden = true
        print("Firmware upload success!")
        
    }
    
    func firmwareUpdateError() {
        updateProgressView.progress = 0.0
        updateProgressView.isHidden = true
        print("Firmware update failure. Try again.")
    }
}

// MARK: - SMExaminationDelegate
extension ViewController: SMExaminationDelegate {
    func recordingStarted() {
        print("Started recording.")
    }
    
    func recordingProgress(percentage: Int) {
        print("Recording progress: \(percentage)")
    }
    
    func recordingFinished() {
        print("Recording finished.")
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
