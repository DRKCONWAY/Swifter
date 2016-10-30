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

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: HomeCell = tableView.dequeueReusableCell(withIdentifier: "HomeVCCell", for: indexPath) as! HomeCell
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
 
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
