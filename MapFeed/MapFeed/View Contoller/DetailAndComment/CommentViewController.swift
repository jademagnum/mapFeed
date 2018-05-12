//
//  CommentViewController.swift
//  MapFeed
//
//  Created by Jade Thomason on 5/11/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var commentTableVIew: UITableView!
    
    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentTableVIew.delegate = self
        commentTableVIew.dataSource = self
        commentTableVIew.rowHeight = 150
        self.tabBarController?.tabBar.isHidden = true

        guard let post = post else { return }
        
        CommmentController.shared.fetchComments(post: post) {_ in
            DispatchQueue.main.async {
                self.commentTableVIew.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let post = post else { return 0 }
        return post.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as? CommentTableViewCell else { return UITableViewCell() }
        
        let comment = post?.comments[indexPath.row]
        cell.comment = comment
        return cell
    }

//    @discardableResult func addComment(toPost post: Post, user: User, commentText: String, userRef: CKReference, postRef: CKReference, completion: @escaping ((Comment) -> Void) = { _ in }) -> Comment {
//        let comment = Comment(post: post, user: user, text: commentText, userRef: userRef, postRef: postRef)
//        post.comments.append(comment)
//
//                cloudKitManager.modifyRecords([comment.cloudKitRecord], perRecordCompletion: nil) { (records, error) in
//                    guard let records = records else { return }
//                    if let error = error {
//                        print("\(#function), \(error), \(error.localizedDescription)")
//                    }
//                }
//        return comment
//    }
    

}
