//
//  AKMSResponseItem.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 4. 15..
//  Copyright © 2018년 Keunhyun Oh. All rights reserved.
//

import Foundation

/// AirKorea로부터 반환받은 측정소 정보의 개별 아이템이다.
public struct AKMSResponseItem : Codable {
    
    var stationName : String
    var addr : String
    var tm : Float
    var tmX : String
    var tmY : String
    
}
