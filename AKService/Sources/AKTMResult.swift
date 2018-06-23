//
//  AKTMResult.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 6. 17..
//

import Foundation
import Alamofire

public struct AKTMResult<InputType> {
    public let input: InputType         //데이터를 얻기위해 api 사용자가 입력으로 준 값
    public let serviceKey: String
    public let requestUrl: URL?
    public let dataResponseRaw: Alamofire.DataResponse<Any>?
    public let response: AKTMResponse?  //parsing된 값. 이 값이 nil이면 정상처리되지 않은 것이다.
    
    public init(input: InputType,
                serviceKey: String,
                requestUrl: URL? = nil,
                dataResponseRaw: Alamofire.DataResponse<Any>? = nil,
                response: AKTMResponse? = nil) {
        
        self.input = input
        self.serviceKey = serviceKey
        self.requestUrl = requestUrl
        self.dataResponseRaw = dataResponseRaw
        self.response = response
    }
}
