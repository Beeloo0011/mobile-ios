//
//  TrustedNetworksViewController.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 18/12/2018.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit
import PIALibrary

struct Rule {
    var type: NMTType
    var rule: NMTRules
}

class TrustedNetworksViewController: AutolayoutViewController {

    @IBOutlet private weak var collectionView: UICollectionView!

    private var data = [Rule]()
    
    private var availableNetworks: [String] = []
    private var trustedNetworks: [String] = []
    private let currentNetwork: String? = nil
    private var hotspotHelper: PIAHotspotHelper!
    var shouldReconnectAutomatically = false
    var hasUpdatedPreferences = false
    var persistentConnectionValue = false
    var vpnType = ""
    
    private struct Cells {
        static let network = "NetworkCollectionViewCell"
        static let header = "NetworkHeaderCollectionViewCell"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadRulesData()
        self.hotspotHelper = PIAHotspotHelper(withDelegate: self)

        NotificationCenter.default.addObserver(self, selector: #selector(filterAvailableNetworks), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshContent),
                                               name: .RefreshNMTRules,
                                               object: nil)

        configureCollectionView()
        
        if !persistentConnectionValue,
            Client.preferences.nmtRulesEnabled {
            presentKillSwitchAlert()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        filterAvailableNetworks()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if shouldReconnectAutomatically,
            hasUpdatedPreferences{
            NotificationCenter.default.post(name: .PIASettingsHaveChanged,
                                            object: self,
                                            userInfo: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Restylable
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        
        styleNavigationBarWithTitle("")

        if let viewContainer = viewContainer {
            Theme.current.applyPrincipalBackground(viewContainer)
        }
        Theme.current.applyPrincipalBackground(collectionView)
        self.collectionView.reloadData()

    }
    
    // MARK: Private Methods
    private func presentKillSwitchAlert() {
        let alert = Macros.alert(nil, L10n.Settings.Nmt.Killswitch.disabled)
        alert.addCancelAction(L10n.Global.close)
        alert.addActionWithTitle(L10n.Global.enable) {
            let preferences = Client.preferences.editable()
            preferences.isPersistentConnection = true
            preferences.commit()
            NotificationCenter.default.post(name: .PIAPersistentConnectionSettingHaveChanged,
                                            object: self,
                                            userInfo: nil)
        }
        present(alert, animated: true, completion: nil)
    }
    
    private func configureCollectionView() {

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(UINib(nibName: Cells.network,
                                      bundle: nil),
                                forCellWithReuseIdentifier: Cells.network)
        collectionView.register(UINib(nibName: Cells.header, bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier:Cells.header)
        collectionView.delegate = self
        collectionView.dataSource = self
        filterAvailableNetworks()
    }
    
    @objc private func filterAvailableNetworks() {
        self.availableNetworks = Client.preferences.availableNetworks
        self.trustedNetworks = Client.preferences.trustedNetworks
        self.availableNetworks = self.availableNetworks.filter { !self.trustedNetworks.contains($0) }
        self.collectionView.reloadData()
    }
    
    private func reloadRulesData() {
        data = []
        let genericRules = Client.preferences.nmtGenericRules
        for rule in genericRules {
            if let type = NMTType(rawValue: rule.key), let rule = NMTRules(rawValue: rule.value) {
                data.append(Rule(type: type, rule: rule))
            }
        }
        data = data.sorted(by: { $0.type.order() < $1.type.order() })

    }
    
    // MARK: Actions
    @objc private func refreshContent() {
        reloadRulesData()
        self.collectionView.reloadItems(at: [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)])
    }
        
}

extension TrustedNetworksViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if Macros.isDevicePad {
            let size =  collectionView.frame.width/6
            return CGSize(width: size, height: size)
        } else {
            if !isLandscape {
                let size =  ((collectionView.frame.width/2) - 28)
                return CGSize(width: size, height: size)
            } else {
                let size =  collectionView.frame.width/4
                return CGSize(width: size, height: size)
            }
        }
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.network, for: indexPath) as! NetworkCollectionViewCell
        cell.data = self.data[indexPath.item]
        cell.viewShouldRestyle()

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {

        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Cells.header, for: indexPath) as! NetworkHeaderCollectionViewCell
            headerView.setup(withTitle: "Manage automation", andSubtitle: "Configure how PIA behave on connection to WiFi or Cellular networks. This excludes disconnecting manually.")
            return headerView

        default:
            assert(false, "Unexpected element kind")
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath) as! NetworkHeaderCollectionViewCell

        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .defaultHigh,
                                                  verticalFittingPriority: .fittingSizeLevel) 

    }

}

extension TrustedNetworksViewController: PIAHotspotHelperDelegate{
    
    func refreshAvailableNetworks(_ networks: [String]?) {
        if let networks = networks {
            self.availableNetworks = networks
            self.collectionView.reloadData()
        }
    }
    
}
