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

fileprivate func requestMSUrl(tmXString: String, tmYString: String, serviceKey: String) -> URL? {
    
    guard let urlFormatString = urlFormatString(keyName: "AKMSNearMsrStnRequestUrlFormat") else {
        return nil
    }
    
    let nearMsrStnRequestUrlString = String(format: urlFormatString, arguments:[tmXString, tmYString, serviceKey])
    let url = URL(string: nearMsrStnRequestUrlString)
    return url
}

//measurement station
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

public func requestMS(responseItem : AKTMResponseItem, serviceKey: String, completionHandler: @escaping (AKMSResponse) -> Void) {
    
    requestMS(tmXString: responseItem.tmX, tmYString: responseItem.tmY, serviceKey: serviceKey, completionHandler: completionHandler)
    
}

public func requestMS(response : AKTMResponse, serviceKey: String, completionHandler: @escaping (AKMSResponse) -> Void) {
    
    guard let first = response.first else {
        return
    }
    
    requestMS(responseItem : first, serviceKey: serviceKey, completionHandler: completionHandler)
    
}

public func requestMS(location: CLLocation, serviceKey: String, completionHandler: @escaping (AKMSResponse) -> Void) {
    
    requestTM(location: location, serviceKey: serviceKey) { requestMS(response: $0, serviceKey: serviceKey, completionHandler: completionHandler) }
    
}

public func requestMS(placemark: CLPlacemark, serviceKey: String, completionHandler: @escaping (AKMSResponse) -> Void) {
    
    requestTM(placemark: placemark, serviceKey: serviceKey) { requestMS(response: $0, serviceKey: serviceKey, completionHandler: completionHandler) }
    
}
