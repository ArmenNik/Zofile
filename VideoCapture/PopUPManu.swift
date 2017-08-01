//
//  PopUPManu.swift
//  VideoCapture
//
//  Created by MacMini on 7/27/17.
//  Copyright © 2017 com.armomik. All rights reserved.
//

import Foundation
import UIKit
class PopUPManu: UIView {
    
    var didSelectedItem: ((_ item: Int)->Void)?
    var menudidHide: (()->Void)?
    
    override func awakeFromNib() {
        self.frontImage.layer.cornerRadius = self.frontImage.frame.size.width / 2
        self.rightImage.layer.cornerRadius = self.rightImage.frame.size.width / 2
        self.leftImage.layer.cornerRadius = self.leftImage.frame.size.width / 2
        self.frontImage.layer.borderWidth = 3
        self.rightImage.layer.borderWidth = 3
        self.leftImage.layer.borderWidth = 3
        self.frontImage.layer.borderColor = UIColor.black.cgColor
        self.rightImage.layer.borderColor = UIColor.black.cgColor
        self.leftImage.layer.borderColor = UIColor.black.cgColor
        
    }
    @IBOutlet weak var frontImage: UIImageView!
    @IBOutlet weak var rightImage: UIImageView!
    @IBOutlet weak var leftImage: UIImageView!
    
    @IBOutlet weak var frontButton: MenuButton!
    @IBOutlet weak var leftButton: MenuButton!
    @IBOutlet weak var rightButton: MenuButton!
    
    @IBAction func frontAction(_ sender: Any) {
        let btn = sender as! UIButton
         self.didSelectedItem!(btn.tag)
        
    }
    
    @IBAction func rightAction(_ sender: Any) {
        let btn = sender as! UIButton
        self.didSelectedItem!(btn.tag)
        

        
    }
    
    @IBAction func leftAction(_ sender: Any) {
        let btn = sender as! UIButton
        self.didSelectedItem!(btn.tag)
       

        
    }
    
    
    func setupframe(frame: CGRect, images:[UIImage]) {
        self.frame = frame
        print(images)
        self.frontImage.image = images[0]
        self.rightImage.image = images[2]
        self.leftImage.image = images[1]
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.removeFromSuperview()
        self.menudidHide!()
        print("touch")
    }
    
}
