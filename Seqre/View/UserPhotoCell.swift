//
//  UserPostCell.swift
//  InstagramProj
//
//  Created by Ivan Blinov on 11/19/19.
//  Copyright © 2019 Ivan Blinov. All rights reserved.
//

import UIKit

class UserPhotoCell: UICollectionViewCell {
    
    var imageData: ImageData? {
        
        didSet {
            
            guard let base64 = imageData?.base64 else { return }
            postImageView.image = UIImage.fromBase64(base64: base64)
        }
    }
    
    let postImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(postImageView)
        postImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
