//
//  AKMSDustRepuest.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 4. 15..
//  Copyright © 2018년 Keunhyun Oh. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation

/// 미세먼지 데이터를 요청할 수 있는 url을 반환한다.
///
/// - Parameters:
///   - stationName: 측정소 이름. AKMSRequest를 사용해서 얻어온 측정소 이름이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
/// - Returns: 성공하면 url을 반환한다. 실패하면 nil을 반환한다.
fileprivate func requestDustUrl(stationName: String, serviceKey: String) -> URL? {
    
    guard let urlFormatString = urlFormatString(keyName: "AKMSDustRequestUrlFormat") else {
        return nil
    }
    
    let msrDustRequestUrlString = String(format: urlFormatString, arguments:[stationName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, serviceKey])
    
    let url = URL(string: msrDustRequestUrlString)
    return url
}


/// 측정소 이름을 입력으로 미세먼지를 요청한다.
///
/// - Parameters:
///   - stationName: 측정소 이름. AKMSRequest를 사용해서 얻어온 측정소 이름이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDust(stationName: String, serviceKey: String, completionHandler: @escaping (AKMSDustResponse) -> Void) {
    
    guard let url = requestDustUrl(stationName: stationName, serviceKey: serviceKey) else {
        return
    }
    
    Alamofire.request(url).responseJSON {
        
        guard let response = try? JSONDecoder().decode(AKMSDustResponse.self, from: $0.data!) else {
            return
        }
        
        completionHandler(response)
        
    }
}

/// AKMSResponseItem을 입력으로 미세먼지를 요청한다. AKMSResponseItem는 측정소 개별 정보이다.
///
/// - Parameters:
///   - responseItem: AKMSResponseItem. AKMSRequest를 사용해서 얻어온 측정소 정보이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDust(responseItem : AKMSResponseItem, serviceKey: String, completionHandler: @escaping (AKMSDustResponse) -> Void) {
    
    requestDust(stationName: responseItem.stationName, serviceKey: serviceKey, completionHandler: completionHandler)
    
}

/// AKMSResponse을 입력으로 미세먼지를 요청한다.
///
/// - Parameters:
///   - response: AKMSResponse. AKMSRequest를 사용해서 얻어온 측정소 정보이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 각 측정소마다 정보를 요청해서 가져온 Array가 저장되어있다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDust(response: AKMSResponse, serviceKey: String, completionHandler: @escaping (Array<AKMSDustResponse>) -> Void) {
    
    func eachCompletionHandler(response: AKMSResponse) -> ((AKMSDustResponse) -> Void) {
        
        let responseCount = response.list.count
        var array: [AKMSDustResponse] = []
        
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

/// AKMSResponse을 입력으로 미세먼지를 요청한다.
///
/// - Parameters:
///   - response: AKMSResponse. AKMSRequest를 사용해서 얻어온 측정소 정보이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 미세먼지/초미세먼지 정보 유형별로 값을 채워서 반환해준다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDustItems(response: AKMSResponse, serviceKey: String, completionHandler: @escaping (AKMSDustResponseItems) -> Void) {
    
    requestDust(response: response, serviceKey: serviceKey) {
        let newResult = $0.reduce(AKMSDustResponseItems(pm25Value1hItem: nil,pm25Value24hItem: nil,pm10Value1hItem: nil,pm10Value24hItem: nil), { (result, response) in
            
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

/// 사용자의 위치 정보를 입력으로 미세먼지를 요청한다.
/// 사용자의 위치 주변 측정소 정보를 얻어와서 각 측정소에 미세먼지 정보를 요청한다.
///
/// - Parameters:
///   - location: 사용자의 위치 정보이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 각 측정소마다 정보를 요청해서 가져온 Array가 저장되어있다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDust(location: CLLocation, serviceKey: String, completionHandler: @escaping (Array<AKMSDustResponse>) -> Void) {
    
    requestMS(location: location, serviceKey: serviceKey) { requestDust(response: $0, serviceKey: serviceKey, completionHandler: completionHandler)
    }
    
}

/// 사용자의 위치 정보를 입력으로 미세먼지를 요청한다.
/// 사용자의 위치 주변 측정소 정보를 얻어와서 각 측정소에 미세먼지 정보를 요청한다.
///
/// - Parameters:
///   - location: 사용자의 위치 정보이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 미세먼지/초미세먼지 정보 유형별로 값을 채워서 반환해준다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDustItems(location: CLLocation, serviceKey: String, completionHandler: @escaping (AKMSDustResponseItems) -> Void) {
    
    requestMS(location: location, serviceKey: serviceKey) { requestDustItems(response: $0, serviceKey: serviceKey, completionHandler: completionHandler)
    }
    
}

/// 사용자의 장소 정보를 입력으로 미세먼지를 요청한다.
/// 사용자의 장소 주변 측정소 정보를 얻어와서 각 측정소에 미세먼지 정보를 요청한다.
///
/// - Parameters:
///   - placemark: 사용자의 장소 정보이다. 한국지역에만 제공하기 때문에 내부에서 locale을 ko-kr로 변경하기 위해서 placemark 내부에서 location 정보만을 사용한다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 각 측정소마다 정보를 요청해서 가져온 Array가 저장되어있다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDust(placemark: CLPlacemark, serviceKey: String, completionHandler: @escaping (Array<AKMSDustResponse>) -> Void) {
    
    requestMS(placemark: placemark, serviceKey: serviceKey) { requestDust(response: $0, serviceKey: serviceKey, completionHandler: completionHandler)
    }
    
}

/// 사용자의 장소 정보를 입력으로 미세먼지를 요청한다.
/// 사용자의 장소 주변 측정소 정보를 얻어와서 각 측정소에 미세먼지 정보를 요청한다.
///
/// - Parameters:
///   - placemark: 사용자의 장소 정보이다. 한국지역에만 제공하기 때문에 내부에서 locale을 ko-kr로 변경하기 위해서 placemark 내부에서 location 정보만을 사용한다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 미세먼지/초미세먼지 정보 유형별로 값을 채워서 반환해준다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDustItems(placemark: CLPlacemark, serviceKey: String, completionHandler: @escaping (AKMSDustResponseItems) -> Void) {
    
    requestMS(placemark: placemark, serviceKey: serviceKey) { requestDustItems(response: $0, serviceKey: serviceKey, completionHandler: completionHandler)
    }
    
}
