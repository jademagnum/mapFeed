//
//  WelcomeViewController.swift
//  MapFeed
//
//  Created by Jade Thomason on 4/18/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUser = UserController.shared.currentUser else { return }
        
        usernameLabel.text = "Welcome, \(currentUser.username)!"
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
