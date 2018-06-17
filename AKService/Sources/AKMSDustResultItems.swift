//
//  AKMSDustResultItems.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 4. 29..
//  Copyright © 2018년 Keunhyun Oh. All rights reserved.
//

import Foundation

public typealias AKMSDustResultItem = (stationName: String, msDustResponseItem : AKMSDustResponseItem)

/// AirKorea로부터 반환받은 미세먼지 측정 / 예보 정보를 유효한 정보를 담고 있다.
public struct AKMSDustResultItems {
    
    public var pm25ValueItem: AKMSDustResultItem?
    public var pm25Value24hItem: AKMSDustResultItem?  //24시간예측이동농도
    public var pm10ValueItem: AKMSDustResultItem?
    public var pm10Value24hItem: AKMSDustResultItem?  //24시간예측이동농도
    
    public init(pm25ValueItem: AKMSDustResultItem? = nil,
                pm25Value24hItem: AKMSDustResultItem? = nil,
                pm10ValueItem: AKMSDustResultItem? = nil,
                pm10Value24hItem: AKMSDustResultItem? = nil) {
        
        self.pm25ValueItem = pm25ValueItem
        self.pm25Value24hItem = pm25Value24hItem    //24시간예측이동농도
        self.pm10ValueItem = pm10ValueItem
        self.pm10Value24hItem = pm10Value24hItem    //24시간예측이동농도
        
    }
    
    public var isEmpty : Bool {
        return pm25ValueItem == nil
            && pm25Value24hItem == nil
            && pm10ValueItem == nil
            && pm10Value24hItem == nil
    }
    
    public var isFullSet : Bool {
        return pm25ValueItem != nil
            && pm25Value24hItem != nil
            && pm10ValueItem != nil
            && pm10Value24hItem != nil
    }

}
