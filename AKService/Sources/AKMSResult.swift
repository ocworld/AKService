//
//  AKMSResult.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 6. 23..
//

import Foundation
import Alamofire

/// 측정소 정보 요청에 대한 응답 결과이다.
public struct AKMSResult<InputType> {
    
    //데이터를 얻기위해 api 사용자가 입력으로 준 값
    public let input: InputType
    
    //서비스키이다.
    public let serviceKey: String
    
    //pageNo
    public let pageNo: Int
    
    //numOfRows
    public let numOfRows: Int
    
    //요청 URL이다. 이 값이 nil이면 요청 이전 단계(예: TM좌표 얻기)에서 실패한 것이다.
    public let requestUrl: URL?
    
    //요청 결과 응답의 alamofire data response 객체이다.
    //디버깅과 이슈 추적, 로그 남김용으로 raw data를 보존하여 넘겨준다.
    public let dataResponseRaw: Alamofire.DataResponse<Any>?
    
    //요청 결과 응답을 parsing한 값이다.
    //이 값이 nil이면 정상처리되지 않은 것이다.
    public let response: AKMSResponse?
    
    //함수 내부에서 TM좌표를 요청을 했을 경우만 정보를 포함한다. location이다 placemark를 통해 데이터를 얻을때가 이에 해당한다.
    //TM좌표 요청에 대한 결과이다. tracking을 위해 저장하여 반환한다.
    public let tmResult: AKTMResult<InputType>?
    
    public init(input: InputType,
                serviceKey: String,
                pageNo: Int,
                numOfRows: Int,
                requestUrl: URL? = nil,
                dataResponseRaw: Alamofire.DataResponse<Any>? = nil,
                response: AKMSResponse? = nil,
                tmResult: AKTMResult<InputType>? = nil) {
        
        self.input = input
        self.serviceKey = serviceKey
        self.pageNo = pageNo
        self.numOfRows = numOfRows
        self.response = response
        self.dataResponseRaw = dataResponseRaw
        self.requestUrl = requestUrl
        self.tmResult = tmResult
    }
}
