//
//  SubscriptionTileCollectionViewCell.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 14/01/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

class SubscriptionTileCollectionViewCell: UICollectionViewCell, TileableCell {
    
    var tileType: AvailableTiles = .subscription
    
    typealias Entity = IPTile
    @IBOutlet private weak var tile: Entity!
    @IBOutlet private weak var accessoryImageRight: UIImageView!
    @IBOutlet private weak var accessoryButtonLeft: UIButton!
    @IBOutlet weak var tileLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var tileRightConstraint: NSLayoutConstraint!
    
    func setupCellForStatus(_ status: TileStatus) {
        self.accessoryImageRight.image = Theme.current.dragDropImage()
        tile.status = status
        UIView.animate(withDuration: AppConfiguration.Animations.duration, animations: {
            switch status {
            case .normal:
                self.tileLeftConstraint.constant = 0
                self.tileRightConstraint.constant = 0
            case .edit:
                self.tileLeftConstraint.constant = self.leftConstraintValue
                self.tileRightConstraint.constant = self.rightConstraintValue
                self.setupVisibilityButton()
            }
            self.layoutIfNeeded()
        })
    }
    
    private func setupVisibilityButton() {
        if Client.providers.tileProvider.visibleTiles.contains(tileType) {
            accessoryButtonLeft.setImage(Asset.Piax.Global.eyeActive.image, for: .normal)
            accessoryButtonLeft.setImage(Asset.Piax.Global.eyeInactive.image, for: .highlighted)
        } else {
            accessoryButtonLeft.setImage(Asset.Piax.Global.eyeInactive.image, for: .normal)
            accessoryButtonLeft.setImage(Asset.Piax.Global.eyeActive.image, for: .highlighted)
        }
    }
    
    @IBAction private func changeTileVisibility() {
        var visibleTiles = Client.providers.tileProvider.visibleTiles
        if Client.providers.tileProvider.visibleTiles.contains(tileType) {
            let tiles = visibleTiles.filter { $0 != tileType }
            Client.providers.tileProvider.visibleTiles = tiles
        } else {
            visibleTiles.append(tileType)
            Client.providers.tileProvider.visibleTiles = visibleTiles
        }
        Macros.postNotification(.PIAThemeDidChange)
    }
}
