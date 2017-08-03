//
//  SignUpViewController.swift
//  VideoCapture
//
//  Created by Armen Nikodhosyan on 03.08.17.
//  Copyright © 2017 com.armomik. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate {
 
    @IBOutlet weak var confirmPasswordTextField: TJTextField!
    @IBOutlet weak var passwordTextField: TJTextField!
    @IBOutlet weak var userNameTextField: TJTextField!
    var isKeyboardOpen : Bool = false
    
    @IBOutlet weak var signUpImageView: UIImageView!
    @IBOutlet weak var signInImageView: UIImageView!
    @IBOutlet  var userNameConstrain: NSLayoutConstraint!
    @IBOutlet  var passwordConstrain: NSLayoutConstraint!
    @IBOutlet  var confirmPasswordConstrain: NSLayoutConstraint!
    @IBOutlet  var signUpConstrain: NSLayoutConstraint!
    @IBOutlet  var signInConstrain: NSLayoutConstraint!
    var newConstUserName : NSLayoutConstraint?
    var newConstPassword : NSLayoutConstraint?
    var newConstConfirmPassword : NSLayoutConstraint?
    var newConstSignIn : NSLayoutConstraint?
    var newConstSignUp : NSLayoutConstraint?

    
    
    
    override func viewDidLoad() {
        
        self.userNameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
     func keyboardWillAppear() {
        if !self.isKeyboardOpen {
            self.isKeyboardOpen = true
            
            self.newConstUserName = NSLayoutConstraint.init(item: self.userNameTextField, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 0.4, constant: 0)
            self.newConstPassword = NSLayoutConstraint.init(item: self.passwordTextField, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 0.5, constant: 0)
            self.newConstConfirmPassword = NSLayoutConstraint.init(item: self.confirmPasswordTextField, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 0.6, constant: 0)
            self.newConstSignIn = NSLayoutConstraint.init(item: self.signInImageView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 0.95, constant: 0)
            self.newConstSignUp = NSLayoutConstraint.init(item: self.signUpImageView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 0.8, constant: 0)
           
            
            self.userNameConstrain.isActive = false
            self.passwordConstrain.isActive = false
            self.confirmPasswordConstrain.isActive = false
            self.signInConstrain.isActive = false
            self.signUpConstrain.isActive = false
            self.newConstUserName?.isActive = true
            self.newConstPassword?.isActive = true
            self.newConstConfirmPassword?.isActive = true
            self.newConstSignIn?.isActive = true
            self.newConstSignUp?.isActive = true
            
            
        }
        
     }
    
     func keyboardWillDisappear() {
        if self.isKeyboardOpen {
            self.isKeyboardOpen = false
        
        self.userNameConstrain.isActive = true
        self.passwordConstrain.isActive = true
        self.confirmPasswordConstrain.isActive = true
        self.signInConstrain.isActive = true
        self.signUpConstrain.isActive = true
        self.newConstUserName?.isActive = false
        self.newConstPassword?.isActive = false
        self.newConstConfirmPassword?.isActive = false
        self.newConstSignIn?.isActive = false
        self.newConstSignUp?.isActive = false
        }

     }
    
    
    @IBAction func signInAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func signUpAction(_ sender: UIButton) {
        
        self.userNameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        self.confirmPasswordTextField.resignFirstResponder()
        
        do{
            let rech = try Reachability.init()
            if (rech?.isConnectedToNetwork)!{
                print("Internet Connection Available!")
                guard let email = self.userNameTextField.text, let password = passwordTextField.text else {
                    
                    print("Form is not valid")
                    let alert = Alerts.sharedInstance.callToAlert(title: "Info", message: "Form is not valid.")
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                if password != self.confirmPasswordTextField.text {
                    let alert = Alerts.sharedInstance.callToAlert(title: "Error", message: "Passwords are not matched.")
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                Auth.auth().createUser(withEmail: email, password: password, completion: { (user: User?, error) in
                    if error != nil {
                        print("error = \((error?.localizedDescription)!)")
                        
                        let alert = Alerts.sharedInstance.callToAlert(title: "Error", message: "\((error?.localizedDescription)!).")
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    //print("user = \(user)")
                    
                    guard let uid = user?.uid else {
                        return
                    }
                    
                    //Successfuly authenticated user
                    let ref = Database.database().reference(fromURL: "https://videocapture-11f35.firebaseio.com/")
                    let userReference = ref.child("users").child(uid)
                    let values = ["email" : email]
                    userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                        if err != nil {
                            print("err = \(err.debugDescription)")
                            return
                        }
                        //self.dismiss(animated: true, completion: nil)
                        
                        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                        let sessionController = storyboard.instantiateViewController(withIdentifier: "sessionVC")
                        //self.present(sessionController, animated: true, completion: nil)
                        let appObj = UIApplication.shared.delegate as! AppDelegate
                        appObj.window?.rootViewController = UINavigationController(rootViewController: ViewController())
                        
                        print("Saved user successfully into Firebase db")
                    })
                })
            }else{
                let alert = Alerts.sharedInstance.callToAlert(title: "Error", message: "You do not have internet access.")
                self.present(alert, animated: true, completion: nil)
                print("Internet Connection not Available!")
            }
            
        }catch{
            print("ERROR")
        }

    }
    
    
    deinit {
        print("SignUpViewController deinit")
    }
    
    // TextField delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print(self.userNameTextField)
        self.userNameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        self.confirmPasswordTextField.resignFirstResponder()
        return true
    }
}
