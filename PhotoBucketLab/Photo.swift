//
//  Photo.swift
//  PhotoBucketLab
//
//  Created by Hanyu Yang on 2021/1/12.
//

import Foundation
import Firebase

class Photo {
    var caption: String
    var url: String
    var id: String?
    var author: String
    
    init(documentSnapshot: DocumentSnapshot) {
        self.id = documentSnapshot.documentID
        let data = documentSnapshot.data()!
        //print(data)
        self.caption = data["caption"] as! String
        self.url = data["url"] as! String
        self.author = data["author"] as! String
    }
}
