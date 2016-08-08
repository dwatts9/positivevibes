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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        //this initializes the listener (listening for changes that happen on the app) REF_POSTS will listen to the posts
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            print(snapshot.value)
        })
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
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
