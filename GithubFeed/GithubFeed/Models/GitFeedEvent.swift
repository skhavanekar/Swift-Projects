//
//  GitFeedEvent.swift
//  GithubFeed
//
//  Created by Sameer Khavanekar on 6/24/18.
//  Copyright © 2018 Sameer Khavanekar. All rights reserved.
//

import Foundation
import ObjectMapper

class Repo: Mappable {
    var id: String!
    var name: String!
    var url: String!
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        url <- map["url"]
    }
}

class Actor: Mappable {
    var name: String!
    var url: String!
    
    var imageURL: URL {
        return URL(string: url)!
    }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        name <- map["display_login"]
        url <- map["avatar_url"]
    }
}

class GitFeedEvent: Mappable {
    var repo: Repo!
    var action: String!
    var actor: Actor!
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        repo <- map["repo"]
        actor <- map["actor"]
        action <- map["type"]
    }
    
}
