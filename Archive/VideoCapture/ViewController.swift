//
//  ViewController.swift
//  VideoCapture
//
//  Created by MacMini on 7/1/17.
//  Copyright © 2017 com.armomik. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import MobileCoreServices
import RealmSwift
import AVFoundation
import AVKit
import SystemConfiguration
import Alamofire

enum Position {
    case one
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine
}


struct postStruct {
    //let title : String!
    let video : String!
}

class ViewController: UIViewController, UIImagePickerControllerDelegate {

    
    var buttonOne : UIButton?
    var buttonTwo : UIButton?
    var buttonThree : UIButton?
    var buttonFour : UIButton?
    var buttonFive : UIButton?
    var buttonSix : UIButton?
    var buttonSeven : UIButton?
    var buttonEight : UIButton?
    var buttonNine : UIButton?
    
    var posts = [postStruct]()
    var data : NSData?
    var videUrls = [SavingVideos]()
    var dbSessionRef: DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: " + New Session", style: .plain, target: self, action: #selector(handleNewSession))
        self.view.backgroundColor = UIColor.white
        
        createImageViews()
        
        
        
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            handleLogout()
        }
        
    }
    
    func handleNewSession() {
        
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let alert = UIAlertController(title: "New Session", message: "New Session has been created successfully.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        print(date)
        let dateStr = "Session \(month) \(day) \(year)"
        self.dbSessionRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child(dateStr)
    }
    
    func createButtons() {
        buttonOne = UIButton.init(frame: CGRect.init(x: 0, y: 65, width: (self.view.frame.size.width / 3) - 3, height: self.view.frame.size.width / 3))
        buttonOne?.tag = 0
        buttonOne?.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(buttonOne!)
        print("\(buttonOne)")
        buttonTwo = UIButton.init(frame: CGRect.init(x: self.view.frame.size.width / 3, y: 65, width: (self.view.frame.size.width / 3) - 3, height: self.view.frame.size.width / 3))
        buttonTwo?.tag = 1
        buttonTwo?.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(buttonTwo!)
        buttonThree = UIButton.init(frame: CGRect.init(x: self.view.frame.size.width / 3 * 2, y: 65, width: (self.view.frame.size.width / 3) - 3, height: self.view.frame.size.width / 3))
        buttonThree?.tag = 2
        buttonThree?.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(buttonThree!)
        buttonFour = UIButton.init(frame: CGRect.init(x: 0, y: (self.view.frame.size.height / 3) + 65, width: (self.view.frame.size.width / 3) - 3, height: self.view.frame.size.width / 3))
        buttonFour?.tag = 3
        buttonFour?.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(buttonFour!)
        buttonFive = UIButton.init(frame: CGRect.init(x: self.view.frame.size.width / 3, y: (self.view.frame.size.height / 3) + 65 , width: (self.view.frame.size.width / 3) - 3, height: self.view.frame.size.width / 3))
        buttonFive?.tag = 4
        buttonFive?.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(buttonFive!)
        buttonSix = UIButton.init(frame: CGRect.init(x: self.view.frame.size.width / 3 * 2, y: (self.view.frame.size.height / 3) + 65, width: (self.view.frame.size.width / 3) - 3, height: self.view.frame.size.width / 3))
        buttonSix?.tag = 5
        buttonSix?.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(buttonSix!)
        buttonSeven = UIButton.init(frame: CGRect.init(x: 0, y: (self.view.frame.size.height / 3 * 2) + 65, width: (self.view.frame.size.width / 3) - 3, height: self.view.frame.size.width / 3))
        buttonSeven?.tag = 6
        buttonSeven?.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(buttonSeven!)
        buttonEight = UIButton.init(frame: CGRect.init(x: self.view.frame.size.width / 3, y: (self.view.frame.size.height / 3 * 2) + 65, width: (self.view.frame.size.width / 3) - 3, height: self.view.frame.size.width / 3))
        buttonEight?.tag = 7
        buttonEight?.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(buttonEight!)
        buttonNine = UIButton.init(frame: CGRect.init(x: self.view.frame.size.width / 3 * 2, y: (self.view.frame.size.height / 3 * 2) + 65, width: (self.view.frame.size.width / 3) - 3, height: self.view.frame.size.width / 3))
        buttonNine?.tag = 8
        buttonNine?.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(buttonNine!)
        
    }
    
    func createImageViews() {
        let imageOne = UIImageView.init(frame: CGRect.init(x: 0, y: 65, width: (self.view.frame.size.width / 3) - 3, height: self.view.frame.size.width / 3))
        imageOne.tag = 0
        imageOne.image = UIImage(named: "1")
        imageOne.contentMode = .scaleAspectFit
        self.view.addSubview(imageOne)
        
        let imageTwo = UIImageView.init(frame: CGRect.init(x: self.view.frame.size.width / 3, y: 65, width: (self.view.frame.size.width / 3) - 3, height: self.view.frame.size.width / 3))
        imageTwo.tag = 1
        imageTwo.image = UIImage(named: "2")
        imageTwo.contentMode = .scaleAspectFit
        self.view.addSubview(imageTwo)
        
        let imageThree = UIImageView.init(frame: CGRect.init(x: self.view.frame.size.width / 3 * 2, y: 65, width: (self.view.frame.size.width / 3) - 3, height: self.view.frame.size.width / 3))
        imageThree.tag = 2
        imageThree.image = UIImage(named: "3")
        imageThree.contentMode = .scaleAspectFit
        self.view.addSubview(imageThree)
        
        let imageFour = UIImageView.init(frame: CGRect.init(x: 0, y: (self.view.frame.size.height / 3) + 65, width: (self.view.frame.size.width / 3) - 3, height: self.view.frame.size.width / 3))
        imageFour.tag = 3
        imageFour.image = UIImage(named: "4")
        imageFour.contentMode = .scaleAspectFit
        self.view.addSubview(imageFour)
        
        let imageFive = UIImageView.init(frame: CGRect.init(x: self.view.frame.size.width / 3, y: (self.view.frame.size.height / 3) + 65 , width: (self.view.frame.size.width / 3) - 3, height: self.view.frame.size.width / 3))
        imageFive.tag = 4
        imageFive.image = UIImage(named: "5")
        imageFive.contentMode = .scaleAspectFit
        self.view.addSubview(imageFive)
        
        let imageSix = UIImageView.init(frame: CGRect.init(x: self.view.frame.size.width / 3 * 2, y: (self.view.frame.size.height / 3) + 65, width: (self.view.frame.size.width / 3) - 3, height: self.view.frame.size.width / 3))
        imageSix.tag = 5
        imageSix.image = UIImage(named: "6")
        imageSix.contentMode = .scaleAspectFit
        self.view.addSubview(imageSix)
        
        let imageSeven = UIImageView.init(frame: CGRect.init(x: 0, y: (self.view.frame.size.height / 3 * 2) + 65, width: (self.view.frame.size.width / 3) - 3, height: self.view.frame.size.width / 3))
        imageSeven.tag = 6
        imageSeven.image = UIImage(named: "7")
        imageSeven.contentMode = .scaleAspectFit
        self.view.addSubview(imageSeven)
        
        let imageEight = UIImageView.init(frame: CGRect.init(x: self.view.frame.size.width / 3, y: (self.view.frame.size.height / 3 * 2) + 65, width: (self.view.frame.size.width / 3) - 3, height: self.view.frame.size.width / 3))
        imageEight.tag = 7
        imageEight.image = UIImage(named: "8")
        imageEight.contentMode = .scaleAspectFit
        self.view.addSubview(imageEight)
        
        let imageNine = UIImageView.init(frame: CGRect.init(x: self.view.frame.size.width / 3 * 2, y: (self.view.frame.size.height / 3 * 2) + 65, width: (self.view.frame.size.width / 3) - 3, height: self.view.frame.size.width / 3))
        imageNine.tag = 8
        imageNine.image = UIImage(named: "9")
        imageNine.contentMode = .scaleAspectFit
        self.view.addSubview(imageNine)
        
        createButtons()
        
    }
    
    
    func buttonAction(sender: UIButton!) {
        do{
        let rech = try Reachability.init()
            if (rech?.isConnectedToNetwork)!{
                print("Internet Connection Available!")
                switch sender.tag {
                case 0:
                    startCameraFromViewController(viewController: self, withDelegate:  self, par: Position.one)
                    UserDefaults.standard.set(sender.tag, forKey: "position")
                    UserDefaults.standard.synchronize()
                    break
                case 1:
                    startCameraFromViewController(viewController: self, withDelegate:  self, par: Position.two)
                    UserDefaults.standard.set(sender.tag, forKey: "position")
                    UserDefaults.standard.synchronize()
                    break
                case 2:
                    startCameraFromViewController(viewController: self, withDelegate:  self, par: Position.three)
                    UserDefaults.standard.set(sender.tag, forKey: "position")
                    UserDefaults.standard.synchronize()
                    break
                case 3:
                    startCameraFromViewController(viewController: self, withDelegate:  self, par: Position.four)
                    UserDefaults.standard.set(sender.tag, forKey: "position")
                    UserDefaults.standard.synchronize()
                    break
                case 4:
                    startCameraFromViewController(viewController: self, withDelegate:  self, par: Position.five)
                    UserDefaults.standard.set(sender.tag, forKey: "position")
                    UserDefaults.standard.synchronize()
                    break
                case 5:
                    startCameraFromViewController(viewController: self, withDelegate:  self, par: Position.six)
                    UserDefaults.standard.set(sender.tag, forKey: "position")
                    UserDefaults.standard.synchronize()
                    break
                case 6:
                    startCameraFromViewController(viewController: self, withDelegate:  self, par: Position.seven)
                    UserDefaults.standard.set(sender.tag, forKey: "position")
                    UserDefaults.standard.synchronize()
                    break
                case 7:
                    startCameraFromViewController(viewController: self, withDelegate:  self, par: Position.eight)
                    UserDefaults.standard.set(sender.tag, forKey: "position")
                    UserDefaults.standard.synchronize()
                    break
                case 8:
                    startCameraFromViewController(viewController: self, withDelegate:  self, par: Position.nine)
                    UserDefaults.standard.set(sender.tag, forKey: "position")
                    UserDefaults.standard.synchronize()
                    break
                default:
                    break
                }

            }else{
                let alert = UIAlertController(title: "Error", message: "You do not have internet access.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                print("Internet Connection not Available!")
            }

        }catch{
            print("ERROR")
        }
        
        
    }
    
    func sharedController() -> ViewController {
        return self
    }
    
    func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func startCameraFromViewController(viewController: UIViewController, withDelegate delegate: ViewController, par: Position) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
//            return false
        }
        
        
        let cameraController = UIImagePickerController()
        cameraController.sourceType = .camera
        cameraController.mediaTypes = [kUTTypeMovie as NSString as String]
        cameraController.allowsEditing = false
        cameraController.delegate = delegate
        
        present(cameraController, animated: true, completion: nil)
    }
    
    func video(videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) {
        var title = "Success"
        var message = "Video was saved"
        if let _ = error {
            title = "Error"
            message = "Video failed to save"
        }
        
                
    }
    
    func getUrlsFromRealm()  {
        let realm = try! Realm()
        
        let video = try! realm.objects(SavingVideos)
        videUrls = video.toArray()
        print("videUrls = \(videUrls)")
    }
    
     func uploadVideo(url: URL) {
        let storageReference = Storage.storage().reference().child("video.mov\(Date.timeIntervalSinceReferenceDate * 1000)")
        
        var boxView = UIView()
        
        boxView = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 25, width: 180, height: 50))
        boxView.backgroundColor = UIColor.gray
        boxView.alpha = 0.8
        boxView.layer.cornerRadius = 10
        
        //Here the spinnier is initialized
        var activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityView.startAnimating()
        
        var textLabel = UILabel(frame: CGRect(x: 45, y: 0, width: 400, height: 50))
        textLabel.textColor = UIColor.white
        textLabel.text = "Uploading Video"
        
        boxView.addSubview(activityView)
        boxView.addSubview(textLabel)
        
        view.addSubview(boxView)
        print("db = \(self.dbSessionRef)")
        print("storageReference = \(storageReference)")
        // Start the video storage process
        storageReference.putFile(from: url as URL, metadata: nil, completion: { (metadata, error) in
            
            if error == nil {
                print("Successful video upload")
                //actInd.stopAnimating()
                activityView.stopAnimating()
                boxView.isHidden = true
                
                self.saveVideoPath(url: url)
            } else {
                print(error?.localizedDescription)
            }
        })
    }
    
     func saveVideoPath(url: URL) {
       // let databaseRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("session")
        let positionName = UserDefaults.standard.value(forKey: "position")
        
        switch positionName as! Int {
        case 0:
            addSuccesImage(buttonView: self.buttonOne!, flag: true)
            
            break
        case 1:
            addSuccesImage(buttonView: self.buttonTwo!, flag: true)
            break
        case 2:
            addSuccesImage(buttonView: self.buttonThree!, flag: true)
            break
        case 3:
            addSuccesImage(buttonView: self.buttonFour!, flag: true)
            break
        case 4:
            addSuccesImage(buttonView: self.buttonFive!, flag: true)
            break
        case 5:
            addSuccesImage(buttonView: self.buttonSix!, flag: true)
            break
        case 6:
            addSuccesImage(buttonView: self.buttonSeven!, flag: true)
            break
        case 7:
            addSuccesImage(buttonView: self.buttonEight!, flag: true)
            break
        case 8:
            addSuccesImage(buttonView: self.buttonNine!, flag: true)
            break
            
        default:
            print("default")
            break
        }
       
        let dict = ["videoURL" : "\(url)"]
        let pos = UserDefaults.standard.value(forKey: "position") as! Int
        self.dbSessionRef?.child("\(pos)").updateChildValues(dict) { (error, reference) in
            if error != nil {
                print("error")
            } else{
               print("succeeded")
            }
            
        }
    }
    
    
    func addSuccesImage(buttonView: UIButton, flag: Bool) {
        //let width = buttonView.frame.size.width - 90,
        let imageView = UIImageView.init(frame: CGRect.init(x: buttonView.frame.origin.x + buttonView.frame.size.width - 20, y: buttonView.frame.origin.y, width: 20, height: 20))
        print(imageView.frame)
        if flag == true {
            imageView.image = UIImage.init(named: "10")
        }else {
        }
        imageView.contentMode = .scaleAspectFit
         imageView.backgroundColor = UIColor.red
        DispatchQueue.main.async { [unowned self] in
             self.view.addSubview(imageView)
            
        }
        
       // DispatchQueue.global().async { [unowned self] in
            //self.perform(#selector(self.addDoneImage), with: buttonView, afterDelay: 60)
            Timer.scheduledTimer(timeInterval: 30.0, target: self, selector:  #selector(self.addDoneImage(_:)), userInfo: buttonView, repeats: false)
            
        //}
    }
    
    func addDoneImage(_ timer: Timer) {
        let buttonView = timer.userInfo as? UIButton
        let imageView = UIImageView.init(frame: CGRect.init(x: (buttonView?.frame.origin.x)! + (buttonView?.frame.size.width)! - 20, y: (buttonView?.frame.origin.y)!, width: 20, height: 20))
        print(imageView.frame)
        imageView.image = UIImage.init(named: "11")
        
        imageView.contentMode = .scaleAspectFit
        DispatchQueue.main.async { [unowned self] in
            self.view.addSubview(imageView)
            
        }
    }
    
    func uploadVideoToServer(url: URL, videoURL: URL) {
        

        
        Alamofire.upload(multipartFormData: { (data) in
            data.append(videoURL, withName: "video")
            
        }, to: url) { (result) in
            
            switch result {
            case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
//                upload.responseJSON(completionHandler: { (response) in
//                    print(response)
//                })
                upload.response(completionHandler: { (response) in
                    print(response)
                })
                upload.responseString(completionHandler: { (response) in
                    print(response)
                })
            break
                
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        }
        
   
        
        
        
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        dismiss(animated: true, completion: nil)
        // Handle a movie capture
        if mediaType == kUTTypeMovie {
            guard let path = (info[UIImagePickerControllerMediaURL] as! NSURL).path else { return }
            
            self.uploadVideo(url: (info[UIImagePickerControllerMediaURL] as! NSURL) as URL)
            self.uploadVideoToServer(url: URL.init(string: "http://posttestserver.com/post.php")!, videoURL: (info[UIImagePickerControllerMediaURL] as! NSURL) as URL)
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path) {
                UISaveVideoAtPathToSavedPhotosAlbum(path, self, #selector(ViewController.video(videoPath:didFinishSavingWithError:contextInfo:)), nil)
                
            }
        }
    }

    
    
}

class Reachability {
    var hostname: String?
    var isRunning = false
    var isReachableOnWWAN: Bool
    var reachability: SCNetworkReachability?
    var reachabilityFlags = SCNetworkReachabilityFlags()
    let reachabilitySerialQueue = DispatchQueue(label: "ReachabilityQueue")
    init?(hostname: String) throws {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, hostname) else {
            throw Network.Error.failedToCreateWith(hostname)
        }
        self.reachability = reachability
        self.hostname = hostname
        isReachableOnWWAN = true
    }
    init?() throws {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let reachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }}) else {
                throw Network.Error.failedToInitializeWith(zeroAddress)
        }
        self.reachability = reachability
        isReachableOnWWAN = true
    }
    var status: Network.Status {
        return  !isConnectedToNetwork ? .unreachable :
            isReachableViaWiFi    ? .wifi :
            isRunningOnDevice     ? .wwan : .unreachable
    }
    var isRunningOnDevice: Bool = {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            return false
        #else
            return true
        #endif
    }()
    deinit { stop() }
}

extension Reachability {
    func start() throws {
        guard let reachability = reachability, !isRunning else { return }
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = Unmanaged<Reachability>.passUnretained(self).toOpaque()
        guard SCNetworkReachabilitySetCallback(reachability, callout, &context) else { stop()
            throw Network.Error.failedToSetCallout
        }
        guard SCNetworkReachabilitySetDispatchQueue(reachability, reachabilitySerialQueue) else { stop()
            throw Network.Error.failedToSetDispatchQueue
        }
        reachabilitySerialQueue.async { self.flagsChanged() }
        isRunning = true
    }
    func stop() {
        defer { isRunning = false }
        guard let reachability = reachability else { return }
        SCNetworkReachabilitySetCallback(reachability, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachability, nil)
        self.reachability = nil
    }
    var isConnectedToNetwork: Bool {
        return isReachable &&
            !isConnectionRequiredAndTransientConnection &&
            !(isRunningOnDevice && isWWAN && !isReachableOnWWAN)
    }
    var isReachableViaWiFi: Bool {
        return isReachable && isRunningOnDevice && !isWWAN
    }
    
    /// Flags that indicate the reachability of a network node name or address, including whether a connection is required, and whether some user intervention might be required when establishing a connection.
    var flags: SCNetworkReachabilityFlags? {
        guard let reachability = reachability else { return nil }
        var flags = SCNetworkReachabilityFlags()
        return withUnsafeMutablePointer(to: &flags) {
            SCNetworkReachabilityGetFlags(reachability, UnsafeMutablePointer($0))
            } ? flags : nil
    }
    
    /// compares the current flags with the previous flags and if changed posts a flagsChanged notification
    func flagsChanged() {
        guard let flags = flags, flags != reachabilityFlags else { return }
        reachabilityFlags = flags
        NotificationCenter.default.post(name: .flagsChanged, object: self)
    }
    
    /// The specified node name or address can be reached via a transient connection, such as PPP.
    var transientConnection: Bool { return flags?.contains(.transientConnection) == true }
    
    /// The specified node name or address can be reached using the current network configuration.
    var isReachable: Bool { return flags?.contains(.reachable) == true }
    
    /// The specified node name or address can be reached using the current network configuration, but a connection must first be established. If this flag is set, the kSCNetworkReachabilityFlagsConnectionOnTraffic flag, kSCNetworkReachabilityFlagsConnectionOnDemand flag, or kSCNetworkReachabilityFlagsIsWWAN flag is also typically set to indicate the type of connection required. If the user must manually make the connection, the kSCNetworkReachabilityFlagsInterventionRequired flag is also set.
    var connectionRequired: Bool { return flags?.contains(.connectionRequired) == true }
    
    /// The specified node name or address can be reached using the current network configuration, but a connection must first be established. Any traffic directed to the specified name or address will initiate the connection.
    var connectionOnTraffic: Bool { return flags?.contains(.connectionOnTraffic) == true }
    
    /// The specified node name or address can be reached using the current network configuration, but a connection must first be established.
    var interventionRequired: Bool { return flags?.contains(.interventionRequired) == true }
    
    /// The specified node name or address can be reached using the current network configuration, but a connection must first be established. The connection will be established "On Demand" by the CFSocketStream programming interface (see CFStream Socket Additions for information on this). Other functions will not establish the connection.
    var connectionOnDemand: Bool { return flags?.contains(.connectionOnDemand) == true }
    
    /// The specified node name or address is one that is associated with a network interface on the current system.
    var isLocalAddress: Bool { return flags?.contains(.isLocalAddress) == true }
    
    /// Network traffic to the specified node name or address will not go through a gateway, but is routed directly to one of the interfaces in the system.
    var isDirect: Bool { return flags?.contains(.isDirect) == true }
    
    /// The specified node name or address can be reached via a cellular connection, such as EDGE or GPRS.
    var isWWAN: Bool { return flags?.contains(.isWWAN) == true }
    
    /// The specified node name or address can be reached using the current network configuration, but a connection must first be established. If this flag is set
    /// The specified node name or address can be reached via a transient connection, such as PPP.
    var isConnectionRequiredAndTransientConnection: Bool {
        return (flags?.intersection([.connectionRequired, .transientConnection]) == [.connectionRequired, .transientConnection]) == true
    }
}

func callout(reachability: SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) {
    guard let info = info else { return }
    DispatchQueue.main.async {
        Unmanaged<Reachability>.fromOpaque(info).takeUnretainedValue().flagsChanged()
    }
}

extension Notification.Name {
    static let flagsChanged = Notification.Name("FlagsChanged")
}

struct Network {
    static var reachability: Reachability?
    enum Status: String, CustomStringConvertible {
        case unreachable, wifi, wwan
        var description: String { return rawValue }
    }
    enum Error: Swift.Error {
        case failedToSetCallout
        case failedToSetDispatchQueue
        case failedToCreateWith(String)
        case failedToInitializeWith(sockaddr_in)
    }
}





extension ViewController: UINavigationControllerDelegate {
}

extension Results {
    
    func toArray() -> [T] {
        return self.map{$0}
    }
}

extension RealmSwift.List {
    
    func toArray() -> [T] {
        return self.map{$0}
    }
}


