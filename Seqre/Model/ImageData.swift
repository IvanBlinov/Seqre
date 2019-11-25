//
//  Image.swift
//  Seqre
//
//  Created by Ivan Blinov on 11/22/19.
//  Copyright © 2019 Ivan Blinov. All rights reserved.
//

import Foundation
import RealmSwift

class ImageData: Object {
    
    @objc dynamic var base64: String = ""
    var parentDirectory = LinkingObjects(fromType: Directory.self, property: "images")
}
