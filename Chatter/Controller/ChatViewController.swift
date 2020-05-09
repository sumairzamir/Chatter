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

class ChatViewController: MessagesViewController {
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var chatListener: ListenerRegistration?
    
    @IBOutlet var parentView: UIView!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var chatLoadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: true)
        title = "Chatter"
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        
        parentView.bringSubviewToFront(subView)
        
        subView.alpha = 0.5
        subView.isHidden = false
        
        let settings = FirestoreSettings()
        
        // Add offline persistence
        settings.isPersistenceEnabled = true
        NetworkLogic.db.settings = settings
        
        chatLoadingIndicator.startAnimating()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NetworkLogic.getCurrentUserData(completionHandler: handleUserData(success:error:))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        chatListener!.remove()
    }
    
    func handleUserData(success: Bool, error: Error?) {
        if success {
            chatListener = NetworkLogic.getMessageUpdates(completionHandler: handleMessageData(success:error:))
        } else {
            showLogicFailure(title: "Network error", message: error?.localizedDescription ?? "")
        }
    }
    
    func handleMessageData(success: Bool, error: Error?) {
        if success {
            messagesCollectionView.reloadData()
            // scroll to bottom is jittery for some reason...
            //            messagesCollectionView.scrollTobo
            messagesCollectionView.scrollToItem(at: IndexPath(row: 0, section: NetworkLogic.messages.count - 1), at: .top, animated: false)
            chatLoadingIndicator.stopAnimating()
            subView.isHidden = true
        } else {
            showLogicFailure(title: "Unable to update", message: error?.localizedDescription ?? "")
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
        let currentUser = User(senderId: NetworkLogic.currentUserUid!, displayName: NetworkLogic.currentDisplayName)
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return NetworkLogic.messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return NetworkLogic.messages.count
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
                let messageId = UUID().uuidString
                let sentDate = Date()
                NetworkLogic.db.collection("messages").addDocument(data: [
                    "messageId": messageId,
                    "sentDate": sentDate,
                    "text": str,
                    "user": NetworkLogic.currentDisplayName,
                    "userId": NetworkLogic.currentUserUid!
                ]) { (error) in
                    if error != nil {
                        self.showLogicFailure(title: "Unable to insert message", message: error?.localizedDescription ?? "")
                    }
                }
            }
        }
    }
    
}
