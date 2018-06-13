//
//  AKDustResponse.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 4. 22..
//  Copyright © 2018년 Keunhyun Oh. All rights reserved.
//

import Foundation

/// AirKorea로부터 반환받은 미세먼지 측정 정보이다.
public struct AKDustResponse : Codable {
    
    var list : [AKDustResponseItem]
    
    var totalCount : Int

}

extension AKDustResponse {
    subscript(index:Int) -> Any {
        get {
            return list[index]
        }
    }
}

extension AKDustResponse {
    
    var first: AKDustResponseItem? {
        return list.first
    }
    
    var pm25Value1hItem: AKDustResponseItem? {
        return list.filter({Int($0.pm25Value) != nil}).first
    }
    
    var pm25Value24hItem: AKDustResponseItem? {
        return list.filter({Int($0.pm25Value24) != nil}).first
    }
    
    var pm10Value1hItem: AKDustResponseItem? {
        return list.filter({Int($0.pm10Value) != nil}).first
    }

    var pm10Value24hItem: AKDustResponseItem? {
        return list.filter({Int($0.pm10Value24) != nil}).first
    }

}
