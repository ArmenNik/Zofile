//
//  playerCell.swift
//  VideoCapture
//
//  Created by MacMini on 7/3/17.
//  Copyright © 2017 com.armomik. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit

class PlayerCell: UITableViewCell {
    
    
    @IBOutlet weak var hh: UIImageView!
    
    func gettingVideoFromUrl(url: String) {
        print(url)
        let URl = URL.init(string: url)
       
        let avasset = AVAsset.init(url: URl!)
//        if avasset == nil {
//            print("asset nil")
//            return
//        }
        let avAssetgenerator = AVAssetImageGenerator(asset: avasset)
        let time = CMTimeMakeWithSeconds(1.0, 1)
        
        var actualTime : CMTime = CMTimeMake(0, 0)
        //var error : NSError?
        DispatchQueue.global().async {
            do{
                let myImage = try avAssetgenerator.copyCGImage(at: time, actualTime: &actualTime)
                //let myImage = avAssetgenerator.copyCGImageAtTime(time, actualTime: &actualTime, error: &error)
                let img = UIImage.init(cgImage: myImage)
                DispatchQueue.main.async {
                    
                    self.hh.image = img
                    
                }

                
            }catch{
                print("error   hgjh")
            }
            
        }
        
    }
    
    
    
}
