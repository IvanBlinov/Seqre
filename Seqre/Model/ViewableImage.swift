//
//  ViewableImage.swift
//  Seqre
//
//  Created by Ivan Blinov on 11/22/19.
//  Copyright © 2019 Ivan Blinov. All rights reserved.
//

import Foundation
import Viewer

class ViewableImage: Viewable {
    
    init(with image: UIImage) {
        placeholder = image
        type = .image
        assetID = UUID().uuidString
        url = ""
    }
    
    var type: ViewableType
    
    var assetID: String?
    
    var url: String?
    
    var placeholder: UIImage
    
    func media(_ completion: @escaping (_ image: UIImage?, _ error: NSError?) -> Void) {
        completion(placeholder, nil)
    }
    
    
}
