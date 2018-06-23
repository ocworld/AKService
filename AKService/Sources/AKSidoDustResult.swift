//
//  AKSidoDustResult
//  AKService
//
//  Created by Keunhyun Oh on 2018. 6. 23.
//

import Foundation
import Alamofire

public struct AKSidoDustResult<InputType> {
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
    public let response: AKSidoDustResponse?
    
    //시도 하위의 시군 이름이다. City계열 함수를 사용했을때만 값을 포함한다.
    public let cityName: String?
    
    //시도 하위의 시군의 데이터이다. City계열 함수를 사용했을때만 값을 포함한다.
    public let cityResponseItem: AKSidoDustResponseItem?
    
    public init(input: InputType,
                serviceKey: String,
                pageNo: Int,
                numOfRows: Int,
                requestUrl: URL? = nil,
                dataResponseRaw: Alamofire.DataResponse<Any>? = nil,
                response: AKSidoDustResponse? = nil,
                cityName: String? = nil,
                cityResponseItem: AKSidoDustResponseItem? = nil) {
        
        self.input = input
        self.serviceKey = serviceKey
        self.pageNo = pageNo
        self.numOfRows = numOfRows
        self.requestUrl = requestUrl
        self.dataResponseRaw = dataResponseRaw
        self.response = response
        self.cityName = cityName
        self.cityResponseItem = cityResponseItem

    }
}
