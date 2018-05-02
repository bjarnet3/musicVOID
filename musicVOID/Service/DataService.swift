//
//  DataService.swift
//  musicVOID
//
//  Created by Bjarne Tvedten on 28.04.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit
import Firebase

// Public Static Variables
let userID = "0kDX22RQmUSRSqFi85HYtGxesxe1"
let eventID = "00001"

let DB_BASE = Database.database().reference()
let STORAGE_BASE = Storage.storage().reference()

enum DBFolder: String {
    case voting = "voting"
    case playlist = "playlist"
    case status = "status"
}

class DataService {
    // Singleton
    static let connect = DataService()
    
    // DB references // ROOT
    private var _REF_BASE = DB_BASE
    
    // DB child references // Base "folders"
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_EVENTS = DB_BASE.child("events")
    
    // Storage references
    private var _REF_PROFILE_IMAGES = STORAGE_BASE.child("profile").child(userID)
    private var _REF_MUSIC_EVENT_IMAGES = STORAGE_BASE.child("musicArt").child("Event").child(eventID)
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_EVENTS: DatabaseReference {
        return _REF_EVENTS
    }
    
    var REF_PROFILE_IMAGES: StorageReference {
        return _REF_PROFILE_IMAGES
    }
    
    var REF_MUSIC_EVENT_IMAGES: StorageReference {
        return _REF_MUSIC_EVENT_IMAGES
    }
}

