//
//  ProfileUpdateViewController.swift
//  MapFeed
//
//  Created by Jade Thomason on 5/7/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import UIKit

class ProfileUpdateViewController: ShiftableViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var bioTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        usernameTextField.delegate = self
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        websiteTextField.delegate = self
        bioTextField.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
