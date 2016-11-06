//
//  NewSweetVC.swift
//  Swifter
//
//  Created by D on 10/30/16.
//  Copyright © 2016 D Conway. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class NewSweetVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var newSweetTextView: UITextView!
    @IBOutlet weak var newSweetToolbar: UIToolbar!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    var toolbarBottomConstraintInitialValue: CGFloat?
    var databaseRef = FIRDatabase.database().reference()
    var loggedInUser: AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.newSweetToolbar.isHidden = true
        
        self.loggedInUser = FIRAuth.auth()?.currentUser
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NewSweetVC.dismissKeyboard))
        view.addGestureRecognizer(tap)

        
        newSweetTextView.textContainerInset = UIEdgeInsetsMake(30, 20, 20, 20)
        newSweetTextView.text = "What's going on?"
        newSweetTextView.textColor = UIColor.lightGray
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        enableKeyboardHideOnTapped()
        self.toolbarBottomConstraintInitialValue = toolbarBottomConstraint.constant
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if newSweetTextView.textColor == UIColor.lightGray {
            
            newSweetTextView.text = ""
            newSweetTextView.textColor = UIColor.black
            
        }
        
    }

    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // hides the keyboard when you press enter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return false
    }
    
    @IBAction func sweetButtonPressed(_ sender: AnyObject) {
        
        if newSweetTextView.text.characters.count > 0 {
            
            let key = self.databaseRef.child("sweets").childByAutoId().key
            
            let childUpdates = ["/sweets/\(self.loggedInUser!.uid!)/\(key)/text":newSweetTextView.text, "/sweets/\(self.loggedInUser!.uid!)/\(key)/timestamp":"\(Date().timeIntervalSince1970)"] as [String : Any]
            
            self.databaseRef.updateChildValues(childUpdates)
            
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    func enableKeyboardHideOnTapped() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(NewSweetVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(NewSweetVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NewSweetVC.hideKeyboard))
        
        self.view.addGestureRecognizer(tap)
        
    }
    
    func keyboardWillShow(_ notification: NSNotification) {
        
        let info = notification.userInfo!
        
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animate(withDuration: duration) { 
            
            self.toolbarBottomConstraint.constant = keyboardFrame.size.height
            
            self.newSweetToolbar.isHidden = false
            
            self.view.layoutIfNeeded()
            
        }
        
    }
    
    func keyboardWillHide(_ notification: NSNotification) {
        
      let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animate(withDuration: duration) { 
            
            self.toolbarBottomConstraint.constant = self.toolbarBottomConstraintInitialValue!
            
            self.newSweetToolbar.isHidden = true
            
            self.view.layoutIfNeeded()
            
        }
        
    }
    
    func hideKeyboard() {
        
        self.view.endEditing(true)
        
    }
    
    
    
    
}
