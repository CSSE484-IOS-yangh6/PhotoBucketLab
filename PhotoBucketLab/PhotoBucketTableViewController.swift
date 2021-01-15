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
    var authStateListenerHandle: AuthStateDidChangeListenerHandle!
    var photoListener: ListenerRegistration!
    
    @IBOutlet weak var tableTitle: UINavigationItem!
    
    var photos = [Photo]()
    var isShowingAllPhotos = true
    var emptyUrlPhotos = ["https://thenewswheel.com/wp-content/uploads/2016/07/rusted-car-broken-down-rust-damage-760x515.jpg", "https://knowhow.napaonline.com/wp-content/uploads/2018/04/rust_in_peace._15700920021.jpg",
        "https://knowhow.napaonline.com/wp-content/uploads/2017/09/10365219726_0b53e83173.jpg"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "☰",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(showMenu))
//        photos.append(Photo(caption: "Koenigsegg Jesko", url: "https://www.cars-show.org/wp-content/uploads/2019/06/Koenigsegg-Jesko-Red-Cherry-Edition-2020-01.jpg"))
//        photos.append(Photo(caption: "Bugatti Chiron", url: "https://im.rediff.com/money/2017/nov/29bugatti.jpg?w=670&h=900"))
        photosRef = Firestore.firestore().collection("Photos")
    }
    
    @objc func showMenu() {
        let alertController = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Create Photo",
                                                style: .default)
        { (action) in
            self.showAddPhotoDialog()
        })
        
        alertController.addAction(UIAlertAction(title: self.isShowingAllPhotos ? "Show only my photos" : "Show all photos",
                                                style: .default)
        { (action) in
            // Toggle the show all vs show mine mode.
            self.isShowingAllPhotos = !self.isShowingAllPhotos
            // Update the list
            self.startListening()
        })
        
        alertController.addAction(UIAlertAction(title: "Sign out",
                                                style: .default)
        { (action) in
            do {
                try Auth.auth().signOut()
            } catch {
                print("sign out error")
            }
            
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel",
                                                style: .cancel,
                                                handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        
        authStateListenerHandle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if Auth.auth().currentUser == nil {
                print("No user, go back to login page")
                self.navigationController?.popViewController(animated: true)
            } else {
                print("signed in. Stay on this page")
            }
        })
        
        startListening()
    }
    
    func startListening() {
        if photoListener != nil {
            photoListener.remove()
        }
        
        var query = photosRef.order(by: "created", descending: true).limit(to: 50)
        
        if !isShowingAllPhotos {
            query = query.whereField("author", isEqualTo: Auth.auth().currentUser!.uid)
        }
        
        photoListener = query.addSnapshotListener({ (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                self.photos.removeAll()
                querySnapshot.documents.forEach { (documentSnapshot) in
//                    print(documentSnapshot.documentID)
//                    print(documentSnapshot.data())
                    self.photos.append(Photo(documentSnapshot: documentSnapshot))
                }
                if self.photos.isEmpty {
                    self.tableTitle.title = "No Photos"
                } else {
                    self.tableTitle.title = "Henry Photos"
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
        Auth.auth().removeStateDidChangeListener(authStateListenerHandle)
    }
    
    func showAddPhotoDialog() {
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
                "created": Timestamp.init(),
                "author": Auth.auth().currentUser!.uid
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
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let photo = photos[indexPath.row]
        return Auth.auth().currentUser!.uid == photo.author
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
