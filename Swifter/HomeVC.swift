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

class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    
    var databaseRef = FIRDatabase.database().reference()
    var loggedInUser: AnyObject?
    var loggedInUserData: NSDictionary?
    var sweets = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeTableView.delegate = self
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
        
        
        cell.configure(nil, name: self.loggedInUserData!["name"] as! String, handle: loggedInUserData!["handles"] as! String, sweet: sweet)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.sweets.count
       
    }
 
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
    
    
    
    
}
