//
//  AKTMRequest.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 4. 1..
//  Copyright © 2018년 Keunhyun Oh. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation

fileprivate func requestTMUrl(umdName: String, serviceKey: String) -> URL? {
    
    guard let urlFormatString = urlFormatString(keyName: "AKTNRequestUrlFormat") else {
        return nil
    }
    
    let nearTNRequestUrlString = String(format: urlFormatString, arguments: [umdName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, serviceKey])
    
    let url = URL(string: nearTNRequestUrlString)
    return url
    
}

fileprivate func tmResponseHandler(data: Data, placemark: CLPlacemark, completionHandler: @escaping (AKTMResponse) -> Void) {
    
    guard let response = try? JSONDecoder().decode(AKTMResponse.self, from: data) else {
        return
    }
    
    //동 이름만으로 검색하기 때문에, 내 위치와 다른 동이 있을 경우 빼고 넘겨줌
    let sidoName = placemark.administrativeArea
    let newList = response.list.filter { $0.sidoName == sidoName ?? String() }
    let newResponse = AKTMResponse(list: newList)
    
    completionHandler(newResponse)
    
}

fileprivate func requestGeoLocationKo(location: CLLocation, serviceKey: String, completionHandler: @escaping (CLPlacemark) -> Void) {
    
    CLGeocoder().reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "Ko-Kr")) { (placemarks, error) in
        guard let placemark = placemarks?.first else {
            return
        }
        
        completionHandler(placemark)
    }
    
}

public func requestTM(location: CLLocation, serviceKey: String, completionHandler: @escaping (AKTMResponse) -> Void)  {
    
    //location을 한국어로 변환
    requestGeoLocationKo(location: location, serviceKey: serviceKey) { (placemark) in
        
        guard let url = requestTMUrl(umdName: placemark.subLocality ?? "", serviceKey: serviceKey) else {
            return
        }
        
        Alamofire.request(url).responseJSON {
            tmResponseHandler(data: $0.data!, placemark: placemark, completionHandler: completionHandler)
        }
        
    }
    
}


public func requestTM(placemark: CLPlacemark, serviceKey: String, completionHandler: @escaping (AKTMResponse) -> Void)  {
    
    requestTM(location: placemark.location ?? CLLocation(), serviceKey: serviceKey, completionHandler: completionHandler)
    
}
