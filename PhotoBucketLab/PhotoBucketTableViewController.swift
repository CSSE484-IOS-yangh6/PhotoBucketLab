//
//  PhotoBucketTableViewController.swift
//  PhotoBucketLab
//
//  Created by Hanyu Yang on 2021/1/12.
//

import UIKit
import Firebase

class PhotoBucketTableViewController: UITableViewController {
    let photoBucketCellIdentifier = "PhotoBucketCell"
    let detailSegueIdentifier = "DetailSegue"
    var photosRef: CollectionReference!
    var photoListener: ListenerRegistration!
    
    var photos = [Photo]()
    var emptyUrlPhotos = ["https://thenewswheel.com/wp-content/uploads/2016/07/rusted-car-broken-down-rust-damage-760x515.jpg", "https://knowhow.napaonline.com/wp-content/uploads/2018/04/rust_in_peace._15700920021.jpg",
        "https://knowhow.napaonline.com/wp-content/uploads/2017/09/10365219726_0b53e83173.jpg"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(showAddPhotoDialog))
        photos.append(Photo(caption: "Koenigsegg Jesko", url: "https://www.cars-show.org/wp-content/uploads/2019/06/Koenigsegg-Jesko-Red-Cherry-Edition-2020-01.jpg"))
        photos.append(Photo(caption: "Bugatti Chiron", url: "https://im.rediff.com/money/2017/nov/29bugatti.jpg?w=670&h=900"))
        photosRef = Firestore.firestore().collection("Photos")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        photoListener = photosRef.order(by: "created", descending: true).limit(to: 50).addSnapshotListener({ (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                self.photos.removeAll()
                querySnapshot.documents.forEach { (documentSnapshot) in
//                    print(documentSnapshot.documentID)
//                    print(documentSnapshot.data())
                    self.photos.append(Photo(documentSnapshot: documentSnapshot))
                }
                self.tableView.reloadData()
            } else {
                print("Error getting photos \(error!)")
                return
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        photoListener.remove()
    }
    
    @objc func showAddPhotoDialog() {
        let alertController = UIAlertController(title: "Create a new photo",
                                                message: "",
                                                preferredStyle: .alert)
        //Configure
        alertController.addTextField { (textField) in
            textField.placeholder = "Caption"
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Image URL or blank"
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel",
                                                style: .cancel,
                                                handler: nil))
        alertController.addAction(UIAlertAction(title: "Create",
                                                style: .default)
        { (action) in
            let captionTextField = alertController.textFields![0] as UITextField
            let urlTextField = alertController.textFields![1] as UITextField
//            self.photos.insert(Photo(caption: captionTextField.text!, url: urlTextField.text!), at: 0)
            //self.tableView.reloadData()
            var url: String?
            if urlTextField.text! == "" {
                url = self.emptyUrlPhotos[Int.random(in: 0..<self.emptyUrlPhotos.count)]
            } else {
                url = urlTextField.text!
            }
            self.photosRef.addDocument(data: [
                "caption": captionTextField.text!,
                "url": url!,
                "created": Timestamp.init()
            ])
        })
        
        present(alertController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: photoBucketCellIdentifier, for: indexPath)
        cell.textLabel?.text = photos[indexPath.row].caption
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            photos.remove(at: indexPath.row)
//            tableView.reloadData()
            let photoToDelete = photos[indexPath.row]
            photosRef.document(photoToDelete.id!).delete()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == detailSegueIdentifier {
            if let indexPath = tableView.indexPathForSelectedRow {
//                (segue.destination as! PhotoBucketDetailViewController).photo = photos[indexPath.row]
                (segue.destination as! PhotoBucketDetailViewController).photoRef = photosRef.document(photos[indexPath.row].id!)
            }
        }
    }
    
    
}
