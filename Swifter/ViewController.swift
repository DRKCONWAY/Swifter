//
//  ViewController.swift
//  Swifter
//
//  Created by D on 10/31/16.
//  Copyright © 2016 D Conway. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            
            if let currentUser = user {
                
                print("user is signed in")
                
        // send the user to home screen
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                
                let homeVC: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "TabBarControllerView")
                
                // send user to home screen
                self.present(homeVC, animated: true, completion: nil)
                
            }
    
        })
    }
    
    

}
