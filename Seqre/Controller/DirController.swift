//
//  MainVC.swift
//  Seqre
//
//  Created by Ivan Blinov on 11/21/19.
//  Copyright © 2019 Ivan Blinov. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import SwipeCellKit
import AVFoundation

private let reuseIdentifier = "Directory"

class DirController: UITableViewController, SwipeTableViewCellDelegate, AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("error occured : \(error.localizedDescription)")
        }

        if let dataImage = photo.fileDataRepresentation() {
            print(UIImage(data: dataImage)?.size as Any)

            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImage.Orientation.right)
            
            do {
                try realm.write {
                    let loginAttempt = LoginAttempt()
                    loginAttempt.photo = image.jpegData(compressionQuality: 1)!.base64EncodedString()
                    currentProfile?.loginAttempts.append(loginAttempt)
                }
            } catch {
                
            }
            /**
               save image in array / do whatever you want to do with the image here
            */
            

        } else {
            print("some error here")
        }
    }
    
    let realm = try! Realm()
    
    var dirs = List<Directory>()
    var currentProfile: Profile?

    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Folders"
        
        self.tableView.separatorStyle = .none
        self.tableView.rowHeight = 100
        self.tableView.backgroundColor = .white
        self.tableView.register(DirCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        self.navigationController?.navigationBar.isHidden = false
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddDir))
        self.navigationItem.rightBarButtonItem = addButton
        
        // TODO mb add logout button
        // TODO also mb add logout after swiping app
        self.navigationItem.leftBarButtonItem = nil
        
        startCamera()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            if self.dirs[indexPath.row].password != "" {
                self.deleteDirWithPass(at: indexPath, title: "Confirm password to delete")
            } else {
                self.deleteDir(at: indexPath)
            }
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "trash-icon")
        
        let editAction = SwipeAction(style: .default, title: "Edit") { action, indexPath in
            // handle action by updating model with deletion
            if self.dirs[indexPath.row].password != "" {
                self.editDirWithPass(at: indexPath, title: "Confirm password to edit")
            } else {
                self.editDir(at: indexPath)
            }
        }
        
        return [deleteAction, editAction]
    }
    
    func editDirWithPass(at indexPath: IndexPath, title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        var textField = UITextField()
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            //what will happen when the user clicks the Add Item butoon
            let dirToEdit = self.dirs[indexPath.row]
            if textField.text == dirToEdit.password {
                print("Editing")
                self.editDir(at: indexPath)
            } else {
                self.editDirWithPass(at: indexPath, title: "Wrong password")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alert.addAction(action)
        alert.addAction(cancelAction)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Password"
            textField = alertTextField
        }
        present(alert, animated: true, completion: nil)
    }
    
    func editDir(at indexPath: IndexPath) {
        let editDirVC = EditDirVC()
        editDirVC.dir = dirs[indexPath.row]
        let navController = UINavigationController(rootViewController: editDirVC)
        navController.navigationBar.tintColor = .black
        navController.view.frame = tableView.bounds
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true) {
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .selection
        options.transitionStyle = .border
        return options
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dirs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! DirCell
        cell.delegate = self
        cell.profileImageView.image = UIImage.fromBase64(base64: dirs[indexPath.row].avatar)
        cell.usernameButton.setTitle(dirs[indexPath.row].name, for: .normal)

        //cell.layer.borderWidth = 1
        //cell.layer.borderColor = UIColor.black.cgColor
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentDir = dirs[indexPath.row]
        if (currentDir.password == "") {
            takePhoto()
            let imagesController = ImagesController(collectionViewLayout: UICollectionViewFlowLayout())
            imagesController.images = currentDir.images
            self.navigationController?.pushViewController(imagesController, animated: true)
        } else {
            enterDirPassword(with: currentDir, title: "Enter password")
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func enterDirPassword(with currentDir: Directory, title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        var passwordField = UITextField()
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            self.takePhoto()
            //what will happen when the user clicks the Add Item butoon
            if (passwordField.text! == currentDir.password) {
                let imagesController = ImagesController(collectionViewLayout: UICollectionViewFlowLayout())
                imagesController.images = currentDir.images
                self.navigationController?.pushViewController(imagesController, animated: true)
            } else if (passwordField.text! == currentDir.fakePassword) {
                let imagesController = ImagesController(collectionViewLayout: UICollectionViewFlowLayout())
                imagesController.images = currentDir.fakeImages
                self.navigationController?.pushViewController(imagesController, animated: true)
            } else {
                print("Wrong password confirmation")
                self.enterDirPassword(with: currentDir, title: "Wrong password")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alert.addAction(action)
        alert.addAction(cancelAction)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Password"
            passwordField = alertTextField
        }

        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func handleAddDir() {
        let alert = UIAlertController(title: "Add New Directory", message: "", preferredStyle: .alert)
        var nameField = UITextField()
        let action = UIAlertAction(title: "Next", style: .default) { (action) in
            self.passwordAddAlert(with: nameField.text!, title: "Add Password")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alert.addAction(action)
        alert.addAction(cancelAction)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Directory"
            nameField = alertTextField
        }
        present(alert, animated: true, completion: nil)
    }
    
    func passwordAddAlert(with folderName: String, title: String) {
        //what will happen when the user clicks the Add Item butoon
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        var passwordField = UITextField()
        var confirmPasswordField = UITextField()
        let action = UIAlertAction(title: "Create", style: .default) { (action) in
            //what will happen when the user clicks the Add Item butoon
            if (passwordField.text! == confirmPasswordField.text!) {
                do {
                    try self.realm.write {
                        let newDirectory = Directory()
                        newDirectory.name = folderName
                        newDirectory.password = passwordField.text!
                        self.dirs.append(newDirectory)
                    }
                } catch {
                    print("Error saving context \(error)")
                }
                self.tableView.reloadData()
            } else {
                print("Wrong password confirmation")
                self.passwordAddAlert(with: folderName, title: "Wrong password confirmation")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alert.addAction(action)
        alert.addAction(cancelAction)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Password"
            passwordField = alertTextField
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Confirm Password"
            confirmPasswordField = alertTextField
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteDirWithPass(at indexPath: IndexPath, title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        var textField = UITextField()
        let action = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            //what will happen when the user clicks the Add Item butoon
            let dirToDelete = self.dirs[indexPath.row]
            if textField.text == dirToDelete.password {
                print("deleting")
                do {
                    try self.realm.write {
                        self.realm.delete(dirToDelete)
                    }
                } catch {
                    print("Error while deleting category \(error)")
                }
                self.tableView.reloadData()
            } else {
                self.deleteDirWithPass(at: indexPath, title: "Wrong password")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alert.addAction(action)
        alert.addAction(cancelAction)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Password"
            textField = alertTextField
        }
        present(alert, animated: true, completion: nil)
    }
    
    func deleteDir(at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Do you really want to delete?", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            //what will happen when the user clicks the Add Item butoon
            let dirToDelete = self.dirs[indexPath.row]
            do {
                try self.realm.write {
                    self.realm.delete(dirToDelete)
                }
            } catch {
                print("Error while deleting category \(error)")
            }
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func save(directory: Directory) {
        do {
            try realm.write {
                realm.add(directory)
            }
        } catch {
            print("Error saving context \(error)")
        }
        tableView.reloadData()
    }
    
    @objc func handleRefresh() {
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
    }
    
    func getDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices: NSArray = AVCaptureDevice.devices() as NSArray;
        for de in devices {
            let deviceConverted = de as! AVCaptureDevice
            if(deviceConverted.position == position){
               return deviceConverted
            }
        }
       return nil
    }
    
    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            kCVPixelBufferWidthKey as String: 160,
            kCVPixelBufferHeightKey as String: 160
        ]
        settings.previewPhotoFormat = previewFormat
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func startCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        cameraOutput = AVCapturePhotoOutput()

        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
           let input = try? AVCaptureDeviceInput(device: device) {
            if (captureSession.canAddInput(input)) {
                captureSession.addInput(input)
                if (captureSession.canAddOutput(cameraOutput)) {
                    captureSession.addOutput(cameraOutput)
                    captureSession.startRunning()
                }
            } else {
                print("issue here : captureSesssion.canAddInput")
            }
        } else {
            print("some problem here")
        }
    }
    
}
