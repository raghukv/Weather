//
//  ViewController.swift
//  Weather
//
//  Created by RaghuKV on 1/14/15.
//  Copyright (c) 2015 RaghuKV. All rights reserved.
// test

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var getStartedLabel: UILabel!
    
    @IBAction func getStartedButtonPress(sender: AnyObject) {
        
        
        getStartedLabel.text = "Thanks for Getting Started !!!!"
        
    }
   

    override func viewDidLoad() {
        super.viewDidLoad()
      
        println("Hello. This is the new weather app....");
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources
    }


}

