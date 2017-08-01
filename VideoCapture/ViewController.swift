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
import Photos





class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var myTableView: UITableView!
    var ref: UIRefreshControl?
    var data : NSData?
    var dbSessionRef: DatabaseReference?
    var dbReference : DatabaseReference?
    var myArray = [[String: Any]]()
    var menuItems = [UIImage]()
    var popMenu :  PopUPManu?
    var existingVideos = [Int]()
    var dawnloadTimer: Timer?
    var uploadView: UIView?
    var indikator: UIActivityIndicatorView?
    var videosInProcess = [Int]()
    var isMenuShowed : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: " + New Session", style: .plain, target: self, action: #selector(handleNewSession))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.blue
        navigationItem.rightBarButtonItem?.tintColor = UIColor.blue
        self.view.backgroundColor = UIColor.white
        self.ref = UIRefreshControl.init()
        self.ref?.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
        self.setupTableView()
        
        }
    
    
    override func viewWillAppear(_ animated: Bool) {
       
        self.myArray =  [[String: Any]]()
        existingVideos = [Int]()
        self.menuItems = [UIImage]()
        let itemOne = UIImage.init(named: "1")
        let itemTow = UIImage.init(named: "2")
        let itemThee = UIImage.init(named: "3")
        menuItems.append(itemOne!)
        menuItems.append(itemTow!)
        menuItems.append(itemThee!)
        print(myTableView)
        self.myTableView.dataSource = nil
        self.myTableView.delegate = nil
        
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            handleLogout()
        }
        else {
            do {
            let rech = try Reachability.init()
                if (rech?.isConnectedToNetwork)!{
                    getSessionsFromFirebase()
                }
                else {
                    let alert = Alerts.sharedInstance.callToAlert(title: "Error", message: "You do not have internet access")
                    self.present(alert, animated: true, completion: nil)
                    
                    }
            }
            catch {
                print("ERROR Internet")
            }
        }

    }
    
    func refreshAction() {
         self.myArray =  [[String: Any]]()
         self.getSessionsFromFirebase()
    }
    
    func setupTableView() {
        
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.backgroundColor =  UIColor(red: 61/255, green: 91/255, blue: 151/255, alpha: 1)
        
        if #available(iOS 10.0, *) {
            myTableView.refreshControl = self.ref
        } else {
            // Fallback on earlier versions
        }

        self.view.addSubview(myTableView)
    }
    
    
    
    func getSessionsFromFirebase() {
        self.dbReference = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("Sessions")
        self.dbReference?.observe(.childAdded, with: { [unowned self] (snapshot) in
            let obj = snapshot.value as! [String: Any]
            self.myArray.append(obj)
            print("snapshot === \(snapshot)")
            DispatchQueue.main.async {
                self.myTableView.dataSource = self
                self.myTableView.delegate = self
                self.myTableView.reloadData()
                
            }
        })

        if self.ref != nil {
            self.ref?.endRefreshing()
        }

    }
    
    func handleNewSession() {
        self.showNewSessionAlert()
    }
    
    func makeNewSession(SessionName: String) {
        
        do {
            let rech = try Reachability.init()
            if (rech?.isConnectedToNetwork)!{
                let sessionName = "\(SessionName)"
                Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("Sessions").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    print(snapshot)
                    if snapshot.hasChild(sessionName) {
                        let alert = Alerts.sharedInstance.callToAlert(title: "Error", message: "Name is already in use")
                        self.present(alert, animated: true, completion: nil)
                    }
                    else{
                        self.dbSessionRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("Sessions").child(sessionName)
                        self.dbSessionRef?.updateChildValues(["Session Name" : sessionName])
                        UserDefaults.standard.set(sessionName, forKey: "sessionName")
                        UserDefaults.standard.synchronize()
                        self.showPopMenu()
                        
                    }
                    
                })

                
            }
            else {
                let alert = Alerts.sharedInstance.callToAlert(title: "Error", message: "You do not have internet access")
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        catch {
            print("ERROR Internet")
        }

  
        
    }
    
    func showNewSessionAlert() {
    
        let alert = UIAlertController(title: "", message: "Enter a session name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter name"
            textField.keyboardType = .emailAddress
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            if textField?.text != "" && !((textField?.text?.rangeOfCharacter(from: CharacterSet.init(charactersIn: "_"))) != nil)  {
                 DispatchQueue.main.async {
                         self.makeNewSession(SessionName: (textField?.text)!)
                }
            }else{
                DispatchQueue.main.async {
                        let alertName = UIAlertController(title: "", message: "Name is not valid", preferredStyle: UIAlertControllerStyle.alert)
                        alertName.addAction(UIAlertAction.init(title: "OK", style: .default, handler: {[unowned self] (action) in
                        self.showNewSessionAlert()
                        }))
                        self.present(alertName, animated: true, completion: nil)
                }
            }
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func isVideoExist(_sessionName : String, callback:@escaping (_ status: Bool)->Void) {
        
        let ref = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("Sessions").child(_sessionName)
        ref.observeSingleEvent(of: .value, with: { (shnapshot) in
            if shnapshot.hasChild("0") || shnapshot.hasChild("1") || shnapshot.hasChild("2") {
                callback(true)
            }
            else {
                callback(false)
            }
        })
    }
    
    
    func handleLogout() {
         self.myArray =  [[String: Any]]()
         self.myTableView.reloadData()
        
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
    
    override func viewDidDisappear(_ animated: Bool) {
         self.dbReference?.removeAllObservers()
         let ref = Database.database().reference(fromURL: "https://videocapture-11f35.firebaseio.com/")
         ref.removeAllObservers()
         self.dbReference = nil
    }
    
    
    func showPopMenu() {
        
        self.isMenuShowed = true
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        self.popMenu = UINib.init(nibName: "PopUPManu", bundle: Bundle.main).instantiate(withOwner: nil, options: nil)[0] as? PopUPManu
        self.popMenu?.setupframe(frame: self.view.bounds, images:menuItems )
        self.popMenu?.didSelectedItem = { [unowned self] (index) in
            if self.existingVideos.contains(index) {
                self.videoExistAlert()
                return
            }
            if self.videosInProcess.contains(index) {
                if let rootViewController = UIApplication.topViewController() {
                    let alert = Alerts.sharedInstance.callToAlert(title: "Info", message: "Upload in process")
                    rootViewController.present(alert, animated: true, completion: nil)
                }
 
               return
            }
            
            if let recorder = VideoRecorder.sharedInstance.startCameraFromViewController() {
                let recorderVC = VideoRecorder.sharedInstance
                recorderVC.finishPickingMediaWith = {[unowned self] (info) in
                    UserDefaults.standard.set(index, forKey: "position")
                    UserDefaults.standard.synchronize()
                    let url = (info[UIImagePickerControllerMediaURL] as! NSURL) as URL
                    VideoUploader.sharedInstance.videoURLs.append(url)
                    if VideoUploader.sharedInstance.dataTask?.state != .running {
                       self.uploadVideoToFirebase()
                    }
                    
                    
                    
                }
                self.present(recorder, animated: true, completion: nil)
                
            }

        }
        
        self.popMenu?.menudidHide = { [unowned self] in
            self.videosInProcess = [Int]()
            self.menuItems = [UIImage]()
            self.isMenuShowed = false
            let itemOne = UIImage.init(named: "1")
            let itemTow = UIImage.init(named: "2")
            let itemThee = UIImage.init(named: "3")
            self.menuItems.append(itemOne!)
            self.menuItems.append(itemTow!)
            self.menuItems.append(itemThee!)
            self.existingVideos = [Int]()
            DispatchQueue.main.async {[unowned self] in
                if self.navigationController?.navigationBar.isHidden == true {
                    self.navigationController?.navigationBar.isHidden = false
                }
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                self.navigationItem.leftBarButtonItem?.isEnabled = true

            }
        }
        UIView.transition(with: self.view, duration: 1, options: .transitionFlipFromLeft, animations: { [unowned self] in
            self.view.addSubview(self.popMenu!)
        }, completion: nil)

       

    }
    
    
    
    func chackRecordedVideos(complatition: @escaping ()->Void) {
        
        self.menuItems = [UIImage]()
        let itemOne = UIImage.init(named: "1")
        let itemTow = UIImage.init(named: "2")
        let itemThee = UIImage.init(named: "3")
        menuItems.append(itemOne!)
        menuItems.append(itemTow!)
        menuItems.append(itemThee!)

        let sessionName = UserDefaults.standard.value(forKey: "sessionName")
        let alert = VideoUploader.sharedInstance.checkUploadedVideosFor(session: sessionName as! String) { [unowned self] (exitingVideos, videoInfo) in
            self.existingVideos = [Int]()
            for i in exitingVideos {
                switch i {
                case 0 :
                    let itemOne = UIImage.init(named: "1Success")
                    self.menuItems[i] = itemOne!
                    break
                case 1:
                    let itemTow = UIImage.init(named: "2Success")
                    self.menuItems[i] = itemTow!
                    break
                case 2:
                    let itemThee = UIImage.init(named: "3Success")
                    self.menuItems[i] = itemThee!
                    break
                default :
                    break
                }
                
                self.existingVideos.append(i)
               
                
                
                
            }
            complatition()
            
        }
        if alert != nil {
            self.present(alert!, animated: true, completion: nil)
        }
        
    }


    
    func uploadVideoToFirebase() {
        DispatchQueue.main.async {
            let pos = UserDefaults.standard.value(forKey: "position") as! Int
            self.videosInProcess.append(pos)
        }
        
        let url = VideoUploader.sharedInstance.videoURLs[0]
        let allert =  VideoUploader.sharedInstance.uploadVideoToFirebaseStorage(url: url, success: {
            DispatchQueue.main.async {
                self.reloadPopUpMenu()
            }
        VideoUploader.sharedInstance.uploadVideoToServer(videoUrl: url,
                                            success: { [unowned self] (result) in
                                            print("success uploadVideoToServer")
                                            VideoUploader.sharedInstance.videoURLs.remove(at: 0)
                                            if VideoUploader.sharedInstance.videoURLs.count > 0 {
                                                self.uploadVideoToFirebase()
                                            }
                                                
                                                
                                          
                                                               
                        },
        
                            failured: { (error, pos) in
                            DispatchQueue.main.async {
                                self.reloadPopUpMenu()
                                if self.videosInProcess.contains(Int.init(pos)!){
                                    if let index = self.videosInProcess.index(of:Int.init(pos)!) {
                                         self.videosInProcess.remove(at: index)
                                    }
                                }
                                if let rootViewController = UIApplication.topViewController() {
                                    let alert = Alerts.sharedInstance.callToAlert(title: "Error", message: " \(pos) Upload failed")
                                    rootViewController.present(alert, animated: true, completion: nil)
                                }
                                
                
                                                    
                                                }

        })
            
            
            }, failured: { (error) in
                DispatchQueue.main.async {
                    self.reloadPopUpMenu()
                }

            
            })
        
            if allert != nil {
                self.present(allert!, animated: true, completion: nil)
            }
        
        
        
       
        
    }
    
    
    func closeAnimation() {
        self.reloadPopUpMenu()
        self.uploadView?.isHidden = true
        self.indikator?.stopAnimating()
        
    }
    

    
    
    func uploadingView() ->(boxView: UIView, activity: UIActivityIndicatorView) {
        
        var boxView = UIView()
        boxView = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 25, width: 180, height: 50))
        boxView.backgroundColor = UIColor.black
        boxView.alpha = 1
        boxView.layer.cornerRadius = 10
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        activityView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityView.startAnimating()
        let textLabel = UILabel(frame: CGRect(x: 45, y: 0, width: 400, height: 50))
        textLabel.textColor = UIColor.white
        textLabel.text = "Uploading Video"
        boxView.addSubview(activityView)
        boxView.addSubview(textLabel)
        view.addSubview(boxView)
        return (boxView, activityView)
        
    }
    
    func reloadPopUpMenu () {
        if  self.isMenuShowed  {
        self.chackRecordedVideos {
                DispatchQueue.main.async {
                self.popMenu?.removeFromSuperview()
                self.showPopMenu()
                self.popMenu?.isUserInteractionEnabled = true
                self.myTableView.isUserInteractionEnabled = true
            }
        }
        }
       
    }
    
    
    
    
    //MARK: TableViewDelegate

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "sessionID")
        let cell = tableView.cellForRow(at: indexPath)
        let sessionName = cell?.textLabel?.text
        UserDefaults.standard.set(sessionName, forKey: "sessionName")
        UserDefaults.standard.synchronize()
        
       if ViewController.isConnected() {
            self.isVideoExist(_sessionName: sessionName!, callback: { [unowned self] (status) in
                if status {
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                else {
                    
                    self.showPopMenu()
                }
            })
        }
       else {
        
               self.internetConnectionAlert()
        }
        
        
        
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return myArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        let obj = myArray[indexPath.row]
        cell.textLabel!.text = "\(obj["Session Name"] ?? "NON")"
        cell.backgroundColor = UIColor(red: 61/255, green: 91/255, blue: 151/255, alpha: 1)
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.minimumScaleFactor = 10
        cell.textLabel?.minimumScaleFactor = 30
        cell.selectionStyle = .blue
        return cell
    }

    
 

}


extension ViewController {
    
    class func isConnected()-> Bool {
        do {
            let rech = try Reachability.init()
                if (rech?.isConnectedToNetwork)!{
                     return true
                }
                else {
                     return false
                }
        }
        catch {
            return false
        }
    }
    
     func internetConnectionAlert () {
        
        let alert = Alerts.sharedInstance.callToAlert(title: "Error", message: "You do not have internet access")
        self.present(alert, animated: true, completion: nil)

    }
    
    func videoExistAlert () {
        let alert = Alerts.sharedInstance.callToAlert(title: "Info", message: "Video of this type already exist.")
        self.present(alert, animated: true, completion: nil)
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
