//
//  AKMinuDustFrcstDspthResponse.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 6. 17..
//

import Foundation

/// 미세먼지 예보 정보 요청에 대한 응답이다.
public struct AKMinuDustFrcstDspthResponse : Codable {
    public var list : [AKMinuDustFrcstDspthResponseItem]
    public var parm : AKMinuDustFrcstDspthResponseItem
    public var MinuDustFrcstDspthVo : AKMinuDustFrcstDspthResponseItem
    public var totalCount : Int
}
