//
//  AKUtils.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 6. 13..
//

import Foundation
import CoreLocation

/// location을 입력으로 ko-kr locale의 placemark를 생성한다.
///
/// - Parameters:
///   - location: 사용자의 위치정보이다
///   - completionHandler: completionHandler이다.
@available(iOS 11.0, *)
func requestGeoLocationKo(location: CLLocation, completionHandler: @escaping (CLPlacemark) -> Void) {
    
    CLGeocoder().reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "Ko-Kr")) { (placemarks, error) in
        guard let placemark = placemarks?.first else {
            return
        }
        
        completionHandler(placemark)
    }
    
}

