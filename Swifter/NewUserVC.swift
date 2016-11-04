//
//  NewUserVC.swift
//  Swifter
//
//  Created by D on 10/29/16.
//  Copyright © 2016 D Conway. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class NewUserVC: UIViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var handleName: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var startSweetingBtn: UIButton!
    
    var currentUser = FIRAuth.auth()?.currentUser?.uid
    var databaseRoot = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NewUserVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }

    @IBAction func startSweeting(_ sender: AnyObject) {
        errorMessage.text = "Sweet!"
        
        // check to see if the handle name exists already
        let handle = self.databaseRoot.child("handles").child(self.handleName.text!).observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            
            if (!snapshot.exists()) {
                
                // update the handle in the user-profiles and in handles node
                self.databaseRoot.child("user_profiles").child(self.currentUser!).child("handles").setValue(self.handleName.text!.lowercased())
                
                // update the name of user
                self.databaseRoot.child("user_profiles").child(self.currentUser!).child("name").setValue(self.name.text!)
            
                // update the handle in the handle node
                self.databaseRoot.child("handles").child(self.handleName.text!.lowercased()).setValue(self.currentUser)
                
                // send user to home screen
                self.performSegue(withIdentifier: "goToHomeVC", sender: nil)
                
            } else {
                
                self.errorMessage.text = "Handle is already in use!"
            }
            
        }
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        print("back button pressed")
        performSegue(withIdentifier: "goToBeginning", sender: nil)
    }
    
    
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
 
}
