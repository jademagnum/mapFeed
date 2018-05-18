//
//  CommentTableViewCell.swift
//  MapFeed
//
//  Created by Jade Thomason on 5/11/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    var comment: Comment? {
        didSet {
            updateViews()
        }
    }

    func updateViews() {
        guard let comment = comment else { return }
        usernameLabel.text = comment.user?.username
        commentLabel.text = comment.text
        timestampLabel.text = "\(comment.timestamp)"
    }
    
}
