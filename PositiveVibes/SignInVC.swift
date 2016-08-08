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
import SwiftKeychainWrapper

class SignInVC: UIViewController {
    
    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var passField: FancyField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //checking if the key exist, checking for string with a UID
        if let _ = KeychainWrapper.stringForKey(KEY_UID) {
            print("DW: ID found in keychain")
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
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
                if let user = user {
                    //this user.uid is coming from the completion handler up above
                    //could do more than the provider like posts and likes from that user but he lazy(uses creditial instead of user.
                    let userData = ["provider": credential.provider]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
            }
        })
    
    }
    //this will check the email and has error handling
    @IBAction func signInTapped(_ sender: AnyObject) {
        //check if theres actually text in the field
        if let email = emailField.text, let password = passField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    print("DW: Email user authenticate with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil {
                            print("DW: Unable to authenticate with Firebase using email")
                        } else {
                            print("DW: Successfully authenticated with Firebase")
                            if let user = user {
                            let userData = ["provider": user.providerID]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }
                        }
                    })
                }
            })
        }
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.setString(id, forKey: KEY_UID)
        print("DW: Data saved to keychain \(keychainResult)")
        //putting this here will make it go to the new VC once its get authenicated for a automatic sign in
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
}

