//
//  DetailVC.swift
//  VirtualTourist
//
//  Created by Arch Studios on 6/30/19.
//  Copyright © 2019 AS. All rights reserved.
//

import UIKit

class DetailVC: UIViewController {
    //MARK:- Properties
    var photo: UIImage!
    
    var actionButton: UIBarButtonItem!
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = photo
        
        actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(setupActivityViewController))
        navigationItem.rightBarButtonItem = actionButton
        actionButton.isEnabled = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(true)
        if photo != nil{
            actionButton.isEnabled = true
        }
    }
    
    
    //MARK:- Custom Functions
    @ objc func setupActivityViewController() {
        guard let image = imageView.image else {return}
        let ac = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        ac.excludedActivityTypes = [.saveToCameraRoll]
        self.present(ac, animated: true, completion: nil)
        
        
    }
}
