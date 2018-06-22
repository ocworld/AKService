//
//  AKMSRequest.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 4. 15..
//  Copyright © 2018년 Keunhyun Oh. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation

/// tm좌표를 기반으로 주변 측정소 정보를 요청하는 url을 반환한다.
///
/// - Parameters:
///   - tmXString: tm좌표 X의 문자열이다. AKTMRequest의 반환값을 바로 사용하기 위해 String으로 입력을 받는다.
///   - tmYString: tm좌표 Y의 문자열이다. AKTMRequest의 반환값을 바로 사용하기 위해 String으로 입력을 받는다.
///   - pageNo: url에서 얻어올 데이터의 pageNo이다. 한 pageNo의 최대 아이템은 numOfRows이다. pageNo가 변경되면 numOfRows * pageNo 다음 데이터들이 응답된다.
///   - numOfRows: 한 pageNo의 최대 아이템 개수이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
/// - Returns: 성공하면 url을 반환한다. 실패하면 nil을 반환한다.
fileprivate func requestMSUrl(tmXString: String,
                              tmYString: String,
                              pageNo: Int,
                              numOfRows: Int,
                              serviceKey: String) -> URL? {
    
    guard let urlFormatString = urlFormatString(keyName: "AKMSNearMsrStnRequestUrlFormat") else {
        return nil
    }
    
    let nearMsrStnRequestUrlString = String(format: urlFormatString,
                                            arguments:[tmXString,
                                                       tmYString,
                                                       String(pageNo),
                                                       String(numOfRows),
                                                       serviceKey])
    let url = URL(string: nearMsrStnRequestUrlString)
    return url
}

/// tm좌표를 기반으로 주변 측정소 정보를 요청한다.
///
/// - Parameters:
///   - tmXString: tm좌표 X의 문자열이다. AKTMRequest의 반환값을 바로 사용하기 위해 String으로 입력을 받는다.
///   - tmYString: tm좌표 Y의 문자열이다. AKTMRequest의 반환값을 바로 사용하기 위해 String으로 입력을 받는다.
///   - pageNo: url에서 얻어올 데이터의 pageNo이다. 한 pageNo의 최대 아이템은 numOfRows이다. pageNo가 변경되면 numOfRows * pageNo 다음 데이터들이 응답된다.
///   - numOfRows: 한 pageNo의 최대 아이템 개수이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 응답받은 정보를 처리하기 위한 핸들러이다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestMS(tmXString: String,
                      tmYString: String,
                      pageNo: Int,
                      numOfRows: Int,
                      serviceKey: String,
                      completionHandler: @escaping (String, String, AKMSResponse?, Alamofire.DataResponse<Any>) -> Void) {
    
    guard let url = requestMSUrl(tmXString: tmXString,
                                 tmYString: tmYString,
                                 pageNo: pageNo,
                                 numOfRows: numOfRows,
                                 serviceKey: serviceKey) else {
        return
    }
    
    Alamofire.request(url).responseJSON {
        
        guard let data = $0.data else {
            completionHandler(tmXString, tmYString, nil, $0)
            return
        }
        
        guard let msItems = try? JSONDecoder().decode(AKMSResponse.self, from: data) else {
            completionHandler(tmXString, tmYString, nil, $0)
            return
        }
        
        completionHandler(tmXString, tmYString, msItems, $0)
        
    }
    
}

/// AKTMResponseItem을 기반으로 주변 측정소 정보를 요청한다.
///
/// - Parameters:
///   - responseItem: AKTMResponseItem이다. AKTMRequest의 응답받은 결과값이다.
///   - pageNo: url에서 얻어올 데이터의 pageNo이다. 한 pageNo의 최대 아이템은 numOfRows이다. pageNo가 변경되면 numOfRows * pageNo 다음 데이터들이 응답된다.
///   - numOfRows: 한 pageNo의 최대 아이템 개수이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 응답받은 정보를 처리하기 위한 핸들러이다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestMS(responseItem : AKTMResponseItem,
                      pageNo: Int,
                      numOfRows: Int,
                      serviceKey: String,
                      completionHandler: @escaping (AKTMResponseItem, AKMSResponse?, Alamofire.DataResponse<Any>) -> Void) {
    
    requestMS(tmXString: responseItem.tmX, tmYString: responseItem.tmY, pageNo: pageNo, numOfRows: numOfRows, serviceKey: serviceKey) { (_, _, response, dataResponse) in completionHandler(responseItem, response, dataResponse) }
    
}

/// AKTMResponse을 기반으로 주변 측정소 정보를 요청한다.
///
/// - Parameters:
///   - response: AKTMResponse이다. 내부적으로 이 중 첫번째 item만 사용한다.
///   - pageNo: url에서 얻어올 데이터의 pageNo이다. 한 pageNo의 최대 아이템은 numOfRows이다. pageNo가 변경되면 numOfRows * pageNo 다음 데이터들이 응답된다.
///   - numOfRows: 한 pageNo의 최대 아이템 개수이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 응답받은 정보를 처리하기 위한 핸들러이다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestMS(tmResponse : AKTMResponse,
                      pageNo: Int,
                      numOfRows: Int,
                      serviceKey: String,
                      completionHandler: @escaping (AKTMResponse, AKMSResponse?, Alamofire.DataResponse<Any>?) -> Void) {
    
    guard let first = tmResponse.first else {
        completionHandler(tmResponse, nil, nil)
        return
    }
    
    requestMS(responseItem : first, pageNo: pageNo, numOfRows: numOfRows, serviceKey: serviceKey) {
        (_, response, dateResponse) in completionHandler(tmResponse, response, dateResponse)
    }
    
}

/// location을 기반으로 주변 측정소 정보를 요청한다.
///
/// - Parameters:
///   - location: 사용자의 위치 정보이다.
///   - pageNo: url에서 얻어올 데이터의 pageNo이다. 한 pageNo의 최대 아이템은 numOfRows이다. pageNo가 변경되면 numOfRows * pageNo 다음 데이터들이 응답된다.
///   - numOfRows: 한 pageNo의 최대 아이템 개수이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 응답받은 정보를 처리하기 위한 핸들러이다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestMS(location: CLLocation,
                      pageNo: Int,
                      numOfRows: Int,
                      serviceKey: String,
                      completionHandler: @escaping (CLLocation, AKMSResponse?, Alamofire.DataResponse<Any>?) -> Void) {
    
    requestTM(location: location, serviceKey: serviceKey) { (location, tmResponse, _) in
        
        guard let tmResponseValue = tmResponse else {
            completionHandler(location, nil, nil)
            return
        }
        
        requestMS(tmResponse: tmResponseValue, pageNo: pageNo, numOfRows: numOfRows, serviceKey: serviceKey) {
            (_, response, dataResponse) in
            completionHandler(location, response, dataResponse)
        }
    }
    
}

/// location을 기반으로 주변 측정소 정보를 요청한다.
///
/// - Parameters:
///   - placemark: 사용자의 장소 정보이다. 한국지역에만 제공하기 때문에 내부에서 locale을 ko-kr로 변경하기 위해서 placemark 내부에서 location 정보만을 사용한다.
///   - pageNo: url에서 얻어올 데이터의 pageNo이다. 한 pageNo의 최대 아이템은 numOfRows이다. pageNo가 변경되면 numOfRows * pageNo 다음 데이터들이 응답된다.
///   - numOfRows: 한 pageNo의 최대 아이템 개수이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 응답받은 정보를 처리하기 위한 핸들러이다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestMS(placemark: CLPlacemark,
                      pageNo: Int,
                      numOfRows: Int,
                      serviceKey: String,
                      completionHandler: @escaping (CLPlacemark, AKMSResponse?, Alamofire.DataResponse<Any>?) -> Void) {
    
    requestTM(placemark: placemark, serviceKey: serviceKey) {
        (placemark, tmResponse, tmDataResponse) in
        
        guard let tmResponseValue = tmResponse else {
            completionHandler(placemark, nil, nil)
            return
        }
        
        requestMS(tmResponse: tmResponseValue, pageNo: pageNo, numOfRows: numOfRows, serviceKey: serviceKey) {
            (_, response, DataResponse) in
            completionHandler(placemark, response, DataResponse)
        }
    }
    
}
