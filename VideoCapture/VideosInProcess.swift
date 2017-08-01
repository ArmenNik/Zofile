//
//  VideosInProcess.swift
//  VideoCapture
//
//  Created by Armen Nikodhosyan on 31.07.17.
//  Copyright © 2017 com.armomik. All rights reserved.
//

import Foundation
import RealmSwift

class VideosInProcess: Object {
    dynamic var name : String =  ""
    var videoPos = List<ProcessVideo>()
}
