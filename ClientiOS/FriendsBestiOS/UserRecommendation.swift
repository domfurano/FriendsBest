//
//  NewRecommendation.swift
//  FriendsBest
//
//  Created by Dominic Furano on 4/11/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//


class UserRecommendation {
    var tags: [String]?
    var detail: String?
    var comments: String?
    var type: RecommendationType?
    
    func clear() {
        tags = nil
        detail = nil
        comments = nil
        type = nil
    }
}
