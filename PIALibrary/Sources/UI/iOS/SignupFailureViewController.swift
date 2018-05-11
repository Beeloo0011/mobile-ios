//
//  SignupFailureViewController.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 10/8/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit

class SignupFailureViewController: AutolayoutViewController {
    @IBOutlet private weak var imvPicture: UIImageView!

    @IBOutlet private weak var labelTitle: UILabel!
    
    @IBOutlet private weak var labelMessage: UILabel!

    @IBOutlet private weak var buttonSubmit: ActivityButton!
    
    var error: Error?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true

        title = L10n.Signup.Failure.vcTitle
        imvPicture.image = Asset.imageAccountFailed.image
        labelTitle.text = L10n.Signup.Failure.title
        labelMessage.text = L10n.Signup.Failure.message
            
        if let clientError = error as? ClientError {
            switch clientError {
            case .redeemInvalid:
                title = L10n.Welcome.Redeem.title
                imvPicture.image = Asset.imageRedeemInvalid.image
                labelTitle.text = L10n.Signup.Failure.Redeem.Invalid.title
                labelMessage.text = L10n.Signup.Failure.Redeem.Invalid.message
                break
                
            case .redeemClaimed:
                title = L10n.Welcome.Redeem.title
                imvPicture.image = Asset.imageRedeemClaimed.image
                labelTitle.text = L10n.Signup.Failure.Redeem.Claimed.title
                labelMessage.text = L10n.Signup.Failure.Redeem.Claimed.message
                break
                
            default:
                break
            }
        }
        
        buttonSubmit.title = L10n.Signup.Failure.submit.uppercased()
    }

    @IBAction private func submit() {
        perform(segue: StoryboardSegue.Signup.unwindFailureSegueIdentifier)
    }

    // MARK: Restylable
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        
        Theme.current.applyTitle(labelTitle, appearance: .dark)
        Theme.current.applyBody1(labelMessage, appearance: .dark)
        Theme.current.applyActionButton(buttonSubmit)
    }
}
