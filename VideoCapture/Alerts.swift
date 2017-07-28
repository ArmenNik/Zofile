//
//  Alerts.swift
//  VideoCapture
//
//  Created by MacMini on 7/26/17.
//  Copyright © 2017 com.armomik. All rights reserved.
//

import Foundation
import UIKit

class Alerts: NSObject {
    
    static let sharedInstance: Alerts = {
        let instance = Alerts()
        return instance
    }()
    

    func callToAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        return alert
    }
    
}
