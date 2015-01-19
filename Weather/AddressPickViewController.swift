//
//  AddressPickViewController.swift
//  Weather
//
//  Created by RaghuKV on 1/18/15.
//  Copyright (c) 2015 RaghuKV. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class AddressPickViewController : UIViewController, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var toSearch: UISearchBar!
    @IBOutlet weak var fromSearch: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    var manager : CLLocationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        
//        
//        var viewFrame = fromSearch.superview?.frame
//        var fromFrame = fromSearch.frame
//        fromSearch.frame = CGRectMake(fromFrame.origin.x, fromFrame.origin.y, fromFrame.width, viewFrame!.height/2)
//        
//        var toFrame = toSearch.frame
//        toSearch.frame = CGRectMake(toFrame.origin.x, toFrame.origin.y, toFrame.width, viewFrame!.height/2)

        
        
        
        
        
        
        
        
        
        manager.requestAlwaysAuthorization()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        switch authorizationStatus {
        case .Authorized:
            println("authorized")
        case .AuthorizedWhenInUse:
            println("authorized when in use")
        case .Denied:
            println("denied")
        case .NotDetermined:
            println("not determined")
        case .Restricted:
            println("restricted")
        }
        
        
        manager.startUpdatingLocation()
        mapView.showsUserLocation = true
        
    }
    
    override func viewDidAppear(animated: Bool) {
//        mapView.setCenterCoordinate(mapView.userLocation.location.coordinate, animated: true)
    }
    @IBAction func dismissView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
   
}