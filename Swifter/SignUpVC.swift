//
//  SignUpVC.swift
//  Swifter
//
//  Created by D on 10/29/16.
//  Copyright © 2016 D Conway. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SignUpVC: UIViewController {
    
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var databaseRoot = databaseRef
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
  // hide the sign up button at launch and wait for text to be entered to enable it
        
        signUpBtn.isEnabled = false
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpVC.dismissKeyboard))
        view.addGestureRecognizer(tap)

    }
    
    
    
    @IBAction func signUpButtonPressed(_ sender: AnyObject) {
        
        signUpBtn.isEnabled = false
        
        FIRAuth.auth()?.createUser(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
            
            // if there's an error
            if error != nil {
                
                // display error popup to the user
                let alertController = UIAlertController(title: "Error", message: "Please create a valid account.", preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                    print("You've pressed OK button");
                }
                
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion:nil)
                
            } else {
                
                // successful login
                FIRAuth.auth()?.signIn(withEmail: self.emailField.text!, password: self.passwordField.text!, completion: { (user, error) in
                    
                    if error == nil {
                        
                        self.databaseRoot.child("user_profiles").child((user?.uid)!).child("email").setValue(self.emailField.text)
                        
                        self.performSegue(withIdentifier: "goToNewUserVC", sender: nil)
                    }
                
                })
            }
            
        })
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
    self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func textEntered(_ sender: UITextField) {
        
        if (emailField.text?.characters.count)! > 0 && (passwordField.text?.characters.count)! > 0 {
            
            signUpBtn.isEnabled = true
            
        } else {
            
            signUpBtn.isEnabled = false
        }
    }
    
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
 
    
}
