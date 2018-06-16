//
//  AKSidoDustResponse.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 6. 16..
//

import Foundation

/// AirKorea로부터 반환받은 미세먼지 측정 정보이다. Sido별 정보이다 값이다.
public struct AKSidoDustResponse : Codable {
    
    var list : [AKSidoDustResponseItem]
    
    var totalCount : Int
    
}

extension AKSidoDustResponse {
    subscript(index:Int) -> Any {
        get {
            return list[index]
        }
    }
}
