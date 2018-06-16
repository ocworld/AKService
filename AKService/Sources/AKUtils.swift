//
//  AKUtils.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 6. 13..
//

import Foundation
import CoreLocation

/// urlFormatString - AKService에서 사용하는 url format key를 plist에서 읽어서 반환함
///
/// - Parameter keyName: plist에 적혀있는 url의 키. url은 info.plist의 AKService의 AKUrls 하위에 있다.
/// - Returns: 성공하면 urlFormat이 반환된다. 실패하면 nil이 반환된다.
func urlFormatString(keyName: String) -> String? {
    
    guard let bundle = Bundle(identifier: "com.keunhyunoh.AKService") else {
        return nil
    }
    
    guard let infoPath = bundle.path(forResource: "Info", ofType: "plist") else {
        return nil
    }
    
    guard let info = NSDictionary(contentsOfFile: infoPath) as? Dictionary<String, Any> else {
        return nil
    }
    
    guard let urls = info["AKUrls"] as? Dictionary<String, String> else {
        return nil
    }
    
    guard let url = urls[keyName] else {
        return nil
    }
    
    return url
    
}

/// location을 입력으로 ko-kr locale의 placemark를 생성한다.
///
/// - Parameters:
///   - location: 사용자의 위치정보이다
///   - completionHandler: completionHandler이다.
func requestGeoLocationKo(location: CLLocation, completionHandler: @escaping (CLPlacemark) -> Void) {
    
    CLGeocoder().reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "Ko-Kr")) { (placemarks, error) in
        guard let placemark = placemarks?.first else {
            return
        }
        
        completionHandler(placemark)
    }
    
}

/// Long sido Name을 short sidoName으로 변경한다.
///
/// - Parameters:
///   - longSidoName: 사용자의 위치정보이다
/// - Returns: short sidoName을 변환한다. 실패하면 nil을 반환한다.
func shortSidoName(longSidoName: String) -> String? {
    
    guard let bundle = Bundle(identifier: "com.keunhyunoh.AKService") else {
        return nil
    }
    
    guard let infoPath = bundle.path(forResource: "Info", ofType: "plist") else {
        return nil
    }
    
    guard let info = NSDictionary(contentsOfFile: infoPath) as? Dictionary<String, Any> else {
        return nil
    }
    
    guard let sidoDic = info["AKSidoLongToShowDictionary"] as? Dictionary<String, String> else {
        return nil
    }
    
    guard let shortSidoName = sidoDic[longSidoName] else {
        return nil
    }
    
    return shortSidoName
    
}
