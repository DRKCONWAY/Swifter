//
//  HomeVC.swift
//  Swifter
//
//  Created by D on 10/29/16.
//  Copyright © 2016 D Conway. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import SDWebImage

class HomeVC: UIViewController, UITableViewDataSource {

    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    
    var databaseRef = FIRDatabase.database().reference()
    var loggedInUser: AnyObject?
    var loggedInUserData: NSDictionary?
    var sweets = [NSDictionary]()
    var defaultImageHeightConstraint: CGFloat = 104
    
    override func viewDidLoad() {
        super.viewDidLoad()

        homeTableView.estimatedRowHeight = 202
        homeTableView.rowHeight = UITableViewAutomaticDimension
        
        homeTableView.dataSource = self
        
                //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HomeVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
        self.loggedInUser = FIRAuth.auth()?.currentUser
        

      // get the logged in user's details
        
        self.databaseRef.child("user_profiles").child(self.loggedInUser!.uid).observeSingleEvent(of: .value) { (snapshot:FIRDataSnapshot) in
            
            
            // store the logged in user's details in the var
            
            self.loggedInUserData = snapshot.value as? NSDictionary
            print(self.loggedInUserData)
            
            
            // get all of the tweets made by the user
            
            self.databaseRef.child("sweets").child(self.loggedInUser!.uid).observe(.childAdded, with: { (snapshot) in

                
            self.sweets.append(snapshot.value as! NSDictionary)

                
            self.homeTableView.insertRows(at: [IndexPath (row: 0, section: 0)], with: UITableViewRowAnimation.automatic)

                
            self.activityLoader.stopAnimating()
                
                
            }){(error) in
                
                
                print(error.localizedDescription)
                
             }
        }
     
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: HomeCell = tableView.dequeueReusableCell(withIdentifier: "HomeVCCell", for: indexPath) as! HomeCell

        let sweet = sweets[(self.sweets.count - 1) - (indexPath.row)]["text"] as! String
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapMediaInSweet(_:)))
        
        cell.sweetImage.addGestureRecognizer(imageTap)
        
        if sweets[(self.sweets.count - 1) - (indexPath.row)]["picture"] != nil {
            
            cell.sweetImage.isHidden = false
            cell.sweetImageHeightConstraint.constant = defaultImageHeightConstraint
            
            let picture = sweets[(self.sweets.count - 1) - (indexPath.row)]["picture"] as! String
            
            let url = URL(string: picture)
            cell.sweetImage.layer.cornerRadius = 12
            cell.sweetImage.layer.borderWidth = 3
            
            cell.sweetImage!.sd_setImage(with: url, placeholderImage: UIImage(named:"Swifter bird")!)
            
        } else {
            
            cell.sweetImage.isHidden = true
            cell.sweetImageHeightConstraint.constant = 0
            
        }
        
        
        cell.configure(nil, name: self.loggedInUserData!["name"] as! String, handle: loggedInUserData!["handles"] as! String, sweet: sweet)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.sweets.count
       
    }
 
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    func didTapMediaInSweet(_ sender: UITapGestureRecognizer) {
        
        
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        
        newImageView.frame = self.view.frame
        
        newImageView.backgroundColor = UIColor.black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target:self,action:#selector(self.dismissFullScreenImage))
        
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        
    }
    
    func dismissFullScreenImage(sender: UITapGestureRecognizer) {
        
      sender.view?.removeFromSuperview()
        
    }
    
    
    
}
