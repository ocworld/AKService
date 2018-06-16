//
//  AKSidoDustRequest.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 6. 16..
//

import Foundation
import Alamofire
import CoreLocation

fileprivate extension CLPlacemark {
    
}

/// 미세먼지 데이터를 요청할 수 있는 url을 반환한다.
///
/// - Parameters:
///   - sidoName: 시도 이름. 반드시 한국어여야한다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
/// - Returns: 성공하면 url을 반환한다. 실패하면 nil을 반환한다.
fileprivate func requestDustUrl(sidoName: String, serviceKey: String) -> URL? {
    
    guard let urlFormatString = urlFormatString(keyName: "AKSidoDustRequestUrlFormat") else {
        return nil
    }
    
    let msrDustRequestUrlString = String(format: urlFormatString, arguments:[sidoName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, serviceKey])
    
    let url = URL(string: msrDustRequestUrlString)
    return url
}

/// 측정소 이름을 입력으로 미세먼지를 요청한다.
///
/// - Parameters:
///   - sidoName: 시도 이름. 반드시 한국어여야한다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDust(sidoName: String, serviceKey: String, completionHandler: @escaping (AKSidoDustResponse) -> Void) {
    //short 이름이 없으면 그 자체가 short일수도 있으니 그대로 pass
    guard let url = requestDustUrl(sidoName: shortSidoName(longSidoName: sidoName) ?? sidoName,
                                   serviceKey: serviceKey) else {
        return
    }
    
    Alamofire.request(url).responseJSON {
        
        guard let response = try? JSONDecoder().decode(AKSidoDustResponse.self, from: $0.data!) else {
            return
        }
        
        completionHandler(response)
        
    }
}

/// 사용자의 위치 정보를 입력으로 미세먼지를 요청한다. 시도내의 데이터를 요청한다.
/// 사용자의 위치 주변 측정소 정보를 얻어와서 각 측정소에 미세먼지 정보를 요청한다.
///
/// - Parameters:
///   - location: 사용자의 위치 정보이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 각 측정소마다 정보를 요청해서 가져온 Array가 저장되어있다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDustSido(location: CLLocation, serviceKey: String, completionHandler: @escaping (AKSidoDustResponse) -> Void) {

    requestGeoLocationKo(location: location) {
        
        guard let sidoName = $0.administrativeArea else {
            return
        }
        
        requestDust(sidoName: sidoName, serviceKey: serviceKey, completionHandler: completionHandler)
    }
    
}

/// 사용자의 위치 정보를 입력으로 미세먼지를 요청한다. 시도의 하위 단위(구, 군 등)의 현재 소속된 곳의 데이터만 반환한다.
/// 사용자의 위치 주변 측정소 정보를 얻어와서 각 측정소에 미세먼지 정보를 요청한다.
///
/// - Parameters:
///   - location: 사용자의 위치 정보이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 각 측정소마다 정보를 요청해서 가져온 Array가 저장되어있다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDust(location: CLLocation, serviceKey: String, completionHandler: @escaping (AKSidoDustResponseItem) -> Void) {
    
    requestGeoLocationKo(location: location) { (placemark) in
        
        guard let sidoName = placemark.administrativeArea else {
            return
        }
        
        requestDust(sidoName: sidoName, serviceKey: serviceKey) {
            completionHandler($0.list.filter({$0.cityName == placemark.subAdministrativeArea})[0])
        }
    }
    
}

/// 사용자의 장소 정보를 입력으로 미세먼지를 요청한다. 입력 placemark 시도 하위 전체 데이터를 반환한다.
///
/// - Parameters:
///   - placemark: 사용자의 장소 정보이다. 한국지역에만 제공하기 때문에 내부에서 locale을 ko-kr로 변경하기 위해서 placemark 내부에서 location 정보만을 사용한다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 각 측정소마다 정보를 요청해서 가져온 Array가 저장되어있다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDustSido(placemark: CLPlacemark, serviceKey: String, completionHandler: @escaping (AKSidoDustResponse) -> Void) {
    
    guard let location = placemark.location else {
        return
    }
    
    requestDustSido(location: location, serviceKey: serviceKey, completionHandler: completionHandler)
    
}

/// 사용자의 장소 정보를 입력으로 미세먼지를 요청한다. 시도의 하위 단위(구, 군 등)의 현재 소속된 곳의 데이터만 반환한다.
///
/// - Parameters:
///   - placemark: 사용자의 장소 정보이다. 한국지역에만 제공하기 때문에 내부에서 locale을 ko-kr로 변경하기 위해서 placemark 내부에서 location 정보만을 사용한다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 미세먼지/초미세먼지 정보 유형별로 값을 채워서 반환해준다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDust(placemark: CLPlacemark, serviceKey: String, completionHandler: @escaping (AKSidoDustResponseItem) -> Void) {
    
    guard let location = placemark.location else {
        return
    }
    
    requestDust(location: location, serviceKey: serviceKey, completionHandler: completionHandler)
    
}
