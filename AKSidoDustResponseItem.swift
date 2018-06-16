//
//  AKSidoDustResponseItem.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 6. 16..
//

import Foundation

/// AirKorea로부터 반환받은 미세먼지 측정 정보의 개별 아이템이다. Sido별 하위 값이다.
public struct AKSidoDustResponseItem : Codable {
    
    public var _returnType : String
    public var cityName : String
    public var cityNameEng : String
    public var coValue : String
    public var dataGubun : String
    public var dataTime : String
    public var districtCode : String
    public var districtNumSeq : String
    public var itemCode : String
    public var khaiValue : String
    public var no2Value : String
    public var numOfRows : String
    public var o3Value : String
    public var pageNo : String
    public var pm10Value : String
    public var pm25Value : String
    public var resultCode : String
    public var resultMsg : String
    public var searchCondition : String
    public var serviceKey : String
    public var sidoName : String
    public var so2Value : String
    public var totalCount : String
    
}
