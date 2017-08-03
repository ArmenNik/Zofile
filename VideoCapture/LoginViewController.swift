//
//  LoginViewController.swift
//  VideoCapture
//
//  Created by Armen Nikodhosyan on 03.08.17.
//  Copyright © 2017 com.armomik. All rights reserved.
//

import Foundation
import UIKit
import Firebase


class LoginViewController: UIViewController , UITextFieldDelegate{
    
    @IBOutlet  var signUpButtonConstrain: NSLayoutConstraint!
    @IBOutlet  var signInButtonConstrain: NSLayoutConstraint!
    @IBOutlet  var signUpImageView: UIImageView!
    @IBOutlet  var signInImageView: UIImageView!
    @IBOutlet  var userNameTextField: TJTextField!
    @IBOutlet  var passwordTextField: TJTextField!
    @IBOutlet  var signInButton: UIButton!
    @IBOutlet  var signUpButton: UIButton!
    @IBOutlet  var userNameConstrain: NSLayoutConstraint!
    @IBOutlet  var passwordConstrain: NSLayoutConstraint!
    var newConstUserName : NSLayoutConstraint?
    var newConstPassword : NSLayoutConstraint?
    var newConstSignIn : NSLayoutConstraint?
    var newConstSignUp : NSLayoutConstraint?
    var newConstSignInButton : NSLayoutConstraint?
    var newConstSignUpButton : NSLayoutConstraint?
    @IBOutlet  var signUpConstrain: NSLayoutConstraint!
    @IBOutlet  var signInConstrain: NSLayoutConstraint!
    
    var isKeyboardOpen : Bool = false
    
    override func viewDidLoad() {
       self.userNameTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func keyboardWillAppear() {
        
        if !self.isKeyboardOpen {
            
        self.isKeyboardOpen = true
        self.newConstUserName = NSLayoutConstraint.init(item: self.userNameTextField, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 0.5, constant: 0)
        self.newConstPassword = NSLayoutConstraint.init(item: self.passwordTextField, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 0.6, constant: 0)
        self.newConstSignIn = NSLayoutConstraint.init(item: self.signInImageView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 0.8, constant: 0)
        self.newConstSignUp = NSLayoutConstraint.init(item: self.signUpImageView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 0.95, constant: 0)
         self.newConstSignUpButton = NSLayoutConstraint.init(item: self.signUpButton, attribute: .centerY, relatedBy: .equal, toItem: self.signUpImageView, attribute: .centerY, multiplier: 1, constant: 0)
         self.newConstSignInButton = NSLayoutConstraint.init(item: self.signInButton, attribute: .centerY, relatedBy: .equal, toItem: self.signInImageView, attribute: .centerY, multiplier: 1, constant: 0)
        
        self.userNameConstrain.isActive = false
        self.passwordConstrain.isActive = false
        self.signInConstrain.isActive = false
        self.signUpConstrain.isActive = false
        self.signInButtonConstrain.isActive = false
        self.signUpButtonConstrain.isActive = false
        self.newConstUserName?.isActive = true
        self.newConstPassword?.isActive = true
        self.newConstSignIn?.isActive = true
        self.newConstSignUp?.isActive = true
        self.newConstSignInButton?.isActive = true
        self.newConstSignUpButton?.isActive = true
        }
    }
    
    func keyboardWillDisappear() {
        if self.isKeyboardOpen {
        self.isKeyboardOpen = false
        self.newConstUserName?.isActive = false
        self.newConstPassword?.isActive = false
        self.newConstSignIn?.isActive = false
        self.newConstSignUp?.isActive = false
        self.newConstSignInButton?.isActive = false
        self.newConstSignUpButton?.isActive = false
        self.userNameConstrain.isActive = true
        self.passwordConstrain.isActive = true
        self.signInConstrain.isActive = true
        self.signUpConstrain.isActive = true
        self.signInButtonConstrain.isActive = true
        self.signUpButtonConstrain.isActive = true
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func signInAction(_ sender: UIButton) {
        
        guard let email = self.userNameTextField.text, let password = self.passwordTextField.text else {
            print("Form is not valid")
            let alert = Alerts.sharedInstance.callToAlert(title: "Info", message: "Form is not valid.")
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print("error = \(error.debugDescription)")
                let alert = Alerts.sharedInstance.callToAlert(title: "Error", message: "Wrong Email or Password.")
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            //successfully logged in our user
            self.dismiss(animated: true, completion: nil)
        }

    }
    
    
    @IBAction func signUpAction(_ sender: UIButton) {
        self.userNameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let signUpController = storyboard.instantiateViewController(withIdentifier: "signUpVC")
        present(signUpController, animated: true, completion: nil)
    }
    
    
    
    // TextField delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print(self.userNameTextField)
        self.userNameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        return true
    }
    
    
}
