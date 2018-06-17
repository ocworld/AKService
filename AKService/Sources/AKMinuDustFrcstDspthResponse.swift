//
//  AKMinuDustFrcstDspthResponse.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 6. 17..
//

import Foundation

public struct AKMinuDustFrcstDspthResponse : Codable {
    public var list : [AKMinuDustFrcstDspthResponseItem]
    public var parm : AKMinuDustFrcstDspthResponseItem
    public var MinuDustFrcstDspthVo : AKMinuDustFrcstDspthResponseItem
    public var totalCount : Int
}
