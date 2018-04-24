//
//  ProfileViewController.swift
//  MapFeed
//
//  Created by Jade Thomason on 4/23/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var firstNameLastNameLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    @IBOutlet weak var postsTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postsTableView.delegate = self
        postsTableView.dataSource = self
  
        guard let currentUser = UserController.shared.currentUser else { return }
        PostController.shared.fetchPosts(user: currentUser) {
            DispatchQueue.main.async {
                self.postsTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let userPosts = PostController.shared.posts.count
        return userPosts
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "profilePostCell", for: indexPath) as? UserPostsTableViewCell else { return UITableViewCell() }
        
        let userPost = PostController.shared.posts[indexPath.row]
        cell.post = userPost
        cell.timestampLabel.text = "\(userPost.timeStamp)"
        return cell
        
    }
    

    
    
}
