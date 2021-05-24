//
//  HelpSettingsViewController.swift
//  PIA VPN
//  
//  Created by Jose Blaya on 21/5/21.
//  Copyright © 2021 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software 
//  without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
//  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
//  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//

import UIKit
import SwiftyBeaver
import PIALibrary
import SafariServices

private let log = SwiftyBeaver.self

class HelpSettingsViewController: PIABaseSettingsViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private lazy var switchEnableNMT = UISwitch()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.sectionFooterHeight = UITableView.automaticDimension
        tableView.estimatedSectionFooterHeight = 1.0
                
        tableView.delegate = self
        tableView.dataSource = self
        
        switchEnableNMT.addTarget(self, action: #selector(toggleNMT(_:)), for: .valueChanged)

        NotificationCenter.default.addObserver(self, selector: #selector(reloadSettings), name: .PIASettingsHaveChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        styleNavigationBarWithTitle(L10n.Settings.Section.help)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let trustedNetworksVC = segue.destination as? TrustedNetworksViewController {
            trustedNetworksVC.persistentConnectionValue = pendingPreferences.isPersistentConnection
            trustedNetworksVC.vpnType = pendingPreferences.vpnType
        }
    }
    
    @objc private func reloadSettings() {
        tableView.reloadData()
    }

    @objc private func toggleNMT(_ sender: UISwitch) {
        let preferences = Client.preferences.editable()
        preferences.nmtRulesEnabled = sender.isOn
        preferences.commit()
        reloadSettings()
        settingsDelegate.refreshSettings()
    }

    // MARK: Restylable
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
    
        styleNavigationBarWithTitle(L10n.Settings.Section.help)
        // XXX: for some reason, UITableView is not affected by appearance updates
        if let viewContainer = viewContainer {
            Theme.current.applyPrincipalBackground(view)
            Theme.current.applyPrincipalBackground(viewContainer)
        }
        Theme.current.applyPrincipalBackground(tableView)
        Theme.current.applyDividerToSeparator(tableView)
        tableView.reloadData()
    }

}

extension HelpSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return HelpSections.all().count
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section == 0, let cell = tableView.dequeueReusableCell(withIdentifier: Cells.footer) {
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.style(style: TextStyle.textStyle21)
            cell.backgroundColor = .clear
            cell.textLabel?.text =  L10n.Settings.Log.information
            return cell
        }
        return nil

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.setting, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.accessoryView = nil
        cell.selectionStyle = .default
        cell.detailTextLabel?.text = nil

        let section = HelpSections.all()[indexPath.section]
        
        switch section {
        case .sendDebugLogs:
            cell.textLabel?.text = L10n.Settings.ApplicationInformation.Debug.title
            cell.detailTextLabel?.text = nil
        case .latestNews:
            cell.textLabel?.text = L10n.Settings.Cards.History.title
            cell.detailTextLabel?.text = nil
        case .version:
            cell.textLabel?.text = Macros.localizedVersionFullString()
            cell.detailTextLabel?.text = nil
            cell.accessoryType = .none
        }

        Theme.current.applySecondaryBackground(cell)
        if let textLabel = cell.textLabel {
            Theme.current.applySettingsCellTitle(textLabel,
                                                 appearance: .dark)
            textLabel.backgroundColor = .clear
        }
        if let detailLabel = cell.detailTextLabel {
            Theme.current.applySubtitle(detailLabel)
            detailLabel.backgroundColor = .clear
        }
        
        let backgroundView = UIView()
        Theme.current.applyPrincipalBackground(backgroundView)
        cell.selectedBackgroundView = backgroundView

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = HelpSections.all()[indexPath.section]

        switch section {
            case .sendDebugLogs:
                submitDebugReport()
            case .latestNews:
                let callingCards = CardFactory.getAllCards()
                if !callingCards.isEmpty {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let cardsController = storyboard.instantiateViewController(withIdentifier: "PIACardsViewController") as? PIACardsViewController {
                        cardsController.setupWith(cards: callingCards)
                        cardsController.modalPresentationStyle = .overCurrentContext
                        self.present(cardsController, animated: true)
                    }
                }
            default: break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func submitDebugReport() {
        self.showLoadingAnimation()
        Client.providers.vpnProvider.submitDebugReport(true) { (reportIdentifier, error) in
            self.hideLoadingAnimation()
            
            let title: String
            let message: String

            defer {
                let alert = Macros.alert(title, message)
                alert.addDefaultAction(L10n.Global.ok)
                self.present(alert, animated: true, completion: nil)
            }

            guard let reportId = reportIdentifier else {
                title = L10n.Settings.ApplicationInformation.Debug.Failure.title
                message = L10n.Settings.ApplicationInformation.Debug.Failure.message
                return
            }
            guard !reportId.isEmpty else {
                title = L10n.Settings.ApplicationInformation.Debug.Empty.title
                message = L10n.Settings.ApplicationInformation.Debug.Empty.message
                return
            }

            title = L10n.Settings.ApplicationInformation.Debug.Success.title
            message = L10n.Settings.ApplicationInformation.Debug.Success.message(reportId)
        }
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        Theme.current.applyTableSectionFooter(view)
    }

}
