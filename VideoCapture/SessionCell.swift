//
//  SessionCell.swift
//  VideoCapture
//
//  Created by MacMini on 7/25/17.
//  Copyright © 2017 com.armomik. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import  AVKit

class SessionCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var processedIndikator: UIActivityIndicatorView!
    var videoType: Int?
    var dawnloadTimer: Timer?
    var videoLength: String?
    var result: [String: Any]?
    var originalVideoURL : URL?
    var oprocessedVideoURL : URL?
    @IBOutlet weak var originalIndikator: UIActivityIndicatorView!
    @IBOutlet weak var processedImage: UIImageView!
    @IBOutlet weak var originalImage: UIImageView!
    var sessionName: String?
    var parrentController: SessionViewController?
    var originalVideoExist: Bool = false
    var processedVideoExist: Bool = false
    var isOriginalVideoExist: Bool {
        set {
            self.originalVideoExist = newValue
            self.changStstus(ststus: newValue)
        }
        get {
            return self.originalVideoExist
        }
    }
    var getSessionName : String {
        get {
            if self.sessionName != nil {
                return self.sessionName!
            }else {
                return ""
            }
        }
    }
    
    var getVideotype : Int {
        get {
            if self.videoType != nil {
                return self.videoType!
            }else {
                return 3
            }
        }
    }
    
    func changStstus (ststus: Bool) {
        if ststus {
            DispatchQueue.main.async {
                switch self.getVideotype{
                case 0:
                self.originalImageView.image = UIImage.init(named: "1100")
                    break
                case 1:
                    self.originalImageView.image = UIImage.init(named: "2100")
                    break
                case 2:
                    self.originalImageView.image = UIImage.init(named: "3100")
                    break
                default :
                     break
                    
                }
                
            }
            return
        }
        DispatchQueue.main.async {
            self.originalImageView.image = UIImage.init(named: "")
        }
    }
    
    
    override func awakeFromNib() {
        self.containerView.backgroundColor = UIColor(red: 61/255, green: 91/255, blue: 151/255, alpha: 1)
        self.originalImageView.layer.borderColor = UIColor.white.cgColor
        self.processedImageView.layer.borderColor = UIColor.white.cgColor
        self.originalImageView.layer.borderWidth = 2
        self.processedImageView.layer.borderWidth = 2
        
    }
    @IBOutlet weak var processedImageView: UIImageView!
    @IBOutlet weak var originalImageView: UIImageView!
    
    
    
    func setupCell(name: String?, type: Int, parrent : SessionViewController, length: String, videoURL: String) {
        self.sessionName = name
        self.videoType = type
        self.parrentController = parrent
        self.videoLength = length
        if let url = URL.init(string: videoURL) {
            self.originalVideoURL = url
            self.isOriginalVideoExist = true
            self.dawnload()
        }
        
       
        
        
    }
    
    func getVideoLenght() {
        VideoDawnloader.sharedInstance.getVideoLengthFromFirebase(sessionName: self.getSessionName, type: self.getVideotype, succes: { [unowned self] (lenght) in
            self.dawnloadProcessedVideo(lenght: lenght)
        }) { 
            print("error")
        }
    }
    
    func dawnload() {
        DispatchQueue.global().async { [unowned self] in
            self.checkIsProcessedVideoExistOnFirebase(succes: {
                

                
            }, failured: {
                
                if self.videoLength != nil {
                    self.dawnloadProcessedVideo(lenght:  self.videoLength!)
                }
                
            })
            
        }
        
    }
    
    
    @IBAction func playButtonAction(_ sender: Any) {
        
        if self.isOriginalVideoExist {
            if SessionCell.isConnected() {
                if (self.originalVideoURL != nil) {
                    self.originalIndikator.startAnimating()
                    self.setupAvplayerViewController(videoURL: self.originalVideoURL!)
                }
            
            } else {
                let alert = self.internetConnectionAlert()
                self.parrentController?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    
    @IBAction func processedButtonAction(_ sender: Any) {
        
        if processedVideoExist {
        
            if SessionCell.isConnected() {
                self.processedIndikator.startAnimating()
                self.setupAvplayerViewController(videoURL: self.oprocessedVideoURL!)

            } else {
                let alert = self.internetConnectionAlert()
                self.parrentController?.present(alert, animated: true, completion: nil)
            }
        }

        
       
    }
    
    func checkIsProcessedVideoExistOnFirebase( succes:@escaping ()->Void, failured:@escaping ()-> Void) {
     let alert =  VideoUploader.sharedInstance.checkUploadedProcessedVideosFor(session: self.getSessionName) { [unowned self] (existedVideos, videoInfo) in
            if existedVideos.contains(self.getVideotype) {
               let dict = videoInfo[self.getVideotype]
                    if let urlString = dict["videoURL"] {
                        if let url = URL.init(string: urlString as! String) {
                            self.oprocessedVideoURL = url
                            self.processedVideoExist = true
                            
                            succes()
                            DispatchQueue.main.async {
                                switch self.getVideotype{
                                case 0:
                                    self.processedImageView.image = UIImage.init(named: "1100")
                                    break
                                case 1:
                                    self.processedImageView.image = UIImage.init(named: "2100")
                                    break
                                case 2:
                                    self.processedImageView.image = UIImage.init(named: "3100")
                                    break
                                default :
                                    break
                                    
                                }
                            }
                            
                                

                        }
                    }
                
                
            } else
             {
                failured()
             }
        }
        
        
        if alert != nil {
            self.parrentController?.present(alert!, animated: true, completion: nil)
        }
    }
    
    
    
    func dawnloadProcessedVideo(lenght: String) {
        
        if self.dawnloadTimer == nil {
        self.result = ["type": self.getVideotype,"bytes": lenght] as [String : Any]
        self.dawnloadTimer = Timer.scheduledTimer(timeInterval: 5,
                                                  target: self,
                                                  selector:#selector(self.dawnloadVideo(info:)),
                                                  userInfo: result,
                                                  repeats: true)
        }

        
    }
    
    
    func dawnloadVideo( info: Timer) {
        let params = self.result 
        let str = params!["bytes"]! as! String
        let tp = Int.init(str)
        VideoDawnloader.sharedInstance.downloadVideo(sessionName:sessionName!, type: params!["type"]! as! Int, bytes: tp!, success:{ [unowned self] (url) in
            print("Video Dawnloaded")
            DispatchQueue.main.async { [unowned self] in
                self.dawnloadTimer?.invalidate()
            }
            
            self.uploadProcessedVodeo(videoURL: url)
            }, failured: { (error) in
                print(error)
        })
        
        
    }

    
    func uploadProcessedVodeo(videoURL: URL) {
        
        let alert =  VideoUploader.sharedInstance.uploadProcessedVideoToFirebaseStorage(name:self.getSessionName, type: self.getVideotype, url: videoURL, success: {[unowned self] in
        self.checkIsProcessedVideoExistOnFirebase(succes: {
            
        }, failured: {
            
        })
            print("uploaded to firebase")
        }) { (error) in
            print("error")
        }
        
        if alert != nil {
            self.parrentController?.present(alert!, animated: true, completion: nil)
        }
        
    }
    
    
    func setupAvplayerViewController(videoURL: URL) {
       
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.videoGravity = AVLayerVideoGravityResizeAspect
        playerViewController.player = player
        self.parrentController?.present(playerViewController, animated: true, completion: {
            self.originalIndikator.stopAnimating()
            self.processedIndikator.stopAnimating()
            playerViewController.player!.play()
        })
    }
}






extension SessionCell {
    
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
    
    
    
    func internetConnectionAlert () -> UIAlertController {
        
        let alert = UIAlertController(title: "Error", message: "You do not have internet access.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        return alert
        
    }

    
}
