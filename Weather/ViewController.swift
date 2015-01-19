//
//  ViewController.swift
//  Weather
//
//  Created by RaghuKV on 1/14/15.
//  Copyright (c) 2015 RaghuKV. All rights reserved.
// test

import UIKit

class ViewController: UIViewController {
    

    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var toButton: UILabel!
    @IBOutlet weak var fromButton: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()


        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        var touch = touches.anyObject() as UITouch
        if( CGRectContainsPoint(self.fromButton.frame, touch.locationInView(self.view))){
            println("got it");
            
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil);
            let address : UIViewController = storyboard.instantiateViewControllerWithIdentifier("AddressPickViewController") as UIViewController
        
            self.presentViewController(address, animated: true, completion: nil)

            
        }
        
    }


}

