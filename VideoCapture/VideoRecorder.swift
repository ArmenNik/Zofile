//
//  VideoRecorder.swift
//  VideoCapture
//
//  Created by MacMini on 7/26/17.
//  Copyright © 2017 com.armomik. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit
import SystemConfiguration
import MobileCoreServices





class VideoRecorder: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
  
   static let sharedInstance: VideoRecorder = {
        let instance = VideoRecorder()
        return instance
    }()
    
    var finishPickingMediaWith :((_ info: [String : Any])-> Void)?
    var cameraController : UIImagePickerController?
    
    func startCameraFromViewController()-> UIImagePickerController? {
        if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
            return nil
        }
        cameraController = UIImagePickerController()
        cameraController?.sourceType = .camera
        cameraController?.mediaTypes = [kUTTypeMovie as NSString as String]
        cameraController?.allowsEditing = false
        cameraController?.delegate = self
        return cameraController
    }

    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        cameraController?.dismiss(animated: true, completion: {[unowned self] in
            if mediaType == kUTTypeMovie {
                guard let path = (info[UIImagePickerControllerMediaURL] as! NSURL).path else { return }
                self.finishPickingMediaWith!(info)
                if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path) {
                    UISaveVideoAtPathToSavedPhotosAlbum(path, self,  #selector(self.video(videoPath:didFinishSavingWithError:contextInfo:)), nil)
                    
                }
                
            }
        })
        
    }
    
    
     func video(videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) {
        
    }
    
}
