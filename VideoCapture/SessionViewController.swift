//
//  SessionViewController.swift
//  VideoCapture
//
//  Created by MacMini on 7/25/17.
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
//import pop
//import XHRealTimeBlur
//import PopMenu
import Photos

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

class SessionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var sessionsTableView: UITableView!
    var sessionName: String?
    var menuItems = [UIImage]()
    var popMenu :  PopUPManu?
    var existingVideos = [Int]()
    var dawnloadTimer: Timer?
    var rightItem : UIBarButtonItem?
    var uploadView: UIView?
    var indikator: UIActivityIndicatorView?
    private var myTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.sessionsTableView.register(UINib.init(nibName: "SessionCell", bundle: nil), forCellReuseIdentifier: "cell")
        rightItem =  UIBarButtonItem.init(barButtonSystemItem: .camera, target: self, action: #selector(self.showPopMenu))
        self.navigationItem.rightBarButtonItem = rightItem
       // self.sessionsTableView.backgroundColor = UIColor(red: 61/255, green: 91/255, blue: 151/255, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.sessionName = UserDefaults.standard.value(forKey: "sessionName") as? String
        let attributes = [NSFontAttributeName: UIFont(name: "Avenir", size: 17)!] //change size as per your need here.
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.title = sessionName
        self.menuItems = [UIImage]()
        let itemOne = UIImage.init(named: "1")
        let itemTow = UIImage.init(named: "2")
        let itemThee = UIImage.init(named: "3")
        menuItems.append(itemOne!)
        menuItems.append(itemTow!)
        menuItems.append(itemThee!)
       // self.sessionsTableView.delegate = self
       // self.sessionsTableView.dataSource = self
        self.setupTableView()
        self.chackRecordedVideos()
       // self.view.reloadInputViews()
        


    }
    override func viewDidAppear(_ animated: Bool) {
    }
    
    func setupTableView() {
        
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        print(barHeight)
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        myTableView = UITableView(frame: CGRect(x: 0, y: 60, width: displayWidth, height: displayHeight - barHeight))
        myTableView.register(UINib.init(nibName: "SessionCell", bundle: nil), forCellReuseIdentifier: "cell")
        myTableView.backgroundColor =  UIColor(red: 61/255, green: 91/255, blue: 151/255, alpha: 1)
        myTableView.delegate = self
        myTableView.dataSource = self
        self.view.addSubview(myTableView)
    }
    
    
    func showPopMenu() {
        
        self.popMenu = UINib.init(nibName: "PopUPManu", bundle: Bundle.main).instantiate(withOwner: nil, options: nil)[0] as? PopUPManu
         self.popMenu?.setupframe(frame: self.view.bounds, images:menuItems )
        self.popMenu?.didSelectedItem = { [unowned self] (index) in
            if self.existingVideos.contains(index) {
                self.videoExistAlert()
                return
            }
            if let recorder = VideoRecorder.sharedInstance.startCameraFromViewController() {
                self.popMenu?.removeFromSuperview()
                let recorderVC = VideoRecorder.sharedInstance
                recorderVC.finishPickingMediaWith = {[unowned self] (info) in
                    UserDefaults.standard.set(index, forKey: "position")
                    UserDefaults.standard.synchronize()
                    self.uploadVideoToFirebase(url: (info[UIImagePickerControllerMediaURL] as! NSURL) as URL)
                    
                }
                self.present(recorder, animated: true, completion: nil)
                
            }
            
        }
        
        self.popMenu?.menudidHide = { [unowned self] in
            
        }
        UIView.transition(with: self.view, duration: 1, options: .transitionFlipFromLeft, animations: { [unowned self] in
            self.view.addSubview(self.popMenu!)
            }, completion: nil)
        

    }
    
    func chackRecordedVideos() {
        
        let alert = VideoUploader.sharedInstance.checkUploadedVideosFor(session: self.sessionName!) { [unowned self] (exitingVideos) in
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
                DispatchQueue.main.async { [unowned self] in
                     self.myTableView.reloadData()
                         if self.existingVideos.count > 2 {
                            self.rightItem?.isEnabled = false
                         }
                }
               
               
                
            }
            
           // self.showPopMenu()
        }
        if alert != nil {
            self.present(alert!, animated: true, completion: nil)
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! SessionCell
        cell.setupCell(name: self.sessionName, type: indexPath.row, parrent: self)
        cell.backgroundColor = UIColor(red: 61/255, green: 91/255, blue: 151/255, alpha: 1)
        if self.existingVideos.contains(indexPath.row) {
            cell.isOriginalVideoExist = true
            cell.dawnload()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (self.view.frame.size.height - 60) / 3
    }
    
    
    func uploadVideoToFirebase(url: URL) {
        
        let uploading = self.uploadingView()
        self.uploadView = uploading.boxView
        self.indikator = uploading.activity
        DispatchQueue.main.async {
            self.view.isUserInteractionEnabled = false
            self.myTableView.isUserInteractionEnabled = false
        }
        let allert =  VideoUploader.sharedInstance.uploadVideoToFirebaseStorage(url: url, success: {
            
            VideoUploader.sharedInstance.uploadVideoToServer(videoUrl: url,
                                                             success: {[unowned self]  (result) in
                                                                DispatchQueue.main.async { [unowned self] in
                                                                     self.chackRecordedVideos()
                                                                     self.perform(#selector(self.closeAnimation), with: nil, afterDelay: 15)
                                                                    DispatchQueue.main.async {
                                                                        self.view.isUserInteractionEnabled = true
                                                                        self.myTableView.isUserInteractionEnabled = true
                                                                    }
                                                                                                                                     
                                                                }
                                                                print(result)
                                                                //Show success alert
            },
                                                             failured: { (error) in
                                                                print("error upload to server")
                                                                self.chackRecordedVideos()
                                                                DispatchQueue.main.async {
                                                                     self.perform(#selector(self.closeAnimation), with: nil, afterDelay: 15)
                                                                    DispatchQueue.main.async {
                                                                        self.view.isUserInteractionEnabled = true
                                                                        self.myTableView.isUserInteractionEnabled = true
                                                                    }
                                                                }
                                                                
                                                                //Show failured alert
                                                                
            })

            
            // Show success uploaded message alert
            
        }, failured: { (error) in
            uploading.boxView.isHidden = true
            uploading.activity.stopAnimating()
            DispatchQueue.main.async {
                self.view.isUserInteractionEnabled = true
                self.myTableView.isUserInteractionEnabled = true
            }
            // Show failed uploaded message alert
        })
        
        if allert != nil {
            self.present(allert!, animated: true, completion: nil)
        }
        
        
        
    }
    
    
    func closeAnimation() {
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
        DispatchQueue.main.async {[unowned self] in
            boxView.addSubview(activityView)
            boxView.addSubview(textLabel)
            self.view.addSubview(boxView)
        }
        
        return (boxView, activityView)
        
    }

  
    func recordAction(sender: Int, sessionName: String) {
        
        UserDefaults.standard.set(sender, forKey: "position")
        UserDefaults.standard.set(sessionName, forKey: "sessionName")
        UserDefaults.standard.synchronize()
        
        if let recorder = VideoRecorder.sharedInstance.startCameraFromViewController() {
            let recorderVC = VideoRecorder.sharedInstance
            recorderVC.finishPickingMediaWith = {[unowned self] (info) in
                self.uploadVideoToFirebase(url: (info[UIImagePickerControllerMediaURL] as! NSURL) as URL)
                
            }
            self.present(recorder, animated: true, completion: nil)
        }
    }

    
        
    
    override func viewDidDisappear(_ animated: Bool) {
       let cells = self.myTableView.visibleCells as! [SessionCell]
        for cell in cells {
            cell.dawnloadTimer?.invalidate()
        }
    }
    
   
    
    
  
    
    
      
    
   
    

  
    
    

}

 extension SessionViewController: UINavigationControllerDelegate {
        
        func videoExistAlert () {
            let alert = Alerts.sharedInstance.callToAlert(title: "Info", message: "Video of this type already exist.")
            self.present(alert, animated: true, completion: nil)
        }
    }



extension AVURLAsset {
    var fileSize: Int? {
        var keys = Set<URLResourceKey>()
        keys.insert(.totalFileSizeKey)
        keys.insert(.fileSizeKey)
        
        do {
            let resourceValues = try self.url.resourceValues(forKeys: keys)
            
            return resourceValues.fileSize ?? resourceValues.totalFileSize
        } catch {
            return nil
        }
    }
}
