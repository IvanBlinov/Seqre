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
import Firebase

private let reuseIdentifier = "PhotoCell"

class ImagesController: UICollectionViewController, UICollectionViewDelegateFlowLayout, YMSPhotoPickerViewControllerDelegate, ViewerControllerDataSource {
        
    // MARK: - Properties
    
    let realm = try! Realm()
    var images: List<ImageData>?
    var imagesData: NSArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(PhotoItemCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .white
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        self.navigationController?.navigationBar.isHidden = false
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddFiles))
        self.navigationItem.rightBarButtonItem = addButton
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if let images = self.images {
            return images.count
        } else {
            return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var photos = [SKPhoto]()
        for imageData:ImageData in images! {
            let photo = SKPhoto.photoWithImage(UIImage.fromBase64(base64: imageData.base64))
            photos.append(photo)
        }
        let browser = SKPhotoBrowser(photos: photos, initialPageIndex: indexPath.row)
        browser.initializePageIndex(indexPath.row)
        present(browser, animated: true, completion: {})
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoItemCell
        if let images = self.images {
            let base64 = images[indexPath.row].base64
            cell.img.image = UIImage(data: NSData(base64Encoded: base64, options: .ignoreUnknownCharacters)! as Data)
        }
        return cell
        
        //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserPhotoCell
        //if let dir = self.dir {
         //   cell.imageData = dir.images[indexPath.row]
        //}
        //return cell
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
    
    @objc func handleAddFiles() {
        //self.yms_presentAlbumPhotoView(with: self)
        let pickerViewController = YMSPhotoPickerViewController.init()
        pickerViewController.numberOfPhotoToSelect = 10
        self.yms_presentCustomAlbumPhotoView(pickerViewController, delegate: self)
    }
    
    func photoPickerViewControllerDidReceivePhotoAlbumAccessDenied(_ picker: YMSPhotoPickerViewController!) {
        let alertController = UIAlertController(title: "Allow photo album access?", message: "Need your permission to access photo albums", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        alertController.addAction(dismissAction)
        alertController.addAction(settingsAction)

        self.present(alertController, animated: true, completion: nil)
    }
    
    func photoPickerViewControllerDidReceiveCameraAccessDenied(_ picker: YMSPhotoPickerViewController!) {
        let alertController = UIAlertController(title: "Allow camera album access?", message: "Need your permission to take a photo", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        alertController.addAction(dismissAction)
        alertController.addAction(settingsAction)

        // The access denied of camera is always happened on picker, present alert on it to follow the view hierarchy
        picker.present(alertController, animated: true, completion: nil)
    }

    
    func photoPickerViewController(_ picker: YMSPhotoPickerViewController!, didFinishPickingImages photoAssets: [PHAsset]!) {
        picker.dismiss(animated: true) {
        let imageManager = PHImageManager.init()
        let options = PHImageRequestOptions.init()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.isSynchronous = true

        var mutableImages = [String]()

        for asset: PHAsset in photoAssets
        {
            let scale = UIScreen.main.scale
            let targetSize = CGSize(width: (self.collectionView.bounds.width - 20*2) * scale, height: (self.collectionView.bounds.height - 20*2) * scale)
            imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options, resultHandler: { (image, info) in
                if let base64data = image?.jpegData(compressionQuality: 1.0)?.base64EncodedString(options: .lineLength64Characters) {
                    mutableImages.append(base64data)
                }
                
            })
        }
        // Assign to Array with images
        self.saveBase64Data(with: mutableImages)
        self.updateModels()
        }
    }
    
    func saveBase64Data(with base64list: [String]) {
        do {
            try realm.write {
                let images = base64list.map { (base64) -> ImageData in
                    let image = ImageData()
                    image.base64 = base64
                    return image
                }
                self.images?.append(objectsIn: images)
            }
        } catch {
            print("Failed to save data ")
        }
        self.collectionView.reloadData()
    }
    
    func updateModels() {
        
        self.images?.forEach({ (imageData) in
            if !imageData.loaded {
                if let uploadData = UIImage.fromBase64(base64: imageData.base64).jpegData(compressionQuality: 0.5) {
                    let fileName = NSUUID().uuidString
                    
                    let storageRef = STORAGE_PROFILE_IMAGES_REF.child(fileName)
                        storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                            do {
                                try self.realm.write {
                                    if let _ = error {
                                        imageData.loaded = false
                                    }
                                    imageData.loaded = true
                                }
                            } catch {
                                
                            }
                        })
                }
            }
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // selected image
        guard let profileImage = info[.editedImage] as? UIImage else {
            return
        }
        
        let image = profileImage.withRenderingMode(.alwaysOriginal)
        let imageData = image.jpegData(compressionQuality: 100)
        guard let base64 = imageData?.base64EncodedString() else { return }
        let imageToSave = ImageData()
        imageToSave.base64 = base64
        do {
            try realm.write {
                realm.add(imageToSave)
                print("Successfully saved image with data: \(base64)")
            }
        } catch {
            print("Fail to save image with error: ", error.localizedDescription)
        }
        
        self.dismiss(animated: true, completion: nil)
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
        let image = UIImage(data: NSData(base64Encoded: images![indexPath.row].base64, options: .ignoreUnknownCharacters)! as Data)
        let viewableImage = ViewableImage(with: image!)
        return viewableImage
    }
}

class PhotoItemCell: UICollectionViewCell {
    
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

struct DeviceInfo {
    struct Orientation {
        // indicate current device is in the LandScape orientation
        static var isLandscape: Bool {
            get {
                return UIDevice.current.orientation.isValidInterfaceOrientation
                    ? UIDevice.current.orientation.isLandscape
                    : UIApplication.shared.statusBarOrientation.isLandscape
            }
        }
        // indicate current device is in the Portrait orientation
        static var isPortrait: Bool {
            get {
                return UIDevice.current.orientation.isValidInterfaceOrientation
                    ? UIDevice.current.orientation.isPortrait
                    : UIApplication.shared.statusBarOrientation.isPortrait
            }
        }
    }
}
