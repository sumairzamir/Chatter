//
//  ChatViewController.swift
//  Chatter
//
//  Created by Sumair Zamir on 29/04/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

//Testing

import Foundation
import UIKit
import MessageKit
import Firebase
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
    
    // Use messageKit to update, remove avatar & read receipts?
    
    var messages: [Message] = []
    
    var currentUserUid = Auth.auth().currentUser?.uid
    
    var currentDisplayName = ""
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    // Add scrolling/keyboard functionality!
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        
        let firebaseAuth = Auth.auth()
        
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError {
            print("Error signing out: %@", signOutError)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        title = "Chatter"

       let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        
        let db = Firestore.firestore()
        
        db.settings = settings
        
        
        let dbMessages = Firestore.firestore().collection("messages")
        
        // empty the array instead of metadata adjustment?
        
        dbMessages.addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else {
                print(error!.localizedDescription)
                return
            }
            
            let changesData = snapshot.documentChanges
            
            let source = snapshot.metadata.hasPendingWrites
            
            
            // Check that message is displayed with a message that it will be sent once network activity is returned!
            
//            print(source)
//            print(changesData.count)
            if source == false {
            for changes in changesData {
                
//                print(changes.document.data().count)
                let user = changes.document.data()["user"] as! String
                let messageId = changes.document.data()["messageId"] as! String
                let text = changes.document.data()["text"] as! String
                let timestamp = changes.document.data()["sentDate"] as! Timestamp
                let userId = changes.document.data()["userId"] as! String
                
//                print(timestamp.dateValue())
                
                let date = timestamp.dateValue()
//
//                let formattedDate = self.formatter.date(from: date)
                
                let userData = User(senderId: userId, displayName: user)
//
//                print(text)
//                print(messageId)
//                  let user = SampleData.shared.currentSender
                
                let message = Message(text: text, user: userData, messageId: messageId, date: date)
                
                self.messages.append(message)
                self.messagesCollectionView.reloadData()
            }
            }
        }
            
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // detach listener?
        
    }
    
}

extension ChatViewController: MessagesDataSource {
    
    func currentSender() -> SenderType {
        
        let db = Firestore.firestore()
        
        let userQuery = db.collection("users").whereField("uid", isEqualTo: currentUserUid!)
        
        userQuery.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                print(error!.localizedDescription)
                return
            }
            
            let userData = snapshot.documents
            
            for userDetails in userData {
                
                let displayName = userDetails.data()["firstName"] as! String
                
                self.currentDisplayName = displayName
            }
        }
        
        let currentUser = User(senderId: currentUserUid!, displayName: currentDisplayName)
        
        return currentUser
        
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        return NSAttributedString(string: "Read", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
}

extension ChatViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 18
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 17
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
}

extension ChatViewController: MessagesDisplayDelegate {

    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        // Understand the syntax here?
        return isFromCurrentSender(message: message) ? .systemBlue : .systemGray6
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }


}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        let components = inputBar.inputTextView.components
        messageInputBar.inputTextView.text = String()
        insertMessages(components)
        
        
        
        // Can prob do elsewhere
//        messagesCollectionView.reloadData()
        
    }
    
    func insertMessages(_ data: [Any]) {
        
        for component in data {
            
            let user = SampleData.shared.currentSender
            if let str = component as? String {
                let message = Message(text: str, user: user, messageId: UUID().uuidString, date: Date())
//                insertMessage(message)
            
                let db = Firestore.firestore()
                
                
                let userQuery = db.collection("users").whereField("uid", isEqualTo: currentUserUid!)
                
                userQuery.getDocuments { (snapshot, error) in
                    guard let snapshot = snapshot else {
                        print(error!.localizedDescription)
                        return
                    }
                    
                    let userData = snapshot.documents
                    
                    for userDetails in userData {
                        
                        let displayName = userDetails.data()["firstName"] as! String
                        
                        db.collection("messages").addDocument(data: ["messageId": message.messageId, "sentDate": message.sentDate, "text": str, "user": displayName, "userId": self.currentUserUid!]) { (error) in
                            if error != nil {
                                print(error!.localizedDescription)
                            }
                            
                        }
                        
                        
                        
                    }
                    
                }
                
                
            }
            
            
        }
        
        
        
    }
    
    

    
}
