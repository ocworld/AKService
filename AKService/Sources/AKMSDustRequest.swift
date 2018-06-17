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

/// stationName과 msDustResponse를 매핑한 값
public typealias AKMSDustResult = (stationName: String, msDustResponse : AKMSDustResponse)

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
public func requestDust(stationName: String, serviceKey: String, completionHandler: @escaping (AKMSDustResult) -> Void) {
    
    guard let url = requestDustUrl(stationName: stationName, serviceKey: serviceKey) else {
        return
    }
    
    Alamofire.request(url).responseJSON {
        
        guard let response = try? JSONDecoder().decode(AKMSDustResponse.self, from: $0.data!) else {
            return
        }
        
        completionHandler((stationName: stationName, msDustResponse: response))
        
    }
}

/// AKMSResponseItem을 입력으로 미세먼지를 요청한다. AKMSResponseItem는 측정소 개별 정보이다.
///
/// - Parameters:
///   - responseItem: AKMSResponseItem. AKMSRequest를 사용해서 얻어온 측정소 정보이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDust(msResponseItem : AKMSResponseItem, serviceKey: String, completionHandler: @escaping (AKMSDustResult) -> Void) {
    
    requestDust(stationName: msResponseItem.stationName, serviceKey: serviceKey, completionHandler: completionHandler)
    
}

/// AKMSResponse을 입력으로 미세먼지를 요청한다.
///
/// - Parameters:
///   - response: AKMSResponse. AKMSRequest를 사용해서 얻어온 측정소 정보이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 각 측정소마다 정보를 요청해서 가져온 Array가 저장되어있다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDust(msResponse: AKMSResponse, serviceKey: String, completionHandler: @escaping (Array<AKMSDustResult>) -> Void) {
    
    func eachCompletionHandler(msResponse: AKMSResponse) -> ((AKMSDustResult) -> Void) {
        
        let responseCount = msResponse.list.count
        var array: [AKMSDustResult] = []
        
        return {
            array.append($0)
            
            if responseCount == array.count {
                completionHandler(array)
            }
        }
        
    }
    
    let handler = eachCompletionHandler(msResponse: msResponse)
    msResponse.list.forEach { requestDust(msResponseItem: $0, serviceKey: serviceKey, completionHandler: handler) }
    
}

/// AKMSResponse을 입력으로 미세먼지를 요청한다.
///
/// - Parameters:
///   - response: AKMSResponse. AKMSRequest를 사용해서 얻어온 측정소 정보이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 미세먼지/초미세먼지 정보 유형별로 값을 채워서 반환해준다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDustItems(msResponse: AKMSResponse, serviceKey: String, completionHandler: @escaping (AKMSDustResultItems) -> Void) {
    
    requestDust(msResponse: msResponse, serviceKey: serviceKey) {
        resultItemArray in
        
        var resultItems = AKMSDustResultItems()
        for resultItem in resultItemArray {
            let msDustResponse = resultItem.msDustResponse
            //최신 시간을 최신으로 오도록 보장하기 위해. 리스트가 아주 크진 않을 것이므로 정렬
            //한국시간표기에 맞게 나오므로 그냥 단순 string 비교로 대체
            let sortedDustItems = msDustResponse.list.sorted {$0.dataTime > $1.dataTime}
            
            for dustItem in sortedDustItems {
                if resultItems.pm10ValueItem == nil {
                    if let _ = Int(dustItem.pm10Value) {
                        resultItems.pm10ValueItem = (stationName: resultItem.stationName, msDustResponseItem: dustItem)
                    }
                }
                
                if resultItems.pm25ValueItem == nil {
                    if let _ = Int(dustItem.pm25Value) {
                        resultItems.pm25ValueItem = (stationName: resultItem.stationName, msDustResponseItem: dustItem)
                    }
                }
                
                if resultItems.pm10Value24hItem == nil {
                    if let _ = Int(dustItem.pm10Value24) {
                        resultItems.pm10Value24hItem = (stationName: resultItem.stationName, msDustResponseItem: dustItem)
                    }
                }
                
                if resultItems.pm25Value24hItem == nil {
                    if let _ = Int(dustItem.pm25Value24) {
                        resultItems.pm25Value24hItem = (stationName: resultItem.stationName, msDustResponseItem: dustItem)
                    }
                }
                
                if resultItems.isFullSet {
                    break
                }
            }
            
            if resultItems.isFullSet {
                break
            }
        }
        
        completionHandler(resultItems)
        
    }
    
}

/// 사용자의 위치 정보를 입력으로 미세먼지를 요청한다.
/// 사용자의 위치 주변 측정소 정보를 얻어와서 각 측정소에 미세먼지 정보를 요청한다.
///
/// - Parameters:
///   - location: 사용자의 위치 정보이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 각 측정소마다 정보를 요청해서 가져온 Array가 저장되어있다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDust(location: CLLocation, serviceKey: String, completionHandler: @escaping (Array<AKMSDustResult>) -> Void) {
    
    requestMS(location: location, serviceKey: serviceKey) { requestDust(msResponse: $0, serviceKey: serviceKey, completionHandler: completionHandler)
    }
    
}

/// 사용자의 위치 정보를 입력으로 미세먼지를 요청한다.
/// 사용자의 위치 주변 측정소 정보를 얻어와서 각 측정소에 미세먼지 정보를 요청한다.
///
/// - Parameters:
///   - location: 사용자의 위치 정보이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 미세먼지/초미세먼지 정보 유형별로 값을 채워서 반환해준다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDustItems(location: CLLocation, serviceKey: String, completionHandler: @escaping (AKMSDustResultItems) -> Void) {
    
    requestMS(location: location, serviceKey: serviceKey) { requestDustItems(msResponse: $0, serviceKey: serviceKey, completionHandler: completionHandler)
    }
    
}

/// 사용자의 장소 정보를 입력으로 미세먼지를 요청한다.
/// 사용자의 장소 주변 측정소 정보를 얻어와서 각 측정소에 미세먼지 정보를 요청한다.
///
/// - Parameters:
///   - placemark: 사용자의 장소 정보이다. 한국지역에만 제공하기 때문에 내부에서 locale을 ko-kr로 변경하기 위해서 placemark 내부에서 location 정보만을 사용한다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 각 측정소마다 정보를 요청해서 가져온 Array가 저장되어있다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDust(placemark: CLPlacemark, serviceKey: String, completionHandler: @escaping (Array<AKMSDustResult>) -> Void) {
    
    requestMS(placemark: placemark, serviceKey: serviceKey) { requestDust(msResponse: $0, serviceKey: serviceKey, completionHandler: completionHandler)
    }
    
}

/// 사용자의 장소 정보를 입력으로 미세먼지를 요청한다.
/// 사용자의 장소 주변 측정소 정보를 얻어와서 각 측정소에 미세먼지 정보를 요청한다.
///
/// - Parameters:
///   - placemark: 사용자의 장소 정보이다. 한국지역에만 제공하기 때문에 내부에서 locale을 ko-kr로 변경하기 위해서 placemark 내부에서 location 정보만을 사용한다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 미세먼지/초미세먼지 정보 유형별로 값을 채워서 반환해준다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDustItems(placemark: CLPlacemark, serviceKey: String, completionHandler: @escaping (AKMSDustResultItems) -> Void) {
    
    requestMS(placemark: placemark, serviceKey: serviceKey) { requestDustItems(msResponse: $0, serviceKey: serviceKey, completionHandler: completionHandler)
    }
    
}
