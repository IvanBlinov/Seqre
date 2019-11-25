//
//  DirCell.swift
//  Seqre
//
//  Created by Ivan Blinov on 11/22/19.
//  Copyright © 2019 Ivan Blinov. All rights reserved.
//

import Foundation
import UIKit
import SwipeCellKit

class DirCell: SwipeCollectionViewCell {
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "folder")
        iv.clipsToBounds = true
        iv.backgroundColor = .white
        return iv
    }()
    
    lazy var usernameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Username", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 0, width: 100, height: 0)

        addSubview(usernameButton)
        usernameButton.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        usernameButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
