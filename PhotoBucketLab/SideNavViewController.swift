//
//  SideNavViewController.swift
//  PhotoBucketLab
//
//  Created by Hanyu Yang on 2021/1/27.
//

import UIKit
import Firebase

class SideNavViewController: UIViewController {
    
    @IBAction func pressedGoToProfilePage(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        tableViewController.performSegue(withIdentifier: kProfilePageSegue, sender: tableViewController)
    }
    
    @IBAction func pressedShowAllPhotos(_ sender: Any) {
        tableViewController.isShowingAllPhotos = true
        tableViewController.startListening()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressedShowMyPhotos(_ sender: Any) {
        tableViewController.isShowingAllPhotos = false
        tableViewController.startListening()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressedDeletePhotos(_ sender: Any) {
        tableViewController.setEditing(!tableViewController.isEditing, animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressedLogOut(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        do {
            try Auth.auth().signOut()
        } catch {
            print("sign out error")
        }
    }
    
    var tableViewController: PhotoBucketTableViewController {
        get {
            let navController = presentingViewController as! UINavigationController
            return navController.viewControllers.last as! PhotoBucketTableViewController
        }
    }
}
