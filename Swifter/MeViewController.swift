//
//  MeViewController.swift
//  Swifter
//
//  Created by D on 11/3/16.
//  Copyright © 2016 D Conway. All rights reserved.
//

import UIKit

class MeViewController: UIViewController {

    @IBOutlet weak var sweetsContainer: UIView!
    @IBOutlet weak var mediaContainer: UIView!
    @IBOutlet weak var likesContainer: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
