//
//  ChatViewModel.swift
//  Chatter
//
//  Created by Sumair Zamir on 15/05/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation
import Firebase
import Network

class ChatViewModel {
    
    var messagesArray: [Message] = []
    var userUid = Auth.auth().currentUser?.uid
    var userDisplayName = ""
    
    var scrollAnimated = false
    var networkConnected = true
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    let monitor = NWPathMonitor()
    var chatListener: ListenerRegistration?
    
    func configureNetwork() {
        enableOfflinePersistance()
        networkMonitor()
    }
    
    func networkMonitor() {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.networkConnected = true
            } else {
                self.networkConnected = false
            }
        }
        let networkQueue = DispatchQueue(label: "Monitor")
        monitor.start(queue: networkQueue)
    }
    
}

extension ChatViewModel {
    
    func logout(completionHandler: @escaping (Bool, Error?) -> Void) {
        do {
            try FirebaseParameters.auth.signOut()
            DispatchQueue.main.async {
                completionHandler(true,nil)
            }
        } catch let error {
            DispatchQueue.main.async {
                completionHandler(false,error)
            }
        }
    }
    
    func enableOfflinePersistance() {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        FirebaseParameters.db.settings = settings
    }
    
    func getCurrentUserData(completionHandler: @escaping (Bool, Error?) -> Void) {
        let currentUserQuery = FirebaseParameters.db.collection("users").whereField("uid", isEqualTo: userUid!)
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
                self.userDisplayName = displayName
                DispatchQueue.main.async {
                    completionHandler(true, nil)
                }
            }
        }
    }
    
    // A method which returns a Firestore listener to handle message send/receipt
    func getMessageUpdates(completionHandler: @escaping (Bool, Error?) -> Void) -> ListenerRegistration {
        messagesArray = []
        let dbMessages = FirebaseParameters.db.collection("messages").order(by: "sentDate", descending: false).limit(toLast: 10)
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
                    if self.messagesArray.contains(where: { (message) -> Bool in
                        message.messageId == messageId
                    }) {
                        DispatchQueue.main.async {
                            completionHandler(false,error)
                        }
                    } else {
                        self.messagesArray.append(message)
                        DispatchQueue.main.async {
                            completionHandler(true,nil)
                        }
                    }
                }
            }
            // Determine how to append messages depending on network connection
            if self.networkConnected {
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
