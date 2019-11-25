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

private let reuseIdentifier = "Directory"

class DirController: UICollectionViewController, UICollectionViewDelegateFlowLayout, SwipeCollectionViewCellDelegate {
    
    let realm = try! Realm()
    
    var dirs = List<Directory>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.backgroundColor = .white
        self.collectionView.register(DirCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        self.navigationController?.navigationBar.isHidden = false
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddDir))
        self.navigationItem.rightBarButtonItem = addButton
        
        // TODO mb add logout button
        // TODO also mb add logout after swiping app
        self.navigationItem.leftBarButtonItem = nil
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
          guard orientation == .right else { return nil }
          
          let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
              // handle action by updating model with deletion
              self.deleteDir(at: indexPath)
          }
          
          // customize the action appearance
          deleteAction.image = UIImage(named: "trash-icon")
          
          return [deleteAction]
      }
    
    func deleteDir(at indexPath: IndexPath) {
        do {
            try self.realm.write {
                self.realm.delete(self.dirs[indexPath.row])
            }
        } catch {
            print("Error while deleting item \(error)")
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        
        return CGSize(width: width, height: 80)
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dirs.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DirCell
        cell.delegate = self
        cell.usernameButton.setTitle(dirs[indexPath.row].name, for: .normal)
        //cell.layer.borderWidth = 1
        //cell.layer.borderColor = UIColor.lightGray.cgColor
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imagesController = ImagesController(collectionViewLayout: UICollectionViewFlowLayout())
        imagesController.dir = dirs[indexPath.row]
        navigationController?.pushViewController(imagesController, animated: true)
    }
    
    @objc func handleAddDir() {
        let alert = UIAlertController(title: "Add New Directory", message: "", preferredStyle: .alert)
        var textField = UITextField()
        let action = UIAlertAction(title: "Add Directory", style: .default) { (action) in
            //what will happen when the user clicks the Add Item butoon
            do {
                try self.realm.write {
                    let newDirectory = Directory()
                    newDirectory.name = textField.text!
                    self.dirs.append(newDirectory)
                }
            } catch {
                print("Error saving context \(error)")
            }
            self.collectionView.reloadData()
        }
        alert.addAction(action)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
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
        collectionView.reloadData()
    }
    
    @objc func handleRefresh() {
        collectionView.reloadData()
        collectionView.refreshControl?.endRefreshing()
    }
    
}
