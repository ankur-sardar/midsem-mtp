//
//  ViewController.swift
//  closest-beacon-demo
//
//  Created by Will Dages on 10/11/14.
//  @willdages on Twitter
//

import UIKit
import CoreLocation
let ipAddr = "192.168.43.71"
//let ipAddr = "10.7.6.211"

let port = 30000


class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "2f234454-cf6d-4a0f-adf2-f4911ba9ffa6")!, identifier: "Estimotes")
    // Note: make sure you replace the keys here with your own beacons' Minor Values
    let colors = [
        2: UIColor(red: 84/255, green: 77/255, blue: 160/255, alpha: 1),
        3: UIColor(red: 142/255, green: 212/255, blue: 220/255, alpha: 1),
        4: UIColor(red: 162/255, green: 213/255, blue: 181/255, alpha: 1)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startRangingBeacons(in: region)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print (beacons[0].minor)
        let id = beacons[0].minor
        let RSSI = beacons[0].rssi
        let knownBeacons = beacons.filter{ $0.proximity != CLProximity.unknown }
        if (knownBeacons.count > 0) {
            let closestBeacon = knownBeacons[0] as CLBeacon
            self.view.backgroundColor = self.colors[closestBeacon.minor.intValue]
        }
        let ur = URL(string: "http://\(ipAddr):\(port)/rec/\("1")/\(id)/\(RSSI)")!
        print (RSSI)
        print (ur)
//        let url = URL(string: "http://\(ipAddr):\(port)/rec/\(id))")!
//        let bundle = Bundle.main
        
        // Get path to one of assets (must be added  into Resources folder)
//        let path = bundle.path(forResource: "car", ofType: "png")
        // let path = bundle.pathForResource("IMG_0528", ofType: "MOV")
        
        // Initialise request and session objects
//        let request = NSMutableURLRequest(url: NSURL(string: "http://192.168.43.71:10000/rec/1/3")! as URL)
//        let session = URLSession.shared
        
        // Prepare request headers
//        request.httpMethod = "POST"
//        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        // Pass file name parameters with the headers, used by server to recognize filename
//        request.setValue("car1.png", forHTTPHeaderField: "X-FileName")
        // request.setValue("video1.mov", forHTTPHeaderField: "X-FileName")
        
        // Add input stream to HTTP body
//        request.httpBodyStream = InputStream(fileAtPath: path!)
        
        // Create upload task with streamed request
//        let task = session.uploadTask(withStreamedRequest: request as URLRequest)
//        let task = session.dataTask(withStreamedRequest: request as URLRequest)
        
        // Finally execute upload task
//        task.resume()
//        let request = NSURLRequest(URL: ur)
//        let session = NSURLSession.sharedSession()

        let request = URLRequest(url: ur)
        let session = URLSession.shared
        print ("ok")
        //        let time = NSDate().timeIntervalSince1970
//        let dataTask = session.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) -> Void in
//        let dataTask = session.dataTask(with: request, completionHandler: { (data:Data?, response:URLResponse?, error:Error?) -> Void in
//            print("done, \(id) error: \(error) ")
//                })
//        dataTask.resume()

//        let dataTask = session.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) -> Void in
//            print("done, \(id) error: \(error) ")
//        }
        let dataTask = session.dataTask(with: request, completionHandler: { (data:Data?, response:URLResponse?, error:Error?) -> Void in
            print("done, \((id)) error: \(error) ")
            } as! (Data?, URLResponse?, Error?) -> Void)
        dataTask.resume()
        
//        dataTask.resume()
    }

    }



