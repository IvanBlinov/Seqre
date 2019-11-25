//
//  Constants.swift
//  Seqre
//
//  Created by Ivan Blinov on 11/22/19.
//  Copyright © 2019 Ivan Blinov. All rights reserved.
//

import Firebase

let DB_REF = Database.database().reference()

let STORAGE_REF = Storage.storage().reference()

let STORAGE_PROFILE_IMAGES_REF = STORAGE_REF.child("profile_images")
let STORAGE_POST_IMAGES_REF = STORAGE_REF.child("post_images")
