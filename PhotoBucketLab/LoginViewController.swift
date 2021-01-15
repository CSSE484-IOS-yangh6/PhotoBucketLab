//
//  LoginViewController.swift
//  PhotoBucketLab
//
//  Created by Hanyu Yang on 2021/1/15.
//

import UIKit
import Firebase
import Rosefire

class LoginViewController: UIViewController {
    
    let showListSegueIdentifier = "ShowListSegue"
    let REGISTRY_TOKEN = "addbbde2-8bf9-4dd7-af05-fb01e47a27dc"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            print("Someone is already signed in! Just move on!")
            self.performSegue(withIdentifier: self.showListSegueIdentifier, sender: self)
        }
    }
    
    
    @IBAction func pressedRoseLogin(_ sender: Any) {
        Rosefire.sharedDelegate().uiDelegate = self // This should be your view controller
        Rosefire.sharedDelegate().signIn(registryToken: REGISTRY_TOKEN) { (err, result) in
          if let err = err {
            print("Rosefire sign in error! \(err)")
            return
          }
          //print("Result = \(result!.token!)")
          print("Result = \(result!.username!)")
          print("Result = \(result!.name!)")
          print("Result = \(result!.email!)")
          print("Result = \(result!.group!)")
            
          Auth.auth().signIn(withCustomToken: result!.token) { (authResult, error) in
            if let error = error {
              print("Firebase sign in error! \(error)")
              return
            }
            // User is signed in using Firebase!
            self.performSegue(withIdentifier: self.showListSegueIdentifier, sender: self)
          }
        }
    }
}
