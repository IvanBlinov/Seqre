//
//  Directory.swift
//  Seqre
//
//  Created by Ivan Blinov on 11/21/19.
//  Copyright © 2019 Ivan Blinov. All rights reserved.
//

import Foundation
import RealmSwift

class Directory: Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var password: String = ""
    let images = List<ImageData>()
    var parentProfile = LinkingObjects(fromType: Profile.self, property: "dirs")
}
