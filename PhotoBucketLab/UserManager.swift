//
//  UserManager.swift
//  PhotoBucketLab
//
//  Created by Hanyu Yang on 2021/1/27.
//

import Foundation
import Firebase

let kCollectionUsers = "Users"
let kKeyName = "name"
let kKeyPhotoUrl = "photoUrl"

class UserManager {
    
    let _collectionRef: CollectionReference
    var _document: DocumentSnapshot?
    var _userListener: ListenerRegistration?
    
    static let shared = UserManager()
    
    private init() {
        _document = nil
        _userListener = nil
        _collectionRef = Firestore.firestore().collection(kCollectionUsers)
    }
    
    func addNewUserMabye(uid: String, name: String?, photoUrl: String?) {
        let userRef = _collectionRef.document(uid)
        userRef.getDocument { (documentSnapshot, error) in
            if let error = error {
                print("error getting user \(error)")
                return
            }
            if let documentSnapshot = documentSnapshot {
                if documentSnapshot.exists {
                    return
                } else {
                    print("Create User: \(uid)")
                    userRef.setData([
                        kKeyName: name ?? "",
                        kKeyPhotoUrl: photoUrl ?? ""
                    ])
                }
            }
        }
    }
    
    func beginListening(uid: String, changeListener: (() -> Void)?) {
        stopListening()
        let userRef = _collectionRef.document(uid)
        userRef.addSnapshotListener { (documentSnapshot, error) in
            if let error = error {
                print("error listening for user: \(error)")
                return
            }
            if let documentSnapshot = documentSnapshot {
                self._document = documentSnapshot
                changeListener?()
            }
        }
    }
    
    func stopListening() {
        _userListener?.remove()
    }
    
    func updateName(name: String) {
        let userRef = _collectionRef.document(Auth.auth().currentUser!.uid)
        userRef.updateData([
            kKeyName: name
        ])
    }
    
    func updatePhotoUrl(photoUrl: String) {
        let userRef = _collectionRef.document(Auth.auth().currentUser!.uid)
        userRef.updateData([
            kKeyPhotoUrl: photoUrl
        ])
    }
    
    var name: String {
        if let value = _document?.get(kKeyName) {
            return value as! String
        }
        return ""
    }
    
    var photoUrl: String {
        if let value = _document?.get(kKeyPhotoUrl) {
            return value as! String
        }
        return ""
    }
}
