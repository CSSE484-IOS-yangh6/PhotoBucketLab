//
//  ProfilePageViewController.swift
//  PhotoBucketLab
//
//  Created by Hanyu Yang on 2021/1/27.
//

import UIKit
import Firebase

class ProfilePageViewController: UIViewController {
    
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    
    override func viewDidLoad() {
        displayNameTextField.addTarget(self, action: #selector(handleNameEdit), for: .editingChanged)
        UserManager.shared.beginListening(uid: Auth.auth().currentUser!.uid, changeListener: updateView)
    }
    
    @IBAction func pressedEditPhoto(_ sender: Any) {
        
    }
    
    func updateView() {
        displayNameTextField.text = UserManager.shared.name
    }
    
    @objc func handleNameEdit() {
        if let name = displayNameTextField.text {
            UserManager.shared.updateName(name: name)
        }
    }
}
