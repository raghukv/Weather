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

class AddressPickViewController : UIViewController, UITableViewDelegate ,UITableViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    
    @IBOutlet weak var currentLocButton: UIButton!
    @IBOutlet weak var weatherCall: UIButton!
    // Dropdown table that contains suggestions
    @IBOutlet weak var suggestionView: UITableView!
    
    // Object for holding the Map
    @IBOutlet weak var mapView: MKMapView!
    
    //Object for holding the currentLocation
    var currentLocation = MKMapItem()
    
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
    var suggestionList : NSMutableArray!
    
    // 1 for FROM and 2 for TO
    var addressBeingSelected = 1
    
    var fromMapItem: MKMapItem!
    
    var toMapItem: MKMapItem!

    /**
        Set up everything here
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initializing the array
        suggestionList = NSMutableArray()
        
        // setting up location
        self.locationMananger.delegate = self
        self.locationMananger.desiredAccuracy = kCLLocationAccuracyBest
        self.locationMananger.requestWhenInUseAuthorization()
        self.locationMananger.startUpdatingLocation()
        
        var longPress : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPress.minimumPressDuration = 1.0
        self.mapView.addGestureRecognizer(longPress)
        

        
        
        
        // hiding the dropdown view by default. shown when editing fields
        suggestionView.hidden = true
        suggestionView.userInteractionEnabled = false
        
        // setting up dropdown table
        self.suggestionView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        suggestionView.dataSource = self
        suggestionView.delegate = self
        self.mapView.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        zoomToLocation()
    }
    
    @IBAction func weatherCall(sender: AnyObject) {
    
    }
    
    @IBAction func moveToCurrentLocation(sender: AnyObject) {
        zoomToLocation()
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
    
    @IBAction func getDirections(sender: AnyObject) {
        var directionRequest:MKDirectionsRequest = MKDirectionsRequest()
        
        directionRequest.setSource(self.fromMapItem)
        directionRequest.setDestination(self.toMapItem)
        directionRequest.transportType = MKDirectionsTransportType.Automobile
        directionRequest.requestsAlternateRoutes = true
        
        var directions:MKDirections = MKDirections(request: directionRequest)
        directions.calculateDirectionsWithCompletionHandler({
            (response: MKDirectionsResponse!, error: NSError?) in
            if error != nil{
                println("Error")
                println(error?.description)
            }
            if response != nil{
                println(response.description)
                var routeDetails: MKRoute = response.routes.last as MKRoute
                self.mapView.addOverlay(routeDetails.polyline)
                
                
            }
            else{
                println("No response")
            }

        })
        
        
    }
        
    func handleLongPress(gesture : UIGestureRecognizer){
        if(gesture.state != UIGestureRecognizerState.Began){
            return;
        }
        
        var point : CGPoint = gesture.locationInView(self.mapView)
        
        var coordinate : CLLocationCoordinate2D = self.mapView.convertPoint(point, toCoordinateFromView: self.mapView)
        
        makeWeatherCall(coordinate)
        
        var annot = MKPointAnnotation()
        
        annot.coordinate = coordinate
        self.mapView.addAnnotation(annot)
    }
    
    func makeWeatherCall(coordinate : CLLocationCoordinate2D){
        let latitudeText = String(format: "%f", coordinate.latitude) + ","
        let longitudeText = String(format: "%f", coordinate.longitude) + ","
        let currentDate = NSDate()
        let timeStamp : NSTimeInterval = currentDate.timeIntervalSince1970
        let roundedTime : NSInteger = NSInteger(timeStamp)
        println(roundedTime)

        var baseURL : NSString = "https://api.forecast.io/forecast/"
        baseURL = baseURL + "f01d550c9b8c60858405e41b7c1f47dd/"
        
        baseURL = baseURL + latitudeText
        baseURL = baseURL + longitudeText
        baseURL = baseURL + String(roundedTime)

        
        println(baseURL)
        
        
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: baseURL)
        request.HTTPMethod = "GET"
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            
            if (jsonResult != nil) {
                println(jsonResult)
            } else {
                // couldn't load JSON, look at error
            }
        })
    }
    
    
    func mapView(mapView: MKMapView!, viewForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if(overlay.isKindOfClass(MKPolyline)){
            var polyLine = MKPolylineRenderer(overlay: overlay)
            polyLine.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.8)
            polyLine.lineWidth = 5
            return polyLine
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, didAddAnnotationViews views: [AnyObject]!) {
        
//        var annot = views[0];
//        println("did add annotation");
//        println(annot)
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
//        println("view for annotation");
        return nil
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
        
        var latitude = self.locationMananger.location.coordinate.latitude
        var longitude = self.locationMananger.location.coordinate.longitude
        var placeMark = MKPlacemark(coordinate: CLLocationCoordinate2DMake(latitude, longitude), addressDictionary: nil)
        
        var currentLocItem = MKMapItem(placemark: placeMark)
        currentLocItem.name = "Current Location"
        self.currentLocation = currentLocItem

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
                self.suggestionList.removeAllObjects()
                self.suggestionList.addObjectsFromArray(self.response.mapItems)
                self.suggestionView.reloadData()
            }
        }
    }
    
    
    
    
    //************************** TEXT FIELD FUNCTIONS *****************************************
    
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
        self.suggestionList.removeAllObjects()
        suggestionList.addObject(self.currentLocation)
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
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        reloadSuggestionView()
        return true;
    }
    
    //*******************************  END TEXT FIELD  **********************************
    
    
    
    //******************************* BEGIN TABLE VIEW FUNCTIONS  ***********************
    
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
        
        if(item.name? == "Current Location"){
            cell.textLabel?.text = item.name
            return cell
        }
        
        var address : NSString = ABCreateStringWithAddressDictionary(item.placemark.addressDictionary, true)
        
        let formattedAddress = address.stringByReplacingOccurrencesOfString("\n", withString: ", ", options: nil, range: NSMakeRange(0, address.length))
        
        if(item.placemark.location == locationMananger.location){
            cell.textLabel?.text = "Current location";
        }
        
        cell.textLabel?.text = formattedAddress
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var selectedItem: MKMapItem = self.suggestionList[indexPath.row] as MKMapItem;
        
        if(selectedItem.name? == "Current Location"){
            if(addressBeingSelected == 1){
                fromBar.text = selectedItem.name?
                fromBar.resignFirstResponder()
                fromMapItem = selectedItem
            }else if (addressBeingSelected == 2){
                toBar.text = selectedItem.name?
                toBar.resignFirstResponder()
                toMapItem = selectedItem
            }
        }else{
            
            var address : NSString = ABCreateStringWithAddressDictionary(selectedItem.placemark.addressDictionary, true)
            
            let formattedAddress = address.stringByReplacingOccurrencesOfString("\n", withString: ", ", options: nil, range: NSMakeRange(0, address.length))
            
            
            println(formattedAddress);
            
            if(addressBeingSelected == 1){
                fromBar.text = formattedAddress
                fromBar.resignFirstResponder()
                fromMapItem = selectedItem
            }else if (addressBeingSelected == 2){
                toBar.text = formattedAddress
                toBar.resignFirstResponder()
                toMapItem = selectedItem
            }
        }
        
        hideSuggestionView()
        reloadSuggestionView()
    }
    
    //*****************************  END TABLE VIEW FUNCTIONS  **************************
    


}