//
//  ModalNavigationSegue.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/25/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

class ModalNavigationSegue: UIStoryboardSegue {

    // XXX: dismissModal accessed via protocol is not exposed to Obj-C
    override func perform() {
        guard let modal = destination as? AutolayoutViewController else {
            fatalError("Segue destination is not a ModalController")
        }

        modal.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .stop,
            target: modal,
            action: #selector(modal.dismissModal)
        )
        modal.navigationItem.leftBarButtonItem?.accessibilityLabel = L10n.Global.close

        let nav = UINavigationController(rootViewController: modal)
        Theme.current.applyCustomNavigationBar(nav.navigationBar,
                                               withTintColor: nil,
                                               andBarTintColors: nil)
        
        if let coordinator = source.transitionCoordinator {
            coordinator.animate(alongsideTransition: { (context) in
                self.source.present(nav, animated: true, completion: nil)
            }, completion: nil)
        } else {
            nav.modalPresentationStyle = .overFullScreen
            source.present(nav, animated: true, completion: nil)
        }
    }
}
