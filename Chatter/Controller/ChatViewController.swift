//
//  ChatViewController.swift
//  Chatter
//
//  Created by Sumair Zamir on 29/04/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import UIKit
import MessageKit
import Firebase
import InputBarAccessoryView

// Add keyboard management

class ChatViewController: MessagesViewController {
    
    var messages: [Message] = []
    var currentUserUid = Auth.auth().currentUser?.uid
    var currentDisplayName = ""
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: true)
        title = "Chatter"
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        let settings = FirestoreSettings()
        
        // Add offline persistence
        settings.isPersistenceEnabled = true
        let db = Firestore.firestore()
        db.settings = settings
        
        let dbMessages = Firestore.firestore().collection("messages")
        // Try empty the array instead of the metadata adjustment?
        dbMessages.addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else {
                print(error!.localizedDescription)
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
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom(animated: true)
                }
            }
        }
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError {
            print("Error signing out: %@", signOutError)
        }
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
    }
    
    func insertMessages(_ data: [Any]) {
        for component in data {
            if let str = component as? String {
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
                        let messageId = UUID().uuidString
                        let sentDate = Date()
                        
                        db.collection("messages").addDocument(data: ["messageId": messageId, "sentDate": sentDate, "text": str, "user": displayName, "userId": self.currentUserUid!]) { (error) in
                            if error != nil {
                                print(error!.localizedDescription)
                                self.messagesCollectionView.scrollToBottom(animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
}
