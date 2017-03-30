
import UIKit
import CoreBluetooth
import CoreLocation


let defaults = UserDefaults.standard
var readerId = defaults.integer(forKey: "readerId") ?? 0
var ipAddr = defaults.string(forKey: "serverIpAddrField") ?? "192.168.43.71"
let port = 10000
let threshold:Int = -120
let timeThreshold:Double = 0
let uuid = "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"
let id = "B9407F30-F5F8-466E-AFF9-25556B57FE6D"

class ViewController: UIViewController, CBCentralManagerDelegate, UIApplicationDelegate, CBPeripheralDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var deviceIdField: UITextField!
    @IBOutlet weak var serverIpAddrField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    var timeStamp = [String:Double]()
    var centralM:CBCentralManager!
    var peripherals = Array<CBPeripheral>();
//    let services: [CBUUID] = [CBUUID(string: "81E7")]
    let services: [CBUUID] = [CBUUID(string:"2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6")]
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "Estimotes")
    let colors = [
        54482: UIColor(red: 84/255, green: 77/255, blue: 160/255, alpha: 1),
        31351: UIColor(red: 142/255, green: 212/255, blue: 220/255, alpha: 1),
        27327: UIColor(red: 162/255, green: 213/255, blue: 181/255, alpha: 1)
    ]

//    let services: [CBUUID] = [(CBUUID *)NSUUID(UUIDString: "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6")]
    
    @IBAction func configSetButtonPressed(_ sender: AnyObject) {
        guard let readerIdText = deviceIdField.text, let readerIdRaw = Int(readerIdText), let ipAddrRaw = serverIpAddrField.text else {
            return
        }
        readerId = readerIdRaw
        ipAddr = ipAddrRaw
        deviceIdField.resignFirstResponder()
        serverIpAddrField.resignFirstResponder()
        defaults.set(readerId, forKey: "readerId")
        defaults.set(ipAddr, forKey: "serverIpAddrField")
        print("readerId: \(readerId), ipAddr:\(ipAddr)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeStamp["NONE"] = 0
        locationManager.delegate = self
        locationManager.startRangingBeacons(in: region)
        print("ok")
        
        let queue = DispatchQueue(label: "com.uievolution.BLETest2", attributes: [])
        centralM = CBCentralManager(delegate:self,queue:queue)
        deviceIdField.text = "\(readerId)"
        serverIpAddrField.text = "\(ipAddr)"
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print(beacons)
        //    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        //        print(beacons)
        let knownBeacons = beacons.filter{ $0.proximity != CLProximity.unknown }
        if (knownBeacons.count > 0) {
            let closestBeacon = knownBeacons[0] as CLBeacon
            self.view.backgroundColor = self.colors[closestBeacon.minor.intValue]
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        if central.state == CBCentralManagerState.poweredOn {
//            print("Bluetooth is on!");
            self.centralM.scanForPeripherals(withServices: services , options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
//        }
//        else {
//            print("Bluetooth is off!");
//        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let uIdentifier = uniqueIDFromAdvertisementDictionary(advertisementData as NSDictionary)
        var keygen:String = "NONE";
        var valuegen:Double = 0;
        let url = URL(string: "http://\(ipAddr):\(port)/rec/\(readerId)/\(uIdentifier))")!
        let request = URLRequest(url: url)
        let session = URLSession.shared
        let time = Date().timeIntervalSince1970
        
        if Int(RSSI) < 0 {
            print(RSSI)
            print(uIdentifier)
            if Int(RSSI) > threshold {
                for (key,value) in timeStamp {
                    if key == uIdentifier {
                        keygen = key
                        valuegen = value
                        break;
                    }
                    else {
                        keygen = "NONE"
                        valuegen = 0
                        }
                    }
                    if keygen == uIdentifier {
                        if (time - valuegen) > timeThreshold {
                            let dataTask = session.dataTask(with: request, completionHandler: { (data:Data?, response:URLResponse?, error:NSError?) -> Void in
                                print("done, \(RSSI) error: \(error) ")
                            } as! (Data?, URLResponse?, Error?) -> Void) 
                            dataTask.resume()
                        } else {
                            let oldVal = timeStamp.updateValue(time, forKey: keygen)
                            print(oldVal);
                        }
                    } else {
                        timeStamp[uIdentifier] = time;
                        print(timeStamp[uIdentifier])
                        let dataTask = session.dataTask(with: request, completionHandler: { (data:Data?, response:URLResponse?, error:NSError?) -> Void in
                            print("done, \(RSSI) error: \(error) ")
                        } as! (Data?, URLResponse?, Error?) -> Void) 
                        dataTask.resume()
                }
                statusLabel.text = "\(RSSI)"
            }
        }
    }
    
    func uniqueIDFromAdvertisementDictionary(_ dictionary: NSDictionary) -> String {
        var ret = "unknown"
        if let serviceDict = dictionary["kCBAdvDataServiceData"] {
            let sDict = serviceDict as! NSDictionary
            let firstVal = sDict.allValues.first as! Data
            let uniqueIdData = firstVal.subdata(in: NSMakeRange(4, 6))
            ret = uniqueIdData.hexadecimalString as String
        }
        return ret
    }
}

extension Data {
    // (kdj_hexadecimalString)
    public var hexadecimalString: NSString {
        var bytes = [UInt8](repeating: 0, count: count)
        copyBytes(to: &bytes, count: count)
        let hexString = NSMutableString()
        for byte in bytes {
            hexString.appendFormat("%02x", UInt(byte))
        }
        return NSString(string: hexString)
    }
}


