//
//  AKMinuDustFcstResult.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 6. 23..
//

import Foundation
import Alamofire

/// 미세먼지 예측 정보의 결과값이다.
public struct AKMinuDustFcstResult<InputType> {
    
    //데이터를 얻기위해 api 사용자가 입력으로 준 값
    public let input: InputType
    
    //PM25인지 PM10인지에 대한 정보이다.
    public let informCode: AKMinuDustFrcstDspthInformCode
    
    //서비스키이다.
    public let serviceKey: String
    
    //요청 URL이다.
    public let requestUrl: URL
    
    //요청 결과 응답의 alamofire data response 객체이다.
    //디버깅과 이슈 추적, 로그 남김용으로 raw data를 보존하여 넘겨준다.
    public let dataResponseRaw: Alamofire.DataResponse<Any>
    
    //요청 결과 응답을 parsing한 값이다.
    //이 값이 nil이면 정상처리되지 않은 것이다.
    public let response: AKMinuDustFrcstDspthResponse?
    
    public init(input: InputType,
                informCode: AKMinuDustFrcstDspthInformCode,
                serviceKey: String,
                requestUrl: URL,
                dataResponseRaw: Alamofire.DataResponse<Any>,
                response: AKMinuDustFrcstDspthResponse? = nil) {
        self.input = input
        self.informCode = informCode
        self.serviceKey = serviceKey
        self.requestUrl = requestUrl
        self.dataResponseRaw = dataResponseRaw
        self.response = response
    }
}
