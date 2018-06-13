//
//  AKMSResponse.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 4. 15..
//  Copyright © 2018년 Keunhyun Oh. All rights reserved.
//

import Foundation

/// AirKorea로부터 반환받은 측정소 정보이다.
public struct AKMSResponse : Codable {
    
    public var list: [AKMSResponseItem]
    
}

extension AKMSResponse {
    public subscript(index:Int) -> Any {
        get {
            return list[index]
        }
    }
}

extension AKMSResponse {
    
    public var first : AKMSResponseItem? {
        return list.first
    }
    
}
