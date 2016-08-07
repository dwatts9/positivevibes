//
//  ViewController.swift
//  PositiveVibes
//
//  Created by Damiens Macbook HO! on 8/6/16.
//  Copyright © 2016 Damien Watts. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit

class SignInVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func facebookButtonTapped(_ sender: AnyObject) {
        //authenicate with FB
        let facebookLogin = FBSDKLoginManager()
        //rewuest read permissions, they might cancel it and they might be ok with it
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("DW: Unable to authenicate with Facebook - \(error)")
                //this is for if the user cancels the permission is true
            } else if result?.isCancelled == true {
                print("DW: user canceled Facebook authentication")
            } else {
                print("DW: Successfully authenticated with Facebook")
                //this is how you get the credential for facebook and you create it with a access token
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                //have to call the firebase auth
                self.firebaseAuthenticate(credential)
            }
        }
    }
    
    //authenicate with Firebase
    func firebaseAuthenticate(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("DW: Unable to authenticate with Firebase - \(error)")
            } else {
                print("DW: Successfully authenticated with Firebase")
            }
        })
    
    }

}

