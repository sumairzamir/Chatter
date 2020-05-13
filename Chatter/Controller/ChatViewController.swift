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
import Network
import RxSwift

class ChatViewController: MessagesViewController {
    
    let monitor = NWPathMonitor()
    var chatListener: ListenerRegistration?
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
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
        chatLoadingIndicator.startAnimating()
        
        NetworkLogic.enableOfflinePersistance()
        
        networkMonitor()
    }
    
    var disposeBag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NetworkLogic.getCurrentUserData(completionHandler: handleUserData(success:error:))
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NetworkParameters.scrollAnimated = false
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
            messagesCollectionView.scrollToItem(at: IndexPath(row: 0, section: NetworkParameters.messages.count - 1), at: .top, animated: NetworkParameters.scrollAnimated)
            chatLoadingIndicator.stopAnimating()
            subView.isHidden = true
        } else {
            showLogicFailure(title: "Unable to update", message: error?.localizedDescription ?? "")
        }
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        NetworkLogic.logout(completionHandler: handleLogout(success:error:))
    }
    
    func handleLogout(success: Bool, error: Error?) {
        if success {
            navigationController?.popToRootViewController(animated: true)
        } else {
            showLogicFailure(title: "Unable to logout", message: error!.localizedDescription)
        }
    }
    
    func networkMonitor() {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                NetworkParameters.networkConnected = true
            } else {
                NetworkParameters.networkConnected = false
            }
        }
        let networkQueue = DispatchQueue(label: "Monitor")
        monitor.start(queue: networkQueue)
    }
    
}

extension ChatViewController: MessagesDataSource {
    
    func currentSender() -> SenderType {
        let currentUser = User(senderId: NetworkParameters.userUid!, displayName: NetworkParameters.userDisplayName)
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return NetworkParameters.messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return NetworkParameters.messages.count
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
        
        let image = UIImage(named: "avatarSymbol")
        let avatar = Avatar(image: image, initials: "")
       
        // rx subscription
        NetworkParameters.rxUserAvatar.subscribe(onNext: { (avatarColor) in
            avatarView.tintColor = NetworkParameters.Colour(rawValue: avatarColor)?.colours}).disposed(by: disposeBag)

        avatarView.set(avatar: avatar)
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
                NetworkParameters.scrollAnimated = true
                NetworkParameters.db.collection("messages").addDocument(data: [
                    "messageId": messageId,
                    "sentDate": sentDate,
                    "text": str,
                    "user": NetworkParameters.userDisplayName,
                    "userId": NetworkParameters.userUid!
                ]) { (error) in
                    if error != nil {
                        self.showLogicFailure(title: "Unable to insert message", message: error?.localizedDescription ?? "")
                    }
                }
            }
        }
    }
    
}
