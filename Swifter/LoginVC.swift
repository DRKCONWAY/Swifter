//
//  LoginVC.swift
//  Swifter
//
//  Created by D on 10/29/16.
//  Copyright © 2016 D Conway. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginVC: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    var databaseRoot = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginVC.dismissKeyboard))
        view.addGestureRecognizer(tap)

    }

    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    @IBAction func cancelBtnPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginBtnTapped(_ sender: AnyObject) {
        
        FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
            
            // if there is no error
            if error == nil {
                
                self.databaseRoot.child("user-profiles").child((user?.uid)!).child("handle-names").observeSingleEvent(of: .value, with: { (snapshot: FIRDataSnapshot) in
                    
                    if !snapshot.exists() {
                        
                // user doesn't have a handle, send them to setup screen
                        self.performSegue(withIdentifier: "goToHandleCreationVC", sender: nil)
                        
                    } else {
                        
                        self.performSegue(withIdentifier: "goToHomeVC", sender: nil)
                    }
                    
                })
                
            } else {
                
                self.performSegue(withIdentifier: "goToHandleCreationVC", sender: nil)
            }
            
        })
        
    }
    
}
