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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addImage: CircleView!
    @IBOutlet weak var captionField: FancyField!
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true 
        imagePicker.delegate = self
        
        //this initializes the listener (listening for changes that happen on the app) REF_POSTS will listen to the posts
        //Get the data of the posts could be the user
        //getting the children from the JSON whic his the uid with snapshot children
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                self.posts = []
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
            //when the listener finishes listening you have to reload the tableView Data, when you dont see the tableView
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
        let post = posts[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl) {
                cell.configureCell(post: post, img: img)
                return cell
            } else {
                cell.configureCell(post: post)
            }
            return cell
            
        } else {
            return PostCell()
        }
    }
    
    //this is for when the image is picked it will disappear
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        //it because im letting them edit the image
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            addImage.image = image
            imageSelected = true
        } else {
            print("DW: A valid image wasnt selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImageTapped(_ sender: AnyObject) {
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postButtonTapped(_ sender: AnyObject) {
        guard let caption = captionField.text, caption != "" else {
            //should put an alert here or highlight the textfield to let them know that it aint right
            print("DW: Caption must be entered")
            return
        }
        //the imageSelected was set to a boolean so now the only way the rest of the code will run after the guard is to have a image selected, this stops the ability to upload post with no image
        guard let img = addImage.image, imageSelected == true else {
            print("DW: An image must be selected")
            return
        }
        //actually uploading the image/ converting the image into imagedata/ and compressing
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            //create a uid random string attachment
            let imgUid = NSUUID().uuidString
            //this tells firebase what type of image it is
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpg"
            //using the child value for this particular image
            DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: metaData) { (metaData, error) in
                if error != nil {
                    print("DW: Unable to upload image to firebase storage")
                } else {
                    print("DW: Successfully loaded image to firebase storage")
                    let downloadURL = metaData?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                    self.postToFirebase(imgUrl: url)
                        
                    }
                }
            }
        }
    }
    //this info is from firebase and matches directly
    func postToFirebase(imgUrl: String) {
        let post: Dictionary<String, AnyObject> = [
            "caption": captionField.text!,
            "imageUrl": imgUrl,
            "likes": 0
            ]
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        //reset back to the original
        captionField.text = ""
        imageSelected = false
        addImage.image = UIImage(named: "add-image")
        
        tableView.reloadData()
        
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
