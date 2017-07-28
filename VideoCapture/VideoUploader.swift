//
//  VideoUploader.swift
//  VideoCapture
//
//  Created by MacMini on 7/26/17.
//  Copyright © 2017 com.armomik. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Firebase
import FirebaseDatabase

class VideoUploader: NSObject {
    
    static let sharedInstance: VideoUploader = {
        let instance = VideoUploader()
        return instance
    }()

    
    
    
    func uploadVideoToFirebaseStorage(url: URL, success:@escaping ()-> Void, failured: @escaping(_ error: Error)-> Void) -> UIAlertController?{
        
        if VideoUploader.isConnected() {
             let storageReference = Storage.storage().reference().child("video.mov\(Date.timeIntervalSinceReferenceDate * 1000)")
             storageReference.putFile(from: url as URL, metadata: nil, completion: { (metadata, error) in
                
                if error == nil {
                    self.saveVideoPathToFirebaseDatabase(url: (metadata?.downloadURL())!, success: {
                        success()
                        
                    }, failured: { (error) in
                        
                         failured(error)
                    })
                }
                else {
                      failured(error!)
                }
            })
            
            return nil
        }
        else {
           return  self.internetConnectionAlert()
        }
       
        
      
        
     
    }
    
    
    func uploadProcessedVideoToFirebaseStorage(name: String, type: Int, url: URL, success:@escaping ()-> Void, failured: @escaping(_ error: Error)-> Void) -> UIAlertController?{
        
        if VideoUploader.isConnected() {
            let storageReference = Storage.storage().reference().child("video.mov\(Date.timeIntervalSinceReferenceDate * 1000)")
            storageReference.putFile(from: url as URL, metadata: nil, completion: { (metadata, error) in
                
                if error == nil {
                    self.saveProcessedVideoPathToFirebaseDatabase(name: name, type: type, url: (metadata?.downloadURL())!, success: {
                        success()
                        
                    }, failured: { (error) in
                        
                        failured(error)
                    })
                }
                else {
                    failured(error!)
                }
            })
            
            return nil
        }
        else {
            return  self.internetConnectionAlert()
        }
        
        
        
        
        
    }

    
    fileprivate func saveVideoPathToFirebaseDatabase( url: URL, success:@escaping ()-> Void, failured:@escaping (_ error: Error)-> Void) {
        let dict = ["videoURL" : "\(url)"]
        let pos = UserDefaults.standard.value(forKey: "position") as! Int
        let sessionName =  UserDefaults.standard.value(forKey: "sessionName") as! String
        let ref = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("Sessions").child(sessionName)
        ref.child("\(pos)").updateChildValues(dict) { (error, reference) in
            if error != nil {
                failured(error!)
            } else{
                success()
            }
            
        }
    }
    
    fileprivate func saveProcessedVideoPathToFirebaseDatabase(name: String, type: Int, url: URL, success:@escaping ()-> Void, failured:@escaping (_ error: Error)-> Void) {
        let dict = ["videoURL" : "\(url)"]
        let pos = type //UserDefaults.standard.value(forKey: "position") as! Int
        let sessionName = name//UserDefaults.standard.value(forKey: "sessionName") as! String
        let ref = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("Sessions").child(sessionName)
        print("position === \(pos)")
        ref.child("\(pos)P").updateChildValues(dict) { (error, reference) in
            if error != nil {
                failured(error!)
            } else{
                success()
            }
            
        }
    }

    
    
    
    
    func checkUploadedVideosFor(session: String, callback:@escaping (_ _exitingVideos:[Int])->Void)-> UIAlertController? {
         if VideoUploader.isConnected() {
        var exitingVideos = [Int]()
            print(session)
        let ref = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("Sessions").child(session)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            print("aaa")
            print(snapshot)
            if snapshot.hasChild("0") {
                exitingVideos.append(0)
            }
            if snapshot.hasChild("1") {
                exitingVideos.append(1)
            }
            if snapshot.hasChild("2") {
                exitingVideos.append(2)
            }
            callback(exitingVideos)
            
        })
            return nil
            
         }else {
            
            return  self.internetConnectionAlert()
        }
        
    }
    
    
    func checkUploadedProcessedVideosFor(session: String, callback:@escaping (_ _exitingVideos:[Int])->Void)-> UIAlertController? {
        if VideoUploader.isConnected() {
            var exitingVideos = [Int]()
            let ref = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("Sessions").child(session)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild("0P") {
                    exitingVideos.append(0)
                }
                if snapshot.hasChild("1P") {
                    exitingVideos.append(1)
                }
                if snapshot.hasChild("2P") {
                    exitingVideos.append(2)
                }
                callback(exitingVideos)
                
            })
            return nil
            
        }else {
            
            return  self.internetConnectionAlert()
        }
        
    }

    
    func uploadVideoSize(length: Int) {
        let dict = ["length" : "\(length)"]
        let pos = UserDefaults.standard.value(forKey: "position") as! Int
        let sessionName = UserDefaults.standard.value(forKey: "sessionName") as! String
        let ref = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("Sessions").child(sessionName)
        ref.child("\(pos)").updateChildValues(dict) { (error, reference) in
            if error != nil {
               // failured(error!)
            } else{
                //success()
            }
            
        }

    }
    
    
    
    
    
    func uploadVideoToServer( videoUrl: URL, success: @escaping(_ result: [String: Int])-> Void, failured: @escaping (_ error: Error)-> Void) {
        
        var movieData: NSData?
        do {
            movieData = NSData.init(contentsOf: videoUrl)
        }
        if movieData == nil {
           return
        }
        let body = NSMutableData()
        body.append(movieData! as Data)
        let uid = Auth.auth().currentUser?.uid
        let sessionName = UserDefaults.standard.value(forKey: "sessionName")
        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        

        self.uploadVideoSize(length: movieData!.length)
        let pos = UserDefaults.standard.value(forKey: "position")
        print(movieData!.length)
        let url = URL.init(string: "http://52.175.233.168:5899/desktops/vahagn/\(sessionName!)/\(deviceId!)/\(pos!)/\(movieData!.length)")!
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body as Data
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("close", forHTTPHeaderField: "Connection")
        request.timeoutInterval = 120;
        request.setValue("\(uid!)_\(sessionName!)_\(deviceId!)_\(pos!)_\(movieData!.length).mov", forHTTPHeaderField: "fileName")
        
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data,response,error in
            
            if (error != nil) {
                failured(error!)
            }
            guard let _:NSData = data as NSData?, let _:URLResponse = response, error == nil else {
                failured(error!)
                return
            }
            
            let resultDict = ["type" : pos , "bytes" : movieData!.length]
            success(resultDict as! [String : Int])
        }
        
        task.resume()

    }

    
    


}


extension VideoUploader {
    
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
