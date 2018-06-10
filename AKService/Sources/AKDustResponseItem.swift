//
//  AKDustResponseItem.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 4. 22..
//  Copyright © 2018년 Keunhyun Oh. All rights reserved.
//

import Foundation

public struct AKDustResponseItem : Codable {
    
    public var _returnType : String
    public var coGrade : String
    public var coValue : String
    public var dataTerm : String
    public var dataTime : String
    public var khaiGrade : String
    public var khaiValue : String
    public var mangName : String
    public var no2Grade : String
    public var no2Value : String
    public var numOfRows : String
    public var o3Grade : String
    public var pageNo : String
    public var pm10Grade : String
    public var pm10Grade1h : String
    public var pm10Value : String
    public var pm10Value24 : String
    public var pm25Grade : String
    public var pm25Grade1h : String
    public var pm25Value : String
    public var pm25Value24 : String
    public var resultCode : String
    public var resultMsg : String
    public var rnum : Int
    public var serviceKey : String
    public var sidoName : String
    public var so2Grade : String
    public var so2Value : String
    public var stationCode : String
    public var stationName : String
    public var totalCount : String
    public var ver : String
    
}
