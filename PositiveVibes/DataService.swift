//
//  DataService.swift
//  PositiveVibes
//
//  Created by Damiens Macbook HO! on 8/7/16.
//  Copyright © 2016 Damien Watts. All rights reserved.
//

import Foundation
import Firebase

//global outside of the class. this goes into google service info plist and getting the url with the appname from Firebase
let DB_BASE = FIRDatabase.database().reference()
let STORAGE_BASE = FIRStorage.storage().reference()

class DataService {
    
    //its global everything set in here will be globally accessible
    static let ds = DataService()
    
    
    
    //DB references
    private var _REF_BASE = DB_BASE
    //whatever is put in the string attaches to the url on firebase for the DB
    private var _REF_POSTS = DB_BASE.child("posts")
    private var _REF_USERS = DB_BASE.child("user")
    
    //Storage references (posts-pic is the name of the folder
    private var _REF_POST_IMAGES = STORAGE_BASE.child("post-pics")

    
    //made so no one can reference the private vars
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    var REF_POSTS: FIRDatabaseReference {
        return _REF_POSTS
    }
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_POST_IMAGES: FIRStorageReference {
        return _REF_POST_IMAGES
    }
    
    //getting the data from firebase
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, String>) {
        //this looks at the users, the userID and all the data under that (posts and likes and provider) and updating it with the data thats is being passed in. this one line is all i need to write data to firebase 
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    
    
    
}
