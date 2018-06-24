//
//  GitFeedEvent.swift
//  GithubFeed
//
//  Created by Sameer Khavanekar on 6/24/18.
//  Copyright © 2018 Sameer Khavanekar. All rights reserved.
//

import Foundation
import ObjectMapper


class Actor: Mappable {
    var name: String!
    var url: String!
    
    var imageURL: URL {
        return URL(string: url)!
    }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        name <- map["name"]
        url <- map["url"]
    }
}

class GitFeedEvent: Mappable {
    var repo: String!
    var action: String!
    var actor: Actor!
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        repo <- map["name"]
        actor <- map["actor"]
        action <- map["type"]
    }
    
}
