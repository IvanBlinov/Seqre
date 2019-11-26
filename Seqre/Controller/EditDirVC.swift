//
//  EditDirVC.swift
//  Seqre
//
//  Created by Ivan Blinov on 11/26/19.
//  Copyright © 2019 Ivan Blinov. All rights reserved.
//

import UIKit
import RealmSwift

class EditDirVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    let realm = try! Realm()
    var dir: Directory?
    
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "folder4")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.layer.cornerRadius = button.frame.width / 2
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleSelectProfilePhoto), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Dir name fields
    
    let dirNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Name"
        label.font = UIFont.systemFont(ofSize: 8)
        label.textColor = .black
        return label
    }()
    
    let dirNameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.accessibilityLabel = "Something"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()
    
    let dirNameErrorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Error Message"
        label.font = UIFont.systemFont(ofSize: 8)
        label.textColor = .clear
        return label
    }()
    
    // MARK: - Password fields
    
    let passwordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Password"
        label.font = UIFont.systemFont(ofSize: 8)
        label.textColor = .black
        return label
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "New password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()
    
    let confirmPasswordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "ConfirmPassword"
        label.font = UIFont.systemFont(ofSize: 8)
        label.textColor = .black
        return label
    }()
    
    let confirmPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Confirm new password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()
    
    let passwordErrorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Error Message"
        label.font = UIFont.systemFont(ofSize: 8)
        label.textColor = .clear
        return label
    }()
    
    // MARK: - Fake password fields
    
    let fakePasswordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Fake password"
        label.font = UIFont.systemFont(ofSize: 8)
        label.textColor = .black
        return label
    }()
    
    let fakePasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Fake password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()
    
    let confirmFakePasswordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Confirm fake password"
        label.font = UIFont.systemFont(ofSize: 8)
        label.textColor = .black
        return label
    }()
    
    let confirmFakePasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Confirm fake password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()
    
    let fakePasswordErrorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Error Message"
        label.font = UIFont.systemFont(ofSize: 8)
        label.textColor = .clear
        return label
    }()
    
    // MARK: - Properties
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
        let addButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleConfirmEditing))
        self.navigationItem.rightBarButtonItem = addButton

        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancelButton))
        self.navigationItem.leftBarButtonItem = cancel
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 90, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 120, height: 120)
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        configureViewComponents()
        
        if let dir = self.dir {
            plusPhotoButton.setImage(UIImage.fromBase64(base64: dir.avatar).withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
    
    @objc func handleConfirmEditing() {
        if dirNameField.text! == "" {
            dirNameErrorLabel.textColor = .red
            dirNameErrorLabel.text = "Folder name shouldn't be empty"
            dirNameField.layer.borderWidth = 1.0
            dirNameField.layer.masksToBounds = true
            dirNameField.layer.borderColor = UIColor.red.cgColor
            dirNameField.shake()
            return
        } else {
            dirNameErrorLabel.textColor = .clear
        }
        if passwordTextField.text! != confirmPasswordTextField.text! {
            passwordErrorLabel.textColor = .red
            passwordErrorLabel.text = "Confirmed password must be the same"
            confirmPasswordTextField.layer.borderWidth = 1.0
            confirmPasswordTextField.layer.masksToBounds = true
            confirmPasswordTextField.layer.borderColor = UIColor.red.cgColor
            confirmPasswordTextField.shake()
            return
        } else {
            passwordErrorLabel.textColor = .clear
        }
        if fakePasswordTextField.text! != confirmFakePasswordTextField.text! {
            fakePasswordErrorLabel.textColor = .red
            fakePasswordErrorLabel.text = "Confirmed password must be the same"
            confirmFakePasswordTextField.layer.borderWidth = 1.0
            confirmFakePasswordTextField.layer.masksToBounds = true
            confirmFakePasswordTextField.layer.borderColor = UIColor.red.cgColor
            confirmFakePasswordTextField.shake()
            return
        } else {
            fakePasswordErrorLabel.textColor = .clear
        }
        do {
            try realm.write {
                if let base64 = plusPhotoButton.imageView?.image?.jpegData(compressionQuality: 1)?.base64EncodedString() {
                    dir!.avatar = base64
                }
                
                dir!.password = passwordTextField.text!
                dir!.fakePassword = fakePasswordTextField.text!
                
                if dirNameField.text != "" {
                    dir!.name = dirNameField.text!
                }
            }
            self.dismiss(animated: true, completion: nil)
        } catch {
            print("Error during updating directory ", error.localizedDescription)
        }
    }
    
    @objc func handleCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func formValidation() {
        
    }
    
    @objc func handleSelectProfilePhoto() {
        
        //configure image picker
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        //present image picker
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // selected image
        guard let profileImage = info[.editedImage] as? UIImage else {
            return
        }
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func configureDirNameComponents() {
        
        dirNameField.text = dir?.name
        
        view.addSubview(dirNameLabel)
        dirNameLabel.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 40, paddingBottom: 0, paddingRight: 0, width: 0, height: 8)
        
        view.addSubview(dirNameField)
        dirNameField.anchor(top: dirNameLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 2, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 50)
        
        view.addSubview(dirNameErrorLabel)
        dirNameErrorLabel.anchor(top: dirNameField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 2, paddingLeft: 40, paddingBottom: 0, paddingRight: 0, width: 0, height: 10)
    }
    
    func configurePasswordComponents() {
        
        passwordTextField.text = dir?.password
        confirmPasswordTextField.text = dir?.password

        view.addSubview(passwordLabel)
        passwordLabel.anchor(top: dirNameErrorLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 40, paddingBottom: 0, paddingRight: 0, width: 0, height: 8)
        
        view.addSubview(passwordTextField)
        passwordTextField.anchor(top: passwordLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 2, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 50)
        
        view.addSubview(confirmPasswordLabel)
        confirmPasswordLabel.anchor(top: passwordTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 40, paddingBottom: 0, paddingRight: 0, width: 0, height: 8)
        
        view.addSubview(confirmPasswordTextField)
        confirmPasswordTextField.anchor(top: confirmPasswordLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 2, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 50)
        
        view.addSubview(passwordErrorLabel)
        passwordErrorLabel.anchor(top: confirmPasswordTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 2, paddingLeft: 40, paddingBottom: 0, paddingRight: 0, width: 0, height: 10)
    }
    
    func configureFakePasswordComponents() {
        
        fakePasswordTextField.text = dir?.fakePassword
        confirmFakePasswordTextField.text = dir?.fakePassword
        
        view.addSubview(fakePasswordLabel)
        fakePasswordLabel.anchor(top: passwordErrorLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 40, paddingBottom: 0, paddingRight: 0, width: 0, height: 8)
        
        view.addSubview(fakePasswordTextField)
        fakePasswordTextField.anchor(top: fakePasswordLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 2, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 50)
        
        view.addSubview(confirmFakePasswordLabel)
        confirmFakePasswordLabel.anchor(top: fakePasswordTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 40, paddingBottom: 0, paddingRight: 0, width: 0, height: 8)
        
        view.addSubview(confirmFakePasswordTextField)
        confirmFakePasswordTextField.anchor(top: confirmFakePasswordLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 2, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 50)
        
        view.addSubview(fakePasswordErrorLabel)
        fakePasswordErrorLabel.anchor(top: confirmFakePasswordTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 2, paddingLeft: 40, paddingBottom: 0, paddingRight: 0, width: 0, height: 10)
    }
    
    func configureViewComponents() {
        
        configureDirNameComponents()
        configurePasswordComponents()
        configureFakePasswordComponents()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
