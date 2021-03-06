//
//  APIURL.swift
//  NetflixClone
//
//  Created by 양중창 on 2020/03/31.
//  Copyright © 2020 Netflex. All rights reserved.
//

import Foundation

typealias PathItem = (name: String, value: String?)

enum APIURL: String {
    case defaultURL = "https://www.netflexx.ga"
    
    case signUp = "https://www.netflexx.ga/members"
    case logIn = "https://www.netflexx.ga/members/auth_token"
    case logOut = "https://www.netflexx.ga/members/logout"
    
    case iconList = "https://www.netflexx.ga/members/profiles/icons"
    case makeProfile = "https://www.netflexx.ga/members/profiles"
   
    
    func makeURL(pathItems: [PathItem] = [], queryItems: [URLQueryItem]? = nil) -> URL? {
        let urlString = self.rawValue
        var pathItem = pathItems.reduce("", { (before, next) in
            var value = ""
            
            if let unrappingValue = next.value {
                value = "/" + unrappingValue
            }
            return before + "/" + next.name + value
        })
        
        pathItem += queryItems == nil ? "/": ""
        guard var urlComponents = URLComponents(string: urlString + pathItem) else { return nil }
        urlComponents.queryItems = queryItems
        
        
        return urlComponents.url
    }
}
