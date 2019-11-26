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
    @objc dynamic var fakePassword: String = ""
    @objc dynamic var avatar: String = UIImage(named: "folder-circle-1")!.withRenderingMode(.alwaysOriginal).jpegData(compressionQuality: 1)!.base64EncodedString()
    let images = List<ImageData>()
    let fakeImages = List<ImageData>()
    var parentProfile = LinkingObjects(fromType: Profile.self, property: "dirs")
}
