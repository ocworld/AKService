//
//  AKSidoDustRequest.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 6. 16..
//

import Foundation
import Alamofire
import CoreLocation

/// 미세먼지 데이터를 요청할 수 있는 url을 반환한다.
///
/// - Parameters:
///   - sidoName: 시도 이름. 반드시 한국어여야한다.
///   - pageNo: url에서 얻어올 데이터의 pageNo이다. 한 pageNo의 최대 아이템은 numOfRows이다. pageNo가 변경되면 numOfRows * pageNo 다음 데이터들이 응답된다.
///   - numOfRows: 한 pageNo의 최대 아이템 개수이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
/// - Returns: 성공하면 url을 반환한다. 실패하면 nil을 반환한다.
fileprivate func requestDustUrl(sidoName: String,
                                pageNo: Int,
                                numOfRows: Int,
                                serviceKey: String) -> URL? {
    
    guard let urlFormatString = urlFormatString(keyName: "AKSidoDustRequestUrlFormat") else {
        return nil
    }
    
    let msrDustRequestUrlString = String(format: urlFormatString,
                                         arguments:[sidoName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                                                    String(pageNo),
                                                    String(numOfRows),
                                                    serviceKey])
    
    let url = URL(string: msrDustRequestUrlString)
    return url
}

/// 측정소 이름을 입력으로 미세먼지를 요청한다.
///
/// - Parameters:
///   - sidoName: 시도 이름. 반드시 한국어여야한다.
///   - pageNo: url에서 얻어올 데이터의 pageNo이다. 한 pageNo의 최대 아이템은 numOfRows이다. pageNo가 변경되면 numOfRows * pageNo 다음 데이터들이 응답된다.
///   - numOfRows: 한 pageNo의 최대 아이템 개수이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDustSido(sidoName: String,
                            pageNo: Int,
                            numOfRows: Int,
                            serviceKey: String,
                            completionHandler: @escaping (String, AKSidoDustResponse?, Alamofire.DataResponse<Any>) -> Void) {
    //short 이름이 없으면 그 자체가 short일수도 있으니 그대로 pass
    guard let url = requestDustUrl(sidoName: shortSidoName(longSidoName: sidoName) ?? sidoName,
                                   pageNo: pageNo,
                                   numOfRows: numOfRows,
                                   serviceKey: serviceKey) else {
        return
    }
    
    Alamofire.request(url).responseJSON {
        
        guard let data = $0.data else {
            completionHandler(sidoName, nil, $0)
            return
        }
        
        guard let response = try? JSONDecoder().decode(AKSidoDustResponse.self, from: data) else {
            completionHandler(sidoName, nil, $0)
            return
        }
        
        completionHandler(sidoName, response, $0)
        
    }
}

/// 사용자의 위치 정보를 입력으로 미세먼지를 요청한다. 시도내의 데이터를 요청한다.
/// 사용자의 위치 주변 측정소 정보를 얻어와서 각 측정소에 미세먼지 정보를 요청한다.
///
/// - Parameters:
///   - location: 사용자의 위치 정보이다.
///   - pageNo: url에서 얻어올 데이터의 pageNo이다. 한 pageNo의 최대 아이템은 numOfRows이다. pageNo가 변경되면 numOfRows * pageNo 다음 데이터들이 응답된다.
///   - numOfRows: 한 pageNo의 최대 아이템 개수이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 각 측정소마다 정보를 요청해서 가져온 Array가 저장되어있다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDustSido(location: CLLocation,
                            pageNo: Int,
                            numOfRows: Int,
                            serviceKey: String,
                            completionHandler: @escaping (CLLocation, AKSidoDustResponse?, Alamofire.DataResponse<Any>?) -> Void) {

    requestGeoLocationKo(location: location) {
        
        guard let sidoName = $0.administrativeArea else {
            completionHandler(location, nil, nil)
            return
        }
        
        requestDustSido(sidoName: sidoName, pageNo: pageNo, numOfRows: numOfRows, serviceKey: serviceKey) {
            completionHandler(location, $1, $2)
        }
        
    }
    
}

/// 사용자의 위치 정보를 입력으로 미세먼지를 요청한다. 시도의 하위 단위(시, 구, 군 등)의 현재 소속된 곳의 데이터만 반환한다.
/// 사용자의 위치 주변 측정소 정보를 얻어와서 각 측정소에 미세먼지 정보를 요청한다.
///
/// - Parameters:
///   - location: 사용자의 위치 정보이다.
///   - pageNo: url에서 얻어올 데이터의 pageNo이다. 한 pageNo의 최대 아이템은 numOfRows이다. pageNo가 변경되면 numOfRows * pageNo 다음 데이터들이 응답된다.
///   - numOfRows: 한 pageNo의 최대 아이템 개수이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 각 측정소마다 정보를 요청해서 가져온 Array가 저장되어있다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDustCity(location: CLLocation,
                            pageNo: Int,
                            numOfRows: Int,
                            serviceKey: String,
                            completionHandler: @escaping (CLLocation, AKSidoDustResponseItem?, Alamofire.DataResponse<Any>?) -> Void) {
    
    requestGeoLocationKo(location: location) { (placemark) in
        
        guard let sidoName = placemark.administrativeArea else {
            completionHandler(location, nil, nil)
            return
        }
        
        //전국에 예상치 못하게 locality에 값이 없을 수 있는 상황이 있을 수 있으니(가능한 있겠지만), locality가 없을 경우 sublocality까지 본다.
        guard let cityName = placemark.locality ?? placemark.subLocality else {
            completionHandler(location, nil, nil)
            return
        }
        
        requestDustSido(sidoName: sidoName, pageNo: pageNo, numOfRows: numOfRows, serviceKey: serviceKey) {
            
            guard let response = $1 else {
                completionHandler(location, nil, $2)
                return
            }
                            
            let filteredList = response.list.filter({$0.cityName == cityName})
            if filteredList.isEmpty {
                completionHandler(location, nil, $2)
            } else {
                completionHandler(location, filteredList[0], $2)
            }
                            
        }
    }
    
}

/// 사용자의 장소 정보를 입력으로 미세먼지를 요청한다. 입력 placemark 시도 하위 전체 데이터를 반환한다.
///
/// - Parameters:
///   - placemark: 사용자의 장소 정보이다. 한국지역에만 제공하기 때문에 내부에서 locale을 ko-kr로 변경하기 위해서 placemark 내부에서 location 정보만을 사용한다.
///   - pageNo: url에서 얻어올 데이터의 pageNo이다. 한 pageNo의 최대 아이템은 numOfRows이다. pageNo가 변경되면 numOfRows * pageNo 다음 데이터들이 응답된다.
///   - numOfRows: 한 pageNo의 최대 아이템 개수이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 각 측정소마다 정보를 요청해서 가져온 Array가 저장되어있다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDustSido(placemark: CLPlacemark,
                            pageNo: Int,
                            numOfRows: Int,
                            serviceKey: String,
                            completionHandler: @escaping (CLPlacemark, AKSidoDustResponse?, Alamofire.DataResponse<Any>?) -> Void) {
    
    guard let location = placemark.location else {
        completionHandler(placemark, nil, nil)
        return
    }
    
    requestDustSido(location: location, pageNo: pageNo, numOfRows: numOfRows, serviceKey: serviceKey) {
        completionHandler(placemark, $1, $2)
    }
    
}

/// 사용자의 장소 정보를 입력으로 미세먼지를 요청한다. 시도의 하위 단위(구, 군 등)의 현재 소속된 곳의 데이터만 반환한다.
///
/// - Parameters:
///   - placemark: 사용자의 장소 정보이다. 한국지역에만 제공하기 때문에 내부에서 locale을 ko-kr로 변경하기 위해서 placemark 내부에서 location 정보만을 사용한다.
///   - pageNo: url에서 얻어올 데이터의 pageNo이다. 한 pageNo의 최대 아이템은 numOfRows이다. pageNo가 변경되면 numOfRows * pageNo 다음 데이터들이 응답된다.
///   - numOfRows: 한 pageNo의 최대 아이템 개수이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 미세먼지/초미세먼지 정보 유형별로 값을 채워서 반환해준다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDustCity(placemark: CLPlacemark,
                            pageNo: Int,
                            numOfRows: Int,
                            serviceKey: String,
                            completionHandler: @escaping (CLPlacemark, AKSidoDustResponseItem?, Alamofire.DataResponse<Any>?) -> Void) {
    
    guard let location = placemark.location else {
        return
    }
    
    requestDustCity(location: location, pageNo: pageNo, numOfRows: numOfRows, serviceKey: serviceKey) {
        completionHandler(placemark, $1, $2)
    }
    
}
