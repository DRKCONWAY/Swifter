//
//  MeViewController.swift
//  Swifter
//
//  Created by D on 11/3/16.
//  Copyright © 2016 D Conway. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase



class MeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageLoading: UIActivityIndicatorView!
    @IBOutlet weak var sweetsContainer: UIView!
    @IBOutlet weak var mediaContainer: UIView!
    @IBOutlet weak var likesContainer: UIView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var handle: UILabel!
    @IBOutlet weak var about: UITextField!
    
    var imagePicker = UIImagePickerController()
    var loggedInUser: AnyObject?
    var databaseRef = FIRDatabase.database().reference()
    var storageRef = FIRStorage.storage().reference()
        
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loggedInUser = FIRAuth.auth()?.currentUser
        
        // get the data from the database
        self.databaseRef.child("user_profiles").child(self.loggedInUser!.uid).observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            
            let snapshot = snapshot.value as! [String: AnyObject]
            
            self.name.text = snapshot["name"] as? String
            self.handle.text = snapshot["handles"] as? String
            
            // there won't be anything in the about field at first
            if snapshot["about"] != nil {
                
                self.about.text = snapshot["about"] as? String
                
            }
            
            if snapshot["profile_pic"] != nil {
                
                let databaseProfilePic = snapshot["profile_pic"] as! String
                
                let data = try? Data(contentsOf: URL(string: databaseProfilePic)!)
                
                self.setProfilePic(self.profilePic, imageToSet: UIImage(data: data!)!)
            }
        }

    }

    
    @IBAction func showComponents(_ sender: AnyObject) {
        
        if sender.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.5, animations: { 
                
                self.sweetsContainer.alpha = 0
                self.mediaContainer.alpha = 0
                self.likesContainer.alpha = 1
            })
        } else if sender.selectedSegmentIndex == 1 {
            
            UIView.animate(withDuration: 0.5, animations: { 
                
                self.sweetsContainer.alpha = 0
                self.mediaContainer.alpha = 1
                self.likesContainer.alpha = 0
                
            })
            
        } else if sender.selectedSegmentIndex == 2 {
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.sweetsContainer.alpha = 1
                self.mediaContainer.alpha = 0
                self.likesContainer.alpha = 0
        })
    
     }
}
    
    
    func setProfilePic(_ imageView: UIImageView, imageToSet: UIImage) {
        
        imageView.layer.cornerRadius = 10
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.masksToBounds = true
        imageView.image = imageToSet
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    @IBAction func logoutButtonTapped(_ sender: AnyObject) {
        
        try! FIRAuth.auth()!.signOut()
        
        self.performSegue(withIdentifier: "logout", sender: nil)
        
    }
    
    @IBAction func profilePicTapped(_ sender: UITapGestureRecognizer) {
        
        // allow to view the pic, select the pic from gallery, or select pic from the phone's camera
        let myActionSheet = UIAlertController(title: "Profile Pic", message: "Select", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let viewPicture = UIAlertAction(title: "ViewPicture", style: .default) { (action) in
            
            let imageView = sender.view as! UIImageView
            
            let newImageView = UIImageView(image: imageView.image)
            
            newImageView.frame = self.view.frame
            newImageView.backgroundColor = UIColor.black
            newImageView.contentMode = .scaleAspectFit
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissFullScreenImage(_:)))
            
            newImageView.addGestureRecognizer(tap)
            self.view.addSubview(newImageView)
            
        }
        
        let photoGallery = UIAlertAction(title: "Photos", style: .default) { (action) in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) {
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
                
            }
            
        }
        
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
                
            }
            
        }
        
        myActionSheet.addAction(viewPicture)
        myActionSheet.addAction(photoGallery)
        myActionSheet.addAction(camera)
        
        myActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(myActionSheet, animated: true, completion: nil)
    }
    
    func dismissFullScreenImage(_ sender: UITapGestureRecognizer) {
        
        // removes the larger image from the view
        sender.view?.removeFromSuperview()
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        setProfilePic(self.profilePic, imageToSet: image)
        
        if let imageData: Data = UIImagePNGRepresentation(self.profilePic.image!)! {
            
          let profilePicStorageRef = storageRef.child("user_profiles/\(self.loggedInUser!.uid)/profile_pic")
            
            let uploadTask = profilePicStorageRef.put(imageData, metadata: nil) {metadata, error in
                
                if error == nil {
                    
                    let downloadURL = metadata!.downloadURL()
                    
                self.databaseRef.child("user_profiles").child(self.loggedInUser!.uid).child("profile_pic").setValue(downloadURL!.absoluteString)
                    
                } else {
                    
                    print(error?.localizedDescription)
                }
                
            }
            
           // self.imageLoading.stopAnimating()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}
