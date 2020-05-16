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
    
    var chatViewModel = ChatViewModel()
    var disposeBag = DisposeBag()
    
    @IBOutlet var parentView: UIView!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var chatLoadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatViewModel.configureNetwork()
        defineDelegates()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chatViewModel.getCurrentUserData(completionHandler: handleUserData(success:error:))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        chatViewModel.scrollAnimated = false
        chatViewModel.chatListener!.remove()
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        chatViewModel.logout(completionHandler: handleLogout(success:error:))
    }
    
    func handleLogout(success: Bool, error: Error?) {
        if success {
            navigationController?.popToRootViewController(animated: true)
        } else {
            showLogicFailure(title: "Unable to logout", message: error!.localizedDescription)
        }
    }
    
    func handleUserData(success: Bool, error: Error?) {
        if success {
            chatViewModel.chatListener = chatViewModel.getMessageUpdates(completionHandler: handleMessageData(success:error:))
        } else {
            showLogicFailure(title: "Network error", message: error?.localizedDescription ?? "")
        }
    }
    
    func handleMessageData(success: Bool, error: Error?) {
        if success {
            configureMessageView()
        } else {
            showLogicFailure(title: "Unable to update", message: error?.localizedDescription ?? "")
        }
    }
    
    func configureMessageView() {
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToItem(at: IndexPath(row: 0, section: chatViewModel.messagesArray.count - 1), at: .top, animated: chatViewModel.scrollAnimated)
        chatLoadingIndicator.stopAnimating()
        subView.isHidden = true
    }
    
    func configureUI() {
        title = "Chatter"
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: true)
        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        parentView.bringSubviewToFront(subView)
        subView.alpha = 0.5
        subView.isHidden = false
        chatLoadingIndicator.startAnimating()
    }
    
    func defineDelegates() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
 
}
