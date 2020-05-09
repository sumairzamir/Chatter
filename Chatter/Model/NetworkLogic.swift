//
//  NetworkLogic.swift
//  Chatter
//
//  Created by Sumair Zamir on 06/05/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation
import Firebase
import UIKit

class NetworkLogic {
    
    static var currentUserUid = Auth.auth().currentUser?.uid
    static var currentDisplayName = ""
    static let db = Firestore.firestore()
    static var messages: [Message] = []
    
    static func getCurrentUserData(completionHandler: @escaping (Bool, Error?) -> Void) {
        let userQuery = db.collection("users").whereField("uid", isEqualTo: self.currentUserUid!)
        userQuery.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                print(error!.localizedDescription)
                DispatchQueue.main.async {
                    completionHandler(false,error)
                }
                return
            }
            let userData = snapshot.documents
            for userDetails in userData {
                let displayName = userDetails.data()["firstName"] as! String
                self.currentDisplayName = displayName
                DispatchQueue.main.async {
                    completionHandler(true, nil)
                }
            }
        }
    }
    
    static func getMessageUpdates(completionHandler: @escaping (Bool, Error?) -> Void) -> ListenerRegistration {
        messages = []
        let dbMessages = db.collection("messages").order(by: "sentDate", descending: false).limit(toLast: 15)
        return dbMessages.addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else {
                DispatchQueue.main.async {
                    completionHandler(false,error)
                }
                return
            }
            let changesData = snapshot.documentChanges
            let source = snapshot.metadata.hasPendingWrites
            if source == false {
                for changes in changesData {
                    let user = changes.document.data()["user"] as! String
                    let messageId = changes.document.data()["messageId"] as! String
                    let text = changes.document.data()["text"] as! String
                    let timestamp = changes.document.data()["sentDate"] as! Timestamp
                    let userId = changes.document.data()["userId"] as! String
                    
                    let date = timestamp.dateValue()
                    
                    let userData = User(senderId: userId, displayName: user)
                    let message = Message(text: text, user: userData, messageId: messageId, date: date)
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        completionHandler(true,nil)
                    }
                }
            }
        }
    }
}

