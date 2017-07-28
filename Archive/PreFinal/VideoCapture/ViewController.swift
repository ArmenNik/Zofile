//
//  ViewController.swift
//  VideoCapture
//
//  Created by MacMini on 7/1/17.
//  Copyright © 2017 com.armomik. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        let image = UIImage(named: "camera") as UIImage?
        let button = UIButton(type: UIButtonType.custom) as UIButton
        //button.center = self.view.center
        //button.frame = CGRect(x: ((self.view.frame.size.width / 2) - 25) , y: self.view.frame.size.height - 100, width: 50, height: 50)
        button.frame.size.height = 50
        button.frame.size.width = 50
        button.center.x = self.view.frame.size.width / 2
        button.center.y = self.view.frame.size.height - 75
        
        
        
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(button)
        
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            handleLogout()
        }
    }
    
    func buttonAction(sender: UIButton!) {
        print("Button tapped")
        startCameraFromViewController(viewController: self, withDelegate: self)
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
//    @IBAction func cameraButtonTapped(_ sender: Any) {
//        startCameraFromViewController(self, withDelegate: self)
//    }
    
    func startCameraFromViewController(viewController: UIViewController, withDelegate delegate: protocol<UIImagePickerControllerDelegate, UINavigationControllerDelegate>) -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
            return false
        }
        
        let cameraController = UIImagePickerController()
        cameraController.sourceType = .camera
        cameraController.mediaTypes = [kUTTypeMovie as NSString as String]
        cameraController.allowsEditing = false
        cameraController.delegate = delegate
        
        present(cameraController, animated: true, completion: nil)
        return true
    }
    
    func video(videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) {
        var title = "Success"
        var message = "Video was saved"
        if let _ = error {
            title = "Error"
            message = "Video failed to save"
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}



extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        dismiss(animated: true, completion: nil)
        // Handle a movie capture
        if mediaType == kUTTypeMovie {
            guard let path = (info[UIImagePickerControllerMediaURL] as! NSURL).path else { return }
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path) {
                UISaveVideoAtPathToSavedPhotosAlbum(path, self, #selector(ViewController.video(videoPath:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
//        dismiss(animated: true, completion: nil)
//        // Handle a movie capture
//        if mediaType == kUTTypeMovie {
//            guard let path = (info[UIImagePickerControllerMediaURL] as! NSURL).path else { return }
//            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path) {
//                UISaveVideoAtPathToSavedPhotosAlbum(path, self, #selector(ViewController.video(videoPath:didFinishSavingWithError:contextInfo:)), nil)
//            }
//        }
//    }
}

extension ViewController: UINavigationControllerDelegate {
}


