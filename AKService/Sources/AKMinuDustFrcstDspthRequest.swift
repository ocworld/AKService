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
public func requestDustFrcst(date: Date, informCode: AKMinuDustFrcstDspthInformCode, serviceKey: String, completionHandler: @escaping (Date, AKMinuDustFrcstDspthInformCode, AKMinuDustFrcstDspthResponse?, Alamofire.DataResponse<Any>) -> Void) {
    
    guard let url = requestDustFrcstUrl(date: date, informCode: informCode, serviceKey: serviceKey) else {
                                    return
    }
    
    Alamofire.request(url).responseJSON {
        
        guard let data = $0.data else {
            completionHandler(date, informCode, nil, $0)
            return
        }
        
        guard let response = try? JSONDecoder().decode(AKMinuDustFrcstDspthResponse.self, from: data) else {
            completionHandler(date, informCode, nil, $0)
            return
        }
        
        completionHandler(date, informCode, response, $0)
        
    }
}

/// 미세먼지 데이터 예측 데이터를 요청한다. PM25와 PM10 데이터를 같이 요청한다.
/// 요청하는 날짜의 예보 정보가 업데이트되지 않았을 경우 list에 정보가 없을 수 있다.
///
/// - Parameters:
///   - date: 요청 기준 date이다. 내부적으로 ko-kr locale로 지정해서 요청한다. 한국날짜로 예보정보를 가져온다.
///   - informCode: PM10과 PM25 중 어떤 값을 예보하는지 값을 가져온다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDustFrcst(date: Date, serviceKey: String,
                        completionHandler: @escaping (Date, Dictionary<AKMinuDustFrcstDspthInformCode, AKMinuDustFrcstDspthResponse?>) -> Void) {
    
    func eachCompletionHandler() -> ((AKMinuDustFrcstDspthInformCode, AKMinuDustFrcstDspthResponse?) -> Void) {
        
        var dictionary: [AKMinuDustFrcstDspthInformCode : AKMinuDustFrcstDspthResponse?] = [:]
        
        return { (informCode, response) in
            
            dictionary.updateValue(response, forKey: informCode)
            
            if dictionary.keys.contains(.PM25) && dictionary.keys.contains(.PM10) {
                completionHandler(date, dictionary)
            }
        }
        
    }
    
    let handler = eachCompletionHandler()
    let informCodeArray : [AKMinuDustFrcstDspthInformCode] = [.PM25, .PM10]
    informCodeArray.forEach {
        requestDustFrcst(date: date, informCode: $0, serviceKey: serviceKey) {
            (_, informCode, response, _)  in handler(informCode, response)
        }
    }
    
}

/// 미세먼지 데이터 예측 데이터를 요청한다. 기준 날짜는 오늘이다.
/// 요청하는 날짜의 예보 정보가 업데이트되지 않았을 경우 list에 정보가 없을 수 있다. 이때는 어제 데이터를 요청해서 가져온다.
/// 어제 데이터까지 없을 경우에는 비어있는 상태(nil)로 반환한다.
///
/// - Parameters:
///   - informCode: PM10과 PM25 중 어떤 값을 예보하는지 값을 가져온다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDustFrcst(informCode: AKMinuDustFrcstDspthInformCode, serviceKey: String, completionHandler: @escaping (Date, AKMinuDustFrcstDspthInformCode, AKMinuDustFrcstDspthResponse?, Alamofire.DataResponse<Any>) -> Void) {
    
    requestDustFrcst(date: Date(), informCode: informCode, serviceKey: serviceKey) {
        (date, informCode, response, _) in
        
        if response == nil || response!.list.isEmpty {
            let yesterdayDate = date - 86400 //(1 * 60 * 60 * 24)
            requestDustFrcst(date: yesterdayDate, informCode: informCode, serviceKey: serviceKey, completionHandler: completionHandler)
        }
        
    }
    
}

/// 미세먼지 데이터 예측 데이터를 요청한다. PM25와 PM10 데이터를 같이 요청한다.
/// 요청하는 날짜의 예보 정보가 업데이트되지 않았을 경우 list에 정보가 없을 수 있다. 이때는 어제 데이터를 요청해서 가져온다.
///
/// - Parameters:
///   - informCode: PM10과 PM25 중 어떤 값을 예보하는지 값을 가져온다.
///   - serviceKey: API 호출을 위해 사용하는 service key이다. airkorea에서 발급받아야한다.
///   - completionHandler: 호출 결과를 처리하기 위한 핸들러이다. 메인큐가 아닌 별도 큐에서 동작한다.
public func requestDustFrcst(serviceKey: String,
                             completionHandler: @escaping (Date, Dictionary<AKMinuDustFrcstDspthInformCode, AKMinuDustFrcstDspthResponse?>) -> Void) {
    
    requestDustFrcst(date: Date(), serviceKey: serviceKey, completionHandler: completionHandler)
    
}
