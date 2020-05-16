//
//  ChatViewExtensions.swift
//  Chatter
//
//  Created by Sumair Zamir on 15/05/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import UIKit
import MessageKit
import Firebase
import InputBarAccessoryView
import RxSwift

extension ChatViewController: MessagesDataSource {
    
    func currentSender() -> SenderType {
        let currentUser = User(senderId: chatViewModel.userUid!, displayName: chatViewModel.userDisplayName)
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return chatViewModel.messagesArray[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return chatViewModel.messagesArray.count
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = chatViewModel.formatter.string(from: message.sentDate)
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
        return isFromCurrentSender(message: message) ? .systemGray6: .systemGray3
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .white
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        let senderImage = UIImage(named: "senderAvatarSymbol")
        let senderAvatar = Avatar(image: senderImage, initials: "")
        
        // rx subscription
        FirebaseParameters.rxUserAvatar.subscribe(onNext: { (avatarColor) in
            avatarView.tintColor = FirebaseParameters.Colour(rawValue: avatarColor)?.colours}).disposed(by: disposeBag)
        
        avatarView.backgroundColor = .clear
        avatarView.set(avatar: senderAvatar)
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
                chatViewModel.scrollAnimated = true
                FirebaseParameters.db.collection("messages").addDocument(data: [
                    "messageId": messageId,
                    "sentDate": sentDate,
                    "text": str,
                    "user": chatViewModel.userDisplayName,
                    "userId": chatViewModel.userUid!
                ]) { (error) in
                    if error != nil {
                        self.showLogicFailure(title: "Unable to insert message", message: error?.localizedDescription ?? "")
                    }
                }
            }
        }
    }
    
}
