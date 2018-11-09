//
//  HomeFeedViewController.swift
//  MapFeed
//
//  Created by Jade Thomason on 4/23/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import UIKit

class HomeFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var feedTableView: UITableView!
    
    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedTableView.delegate = self
        feedTableView.dataSource = self
        feedTableView.rowHeight = 200
        handleFetching()
    }
    
    func handleFetching() {
        UserController.shared.fetchAllUsers { (_) in
            DispatchQueue.main.async {
                self.feedTableView.reloadData()
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserController.shared.users.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "homeFeedTableViewCell", for: indexPath) as? HomeFeedTableViewCell else { return UITableViewCell() }
        
        let user = UserController.shared.users[indexPath.row]
        cell.user = user
        cell.delegate = self
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVCFromHomeFeedVC" {
            if let detailVC = segue.destination as? DetailViewController {
                let post = self.post
                detailVC.post = post
            }
        }
    }
}

extension HomeFeedViewController: CollectionViewCellDelegate {
    func collectionViewCellWasTapped(post: Post) {
        self.post = post
        performSegue(withIdentifier: "toDetailVCFromHomeFeedVC", sender: nil)
    }
}


















