//
//  CommentViewController.swift
//  MapFeed
//
//  Created by Jade Thomason on 5/11/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import UIKit
import CloudKit

class CommentViewController: ShiftableViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var commentTableView: UITableView!
    
    var post: Post?
    var comments: [Comment] = []
    var currentUser = UserController.shared.currentUser
    
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter comment..."
        return textField
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        let titleColor = UIColor.blue
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    @objc func handleSend() {
        print(inputTextField.text)
        guard let currentUserID = currentUser?.cloudKitRecordID else { return }
        var userRef = CKReference(recordID: currentUserID, action: .deleteSelf)
        
        guard let postID = post?.cloudKitRecordID else { return }
        let postRef = CKReference(recordID: postID, action: .deleteSelf)
        
        guard let post = post else { return }
        guard let currentUser = currentUser else { return }
        
        guard let comment = inputTextField.text else { return }
        
        CommmentController.shared.addComment(toPost: post, user: currentUser, commentText: comment, userRef: userRef, postRef: postRef)
        
        CommmentController.shared.fetchComments(post: post) {_ in
            self.comments = post.comments
            DispatchQueue.main.async {
                self.commentTableView.reloadData()
            }
        }
        commentTableView.reloadData()
        inputTextField.text = ""
    }
    
    var bottomConstaint: NSLayoutConstraint?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        self.tabBarController?.tabBar.isHidden = true
        super.viewDidLoad()
        commentTableView.delegate = self
        commentTableView.dataSource = self
        commentTableView.rowHeight = 150
        
        
        guard let post = post else { return }
        
        CommmentController.shared.fetchComments(post: post) {_ in
            self.comments = post.comments
            DispatchQueue.main.async {
                self.commentTableView.reloadData()
            }
        }
        view.addSubview(messageInputContainerView)
        view.addConstraintsWithFormat("H:|[v0]|", views: commentTableView)
        view.addConstraintsWithFormat("H:|[v0]|", views: messageInputContainerView)
        view.addConstraintsWithFormat("V:|[v0][v1(48)]", views: commentTableView, messageInputContainerView)
        
        bottomConstaint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraints([bottomConstaint!])
        
        setupInputComponents()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue
            let keyboardFrameValue = keyboardFrame?.cgRectValue
            
            let isKeyboardShowing = notification.name == .UIKeyboardWillShow
            
            bottomConstaint?.constant = isKeyboardShowing ? -keyboardFrameValue!.height : 0
            
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }) { (completed) in
                if isKeyboardShowing {
                    let indexPath = IndexPath(item: self.post!.comments.count - 1, section: 0)
                    self.commentTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        inputTextField.endEditing(true)
    }
  
//    If you'd like to dismiss the keyboard if the user taps anywhere (not only on the bubbles), I suggest adding a tap gesture recognizer directly on the controller referring to a method calling endEditing on your message field. Eg. view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(YourControllerName.dismissKeyboard))) directly in viewDidLoad() of your controller and implementing the yourTextField.endEditing(true) in a method called dismissKeyboard() in this example﻿
    
    private func setupInputComponents() {
        let topBorderView = UIView()
        topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addSubview(topBorderView)
        
        messageInputContainerView.addConstraintsWithFormat("H:|-8-[v0][v1(60)]|", views: inputTextField, sendButton)
        messageInputContainerView.addConstraintsWithFormat("V:|[v0]|", views: inputTextField)
        messageInputContainerView.addConstraintsWithFormat("V:|[v0]|", views: sendButton)
        
        messageInputContainerView.addConstraintsWithFormat("H:|[v0]|", views: topBorderView)
        messageInputContainerView.addConstraintsWithFormat("V:|[v0(0.5)]", views: topBorderView)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.comments.sort(by: { $0.timestamp < $1.timestamp })
            self.comments.remove(at: indexPath.row)
            self.commentTableView.reloadData()
        }
        
//        let reportAction = UITableViewRowAction(style: .default, title: "Report") { (action, indexPath) in
//            self.post?.comments.remove(at: indexPath.row)
//            self.commentTableView.reloadData()
//        }
        
        return [deleteAction]
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as? CommentTableViewCell else { return UITableViewCell() }
        
        var comments = self.comments
        
        comments.sort(by: { $0.timestamp < $1.timestamp })
        let comment = comments[indexPath.row]
        cell.comment = comment
        return cell
        
    }
}























