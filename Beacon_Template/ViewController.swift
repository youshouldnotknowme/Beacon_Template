//
//  ViewController.swift
//  Beacon_Template
//
//  Created by Miguel Sicart on 24/09/2018.
//  Copyright © 2018 Miguel Sicart. All rights reserved.
//

import UIKit
import CoreLocation //importing the framework for Bluetooth access
import CoreBluetooth //import so we can work the Bluetooth radio

class ViewController: UIViewController, CLLocationManagerDelegate, CBPeripheralManagerDelegate //need to declare these delegates, one for location management, the other to work with the bluetooth radio
{
    
    //Beacon creation comes from https://developer.apple.com/documentation/corelocation/turning_an_ios_device_into_an_ibeacon

    //MARK: - Properties
    
    //The Location Manager is used to interface with the Bluetooth data
    var locationManager: CLLocationManager!
    
    //variables for creating a beacon
    var beacon: CLBeaconRegion!
    var beaconData: NSDictionary!
    var beaconPeripheralManager: CBPeripheralManager!
    
    //MARK: - UI
    var beaconDataLabel: UILabel!
    
    //MARK: - View Management
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //we initialize the location manager
        //the delegate is the self (ah, programming)
        //we need the user authorization
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        
        //UI Stuff
        //A switch to toggle the Beacon Broadcasting on/off
        let beaconSwitch = UISwitch(frame: CGRect(x: self.view.frame.midX - 25, y: self.view.frame.midY - 50, width: 50, height: 50))
        beaconSwitch.addTarget(self, action: #selector(ViewController.switchStateDidChange(_:)), for: .valueChanged)
        beaconSwitch.setOn(false, animated: false) //the beacon starts being turned off
        self.view.addSubview(beaconSwitch)
        
        //A label to show stuff
        beaconDataLabel = UILabel(frame: CGRect(x: self.view.frame.midX - 50, y: self.view.frame.midY - 250, width: 200, height: 50))
        beaconDataLabel.font = UIFont.preferredFont(forTextStyle: .body)
        beaconDataLabel.textColor = .black
        beaconDataLabel.center = CGPoint(x: self.view.frame.midX - 25, y: self.view.frame.midY - 50)
        beaconDataLabel.textAlignment = .center
        beaconDataLabel.text = ""
        beaconDataLabel.isHidden = true
        self.view.addSubview(beaconDataLabel)
        
    }
    
    //MARK: - Location Manager
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
    
    
    //MARK: - Beacon Scanning
    func scanForBeacons()
    {
        //we declare the UUID to look for
        //this is the beacon UUID
        let uuid = UUID(uuidString:"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")! //this uuid is the Apper AirLocate from the Locate Beacon iOS App
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: "MyBeacon") //values here are taken from my Locate iOS app
        
        //looking for beacons
        locationManager.startMonitoring(for: beaconRegion)
        
        //and trying to figure out how far away they are
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    
    //MARK: - Update Loop
    
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
    
    //MARK: - Beacon initialization
    func initLocalBeacon()
    {
        print("initializad")

        //if there's a beacon already running, we stop it
        if beacon != nil
        {
            stopBeacon()
        }
        
        //variables that define the beacon
        let beaconUUID = "92AB49BE-4127-42F4-B532-90fAF1E26491" //This UUID is the TwoCanoes beacon from the Locate Beacon iOS App
        let beaconMajor: CLBeaconMajorValue = 123
        let beaconMinor: CLBeaconMinorValue = 456
        
        let uuid = UUID(uuidString: beaconUUID)
        
        //the beacon is created
        beacon = CLBeaconRegion(proximityUUID: uuid!, major: beaconMajor, minor: beaconMinor, identifier: "Phone Beacon")
        
        //To be honest, I am not sure why these need to be here,
        //but other people have written it on their beacon projects
        //so I totally trust GitHUb.
        //There is probably a proper reason for this, who cares, it works.
        beaconData = beacon.peripheralData(withMeasuredPower: nil)
        beaconPeripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        
        beaconDataLabel.text = "Beacon Transmitting"
        beaconDataLabel.sizeToFit()
        beaconDataLabel.isHidden = false
    }
    
    
    //MARK: - Beacon management
    func stopBeacon()
    {
        if beaconPeripheralManager != nil
        {
            beaconPeripheralManager.stopAdvertising()
            beaconPeripheralManager = nil
            beaconData = nil
            beacon = nil
            
            beaconDataLabel.isHidden = true
        }
    }
    
    //MARK: - Beacon On/Off Toggle
    @objc func switchStateDidChange(_ sender:UISwitch){
        if (sender.isOn == true)
        {
            print("UISwitch state is now ON")
            initLocalBeacon()
        }
        else
        {
            print("UISwitch state is now Off")
            stopBeacon()
        }
    }
    
    //MARK: - Complying with CBPeripheralManagerDelegate
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager)
    {
        if peripheral.state == .poweredOn
        {
            beaconPeripheralManager.startAdvertising(beaconData as! [String: AnyObject]!)
        }
        else if peripheral.state == .poweredOff
        {
            beaconPeripheralManager.stopAdvertising()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

