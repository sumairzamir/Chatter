//
//  NetworkLogic.swift
//  Chatter
//
//  Created by Sumair Zamir on 06/05/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation
import Firebase

class NetworkLogic {
    
    class func login(completionHandler: @escaping (Bool, Error?) -> Void) {
        NetworkParameters.firebaseAuth.signIn(withEmail: NetworkParameters.userEmail, password: NetworkParameters.userPassword) { (result, error) in
            guard error != nil else {
                NetworkParameters.userUid = Auth.auth().currentUser?.uid
                DispatchQueue.main.async {
                    completionHandler(true,nil)
                }
                return
            }
            completionHandler(false,error)
        }
    }
    
    class func logout(completionHandler: @escaping (Bool, Error?) -> Void) {
        do {
            try NetworkParameters.firebaseAuth.signOut()
            DispatchQueue.main.async {
                completionHandler(true,nil)
            }
        } catch let error {
            DispatchQueue.main.async {
                completionHandler(false,error)
            }
        }
    }
    
    class func returnDisplayName() -> String {
        return NetworkParameters.userDisplayName
    }
    
    class func registerNewUser(completionHandler: @escaping (Bool, Error?) -> Void) {
        NetworkParameters.firebaseAuth.createUser(withEmail: NetworkParameters.userEmail, password: NetworkParameters.userPassword) { (result, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completionHandler(false,error)
                }
            } else {
                NetworkParameters.db.collection("users").addDocument(data: ["displayName": NetworkParameters.userDisplayName, "uid": result!.user.uid]) { (error) in
                    guard error != nil else {
                        NetworkParameters.userUid = Auth.auth().currentUser?.uid
                        DispatchQueue.main.async {
                            completionHandler(true,nil)
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        completionHandler(false,error)
                    }
                }
            }
        }
    }
    
    // A method which gets the display name of the currently logged in user
    class func getCurrentUserData(completionHandler: @escaping (Bool, Error?) -> Void) {
        let currentUserQuery = NetworkParameters.db.collection("users").whereField("uid", isEqualTo: NetworkParameters.userUid!)
        currentUserQuery.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                DispatchQueue.main.async {
                    completionHandler(false,error)
                }
                return
            }
            let currentUserData = snapshot.documents
            for currentUserDetails in currentUserData {
                let displayName = currentUserDetails.data()["displayName"] as! String
                NetworkParameters.userDisplayName = displayName
                DispatchQueue.main.async {
                    completionHandler(true, nil)
                }
            }
        }
    }
    
    class func enableOfflinePersistance() {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        NetworkParameters.db.settings = settings
    }
    
    // A method which returns a Firestore listener to handle message send/receipt
    class func getMessageUpdates(completionHandler: @escaping (Bool, Error?) -> Void) -> ListenerRegistration {
        NetworkParameters.messages = []
        let dbMessages = NetworkParameters.db.collection("messages").order(by: "sentDate", descending: false).limit(toLast: 10)
        return dbMessages.addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else {
                DispatchQueue.main.async {
                    completionHandler(false,error)
                }
                return
            }
            let messageData = snapshot.documentChanges
            let dataSource = snapshot.metadata.hasPendingWrites
            
            // A method called to insert messages to the messages array
            func appendMessage() {
                for messages in messageData {
                    let user = messages.document.data()["user"] as! String
                    let messageId = messages.document.data()["messageId"] as! String
                    let text = messages.document.data()["text"] as! String
                    let timestamp = messages.document.data()["sentDate"] as! Timestamp
                    let userId = messages.document.data()["userId"] as! String
                    
                    // Convert the date retrieved into a date format
                    let date = timestamp.dateValue()
                    
                    // Instantiate structs for message data received
                    let userData = User(senderId: userId, displayName: user)
                    let message = Message(text: text, user: userData, messageId: messageId, date: date)
                    
                    // Determine if the message is already within the array
                    if NetworkParameters.messages.contains(where: { (message) -> Bool in
                        message.messageId == messageId
                    }) {
                        DispatchQueue.main.async {
                            completionHandler(false,error)
                        }
                    } else {
                        NetworkParameters.messages.append(message)
                        DispatchQueue.main.async {
                            completionHandler(true,nil)
                        }
                    }
                }
            }
            // Determine how to append messages depending on network connection
            if NetworkParameters.networkConnected {
                if dataSource == false {
                    appendMessage()
                }
            } else {
                if dataSource == true {
                    appendMessage()
                }
            }
        }
    }
    
}
