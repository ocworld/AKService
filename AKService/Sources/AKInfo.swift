//
//  AKInfo.swift
//  AKService
//
//  Created by Keunhyun Oh on 2018. 7. 1..
//  Copyright © 2018년 Keunhyun Oh. All rights reserved.
//

import Foundation

fileprivate let AKBundleIdentifier = "org.cocoapods.AKService"
fileprivate let AKInfoPlistName = "AKInfo"

struct AKInfo: Codable {
    var AKSidoLongToShowDictionary: [String : String]
    var AKUrls: [String : String]
}

extension AKInfo {
    
    var AKMinuDustFrcstDspthUrlFormat: String? {
        return AKUrls["AKMinuDustFrcstDspthUrlFormat"]
    }
    
    var AKMSDustRequestUrlFormat: String? {
        return AKUrls["AKMSDustRequestUrlFormat"]
    }
    
    var AKMSNearMsrStnRequestUrlFormat: String? {
        return AKUrls["AKMSNearMsrStnRequestUrlFormat"]
    }
    
    var AKSidoDustRequestUrlFormat: String? {
        return AKUrls["AKSidoDustRequestUrlFormat"]
    }
    
    var AKTMRequestUrlFormat: String? {
        return AKUrls["AKTMRequestUrlFormat"]
    }
    
}

extension AKInfo {
    
    static let `default` : AKInfo = {
        guard let bundle = Bundle(identifier: AKBundleIdentifier) else {
            return AKInfo(AKSidoLongToShowDictionary: [:], AKUrls: [:])
        }
        
        guard let infoUrl = bundle.url(forResource: AKInfoPlistName, withExtension: "plist") else {
            return AKInfo(AKSidoLongToShowDictionary: [:], AKUrls: [:])
        }
        
        guard let data = try? Data(contentsOf: infoUrl) else {
            return AKInfo(AKSidoLongToShowDictionary: [:], AKUrls: [:])
        }
        
        let decoder = PropertyListDecoder()
        guard let akInfo = try? decoder.decode(AKInfo.self, from: data) else {
            return AKInfo(AKSidoLongToShowDictionary: [:], AKUrls: [:])
        }
        
        return akInfo
    }()
    
}
