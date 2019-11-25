//
//  Profile.swift
//  Seqre
//
//  Created by Ivan Blinov on 11/21/19.
//  Copyright © 2019 Ivan Blinov. All rights reserved.
//

import Foundation
import RealmSwift

class Profile: Object {
    
    @objc dynamic var password = ""
    let dirs = List<Directory>()
}
