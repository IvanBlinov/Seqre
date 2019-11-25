//
//  LoginVC.swift
//  InstagramProj
//
//  Created by Ivan Blinov on 11/6/19.
//  Copyright © 2019 Ivan Blinov. All rights reserved.
//

import UIKit
import RealmSwift

class LoginVC: UIViewController {
    
    let realm = try! Realm()
    
    var profiles: Results<Profile>?
    
    let logoContainerView: UIView = {
        let view = UIView()
        
        view.backgroundColor = UIColor(red: 0/255, green: 120/255, blue: 175/255, alpha: 1)
        return view
    }()
    
    let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Error Message"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .clear
        return label
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [NSMutableAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSMutableAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255,green: 154/255, blue: 237/255, alpha: 1)]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load existed profiles
        loadProfiles()
        
        //background color
        view.backgroundColor = .white
        
        //hide nav bar
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(logoContainerView)
        logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        
        view.addSubview(errorLabel)
        errorLabel.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 40, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        configureViewComponents()
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    }
    
    @objc func handleShowSignUp() {
        let signUpVC = SignUpVC()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @objc func formValidation() {
        
        guard
            passwordTextField.hasText
        else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            return
        }
        
        loginButton.isEnabled = true
        loginButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        
    }
    
    func loadProfiles() {
        self.profiles = realm.objects(Profile.self)
    }
    
    @objc func handleLogin() {
        
        guard
            let password = passwordTextField.text else { return }

        if let profile = profiles?.filter(NSPredicate(format: "%K = %@", "password", "\(password)")).first {
            errorLabel.textColor = .clear
            let mainVC = MainTabVC()
            mainVC.configureViewControllers(with: profile)
            navigationController?.pushViewController(mainVC, animated: true)
        } else {
            print("No such profile with password \(password)")
            passwordTextField.layer.borderWidth = 1.0
            passwordTextField.layer.masksToBounds = true
            passwordTextField.layer.borderColor = UIColor.red.cgColor
            errorLabel.textColor = .red
            errorLabel.text = "No such password"
            passwordTextField.shake()
        }
    }
    
    func configureViewComponents() {
        let stackView = UIStackView(arrangedSubviews: [passwordTextField, loginButton])
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: errorLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 120)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
