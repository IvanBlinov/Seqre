//
//  DirController.swift
//  Seqre
//
//  Created by Ivan Blinov on 11/22/19.
//  Copyright © 2019 Ivan Blinov. All rights reserved.
//

import UIKit
import RealmSwift
import YangMingShan
import Viewer
import SKPhotoBrowser

private let reuseIdentifier = "LoginAttemptCell"

class LoginAttemptsVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, ViewerControllerDataSource {
        
    // MARK: - Properties
    
    let realm = try! Realm()
    var loginAttempts: List<LoginAttempt>?
    var imagesData: NSArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(LoginAttemptItemCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .white
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        self.navigationController?.navigationBar.isHidden = false
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if let loginAttempts = self.loginAttempts {
            return loginAttempts.count
        } else {
            return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var photos = [SKPhoto]()
        for loginAttempts: LoginAttempt in loginAttempts! {
            let photo = SKPhoto.photoWithImage(UIImage.fromBase64(base64: loginAttempts.photo))
            photos.append(photo)
        }
        let browser = SKPhotoBrowser(photos: photos, initialPageIndex: indexPath.row)
        browser.initializePageIndex(indexPath.row)
        present(browser, animated: true, completion: {})
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LoginAttemptItemCell
        if let loginAttempts = self.loginAttempts {
            let base64 = loginAttempts[indexPath.row].photo
            cell.img.image = UIImage(data: NSData(base64Encoded: base64, options: .ignoreUnknownCharacters)! as Data)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    @objc func handleRefresh() {
       collectionView.reloadData()
       collectionView.refreshControl?.endRefreshing()
    }

    // MARK: Viewer Delegate

    func numberOfItemsInViewerController(_ viewerController: ViewerController) -> Int {
        return 1
    }
    
    func viewerController(_ viewerController: ViewerController, viewableAt indexPath: IndexPath) -> Viewable {
        let image = UIImage(data: NSData(base64Encoded: loginAttempts![indexPath.row].photo, options: .ignoreUnknownCharacters)! as Data)
        let viewableImage = ViewableImage(with: image!)
        return viewableImage
    }
}

class LoginAttemptItemCell: UICollectionViewCell {
    
    var img = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        img.contentMode = .scaleAspectFill
        img.clipsToBounds=true
        self.addSubview(img)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        img.frame = self.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
