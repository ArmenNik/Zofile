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

class VideoUploader: NSObject, URLSessionDataDelegate {
    
    var dataTask: URLSessionDataTask?
    var session : URLSession?
    var videoURLs = [URL]()
    
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
                        var movieData: NSData?
                        do {
                            movieData = NSData.init(contentsOf: url)
                            self.uploadVideoSize(length: movieData!.length)
                            success()
                        }
                        if movieData == nil {
                            
                            failured(NSError.init())
                            return
                        }
                       
                        
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

    
    
    
    
    func checkUploadedVideosFor(session: String, callback:@escaping (_ _exitingVideos:[Int],  _ videoInfo: [[String: Any]])->Void)-> UIAlertController? {
        
    if VideoUploader.isConnected() {
        
        
        var exitingVideos = [Int]()
        var videoInfo = [["length" : "", "videoURL" : ""], ["length" : "", "videoURL" : ""] , ["length" : "", "videoURL" : ""]]
        let ref = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("Sessions").child(session)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            if snapshot.hasChild("0") {
                if let value = snapshot.value as? [String : Any] {
                let dict = value["0"] as? [String : String]
                if let length = dict?["length"] {
                    if let url =  dict?["videoURL"] {
                        
                                let dict = ["length" : length, "videoURL" : url]
                                videoInfo[0] = dict 
                                exitingVideos.append(0)

                    }
                }
             }
            }
            if snapshot.hasChild("1") {
                if let value = snapshot.value as? [String : Any] {
                    let dict = value["1"] as? [String : String]
                    if let length = dict?["length"] {
                        if let url =  dict?["videoURL"] {
                            
                            let dict = ["length" : length, "videoURL" : url]
                            videoInfo[1] = dict
                            exitingVideos.append(1)
                            
                        }
                    }
                }
                
            }
            if snapshot.hasChild("2") {
                if let value = snapshot.value as? [String : Any] {
                    let dict = value["2"] as? [String : String]
                    if let length = dict?["length"] {
                        if let url =  dict?["videoURL"] {
                            
                            let dict = ["length" : length, "videoURL" : url]
                            videoInfo[2] = dict
                            exitingVideos.append(2)
                            
                        }
                    }
                }
                
            }
            callback(exitingVideos, videoInfo)
            
        })
            return nil
            
         }else {
            
            return  self.internetConnectionAlert()
        }
        
    }
    
    
    func checkUploadedProcessedVideosFor(session: String, callback:@escaping (_ _exitingVideos:[Int], _ videoInfo: [[String: Any]])->Void)-> UIAlertController? {
        if VideoUploader.isConnected() {
            var exitingVideos = [Int]()
            var videoInfo = [["videoURL" : ""], ["videoURL" : ""] , [ "videoURL" : ""]]
            let ref = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("Sessions").child(session)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild("0P") {
                    if let value = snapshot.value as? [String : Any] {
                        let dict = value["0P"] as? [String : String]
                            if let url =  dict?["videoURL"] {
                                let dict = ["videoURL" : url]
                                videoInfo[0] = dict
                                exitingVideos.append(0)
                            }
                    }

                }
                if snapshot.hasChild("1P") {
                    if let value = snapshot.value as? [String : Any] {
                        let dict = value["1P"] as? [String : String]
                        if let url =  dict?["videoURL"] {
                            let dict = ["videoURL" : url]
                            videoInfo[1] = dict
                            exitingVideos.append(1)
                        }
                    }

                }
                if snapshot.hasChild("2P") {
                    if let value = snapshot.value as? [String : Any] {
                        let dict = value["2P"] as? [String : String]
                        if let url =  dict?["videoURL"] {
                            let dict = ["videoURL" : url]
                            videoInfo[2] = dict
                            exitingVideos.append(2)
                        }
                    }
                }
                callback(exitingVideos, videoInfo)
                
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
    
    
    
    
    
    func uploadVideoToServer( videoUrl: URL, success: @escaping(_ result: [String: Int])-> Void, failured: @escaping (_ error: Error, _ pos: String)-> Void) {
        
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
        
        
        session = URLSession.init(configuration: .default, delegate: self, delegateQueue: .main)
        dataTask = session?.dataTask(with: request as URLRequest) { data,response,error in
            
            if (error != nil) {
                
                switch pos as! Int{
                case 0 :
                failured(error!, "\("Frontal possition")")
                break
                case 1 :
                failured(error!, "\("Right possition")")
                break
                case 2 :
                failured(error!, "\("Left possition" )")
                break
                default :
                break
                    
                }
                
            }
            guard let _:NSData = data as NSData?, let _:URLResponse = response, error == nil else {
                failured(error!, "\(pos ?? "3")")
                return
            }
            
            let resultDict = ["type" : pos , "bytes" : movieData!.length]
            success(resultDict as! [String : Int])
        }
        dataTask?.resume()

    }
    
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("didCompleteWithError = \(error?.localizedDescription)")
    }

    
     func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void) {
        
        print("response = \(response)")
        
    }
    
//    func uploadVideoToServer( videoUrl: URL, success: @escaping(_ result: [String: Int])-> Void, failured: @escaping (_ error: Error)-> Void) {
//        
//        var movieData: NSData?
//                do {
//                    movieData = NSData.init(contentsOf: videoUrl)
//                }
//                if movieData == nil {
//                   return
//                }
//        
//        let uid = Auth.auth().currentUser?.uid
//                let sessionName = UserDefaults.standard.value(forKey: "sessionName")
//                let deviceId = UIDevice.current.identifierForVendor?.uuidString
//                let pos = UserDefaults.standard.value(forKey: "position")
//                print(movieData!.length)
//    let url = URL.init(string: "http://52.175.233.168:5899/desktops/vahagn/\(sessionName!)/\(deviceId!)/\(pos!)/\(movieData!.length)")!
//        
//        
//            //let url:NSURL? = NSURL(string: "http://192.168.5.107/upload.php")
//            let cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
//            var request = URLRequest.init(url: url as URL, cachePolicy: cachePolicy, timeoutInterval: 2.0)
//        
//            request.httpMethod = "POST"
//            
//            // Set Content-Type in HTTP header.
//            let boundaryConstant = "Boundary-7MA4YWxkTLLu0UIW"; // This should be auto-generated.
//            let contentType =  "multipart/form-data; boundary=" + boundaryConstant
//            
//            let fileName = videoUrl.lastPathComponent
//            let mimeType = "video/mov"
//            let fieldName = "uploadFile"
//            
//            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
//            
//            // Set data
//            var error: NSError?
//        var dataString = "--\(boundaryConstant)\r\n"
//            dataString += "Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n"
//            dataString += "Content-Type: \(mimeType)\r\n\r\n"
//        
//        
//       
//        do {
//            
//            dataString += (movieData?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0)))!
//            print(videoUrl.path)
//            //dataString +=  try String(contentsOfFile: videoUrl.path, encoding: .ba)//(fileName.path!, encoding: NSUTF8StringEncoding,
//            //error: &error)!
//           print(dataString)
//            
//        }catch{ (error)
//            print(error)
//        }
//            dataString += "\r\n"
//            dataString += "--\(boundaryConstant)--\r\n"
//       
//
//        
//        
//            // Set the HTTPBody we'd like to submit
//            let requestBodyData = (dataString as NSString).data(using: String.Encoding.utf8.rawValue)
//            request.httpBody = requestBodyData
//        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            do {
//                if error != nil {
//                    print("error Upload Server = \(error)")
//                }
//                else {
//                    let resultDict = ["type" : pos , "bytes" : movieData!.length]
//                    success(resultDict as! [String : Int])
//                }
//            }
//        }
//        task.resume()
    
            // Make an asynchronous call so as not to hold up other processes.
//            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main, completionHandler: {(response, dataObject, error) in
//                if let apiError = error {
//                   // aHandler?(obj: error, success: false)
//                     print("error Upload Server")
//                } else {
//                    
//                    print("success")
//                    let resultDict = ["type" : pos , "bytes" : movieData!.length]
//                    success(resultDict as! [String : Int])
//                    //aHandler?(obj: dataObject, success: true)
//                }
//            })
        
        

//}
    
    
    
    
    
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
