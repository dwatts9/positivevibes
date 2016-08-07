//
//  FeedVC.swift
//  PositiveVibes
//
//  Created by Damiens Macbook HO! on 8/7/16.
//  Copyright © 2016 Damien Watts. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase

class FeedVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func signOutTapped(_ sender: AnyObject) {
        //need to sign out of firebase first and then remove ID from the keychain
        try!FIRAuth.auth()?.signOut()
        //remove the KEY UID from that signin
        let keychainResult = KeychainWrapper.removeObjectForKey(KEY_UID)
        print("DW: ID removed from keychain \(keychainResult)")
        //go back to the sign in VC
        performSegue(withIdentifier: "goToSignInScreen", sender: nil)
    }
   

}
