//
//  PhotoBucketDetailViewController.swift
//  PhotoBucketLab
//
//  Created by Hanyu Yang on 2021/1/12.
//

import UIKit
import Firebase

class PhotoBucketDetailViewController: UIViewController {
    
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var photo: Photo?
    var photoRef: DocumentReference!
    var photoListener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc func showEditDialog() {
        let alertController = UIAlertController(title: "Edit photo",
                                                message: "",
                                                preferredStyle: .alert)
        //Configure
        alertController.addTextField { (textField) in
            textField.placeholder = "Caption"
            textField.text = self.photo?.caption
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel",
                                                style: .cancel,
                                                handler: nil))
        alertController.addAction(UIAlertAction(title: "Update",
                                                style: .default)
        { (action) in
            let captionTextField = alertController.textFields![0] as UITextField
//            self.photo?.caption = captionTextField.text!
//            self.updateView()
            self.photoRef.updateData([
                "caption": captionTextField.text!
            ])
        })
        
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let imgString = photo?.url {
          if let imgUrl = URL(string: imgString) {
            DispatchQueue.global().async { // Download in the background
              do {
                let data = try Data(contentsOf: imgUrl)
                DispatchQueue.main.async { // Then update on main thread
                  self.imageView.image = UIImage(data: data)
                }
              } catch {
                print("Error downloading image: \(error)")
              }
            }
          }
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        photoListener = photoRef.addSnapshotListener { (documentSnapshot, error) in
            if let error = error {
                print("Error getting photo \(error)")
                return
            }
            if !documentSnapshot!.exists {
                print("Go Back")
                return
            }
            self.photo = Photo(documentSnapshot: documentSnapshot!)
            
            if Auth.auth().currentUser!.uid == self.photo?.author {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                                    target: self,
                                                                    action: #selector(self.showEditDialog))
            } else {
                self.navigationItem.rightBarButtonItem = nil
            }
            self.updateView()
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        photoListener.remove()
    }
    
    func updateView() {
        captionLabel.text = photo?.caption
    }
}
