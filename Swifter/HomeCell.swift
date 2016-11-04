//
//  HomeCell.swift
//  Swifter
//
//  Created by D on 10/30/16.
//  Copyright © 2016 D Conway. All rights reserved.
//

import UIKit

open class HomeCell: UITableViewCell {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var handle: UILabel!
    @IBOutlet weak var sweet: UITextView!
    
    
    override open func awakeFromNib() {
        super.awakeFromNib()
    }

    open func configure(_ profilePic: String?, name: String, handle: String, sweet: String) {
        
        self.sweet.text = sweet
        self.handle.text = "@" + handle
        self.name.text = name
        
        if profilePic != nil {
            
            let imageData = NSData(contentsOf: NSURL(string: profilePic!) as! URL)
            
            self.profilePic.image = UIImage(data: imageData as! Data)
            
        } else {
            
            self.profilePic.image = UIImage(named: "final profile")
        }
        
        
    }
    
    
    
    
    
}
