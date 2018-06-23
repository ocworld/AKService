//
//  AKMSDustResult.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 6. 23..
//

import Foundation
import Alamofire

/// 미세먼지 정보 요청에 대한 응답 결과이다.
public struct AKMSDustResult<InputType> {
    
    //데이터를 얻기위해 api 사용자가 입력으로 준 값이다.
    public let input: InputType
    
    //서비스키이다.
    public let serviceKey: String

    //pageNo
    public let pageNo: Int
    
    //numOfRows
    public let numOfRows: Int
    
    //요청 URL이다. 이 값이 nil이면 요청 이전 단계(예: 측정소 정보 얻기)에서 실패한 것이다.
    public let requestUrl: URL?
    
    //요청 결과 응답의 alamofire data response 객체이다.
    //디버깅과 이슈 추적, 로그 남김용으로 raw data를 보존하여 넘겨준다.
    public let dataResponseRaw: Alamofire.DataResponse<Any>?
    
    //요청 결과 응답을 parsing한 값이다.
    //이 값이 nil이면 정상처리되지 않은 것이다.
    public let response: AKMSDustResponse?  //parsing된 값. 이 값이 nil이면 정상처리되지 않은 것이다.
    
    //함수 내부에서 측정소 정보 요청을 했을 경우만 정보를 포함한다. location이다 placemark를 통해 데이터를 얻을때가 이에 해당한다.
    //측정소 정보 요청의 pageNo이다. msResult에도 포함되어있지만 쉽게 접근할 수 있도록 별도로 저장한다.
    public let msPageNo: Int?
    
    //함수 내부에서 측정소 정보 요청을 했을 경우만 정보를 포함한다. location이다 placemark를 통해 데이터를 얻을때가 이에 해당한다.
    //측정소 정보 요청의 msNumOfRows이다. msResult에도 포함되어있지만 쉽게 접근할 수 있도록 별도로 저장한다.
    public let msNumOfRows: Int?
    
    //함수 내부에서 측정소 정보 요청을 했을 경우만 정보를 포함한다. location이다 placemark를 통해 데이터를 얻을때가 이에 해당한다.
    //측정소 정보 요청에 대한 결과이다. tracking을 위해 저장하여 반환한다.
    public let msResult: AKMSResult<InputType>?
    
    //어떤 측정소 정보에서 데이터를 가져왔는지에 대해 저장하고 있다.
    //사용 함수에 따라 정보가 포함되어있을 수도 있고 아닐수도 있다.
    public let msResponseItem: AKMSResponseItem?
    
    public init(input: InputType,
                serviceKey: String,
                pageNo: Int,
                numOfRows: Int,
                requestUrl: URL? = nil,
                dataResponseRaw: Alamofire.DataResponse<Any>? = nil,
                response: AKMSDustResponse? = nil,
                msPageNo: Int? = nil,
                msNumOfRows: Int? = nil,
                msResult: AKMSResult<InputType>? = nil,
                msResponseItem: AKMSResponseItem? = nil) {
        
        self.input = input
        self.serviceKey = serviceKey
        self.pageNo = pageNo
        self.numOfRows = numOfRows
        self.response = response
        self.dataResponseRaw = dataResponseRaw
        self.requestUrl = requestUrl
        self.msPageNo = msPageNo
        self.msNumOfRows = msNumOfRows
        self.msResult = msResult
        self.msResponseItem = msResponseItem
        
    }
}
