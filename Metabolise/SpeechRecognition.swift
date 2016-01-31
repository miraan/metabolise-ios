//
//  SpeechRecognition.swift
//  Metabolise
//
//  Created by Miraan on 31/01/2016.
//  Copyright © 2016 Miraan. All rights reserved.
//

import UIKit

class SpeechRecognition {
    static let SKSAppKey = "5109121bf2f8ef4aeeb9c618ebfee8616c280f97c999b38d444f65a52608b67711c89203c0814dae3a13c62612ae877ed69715a030c82d741792193d9acfb4ab"
    static let SKSAppId = "NMDPPRODUCTION_Miraan_Tabrez_Metabolise_20160131043644"
    static let SKSServerHost = "gui.nmdp.nuancemobility.net"
    static let SKSServerPort = "443"
    
    static let SKSServerUrl = String("nmsps://\(SKSAppId)@\(SKSServerHost):\(SKSServerPort)")
    
}