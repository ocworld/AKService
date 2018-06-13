//
//  AKTMResponseItem.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 4. 8..
//  Copyright © 2018년 Keunhyun Oh. All rights reserved.
//

import Foundation

/// AirKorea로부터 반환받은 TM좌표 정보의 개별 아이템이다.
public struct AKTMResponseItem : Codable {
    var sggName : String
    var sidoName : String
    var tmX : String
    var tmY : String
    var umdName : String
}
