//
//  ProfilePageViewController.swift
//  PhotoBucketLab
//
//  Created by Hanyu Yang on 2021/1/27.
//

import UIKit
import Firebase
import FirebaseStorage

class ProfilePageViewController: UIViewController {
    
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    
    override func viewDidLoad() {
        displayNameTextField.addTarget(self, action: #selector(handleNameEdit), for: .editingChanged)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserManager.shared.beginListening(uid: Auth.auth().currentUser!.uid, changeListener: updateView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserManager.shared.stopListening()
    }
    
    @IBAction func pressedEditPhoto(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera
        } else {
            imagePickerController.sourceType = .photoLibrary
        }
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func updateView() {
        displayNameTextField.text = UserManager.shared.name
        if !UserManager.shared.photoUrl.isEmpty {
            ImageUtils.load(imageView: profilePhotoImageView, from: UserManager.shared.photoUrl)
        }
    }
    
    @objc func handleNameEdit() {
        if let name = displayNameTextField.text {
            UserManager.shared.updateName(name: name)
        }
    }
    
    func uploadImage(_ image: UIImage) {
        if let imageData = ImageUtils.resize(image: image) {
            let storageRef = Storage.storage().reference().child(kCollectionUsers).child(Auth.auth().currentUser!.uid)
            _ = storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("error uploading Image \(error)")
                    return
                }
                
                print("Upload Complete")
                // You can also access to download URL after upload.
                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        print("error getting download url \(error)")
                        return
                    }
                    if let downloadURL = url {
                        // Uh-oh, an error occurred!
                        print("Got download url: \(downloadURL)")
                        UserManager.shared.updatePhotoUrl(photoUrl: downloadURL.absoluteString)
                    }
                }
                
            }
        } else {
            print("Error getting image data")
        }
    }
}

extension ProfilePageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage? {
            profilePhotoImageView.image = image
            uploadImage(image)
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage? {
            profilePhotoImageView.image = image
            uploadImage(image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
