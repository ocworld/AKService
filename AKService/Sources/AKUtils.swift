//
//  AKUtils.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 6. 13..
//

import Foundation


/// urlFormatString - AKService에서 사용하는 url format key를 plist에서 읽어서 반환함
///
/// - Parameter keyName: plist에 적혀있는 url의 키. url은 info.plist의 AKService의 AKUrls 하위에 있다.
/// - Returns: 성공하면 urlFormat이 반환된다. 실패하면 nil이 반환된다.
func urlFormatString(keyName: String) -> String? {
    
    guard let bundle = Bundle(identifier: "com.keunhyunoh.AKService") else {
        return nil
    }
    
    guard let infoPath = bundle.path(forResource: "Info", ofType: "plist") else {
        return nil
    }
    
    guard let info = NSDictionary(contentsOfFile: infoPath) as? Dictionary<String, Any> else {
        return nil
    }
    
    guard let urls = info["AKUrls"] as? Dictionary<String, String> else {
        return nil
    }
    
    guard let url = urls[keyName] else {
        return nil
    }
    
    return url
    
}

