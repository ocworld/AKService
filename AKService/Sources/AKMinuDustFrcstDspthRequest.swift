//
//  AKMinuDustFrcstDspthRequest.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 6. 17..
//

import Foundation
import Alamofire

/// 미세먼지 데이터 예측 url을 반환한다.
///
/// - Parameters:
///   - date: 요청 기준 date이다. 내부적으로 ko-kr locale로 지정해서 요청한다. 한국날짜로 예보정보를 가져온다.
///   - informCode: PM10과 PM25 중 어떤 값을 예보하는지 값을 가져온다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
/// - Returns: 성공하면 url을 반환한다. 실패하면 nil을 반환한다.
fileprivate func requestDustFrcstUrl(date: Date, informCode: AKMinuDustFrcstDspthInformCode, serviceKey: String) -> URL? {
    
    guard let urlFormatString = urlFormatString(keyName: "AKMinuDustFrcstDspth") else {
        return nil
    }
    
    let dateFormat = DateFormatter()
    dateFormat.locale = Locale(identifier: "Ko-kr")
    dateFormat.dateFormat = "yyyy-MM-dd"
    let dateString = dateFormat.string(from: date)
    
    let requestDustFrcsUrlString = String(format: urlFormatString,
                                          arguments:[dateString, informCode.rawValue, serviceKey])

    let url = URL(string: requestDustFrcsUrlString)
    return url
}

/// 미세먼지 데이터 예측 데이터를 요청한다.
///
/// - Parameters:
///   - date: 요청 기준 date이다. 내부적으로 ko-kr locale로 지정해서 요청한다. 한국날짜로 예보정보를 가져온다.
///   - informCode: PM10과 PM25 중 어떤 값을 예보하는지 값을 가져온다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDustFrcst(date: Date, informCode: AKMinuDustFrcstDspthInformCode, serviceKey: String, completionHandler: @escaping (AKMinuDustFrcstDspthInformCode, AKMinuDustFrcstDspthResponse?) -> Void) {
    
    guard let url = requestDustFrcstUrl(date: date, informCode: informCode, serviceKey: serviceKey) else {
                                    return
    }
    
    Alamofire.request(url).responseJSON {
        
        guard let data = $0.data else {
            completionHandler(informCode, nil)
            return
        }
        
        guard let response = try? JSONDecoder().decode(AKMinuDustFrcstDspthResponse.self, from: data) else {
            completionHandler(informCode, nil)
            return
        }
        
        completionHandler(informCode, response)
        
    }
}

/// 미세먼지 데이터 예측 데이터를 요청한다. PM25와 PM10 데이터를 같이 요청한다.
///
/// - Parameters:
///   - date: 요청 기준 date이다. 내부적으로 ko-kr locale로 지정해서 요청한다. 한국날짜로 예보정보를 가져온다.
///   - informCode: PM10과 PM25 중 어떤 값을 예보하는지 값을 가져온다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDustFrcst(date: Date, serviceKey: String,
                        completionHandler: @escaping (Dictionary<AKMinuDustFrcstDspthInformCode, AKMinuDustFrcstDspthResponse?>) -> Void) {
    
    func eachCompletionHandler() -> ((AKMinuDustFrcstDspthInformCode, AKMinuDustFrcstDspthResponse?) -> Void) {
        
        var dictionary: [AKMinuDustFrcstDspthInformCode : AKMinuDustFrcstDspthResponse?] = [:]
        
        return { (informCode, response) in
            
            dictionary.updateValue(response, forKey: informCode)
            
            if dictionary.keys.contains(.PM25) && dictionary.keys.contains(.PM10) {
                completionHandler(dictionary)
            }
        }
        
    }
    
    let handler = eachCompletionHandler()
    let informCodeArray : [AKMinuDustFrcstDspthInformCode] = [.PM25, .PM10]
    informCodeArray.forEach {
        requestDustFrcst(date: date, informCode: $0, serviceKey: serviceKey, completionHandler: handler)
    }
    
}
