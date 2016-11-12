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
import FirebaseStorage

class NewSweetVC: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var newSweetTextView: UITextView!
    @IBOutlet weak var newSweetToolbar: UIToolbar!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    var toolbarBottomConstraintInitialValue: CGFloat?
    var databaseRef = FIRDatabase.database().reference()
    var loggedInUser: AnyObject?
    var imagePicker = UIImagePickerController()
    
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
        
        var imagesArray = [AnyObject]()
        
        //extract the images from the attributed text
        self.newSweetTextView.attributedText.enumerateAttribute(NSAttachmentAttributeName, in: NSMakeRange(0, self.newSweetTextView.text.characters.count), options: []) { (value, range, true) in
            
            if value is NSTextAttachment {
                
                let attachment = value as! NSTextAttachment
                
                var image: UIImage? = nil
                
                if attachment.image != nil {
                    
                    image = attachment.image!
                    imagesArray.append(image!)
                    
                    
                } else {
                    
                    print("No image found!!")
                    
                }
                
            }
            
        }
        
        let sweetLength = newSweetTextView.text.characters.count
        let numImages = imagesArray.count
        
        let key = self.databaseRef.child("sweets").childByAutoId().key
        let storageRef = FIRStorage.storage().reference()
        let picStorageRef = storageRef.child("user_profiles/\(self.loggedInUser!.uid)/media/\(key)")
        
        let lowResImageData = UIImageJPEGRepresentation(imagesArray[0] as! UIImage, 0.5)
        
        if sweetLength > 0 && numImages > 0 {
            
            let uploadTask = picStorageRef.put(lowResImageData!, metadata: nil) {metadata, error in
                
                if error == nil {
                    
                    let downloadURL = metadata!.downloadURL()
                    
                    let childUpdates = ["/sweets/\(self.loggedInUser!.uid!)/\(key)/text": self.newSweetTextView.text, "/sweets/\(self.loggedInUser!.uid!)/\(key)/timestamp":"\(Date().timeIntervalSince1970)", "/sweets/\(self.loggedInUser!.uid!)/\(key)/picture": downloadURL!.absoluteString] as [String : Any]
                    
                    self.databaseRef.updateChildValues(childUpdates)
                }
                
            }
            self.dismiss(animated: true, completion: nil)
            
        } else if sweetLength > 0 {
            
            let childUpdates = ["/sweets/\(self.loggedInUser!.uid!)/\(key)/text":newSweetTextView.text, "/sweets/\(self.loggedInUser!.uid!)/\(key)/timestamp":"\(Date().timeIntervalSince1970)"] as [String : Any]
            
            self.databaseRef.updateChildValues(childUpdates)
            
            dismiss(animated: true, completion: nil)
            
        } else if numImages > 0 {
            
            let uploadTask = picStorageRef.put(lowResImageData!, metadata: nil) {metadata, error in
                
                if error == nil {
                    
                    let downloadURL = metadata!.downloadURL()
                    
                    let childUpdates = ["/sweets/\(self.loggedInUser!.uid!)/\(key)/timestamp":"\(Date().timeIntervalSince1970)", "/sweets/\(self.loggedInUser!.uid!)/\(key)/picture": downloadURL!.absoluteString] as [String : Any]
                    
                    self.databaseRef.updateChildValues(childUpdates)
                    
                    
                } else {
                    
                print(error?.localizedDescription)
            }
        }

            self.dismiss(animated: true, completion: nil)
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
    
    
    @IBAction func selectImageFromPhotos(_ sender: UIBarButtonItem) {
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .savedPhotosAlbum
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
    }
    
    //after user has picked an image from photo gallery, this function will be called
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        var attributedString = NSMutableAttributedString()
        
        if self.newSweetTextView.text.characters.count > 0 {
            
            attributedString = NSMutableAttributedString(string: self.newSweetTextView.text)
            
        } else {
            
            attributedString = NSMutableAttributedString(string: "What's going on?\n")
            
        }
        
        // allows us to attach images to text
        let textAttachment = NSTextAttachment()
        
        textAttachment.image = image
        
        let oldWidth: CGFloat = textAttachment.image!.size.width
        
        let scaleFactor: CGFloat = oldWidth/(newSweetTextView.frame.size.width - 50)
        
        textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
        
        let attributedStringWithImage = NSAttributedString(attachment: textAttachment)
        
        attributedString.append(attributedStringWithImage)
        
        newSweetTextView.attributedText = attributedString
        
        self.dismiss(animated: true, completion: nil)
    
     }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
