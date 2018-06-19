//
//  AKMinuDustFrcstDspthResponseItem.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 6. 17..
//

import Foundation
import Alamofire
import AlamofireImage

/// 미세먼지 예보 정보 요청에 대한 응답의 항목이다.
public struct AKMinuDustFrcstDspthResponseItem : Codable {
    
    public var _returnType : String
    public var actionKnack : String
    public var dataTime : String
    public var f_data_time : String
    public var f_data_time1 : String
    public var f_data_time2 : String
    public var f_data_time3 : String
    public var f_inform_data : String
    public var imageUrl1: String
    public var imageUrl2: String
    public var imageUrl3: String
    public var imageUrl4: String
    public var imageUrl5: String
    public var imageUrl6: String
    public var imageUrl7: String
    public var imageUrl8: String
    public var imageUrl9: String
    public var informCause: String
    public var informCode: String
    public var informData: String
    public var informGrade: String
    public var informOverall: String
    public var numOfRows: String
    public var pageNo: String
    public var resultCode: String
    public var resultMsg: String
    public var searchDate: String
    public var serviceKey: String
    public var totalCount: String
    public var ver: String
    
}

/// 이미지 url에 대한 기능
extension AKMinuDustFrcstDspthResponseItem {
    
    /// 응답에 포한된 image url을 반환한다. 형식상 유효한 URL만 반환한다.
    public var imageURLs : [URL] {
        return [imageUrl1, imageUrl2, imageUrl3, imageUrl4, imageUrl5, imageUrl6, imageUrl7, imageUrl8, imageUrl9].compactMap{ URL(string: $0) }
    }
    
    
    /// 응답에 포함된 image url의 이미지를 다운로드 받는다.
    ///
    /// - Parameter completionHandler: 다운로드 받은 UIImage를 반환한다. main queue에서 동작하지 않고 별도 queue에서 동작한다.
    public func requestImages(completionHandler: @escaping ([UIImage]) -> Void) {
        
        func eachCompletionHandler(totalCount: Int) -> ((DataResponse<Image>) -> Void) {
            
            var responses : [DataResponse<Image>] = []
            
            return {
                responses.append($0)
                if responses.count >= totalCount {
                    completionHandler(responses.compactMap { $0.result.value })
                }
            }
            
        }
        
        let imageURLCaches = imageURLs
        let handler = eachCompletionHandler(totalCount: imageURLCaches.count)
        
        imageURLCaches.forEach { Alamofire.request($0).responseImage{ handler($0) } }
    }
    
}

/// informGrade에 대한 기능
extension AKMinuDustFrcstDspthResponseItem {
    
    public var informGradeDictionary : [String : String] {
        
        return informGrade.components(separatedBy: ",")
            .map({$0.components(separatedBy: ":")})
            .reduce(Dictionary<String, String>()) { (result, stringArray) in
                guard stringArray.count >= 2 else {
                    return result
                }
                
                let key = stringArray[0].trimmingCharacters(in: .whitespaces)
                let value = stringArray[1].trimmingCharacters(in: .whitespaces)
                
                var newResult = result
                newResult[key] = value
                
                return newResult
            }
        
    }
    
}
