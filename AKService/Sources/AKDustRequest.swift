//
//  AKDustRepuest.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 4. 15..
//  Copyright © 2018년 Keunhyun Oh. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation

fileprivate let msrDustRequestUrlFormat = "http://openapi.airkorea.or.kr/openapi/services/rest/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty?stationName=%@&dataTerm=month&pageNo=1&numOfRows=10&ServiceKey=%@&ver=1.3&_returnType=json"

fileprivate func requestDustUrl(stationName: String, serviceKey: String) -> URL? {
    let msrDustRequestUrlString = String(format: msrDustRequestUrlFormat, arguments:[stationName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, serviceKey])
    
    let url = URL(string: msrDustRequestUrlString)
    return url
}

public func requestDust(stationName: String, serviceKey: String, completionHandler: @escaping (AKDustResponse) -> Void) {
    
    guard let url = requestDustUrl(stationName: stationName, serviceKey: serviceKey) else {
        return
    }
    
    Alamofire.request(url).responseJSON {
        
        guard let response = try? JSONDecoder().decode(AKDustResponse.self, from: $0.data!) else {
            return
        }
        
        completionHandler(response)
        
    }
}

public func requestDust(responseItem : AKMSResponseItem, serviceKey: String, completionHandler: @escaping (AKDustResponse) -> Void) {
    
    requestDust(stationName: responseItem.stationName, serviceKey: serviceKey, completionHandler: completionHandler)
    
}

public func requestDust(response: AKMSResponse, serviceKey: String, completionHandler: @escaping (Array<AKDustResponse>) -> Void) {
    
    func eachCompletionHandler(response: AKMSResponse) -> ((AKDustResponse) -> Void) {
        
        let responseCount = response.list.count
        var array: [AKDustResponse] = []
        
        return {
            array.append($0)
            if responseCount == array.count {
                completionHandler(array)
            }
        }
        
    }
    
    let handler = eachCompletionHandler(response: response)
    response.list.forEach { requestDust(responseItem: $0, serviceKey: serviceKey, completionHandler: handler) }
    
}

public func requestDustItems(response: AKMSResponse, serviceKey: String, completionHandler: @escaping (AKDustResponseItems) -> Void) {
    
    requestDust(response: response, serviceKey: serviceKey) {
        let newResult = $0.reduce(AKDustResponseItems(pm25Value1hItem: nil,pm25Value24hItem: nil,pm10Value1hItem: nil,pm10Value24hItem: nil), { (result, response) in
            
            var newResult = result
            if result.pm10Value1hItem == nil {
                if let item = response.pm10Value1hItem {
                    newResult.pm10Value1hItem = item
                }
            }
            
            if result.pm25Value1hItem == nil {
                if let item = response.pm25Value1hItem {
                    newResult.pm25Value1hItem = item
                }
            }
            
            if result.pm10Value24hItem == nil {
                if let item = response.pm10Value24hItem {
                    newResult.pm10Value24hItem = item
                }
            }
            
            if result.pm25Value24hItem == nil {
                if let item = response.pm25Value24hItem {
                    newResult.pm25Value24hItem = item
                }
            }
            
            return newResult
        })
        
        completionHandler(newResult)
    }
    
}

public func requestDust(location: CLLocation, serviceKey: String, completionHandler: @escaping (Array<AKDustResponse>) -> Void) {
    
    requestMS(location: location, serviceKey: serviceKey) { requestDust(response: $0, serviceKey: serviceKey, completionHandler: completionHandler)
    }
    
}

public func requestDustItems(location: CLLocation, serviceKey: String, completionHandler: @escaping (AKDustResponseItems) -> Void) {
    
    requestMS(location: location, serviceKey: serviceKey) { requestDustItems(response: $0, serviceKey: serviceKey, completionHandler: completionHandler)
    }
    
}

public func requestDust(placemark: CLPlacemark, serviceKey: String, completionHandler: @escaping (Array<AKDustResponse>) -> Void) {
    
    requestMS(placemark: placemark, serviceKey: serviceKey) { requestDust(response: $0, serviceKey: serviceKey, completionHandler: completionHandler)
    }
    
}

public func requestDustItems(placemark: CLPlacemark, serviceKey: String, completionHandler: @escaping (AKDustResponseItems) -> Void) {
    
    requestMS(placemark: placemark, serviceKey: serviceKey) { requestDustItems(response: $0, serviceKey: serviceKey, completionHandler: completionHandler)
    }
    
}
