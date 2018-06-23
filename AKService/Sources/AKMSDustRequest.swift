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
///   - pageNo: url에서 얻어올 데이터의 pageNo이다. 한 pageNo의 최대 아이템은 numOfRows이다. pageNo가 변경되면 numOfRows * pageNo 다음 데이터들이 응답된다.
///   - numOfRows: 한 pageNo의 최대 아이템 개수이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
/// - Returns: 성공하면 url을 반환한다. 실패하면 nil을 반환한다.
fileprivate func requestDustUrl(stationName: String,
                                pageNo: Int,
                                numOfRows: Int,
                                serviceKey: String) -> URL? {
    
    guard let urlFormatString = urlFormatString(keyName: "AKMSDustRequestUrlFormat") else {
        return nil
    }
    
    let msrDustRequestUrlString = String(format: urlFormatString,
                                         arguments: [stationName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                                                     String(pageNo),
                                                     String(numOfRows),
                                                     serviceKey])
    
    let url = URL(string: msrDustRequestUrlString)
    return url
}


/// 측정소 이름을 입력으로 미세먼지를 요청한다.
///
/// - Parameters:
///   - stationName: 측정소 이름. AKMSRequest를 사용해서 얻어온 측정소 이름이다.
///   - pageNo: url에서 얻어올 데이터의 pageNo이다. 한 pageNo의 최대 아이템은 numOfRows이다. pageNo가 변경되면 numOfRows * pageNo 다음 데이터들이 응답된다.
///   - numOfRows: 한 pageNo의 최대 아이템 개수이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDust(stationName: String,
                        pageNo: Int,
                        numOfRows: Int,
                        serviceKey: String,
                        completionHandler: @escaping (AKMSDustResult<String>) -> Void) {
    
    guard let url = requestDustUrl(stationName: stationName,
                                   pageNo: pageNo,
                                   numOfRows: numOfRows,
                                   serviceKey: serviceKey) else {
        return
    }
    
    Alamofire.request(url).responseJSON {
        
        guard let data = $0.data else {
            completionHandler(AKMSDustResult(input: stationName,
                                             serviceKey: serviceKey,
                                             pageNo: pageNo,
                                             numOfRows: numOfRows,
                                             requestUrl: url,
                                             dataResponseRaw: $0))
            return
        }
        
        guard let response = try? JSONDecoder().decode(AKMSDustResponse.self, from: data) else {
            completionHandler(AKMSDustResult(input: stationName,
                                             serviceKey: serviceKey,
                                             pageNo: pageNo,
                                             numOfRows: numOfRows,
                                             requestUrl: url,
                                             dataResponseRaw: $0))
            return
        }
        
        completionHandler(AKMSDustResult(input: stationName,
                                         serviceKey: serviceKey,
                                         pageNo: pageNo,
                                         numOfRows: numOfRows,
                                         requestUrl: url,
                                         dataResponseRaw: $0,
                                         response: response))
        
    }
}

/// AKMSResponseItem을 입력으로 미세먼지를 요청한다. AKMSResponseItem는 측정소 개별 정보이다.
///
/// - Parameters:
///   - responseItem: AKMSResponseItem. AKMSRequest를 사용해서 얻어온 측정소 정보이다.
///   - pageNo: url에서 얻어올 데이터의 pageNo이다. 한 pageNo의 최대 아이템은 numOfRows이다. pageNo가 변경되면 numOfRows * pageNo 다음 데이터들이 응답된다.
///   - numOfRows: 한 pageNo의 최대 아이템 개수이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDust(msResponseItem : AKMSResponseItem,
                        pageNo: Int,
                        numOfRows: Int,
                        serviceKey: String,
                        completionHandler: @escaping (AKMSDustResult<AKMSResponseItem>) -> Void) {
    
    requestDust(stationName: msResponseItem.stationName, pageNo: pageNo, numOfRows: numOfRows, serviceKey: serviceKey) {
        completionHandler(AKMSDustResult(input: msResponseItem,
                                         serviceKey: $0.serviceKey,
                                         pageNo: $0.pageNo,
                                         numOfRows: $0.numOfRows,
                                         requestUrl: $0.requestUrl,
                                         dataResponseRaw: $0.dataResponseRaw,
                                         response: $0.response,
                                         msPageNo: nil,
                                         msNumOfRows: nil,
                                         msResult: nil,
                                         msResponseItem: msResponseItem))
    }
    
}

/// AKMSResponse을 입력으로 미세먼지를 요청한다.
///
/// - Parameters:
///   - msResponse: AKMSResponse. AKMSRequest를 사용해서 얻어온 측정소 정보이다.
///   - pageNo: url에서 얻어올 데이터의 pageNo이다. 한 pageNo의 최대 아이템은 numOfRows이다. pageNo가 변경되면 numOfRows * pageNo 다음 데이터들이 응답된다.
///   - numOfRows: 한 pageNo의 최대 아이템 개수이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 각 측정소마다 정보를 요청해서 가져온 Array가 저장되어있다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDust(msResponse: AKMSResponse,
                        pageNo: Int,
                        numOfRows: Int,
                        serviceKey: String,
                        completionHandler: @escaping (Array<AKMSDustResult<AKMSResponse>>) -> Void) {
    
    func eachCompletionHandler(msResponse: AKMSResponse) -> (AKMSDustResult<AKMSResponse>) -> Void {
        
        let responseCount = msResponse.list.count
        var array: [AKMSDustResult<AKMSResponse>] = []
        
        return {
            array.append($0)
            
            if responseCount == array.count {
                completionHandler(array)
            }
        }
        
    }
    
    let handler = eachCompletionHandler(msResponse: msResponse)
    msResponse.list.forEach { (msResponseItem) in
        requestDust(msResponseItem: msResponseItem, pageNo: pageNo, numOfRows: numOfRows, serviceKey: serviceKey) {
            handler(AKMSDustResult(input: msResponse,
                                   serviceKey: $0.serviceKey,
                                   pageNo: $0.pageNo,
                                   numOfRows: $0.numOfRows,
                                   requestUrl: $0.requestUrl,
                                   dataResponseRaw: $0.dataResponseRaw,
                                   response: $0.response,
                                   msPageNo: nil,
                                   msNumOfRows: nil,
                                   msResult: nil,
                                   msResponseItem: $0.msResponseItem))
        }
    }
    
}

/// AKMSResponse을 입력으로 미세먼지를 요청한다.
///
/// - Parameters:
///   - response: AKMSResponse. AKMSRequest를 사용해서 얻어온 측정소 정보이다.
///   - pageNo: url에서 얻어올 데이터의 pageNo이다. 한 pageNo의 최대 아이템은 numOfRows이다. pageNo가 변경되면 numOfRows * pageNo 다음 데이터들이 응답된다.
///   - numOfRows: 한 pageNo의 최대 아이템 개수이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 미세먼지/초미세먼지 정보 유형별로 값을 채워서 반환해준다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDustItems(msResponse: AKMSResponse,
                             pageNo: Int,
                             numOfRows: Int,
                             serviceKey: String,
                             completionHandler: @escaping (AKMSDustResultItems?, Array<AKMSDustResult<AKMSResponse>>) -> Void) {
    
    requestDust(msResponse: msResponse, pageNo: pageNo, numOfRows: numOfRows, serviceKey: serviceKey) {
        
        var resultItems = AKMSDustResultItems()
        for resultItem in $0 {
            
            guard let msDustResponse = resultItem.response else {
                continue
            }
            
            guard let stationName = resultItem.msResponseItem?.stationName else {
                continue
            }
            
            //최신 시간을 최신으로 오도록 보장하기 위해. 리스트가 아주 크진 않을 것이므로 정렬
            //한국시간표기에 맞게 나오므로 그냥 단순 string 비교로 대체
            let sortedDustItems = msDustResponse.list.sorted {$0.dataTime > $1.dataTime}
            
            for dustItem in sortedDustItems {
                if resultItems.pm10ValueItem == nil {
                    if let _ = Int(dustItem.pm10Value) {
                        resultItems.pm10ValueItem = (stationName: stationName, msDustResponseItem: dustItem)
                    }
                }
                
                if resultItems.pm25ValueItem == nil {
                    if let _ = Int(dustItem.pm25Value) {
                        resultItems.pm25ValueItem = (stationName: stationName, msDustResponseItem: dustItem)
                    }
                }
                
                if resultItems.pm10Value24hItem == nil {
                    if let _ = Int(dustItem.pm10Value24) {
                        resultItems.pm10Value24hItem = (stationName: stationName, msDustResponseItem: dustItem)
                    }
                }
                
                if resultItems.pm25Value24hItem == nil {
                    if let _ = Int(dustItem.pm25Value24) {
                        resultItems.pm25Value24hItem = (stationName: stationName, msDustResponseItem: dustItem)
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
        
        completionHandler(resultItems, $0)
        
    }
    
}

/// 사용자의 위치 정보를 입력으로 미세먼지를 요청한다.
/// 사용자의 위치 주변 측정소 정보를 얻어와서 각 측정소에 미세먼지 정보를 요청한다.
///
/// - Parameters:
///   - location: 사용자의 위치 정보이다.
///   - pageNo: url에서 얻어올 데이터의 pageNo이다. 한 pageNo의 최대 아이템은 numOfRows이다. pageNo가 변경되면 numOfRows * pageNo 다음 데이터들이 응답된다.
///   - numOfRows: 한 pageNo의 최대 아이템 개수이다.
///   - msPageNo: 이 함수 내부에서 측정소 정보를 요청한다. 얻어올 측정소 정보의 퀴리의 pageNo이다. 한 pageNo의 최대 아이템은 numOfRows이다. pageNo가 변경되면 numOfRows * pageNo 다음 데이터들이 응답된다.
///   - msNumOfRows: 이 함수 내부에서 측정소 정보를 요청한다. 얻어올 측정소 정보의 퀴리의 msNumOfRows이다. 한 pageNo의 최대 아이템 개수이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 각 측정소마다 정보를 요청해서 가져온 Array가 저장되어있다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDust(location: CLLocation,
                        pageNo: Int,
                        numOfRows: Int,
                        msPageNo: Int,
                        msNumOfRows: Int,
                        serviceKey: String,
                        completionHandler: @escaping (Array<AKMSDustResult<CLLocation>>?) -> Void) {
    
    requestMS(location: location, pageNo: msPageNo, numOfRows: msNumOfRows, serviceKey: serviceKey) {
        
        (msResult) in
        
        guard let msResponseValue = msResult.response else {
            completionHandler(nil)
            return
        }
        
        requestDust(msResponse: msResponseValue, pageNo: pageNo, numOfRows: numOfRows, serviceKey: serviceKey) {
            let newArray = $0.map {
                return AKMSDustResult<CLLocation>(input: location,
                                                  serviceKey: $0.serviceKey,
                                                  pageNo: $0.pageNo,
                                                  numOfRows: $0.numOfRows,
                                                  requestUrl: $0.requestUrl,
                                                  dataResponseRaw: $0.dataResponseRaw,
                                                  response: $0.response,
                                                  msPageNo: msPageNo,
                                                  msNumOfRows: msNumOfRows,
                                                  msResult: msResult)
            }
            
            completionHandler(newArray)
        }
    }
    
}

/// 사용자의 위치 정보를 입력으로 미세먼지를 요청한다.
/// 사용자의 위치 주변 측정소 정보를 얻어와서 각 측정소에 미세먼지 정보를 요청한다.
///
/// - Parameters:
///   - location: 사용자의 위치 정보이다.
///   - pageNo: url에서 얻어올 데이터의 pageNo이다. 한 pageNo의 최대 아이템은 numOfRows이다. pageNo가 변경되면 numOfRows * pageNo 다음 데이터들이 응답된다.
///   - numOfRows: 한 pageNo의 최대 아이템 개수이다.
///   - msPageNo: 이 함수 내부에서 측정소 정보를 요청한다. 얻어올 측정소 정보의 퀴리의 pageNo이다. 한 pageNo의 최대 아이템은 numOfRows이다. pageNo가 변경되면 numOfRows * pageNo 다음 데이터들이 응답된다.
///   - msNumOfRows: 이 함수 내부에서 측정소 정보를 요청한다. 얻어올 측정소 정보의 퀴리의 msNumOfRows이다. 한 pageNo의 최대 아이템 개수이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 미세먼지/초미세먼지 정보 유형별로 값을 채워서 반환해준다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDustItems(location: CLLocation,
                             pageNo: Int,
                             numOfRows: Int,
                             msPageNo: Int,
                             msNumOfRows: Int,
                             serviceKey: String,
                             completionHandler: @escaping (AKMSDustResultItems?, Array<AKMSDustResult<CLLocation>>?) -> Void) {
    
    requestMS(location: location, pageNo: msPageNo, numOfRows: msNumOfRows, serviceKey: serviceKey) {
        
        (msResult) in
        
        guard let msResponseValue = msResult.response else {
            completionHandler(nil, nil)
            return
        }
                            
        requestDustItems(msResponse: msResponseValue, pageNo: pageNo, numOfRows: numOfRows, serviceKey: serviceKey) {
            
            let newResults = $1.map {
                return AKMSDustResult(input: location,
                                      serviceKey: $0.serviceKey,
                                      pageNo: $0.pageNo,
                                      numOfRows: $0.numOfRows,
                                      requestUrl: $0.requestUrl,
                                      dataResponseRaw: $0.dataResponseRaw,
                                      response: $0.response,
                                      msPageNo: msPageNo,
                                      msNumOfRows: msNumOfRows,
                                      msResult: msResult,
                                      msResponseItem: $0.msResponseItem)
            }
            
            completionHandler($0, newResults)
        }
    }
    
}

/// 사용자의 장소 정보를 입력으로 미세먼지를 요청한다.
/// 사용자의 장소 주변 측정소 정보를 얻어와서 각 측정소에 미세먼지 정보를 요청한다.
///
/// - Parameters:
///   - placemark: 사용자의 장소 정보이다. 한국지역에만 제공하기 때문에 내부에서 locale을 ko-kr로 변경하기 위해서 placemark 내부에서 location 정보만을 사용한다.
///   - pageNo: url에서 얻어올 데이터의 pageNo이다. 한 pageNo의 최대 아이템은 numOfRows이다. pageNo가 변경되면 numOfRows * pageNo 다음 데이터들이 응답된다.
///   - numOfRows: 한 pageNo의 최대 아이템 개수이다.
///   - msPageNo: 이 함수 내부에서 측정소 정보를 요청한다. 얻어올 측정소 정보의 퀴리의 pageNo이다. 한 pageNo의 최대 아이템은 numOfRows이다. pageNo가 변경되면 numOfRows * pageNo 다음 데이터들이 응답된다.
///   - msNumOfRows: 이 함수 내부에서 측정소 정보를 요청한다. 얻어올 측정소 정보의 퀴리의 msNumOfRows이다. 한 pageNo의 최대 아이템 개수이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 각 측정소마다 정보를 요청해서 가져온 Array가 저장되어있다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDust(placemark: CLPlacemark,
                        pageNo: Int,
                        numOfRows: Int,
                        msPageNo: Int,
                        msNumOfRows: Int,
                        serviceKey: String,
                        completionHandler: @escaping (Array<AKMSDustResult<CLPlacemark>>?) -> Void) {
    
    requestMS(placemark: placemark, pageNo: msPageNo, numOfRows: msNumOfRows, serviceKey: serviceKey) {
        msResult in
        
        guard let msResponseValue = msResult.response else {
            completionHandler(nil)
            return
        }
                
        requestDust(msResponse: msResponseValue, pageNo: pageNo, numOfRows: numOfRows, serviceKey: serviceKey) {
            let newResults = $0.map {
                return AKMSDustResult(input: placemark,
                                      serviceKey: $0.serviceKey,
                                      pageNo: $0.pageNo,
                                      numOfRows: $0.numOfRows,
                                      requestUrl: $0.requestUrl,
                                      dataResponseRaw: $0.dataResponseRaw,
                                      response: $0.response,
                                      
                                      msResult: msResult,
                                      msResponseItem: $0.msResponseItem)
            }
            
            completionHandler(newResults)
        }
    }
    
}

/// 사용자의 장소 정보를 입력으로 미세먼지를 요청한다.
/// 사용자의 장소 주변 측정소 정보를 얻어와서 각 측정소에 미세먼지 정보를 요청한다.
///
/// - Parameters:
///   - placemark: 사용자의 장소 정보이다. 한국지역에만 제공하기 때문에 내부에서 locale을 ko-kr로 변경하기 위해서 placemark 내부에서 location 정보만을 사용한다.
///   - pageNo: url에서 얻어올 데이터의 pageNo이다. 한 pageNo의 최대 아이템은 numOfRows이다. pageNo가 변경되면 numOfRows * pageNo 다음 데이터들이 응답된다.
///   - numOfRows: 한 pageNo의 최대 아이템 개수이다.
///   - msPageNo: 이 함수 내부에서 측정소 정보를 요청한다. 얻어올 측정소 정보의 퀴리의 pageNo이다. 한 pageNo의 최대 아이템은 numOfRows이다. pageNo가 변경되면 numOfRows * pageNo 다음 데이터들이 응답된다.
///   - msNumOfRows: 이 함수 내부에서 측정소 정보를 요청한다. 얻어올 측정소 정보의 퀴리의 msNumOfRows이다. 한 pageNo의 최대 아이템 개수이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 미세먼지/초미세먼지 정보 유형별로 값을 채워서 반환해준다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDustItems(placemark: CLPlacemark,
                             pageNo: Int,
                             numOfRows: Int,
                             msPageNo: Int,
                             msNumOfRows: Int,
                             serviceKey: String,
                             completionHandler: @escaping (AKMSDustResultItems?, Array<AKMSDustResult<CLPlacemark>>?) -> Void) {
    
    requestMS(placemark: placemark, pageNo: msPageNo, numOfRows: msNumOfRows, serviceKey: serviceKey) {
        (msResult) in
        
        guard let msResponseValue = msResult.response else {
            completionHandler(nil, nil)
            return
        }
                
        requestDustItems(msResponse: msResponseValue, pageNo: pageNo, numOfRows: numOfRows, serviceKey: serviceKey) {
            
            let newResults = $1.map {
                return AKMSDustResult(input: placemark,
                                      serviceKey: $0.serviceKey,
                                      pageNo: $0.pageNo,
                                      numOfRows: $0.numOfRows,
                                      requestUrl: $0.requestUrl,
                                      dataResponseRaw: $0.dataResponseRaw,
                                      response: $0.response,
                                      msPageNo: msPageNo,
                                      msNumOfRows: msNumOfRows,
                                      msResult: msResult,
                                      msResponseItem: $0.msResponseItem)
            }
            
            completionHandler($0, newResults)
            
        }
    }
    
}
