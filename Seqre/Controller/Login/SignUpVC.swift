//
//  SignUpVC.swift
//  InstagramProj
//
//  Created by Ivan Blinov on 11/7/19.
//  Copyright © 2019 Ivan Blinov. All rights reserved.
//

import UIKit
import RealmSwift

class SignUpVC: UIViewController, UINavigationControllerDelegate {

    let realm = try! Realm()
    
    let logoContainerView: UIView = {
        let view = UIView()
        
        let logoImageView = UIImageView(image: UIImage(named: "seqre"))
        logoImageView.contentMode = .scaleAspectFill
        view.addSubview(logoImageView)
        logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.backgroundColor = UIColor(rgb: 0x272343)
        return view
    }()
    
    let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Error Message"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .clear
        return label
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    lazy var confirmPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Confirm Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(rgb: 0xbae8e8)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        
        return button
    }()
    
    let alreadyHaveAnAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSMutableAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSMutableAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(rgb: 0x63e6e6)]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(logoContainerView)
        logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 200)
        
        view.addSubview(errorLabel)
        errorLabel.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 40, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        configureViewComponents()
    }
    
    @objc func handleShowLogin() {
        _ = navigationController?.popViewController(animated: true )
    }
    
    @objc func formValidation() {
        
        guard passwordTextField.hasText,
              confirmPasswordTextField.hasText
            else {
                signUpButton.isEnabled = false
                signUpButton.backgroundColor = UIColor(rgb: 0xbae8e8)
                return
        }
        signUpButton.isEnabled = true
        signUpButton.backgroundColor = UIColor(rgb: 0x63e6e6)
    }
    
    @objc func handleSignUp() {
        
        // properties
        
        guard let password = passwordTextField.text else { return }
        guard let confirmPassword = confirmPasswordTextField.text else { return }
        
        if password != confirmPassword {
            errorLabel.textColor = .red
            errorLabel.text = "Confirmed password must be the same"
            confirmPasswordTextField.layer.borderWidth = 1.0
            confirmPasswordTextField.layer.masksToBounds = true
            confirmPasswordTextField.layer.borderColor = UIColor.red.cgColor
            confirmPasswordTextField.shake()
            
        } else {
            let profile = Profile()
            profile.password = password
            do {
                let existedProfile = realm.objects(Profile.self)
                if let _ = existedProfile.filter(NSPredicate(format: "%K = %@", "password", "\(password)")).first {
                    print("Profile with password \(password) already exists")
                    errorLabel.textColor = .red
                    errorLabel.text = "Profile with such password already exists"
                } else {
                    errorLabel.textColor = .clear
                    confirmPasswordTextField.layer.borderWidth = 0
                    try realm.write {
                        realm.add(profile)
                    }
                    
                    let mainVC = MainTabVC()
                    mainVC.configureViewControllers(with: profile)
                    navigationController?.pushViewController(mainVC, animated: true)
                }
            } catch {
                print("Error during saving new profile \(error)")
            }
        }
    }
    
    func configureViewComponents() {
        let stackView = UIStackView(arrangedSubviews: [passwordTextField, confirmPasswordTextField, signUpButton])
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: errorLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 180)
        
        view.addSubview(alreadyHaveAnAccountButton)
        alreadyHaveAnAccountButton .anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 50)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
