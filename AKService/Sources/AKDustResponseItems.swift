//
//  AKDustResponseItems.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 4. 29..
//  Copyright © 2018년 Keunhyun Oh. All rights reserved.
//

import Foundation

public struct AKDustResponseItems {
    
    public var pm25Value1hItem: AKDustResponseItem?
    public var pm25Value24hItem: AKDustResponseItem?
    public var pm10Value1hItem: AKDustResponseItem?
    public var pm10Value24hItem: AKDustResponseItem?
    
    public init() {
        self.init(pm25Value1hItem: nil, pm25Value24hItem: nil, pm10Value1hItem: nil, pm10Value24hItem: nil)
    }
    
    public init(pm25Value1hItem: AKDustResponseItem?, pm25Value24hItem: AKDustResponseItem?, pm10Value1hItem: AKDustResponseItem?, pm10Value24hItem: AKDustResponseItem?) {
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
