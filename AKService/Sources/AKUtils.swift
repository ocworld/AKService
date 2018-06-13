//
//  AKUtils.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 6. 13..
//

import Foundation

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

