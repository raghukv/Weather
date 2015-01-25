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

class AddressPickViewController : UIViewController, UITableViewDelegate ,UITableViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate {
    
    var suggestionView : UITableView = UITableView()
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var fromBar: UITextField!
    @IBOutlet weak var toBar: UITextField!
    var list : NSMutableArray = NSMutableArray()
    
    var textDelegate : UITextFieldDelegate!
    
    let locationMananger = CLLocationManager()
    
    var localSearch : MKLocalSearch!
    
    var searchTimer = NSTimer()


    override func viewDidLoad() {
    
        self.locationMananger.delegate = self
        
        self.locationMananger.desiredAccuracy = kCLLocationAccuracyBest
        
        self.locationMananger.requestWhenInUseAuthorization()
        
        self.locationMananger.startUpdatingLocation()
        
        zoomToLocation()
        
        mapView = MKMapView()
        
        self.fromBar.delegate = self
        self.toBar.delegate = self
        suggestionView.hidden = true
        suggestionView.userInteractionEnabled = true
        fromBar = UITextField()
        toBar = UITextField()
    }
    
    
    
    /**
        MAP VIEW FUNCTIONS
    */
    func zoomToLocation() -> Void{
        let userLocation = locationMananger.location
        
        let region = MKCoordinateRegionMakeWithDistance(
            userLocation.coordinate, 10000, 10000)
        
        mapView.setRegion(region, animated: true)

    }
    
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!)
    {
        
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler:
            { (placemarks, error) -> Void in
            if (error != nil) {
                println("Error:" + error.localizedDescription)
                return
            }
            if placemarks.count > 0 {
                let pm = placemarks[0] as CLPlacemark
                
                
            }else {
                println("Error with data")
            }
       })
     
    }
    
    func displayLocationInfo(placemark: CLPlacemark) {
        self.locationMananger.stopUpdatingLocation()
        println(placemark.locality)
        
        println(placemark.postalCode)
        
        println(placemark.administrativeArea)
        
        println(placemark.country)
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
        println("Error: " + error.localizedDescription)
        
    }
    
    func loadSuggestions(timer: NSTimer) -> Void {
        
        var text = timer.userInfo as NSString
        
        
        
        if(text == ""){
            return
        }
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = text as NSString

        request.region = self.mapView.region;
        
        var search:MKLocalSearch = MKLocalSearch.init(request: request)
        search.startWithCompletionHandler {
            (response:MKLocalSearchResponse!, error:NSError!) in
            if !(error != nil) {

                for item in response.mapItems {
                    self.list.addObject(item)
                    println(item)
                }
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.showAnnotations(self.list, animated: true)
            } else {
                
            }
        }
    }
    
    
    
    
    /**
        TEXT FIELD FUNCTIONS
    */
    func textFieldDidBeginEditing(textField: UITextField) {
        showSuggestionView()
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        println(textField.text + string)

        
//        if(!searchTimer.valid){
//            searchTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "loadSuggestions:", userInfo: textField.text, repeats: true);
//        }
    
        return true;
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        hideSuggestionView()
    }
    
    func showSuggestionView() -> Void {
        suggestionView.hidden = false
        suggestionView.userInteractionEnabled = true
    }
    
    func hideSuggestionView() -> Void {
        suggestionView.hidden = true
        suggestionView.userInteractionEnabled = false
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell = self.suggestionView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        
        cell.textLabel?.text = list.objectAtIndex(indexPath.row) as NSString
        
        return cell
    }
    

}