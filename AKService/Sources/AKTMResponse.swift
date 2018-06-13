//
//  AKTMResponse.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 4. 8..
//  Copyright © 2018년 Keunhyun Oh. All rights reserved.
//

import Foundation

/// AirKorea로부터 반환받은 TM좌표 정보이다.
public struct AKTMResponse : Codable {
    
    public var list: [AKTMResponseItem]
    
}

extension AKTMResponse {
    public subscript(index:Int) -> Any {
        get {
            return list[index]
        }
    }
}

extension AKTMResponse {
    
    public var first : AKTMResponseItem? {
        return list.first
    }
    
}
