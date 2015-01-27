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
import AddressBookUI

class AddressPickViewController : UIViewController, UITableViewDelegate ,UITableViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate {
    
    
    // Dropdown table that contains suggestions
    @IBOutlet weak var suggestionView: UITableView!
    
    // Object for holding the Map
    @IBOutlet weak var mapView: MKMapView!
    
    // Objects for holding both the search bars respectively
    @IBOutlet weak var fromBar: UITextField!
    @IBOutlet weak var toBar: UITextField!
    
    // Object that listens to activity on text fields
    var textDelegate : UITextFieldDelegate!
    
    // Object for managing location
    let locationMananger = CLLocationManager()
    
    // Object responsible for calling autosuggest
    var localSearch : MKLocalSearch!
    
    // Autosuggest request
    var request: MKLocalSearchRequest!
    
    // Autosuggest response
    var response = MKLocalSearchResponse()
    
    // This is the array in which suggestions are stored. 
    // This is the source for Dropdown table view
    var suggestionList : NSArray!
    
    // 1 for FROM and 2 for TO
    var addressBeingSelected = 1

    /**
        Set up everything here
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initializing the array
        suggestionList = NSArray()
        
        // setting up location
        self.locationMananger.delegate = self
        self.locationMananger.desiredAccuracy = kCLLocationAccuracyBest
        self.locationMananger.requestWhenInUseAuthorization()
        self.locationMananger.startUpdatingLocation()
        
        zoomToLocation()
        
        // hiding the dropdown view by default. shown when editing fields
        suggestionView.hidden = true
        suggestionView.userInteractionEnabled = false
        
        // setting up dropdown table
        self.suggestionView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        suggestionView.dataSource = self
        suggestionView.delegate = self
        
    }
    
    
    /**
        MAP VIEW FUNCTIONS
    */
    func zoomToLocation() -> Void{
        let userLocation = locationMananger.location
        
        let region = MKCoordinateRegionMakeWithDistance(
            userLocation.coordinate, 20000, 20000)
        
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
    
    
    func loadSug(text: NSString) -> Void {
        var searchString = text
        request = MKLocalSearchRequest()
        request?.naturalLanguageQuery = searchString
        request?.region = mapView.region
        
        var search:MKLocalSearch = MKLocalSearch.init(request: request)
        search.startWithCompletionHandler {
            (response:MKLocalSearchResponse!, error:NSError!) in
            if !(error != nil) {
                self.response = response
                self.suggestionList = self.response.mapItems
                self.suggestionView.reloadData()
            } else {
                println("results not found for " + searchString
                )
            }
        }
    }
    
    /**
        TEXT FIELD FUNCTIONS
    */
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if(textField.tag == 1){
            self.addressBeingSelected = 1
        }else if (textField.tag == 2){
            self.addressBeingSelected = 2
        }
        reloadSuggestionView()
        showSuggestionView()
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        reloadSuggestionView()
        hideSuggestionView()
    }
    
    func reloadSuggestionView() -> Void {
        self.suggestionList = nil
        self.suggestionList = NSArray()
        self.suggestionView.reloadData()
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        var searchString = textField.text as NSString
        
        searchString =  searchString.stringByReplacingCharactersInRange(range, withString: string)
        
        loadSug(searchString)
    
        return true;
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
        return self.suggestionList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell = self.suggestionView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        
        var item : MKMapItem = self.suggestionList[indexPath.row] as MKMapItem;
        
        var address : NSString = ABCreateStringWithAddressDictionary(item.placemark.addressDictionary, true)
        
        let formattedAddress = address.stringByReplacingOccurrencesOfString("\n", withString: ", ", options: nil, range: NSMakeRange(0, address.length))
        
        cell.textLabel?.text = formattedAddress
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var selectedItem: MKMapItem = self.suggestionList[indexPath.row] as MKMapItem;
        
        var address : NSString = ABCreateStringWithAddressDictionary(selectedItem.placemark.addressDictionary, true)
        
        let formattedAddress = address.stringByReplacingOccurrencesOfString("\n", withString: ", ", options: nil, range: NSMakeRange(0, address.length))
        
        
        println(formattedAddress);
        
        if(addressBeingSelected == 1){
            fromBar.text = formattedAddress
            fromBar.resignFirstResponder()
        }else if (addressBeingSelected == 2){
            toBar.text = formattedAddress
            toBar.resignFirstResponder()
        }
        
        hideSuggestionView()
        reloadSuggestionView()
        
    }
    

}