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
    
    var posts = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        //this initializes the listener (listening for changes that happen on the app) REF_POSTS will listen to the posts
        //Get the data of the posts could be the user
        //getting the children from the JSON whic his the uid with snapshot children
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    //get the key (uid) for the snap
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
            }
            //when the listener finishes listening you have to reload the tableView Data
            self.tableView.reloadData()
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //just to check if things are working
        
        let post = posts[indexPath.row]
        print("DW: \(post.caption)")
        
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
