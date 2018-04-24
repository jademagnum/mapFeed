//
//  HomeFeedTableViewCell.swift
//  MapFeed
//
//  Created by Jade Thomason on 4/23/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import UIKit

class HomeFeedTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet private weak var homeFeedCollectionView: UICollectionView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var user: User? {
        didSet {
            setupViews()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupViews() {
        homeFeedCollectionView.delegate = self
        homeFeedCollectionView.dataSource = self
        guard let user = user else { return }
        usernameLabel.text = user.username
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PostController.shared.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = homeFeedCollectionView.dequeueReusableCell(withReuseIdentifier: "homeFeedCollectionViewCell", for: indexPath) as? HomeFeedCollectionViewCell,
            let post = user?.posts[indexPath.row] else { return UICollectionViewCell() }
        
        
        cell.headlineLabel.text = post.headline
        cell.timestampLabel.text = "\(post.timeStamp)"
  
     
        return cell
    }
}















