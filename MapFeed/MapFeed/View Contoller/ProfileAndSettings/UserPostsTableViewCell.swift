//
//  UserPostsTableViewCell.swift
//  MapFeed
//
//  Created by Jade Thomason on 4/23/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import UIKit

class UserPostsTableViewCell: UITableViewCell {

    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    var currentUser: UserController?
    
    var post: Post? {
        didSet {
            updateviews()
        }
    }
    
    func updateviews() {
        headlineLabel.text = post?.headline
        timestampLabel.text = "\(String(describing: post?.timeStamp))"
    }
}




