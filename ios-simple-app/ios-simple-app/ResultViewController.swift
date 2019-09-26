//
//  ResultViewController.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 24/09/2019.
//  Copyright © 2019 StethoMe. All rights reserved.
//

import UIKit
import StethoMeSDK

class ResultViewController: UIViewController {
    
    @IBOutlet weak var summaryViewContainer: UIView!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var detailedViewContainer: UIView!
    @IBOutlet weak var legendStackView: UIStackView!
    
    var lungsExaminationResult: SMLungsExaminationResult!
    var patientAge: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - SetupUI
private extension ResultViewController {
    func setupUI() {
        let summaryView = SMLungsSummaryResultView.fromNib()
        summaryView.configure(withResultState: lungsExaminationResult.state) //we provide here only general state of result to show summary information to user
        summaryView.embed(inView: summaryViewContainer)
        
        summaryLabel.textColor = Constants.Colors.StethoMeDarkText
        summaryLabel.font = .systemFont(ofSize: 25, weight: .light)
        switch lungsExaminationResult.state {
        case .unknown:
            break
        case .invalid:
            summaryLabel.text = "summary_invalid".localized
        case .noChanges:
            summaryLabel.text = "summary_no_changes".localized
        case .innocentChanges:
            summaryLabel.text = "summary_innocent_changes".localized
        case .seriousChanges:
            summaryLabel.text = "summary_serious_changes".localized
        }
        
        let detailedView = SMLungsDetailedResultView.fromNib()
        detailedView.configure(withResultsModel: lungsExaminationResult, //details to be properly shown need full result info
                               serverMode: .resultSimple) //you can decide if you show just general info on recording or full AI analysis (may not be possible to show if advanced information from result is missing)
        detailedView.embed(inView: detailedViewContainer)
        
        setupLegend()
    }
    
    func setupLegend() {
        let items = lungsExaminationResult.getLegendItems(age: patientAge)
        let itemsSize: CGFloat = 35
        
        for item in items {
            var view: UIView?
            var text: String?
            
            switch item {
            case .notRecordedItemView:
                view = SMLegendNotRecordedItemView.fromNib()
                text = "legend_not_recorded_item".localized
            case .recordedItemView:
                view = SMLegendRecordedItemView.fromNib()
                text = "legend_recorded_item".localized
            case .invalidItemView:
                view = SMLegendInvalidItemView.fromNib()
                text = "legend_invalid_item".localized
            case .validItemView:
                view = SMLegendValidItemView.fromNib()
                text = "legend_valid_item".localized
            case .noChangesItemView:
                view = SMLegendNoChangesItemView.fromNib()
                text = "legend_no_changes_item".localized
            case .innocentChangesItemView:
                view = SMLegendInnocentChangesItemView.fromNib()
                text = "legend_innocent_changes_item".localized
            case .seriousChangesItemView:
                view = SMLegendSeriousChangesItemView.fromNib()
                text = "legend_serious_changes_item".localized
            case .extendedItemView:
                let extendedItemView = SMLegendExtendedItemView.fromNib()
                legendStackView.addArrangedSubview(extendedItemView)
                extendedItemView.translatesAutoresizingMaskIntoConstraints = false
                extendedItemView.wheezesLabel.text = "legend_wheezes".localized
                extendedItemView.rhonchiLabel.text = "legend_rhonchi".localized
                extendedItemView.coarseCracklesLabel.text = "legend_coarse_crackles".localized
                extendedItemView.fineCracklesLabel.text = "legend_fine_crackles".localized
                extendedItemView.heightAnchor.constraint(equalToConstant: 70).isActive = true
                extendedItemView.widthAnchor.constraint(equalTo: legendStackView.widthAnchor, multiplier: 0.9)
                
                let labels: [UILabel] = [extendedItemView.rhonchiLabel, extendedItemView.wheezesLabel, extendedItemView.fineCracklesLabel, extendedItemView.coarseCracklesLabel]
                labels.forEach({
                    $0.font = .systemFont(ofSize: 17, weight: .light)
                    $0.textColor = Constants.Colors.StethoMeDarkText })
            }
            
            if let view = view, let text = text {
                let legendItem = LegendItemView.fromNib()
                legendItem.configure(withView: view, text: text)
                legendStackView.addArrangedSubview(legendItem)
                legendItem.translatesAutoresizingMaskIntoConstraints = false
                legendItem.heightAnchor.constraint(equalToConstant: itemsSize).isActive = true
                legendItem.widthAnchor.constraint(equalTo: legendStackView.widthAnchor, multiplier: 0.9).isActive = true
            }
        }
    }
}
