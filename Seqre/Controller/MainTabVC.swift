//
//  MainTabVC.swift
//  InstagramProj
//
//  Created by Ivan Blinov on 11/8/19.
//  Copyright © 2019 Ivan Blinov. All rights reserved.
//

import UIKit
import Firebase

class MainTabVC: UITabBarController, UITabBarControllerDelegate {

    var currentProfile: Profile?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
    }
    
    // function to create view controllers that exists within tab bar controller
    func configureViewControllers(with profile: Profile) {
        
        // home feed controller
        let dirController = DirController()
        dirController.dirs = profile.dirs
        dirController.currentProfile = profile
        let feedVC = constructNavController(unselectedImage: UIImage(named: "home_unselected")!, selectedImage: UIImage(named: "home_selected")!, rootViewController: dirController)
        
        // profile controller
        let userProfileController = UserProfileVC()
        userProfileController.currentProfile = profile
        let userProfileVC = constructNavController(unselectedImage: UIImage(named: "profile_unselected")!, selectedImage: UIImage(named: "profile_selected")!, rootViewController: userProfileController)
    
        viewControllers = [feedVC, userProfileVC]
        
        tabBar.tintColor = .black
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
    
    // construct navigation controllers
    func constructNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        
        // construct nav controller
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        navController.navigationBar.tintColor = .black
        
        // return nav controller
        return navController
    }
}
