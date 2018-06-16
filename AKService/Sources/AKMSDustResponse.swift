//
//  AKMSDustResponse.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 4. 22..
//  Copyright © 2018년 Keunhyun Oh. All rights reserved.
//

import Foundation

/// AirKorea로부터 반환받은 미세먼지 측정 정보이다.
public struct AKMSDustResponse : Codable {
    
    var list : [AKMSDustResponseItem]
    
    var totalCount : Int

}

extension AKMSDustResponse {
    subscript(index:Int) -> Any {
        get {
            return list[index]
        }
    }
}

extension AKMSDustResponse {
    
    var first: AKMSDustResponseItem? {
        return list.first
    }
    
    var pm25Value1hItem: AKMSDustResponseItem? {
        return list.filter({Int($0.pm25Value) != nil}).first
    }
    
    var pm25Value24hItem: AKMSDustResponseItem? {
        return list.filter({Int($0.pm25Value24) != nil}).first
    }
    
    var pm10Value1hItem: AKMSDustResponseItem? {
        return list.filter({Int($0.pm10Value) != nil}).first
    }

    var pm10Value24hItem: AKMSDustResponseItem? {
        return list.filter({Int($0.pm10Value24) != nil}).first
    }

}
