//
//  AKMSDustResponseItems.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 4. 29..
//  Copyright © 2018년 Keunhyun Oh. All rights reserved.
//

import Foundation

/// AirKorea로부터 반환받은 미세먼지 측정 정보를 미세먼지/초미세먼지, 1시간정보/24시간정보로 구분해서 저장한다.
public struct AKMSDustResponseItems {
    
    public var pm25Value1hItem: AKMSDustResponseItem?
    public var pm25Value24hItem: AKMSDustResponseItem?
    public var pm10Value1hItem: AKMSDustResponseItem?
    public var pm10Value24hItem: AKMSDustResponseItem?
    
    public init() {
        self.init(pm25Value1hItem: nil, pm25Value24hItem: nil, pm10Value1hItem: nil, pm10Value24hItem: nil)
    }
    
    public init(pm25Value1hItem: AKMSDustResponseItem?, pm25Value24hItem: AKMSDustResponseItem?, pm10Value1hItem: AKMSDustResponseItem?, pm10Value24hItem: AKMSDustResponseItem?) {
        self.pm25Value1hItem = pm25Value1hItem
        self.pm25Value24hItem = pm25Value24hItem
        self.pm10Value1hItem = pm10Value1hItem
        self.pm10Value24hItem = pm10Value24hItem
    }
    
    public var isEmpty : Bool {
        return pm25Value1hItem == nil
            && pm25Value24hItem == nil
            && pm10Value1hItem == nil
            && pm10Value24hItem == nil
    }

}