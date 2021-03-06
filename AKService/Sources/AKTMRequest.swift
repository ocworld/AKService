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

/// 동이름으로 TM좌표를 구해올 수 있는 url을 반환한다.
///
/// - Parameters:
///   - umdName: TM 좌표를 구해올 동 이름이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
/// - Returns: 성공하면 url을 반환한다. 실패하면 nil을 반환한다.
@available(iOS 11.0, *)
fileprivate func requestTMUrl(umdName: String, serviceKey: String) -> URL? {
    
    guard let urlFormatString = AKInfo.default.AKTMRequestUrlFormat else {
        return nil
    }
    
    let nearTNRequestUrlString = String(format: urlFormatString, arguments: [umdName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, serviceKey])
    
    let url = URL(string: nearTNRequestUrlString)
    return url
    
}

/// TM좌표 요청한 내용 중 내 위치와 동일 시도의 데이터를 필터링해준다. 동일 동이름이 다른 지역에 있을 경우를 대비한다.
///
/// - Parameters:
///   - data: TM좌표 요청 응답의 json data이다.
///   - placemark: 동이름이 속해져있는 장소의 정보이다. ko-kr locale이어야한다.
///   - completionHandler: 사용자가 처리할 completionHandler이다. 필터링된 정보만 전달된다.
@available(iOS 11.0, *)
fileprivate func tmResponseHandler(data: Data, placemark: CLPlacemark, completionHandler: @escaping (AKTMResponse?) -> Void) {
    
    guard let response = try? JSONDecoder().decode(AKTMResponse.self, from: data) else {
        completionHandler(nil)
        return
    }
    
    //동 이름만으로 검색하기 때문에, 내 위치와 다른 동이 있을 경우 빼고 넘겨줌
    let sidoName = placemark.administrativeArea
    let newList = response.list.filter { $0.sidoName == sidoName ?? String() }
    let newResponse = AKTMResponse(list: newList)
    
    completionHandler(newResponse)
    
}

/// location을 기반으로 현재 동의 TM 좌표를 구해온다.
///
/// - Parameters:
///   - location: 사용자의 위치정보이다
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 메인큐가 아닌 별도 큐에서 동작한다.
@available(iOS 11.0, *)
public func requestTM(location: CLLocation, serviceKey: String, completionHandler: @escaping (AKTMResult<CLLocation>) -> Void)  {
    
    //location을 한국어로 변환
    requestGeoLocationKo(location: location) { (placemark) in
        
        guard let url = requestTMUrl(umdName: placemark.subLocality ?? "", serviceKey: serviceKey) else {
            return
        }
        
        Alamofire.request(url).responseJSON { (dataResponse) in
            guard let data = dataResponse.data else {
                completionHandler(AKTMResult(input: location, serviceKey: serviceKey, requestUrl: url, dataResponseRaw: dataResponse))
                return
            }
            
            tmResponseHandler(data: data, placemark: placemark) { (tmResponse) in
                completionHandler(AKTMResult(input: location, serviceKey: serviceKey, requestUrl: url, dataResponseRaw: dataResponse, response: tmResponse))
            }
        }
        
    }
    
}

/// 사용자의 장소정보를 기반으로 현재 동의 TM좌표를 구해온다.
///
/// - Parameters:
///   - placemark: 사용자의 장소정보이다. 내부적으로 locale을 ko-kr로만 지정하기 위해 location 값만 사용한다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 메인큐가 아닌 별도 큐에서 동작한다.
@available(iOS 11.0, *)
public func requestTM(placemark: CLPlacemark, serviceKey: String, completionHandler: @escaping (AKTMResult<CLPlacemark>) -> Void)  {
    
    guard let location = placemark.location else {
        completionHandler(AKTMResult(input: placemark, serviceKey: serviceKey))
        return
    }
    
    requestTM(location: location, serviceKey: serviceKey) {
        completionHandler(AKTMResult(input: placemark, serviceKey: $0.serviceKey, requestUrl: $0.requestUrl, dataResponseRaw: $0.dataResponseRaw, response: $0.response))
    }
    
}
