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
/// - Returns: 성공하면 url을 반환한다. 실패하면 nil을 반환한다.
fileprivate func requestMSUrl(tmXString: String, tmYString: String, serviceKey: String) -> URL? {
    
    guard let urlFormatString = urlFormatString(keyName: "AKMSNearMsrStnRequestUrlFormat") else {
        return nil
    }
    
    let nearMsrStnRequestUrlString = String(format: urlFormatString, arguments:[tmXString, tmYString, serviceKey])
    let url = URL(string: nearMsrStnRequestUrlString)
    return url
}

/// tm좌표를 기반으로 주변 측정소 정보를 요청한다.
///
/// - Parameters:
///   - tmXString: tm좌표 X의 문자열이다. AKTMRequest의 반환값을 바로 사용하기 위해 String으로 입력을 받는다.
///   - tmYString: tm좌표 Y의 문자열이다. AKTMRequest의 반환값을 바로 사용하기 위해 String으로 입력을 받는다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 응답받은 정보를 처리하기 위한 핸들러이다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestMS(tmXString: String, tmYString: String, serviceKey: String, completionHandler: @escaping (AKMSResponse) -> Void) {
    
    guard let url = requestMSUrl(tmXString: tmXString, tmYString: tmYString, serviceKey: serviceKey) else {
        return
    }
    
    Alamofire.request(url).responseJSON {
        
        guard let msItems = try? JSONDecoder().decode(AKMSResponse.self, from: $0.data!) else {
            return
        }
        
        completionHandler(msItems)
        
    }
    
}

/// AKTMResponseItem을 기반으로 주변 측정소 정보를 요청한다.
///
/// - Parameters:
///   - responseItem: AKTMResponseItem이다. AKTMRequest의 응답받은 결과값이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 응답받은 정보를 처리하기 위한 핸들러이다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestMS(responseItem : AKTMResponseItem, serviceKey: String, completionHandler: @escaping (AKMSResponse) -> Void) {
    
    requestMS(tmXString: responseItem.tmX, tmYString: responseItem.tmY, serviceKey: serviceKey, completionHandler: completionHandler)
    
}

/// AKTMResponse을 기반으로 주변 측정소 정보를 요청한다.
///
/// - Parameters:
///   - response: AKTMResponse이다. 내부적으로 이 중 첫번째 item만 사용한다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 응답받은 정보를 처리하기 위한 핸들러이다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestMS(response : AKTMResponse, serviceKey: String, completionHandler: @escaping (AKMSResponse) -> Void) {
    
    guard let first = response.first else {
        return
    }
    
    requestMS(responseItem : first, serviceKey: serviceKey, completionHandler: completionHandler)
    
}

/// location을 기반으로 주변 측정소 정보를 요청한다.
///
/// - Parameters:
///   - location: 사용자의 위치 정보이다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 응답받은 정보를 처리하기 위한 핸들러이다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestMS(location: CLLocation, serviceKey: String, completionHandler: @escaping (AKMSResponse) -> Void) {
    
    requestTM(location: location, serviceKey: serviceKey) { requestMS(response: $0, serviceKey: serviceKey, completionHandler: completionHandler) }
    
}

/// location을 기반으로 주변 측정소 정보를 요청한다.
///
/// - Parameters:
///   - placemark: 사용자의 장소 정보이다. 한국지역에만 제공하기 때문에 내부에서 locale을 ko-kr로 변경하기 위해서 placemark 내부에서 location 정보만을 사용한다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 응답받은 정보를 처리하기 위한 핸들러이다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestMS(placemark: CLPlacemark, serviceKey: String, completionHandler: @escaping (AKMSResponse) -> Void) {
    
    requestTM(placemark: placemark, serviceKey: serviceKey) { requestMS(response: $0, serviceKey: serviceKey, completionHandler: completionHandler) }
    
}
