//
//  ForumViewController.swift
//  MuayThaiNotes
//
//  Created by Sumair Zamir on 29/04/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation
import UIKit
import MessageKit
import Firebase
import InputBarAccessoryView

class ForumViewController: MessagesViewController {
    
    var messages: [Message] = []
    
    var currentUserUid = Auth.auth().currentUser?.uid
    
    var currentDisplayName = ""
    
    // Add scrolling/keyboard functionality!
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        title = "Forum View"

        
        let dbMessages = Firestore.firestore().collection("messages")
//
//        dbMessages.getDocuments { (snapshot, error) in
//            guard let snapshot = snapshot else {
//                print(error!.localizedDescription)
//                return
//            }
//
//            let data = snapshot.documents
//
//            for messagesData in data {
////
////                print("this is the \(messagesData.value(forKey: "user"))")
////
//                let messageId = messagesData.data()["messageId"] as! String
////                let user = messagesData.data()["user"] as! String
////                let sentDate = messagesData.data()["sentDate"] as! String
//                let text = messagesData.data()["text"] as! String
//
//                let user = SampleData.shared.currentSender
//
//
//                let message = Message(text: text, user: user, messageId: messageId, date: Date())
//
//                self.messages.append(message)
//                self.messagesCollectionView.reloadData()
//
//            }
//
//        }
        
        // empty the array instead of metadata adjustment?
        
        dbMessages.addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else {
                print(error!.localizedDescription)
                return
            }
            
            let changesData = snapshot.documentChanges
            
            let source = snapshot.metadata.hasPendingWrites
            
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
            
            
            
            
            // remember to remove the listener
            
//        }
        
        
//
//        dbMessages.getDocuments { (snapshot, error) in
//            if error != nil {
//                print(error?.localizedDescription)
//            } else {
//
//                for messagesData in snapshot!.documents {
//
//                    print(messagesData)
//
//                    let messageData = messagesData.data()
//
//                    messages.append(messageData)
//
//                    }
//
//
//
//
//
//
//            }
//        }


    
    
    // Understand following two methods!!!
    
//    func insertMessage(_ message: Message) {
//           messages.append(message)
           // Reload last section to update header/footer labels and insert a new one
//           messagesCollectionView.performBatchUpdates({
//               messagesCollectionView.insertSections([messages.count - 1])
//               if messages.count >= 2 {
//                   messagesCollectionView.reloadSections([messages.count - 2])
//               }
//           }, completion: { [weak self] _ in
//               if self?.isLastSectionVisible() == true {
//                   self?.messagesCollectionView.scrollToBottom(animated: true)
//               }
//           })
       }
    
//    func isLastSectionVisible() -> Bool {
//
//           guard !messages.isEmpty else { return false }
//
//           let lastIndexPath = IndexPath(item: 0, section: messages.count - 1)
//
//           return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
//       }
 
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // detach listener?
        
    }
    
}

extension ForumViewController: MessagesDataSource {
    
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

extension ForumViewController: MessagesLayoutDelegate {
    
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

extension ForumViewController: MessagesDisplayDelegate {

    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        // Understand the syntax here?
        return isFromCurrentSender(message: message) ? .darkGray : .lightGray
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }


}

extension ForumViewController: InputBarAccessoryViewDelegate {
    
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
