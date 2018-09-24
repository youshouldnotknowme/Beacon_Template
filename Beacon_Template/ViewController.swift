//
//  ViewController.swift
//  Beacon_Template
//
//  Created by Miguel Sicart on 24/09/2018.
//  Copyright © 2018 Miguel Sicart. All rights reserved.
//

import UIKit
import CoreLocation //importing the framework for Bluetooth access

class ViewController: UIViewController, CLLocationManagerDelegate //need to declare this delegate
{

    //Mark - Properties
    
    //The Location Manager is used to interface with the Bluetooth data
    var locationManager: CLLocationManager!
    
    
    //Mark - View Management
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //we initialize the location manager
        //the delegate is the self (ah, programming)
        //we need the user authorization
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
    }
    
    
    //Mark - Location Manager
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        //adapted from the hacking with swift tutorial
        //if we are allowed to use location
        //SUPER IMPORTANT: IF IN MACOS, ADD THE FOLLOWING TO YOUR .PLIST
        //privacy location always usage description
        //or
        //privacy location when in use description
        if status == .authorizedAlways
        {
            //if our machine can monitor
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self)
            {
                //if it is possible to search for stuff within a range
                if CLLocationManager.isRangingAvailable()
                {
                    scanForBeacons()
                }
            }
        }
    }
    
    //this function is part of the CLLocationManagerDelegate
    //It uses the ranging method to figure out if there beacons, how far away they are
    //lifted directly from the Hacking with Swift tutorial
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion)
    {
        //if there are more than zero beacons
        if beacons.count > 0
        {
            //we take the first one from the array
            let beacon = beacons[0]
            //and we sen its distance to the update loop
            update(distance: beacon.proximity)
        }
        else //if there are no beacons around
        {
            //we tell the update loop that there is nothing to see here.
            update(distance: .unknown)
        }
    }
    
    
    //Mark - Beacon Scanning
    func scanForBeacons()
    {
        //we declare the UUID to look for
        //this is the beacon UUID
        let uuid = UUID(uuidString:"92AB49BE-4127-42F4-B532-90fAF1E26491")! //values here are taken from my Locate iOS app
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: "MyBeacon") //values here are taken from my Locate iOS app
        
        //looking for beacons
        locationManager.startMonitoring(for: beaconRegion)
        
        //and trying to figure out how far away they are
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    
    //Mark - Update Loop
    
    //A loop that "pings" for proximity
    //I would make the calls to very simple game logic here
    //as in, things that say boom, state changes, etc.
    func update(distance: CLProximity)
    {
        switch distance
        {
        case .unknown:
            print("Unknown Distance")
        case .far:
            print("Far Distance")
        case .near:
            print("Near Distance")
        case .immediate:
            print("Immediate Distance")
        default:
            break
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

