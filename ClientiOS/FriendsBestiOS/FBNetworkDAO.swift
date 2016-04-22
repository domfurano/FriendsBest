//
//  NetworkDataModel.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 1/12/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import Foundation
import CoreData
import FBSDKLoginKit
import FBSDKCoreKit


protocol NetworkDAODelegate: class {
    func queriesFetched()
    func querySolutionsFetched(forQueryID queryID: Int)
    func newQueryFetched(queryID: Int)
    func promptsFetched()
    func userRecommendationsFetched()
    func friendsFetched(friends: [Friend])
}


class FBNetworkDAO {
    
    /* Singleton instance */
    static let instance: FBNetworkDAO = FBNetworkDAO()
    
    /* Instance members */
//    private let friendsBestAPIurl: NSURL! = NSURL(string: "http://localhost:8000/fb/api/")
    private let friendsBestAPIurl: NSURL! = NSURL(string: "https://www.friendsbest.net/fb/api/")
    
    private var friendsBestToken: String? = nil
    
    /* Delegation */
    weak var networkDAODelegate: NetworkDAODelegate? = nil
    
    var authenticatedWithFriendsBestServerDelegate: () -> Void = {}
    
    
    /* Private constructor */
    private init() { }
    
    
    func getQueries(callback: (() -> Void)?) {
        NetworkQueue.instance.enqueue(NetworkTask(task: {
            [weak self] () -> Void in
            self?._getQueries(callback)
            }, description: "getQueries()"))
    }
    
    private func _getQueries(callback: (() -> Void)?) {
        guard let token = self.friendsBestToken else {
            postFacebookTokenAndAuthenticate(nil)
            NetworkQueue.instance.tryAgain()
            NSLog("User has not authenticated")
            return
        }
        
        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = ["Authorization": token]
        let session: NSURLSession = NSURLSession(configuration: configuration)
        
        let queryString: String = "query/"
        let queryURL: NSURL? = NSURL(string: queryString, relativeToURL: friendsBestAPIurl)
        
        guard let validQueryURL = queryURL else {
            NSLog("Error - FriendsBest API - getQueries() - Bad query URL")
            return
        }
        
        session.dataTaskWithURL(validQueryURL,
                                completionHandler: {
                                    [weak self] (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                                    
                                    if let error = error {
                                        NetworkQueue.instance.tryAgain()
                                        NSLog("Error - FriendsBest API - getQueries() - \(error)")
                                        return
                                    }
                                    
                                    if !FBNetworkDAO.instance.responseHasExpectedStatusCode(response, expectedStatusCodes: [200], funcName: "getQueries") {
                                        NetworkQueue.instance.tryAgain()
                                        return
                                    }
                                    
                                    guard let queriesArray: NSArray = FBNetworkDAO.getNSArrayFromJSONdata(data, funcName: "getQueries") else {
                                        NetworkQueue.instance.tryAgain()
                                        return
                                    }
                                    
                                    var queries: [Query] = []
                                    
                                    for queryDict in queriesArray {
                                        guard let validQueryDict: NSDictionary = queryDict as? NSDictionary else {
                                            NetworkQueue.instance.tryAgain()
                                            NSLog("Error - FriendsBest API - getQueries - Invalid JSON object")
                                            return
                                        }
                                        
                                        let tags: [String]? = validQueryDict["tags"] as? [String]
                                        let tagHash: String? = validQueryDict["taghash"] as? String
                                        let tagString: String? = validQueryDict["tagstring"] as? String
                                        let id: Int? = validQueryDict["id"] as? Int
                                        let timestampString: String? = validQueryDict["accessed"] as? String
                                        
                                        guard let validTags = tags,
                                            let validTagHash = tagHash,
                                            let validTagString = tagString,
                                            let validId = id,
                                            let validTimestampString = timestampString,
                                            let validTimestamp: NSDate = self!.convertTimestampStringToNSDate(validTimestampString) else {
                                                NSLog("Error - FriendsBest API - getQueries() - Invalid JSON")
                                                NetworkQueue.instance.tryAgain()
                                                return
                                        }
                                        
                                        let query: Query = Query(
                                            tags: validTags,
                                            tagHash: validTagHash,
                                            tagString: validTagString,
                                            ID: validId,
                                            timestamp: validTimestamp
                                        )
                                        
                                        guard let solutions: Set<Solution>? = self?.parseSolutions(queryDict["solutions"]! as! [NSDictionary], funcName: "getQueries", query: query) else {
                                            NSLog("Error - FriendsBest API - getQueries() - No solutions JSON")
                                            NetworkQueue.instance.tryAgain()
                                            return
                                        }
                                        
                                        if solutions != nil {
                                            query.setSolutions(solutions!)
                                        }
                                        
                                        queries.append(query)
                                    }
                                    
                                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                                        for query in queries {
                                            User.instance.queryHistory.appendQuery(query)
                                        }
                                        self?.networkDAODelegate?.queriesFetched()
                                        NetworkQueue.instance.dequeue()
                                        callback?()
                                    })
            }).resume()
    }
    
    func getFriends(callback: (() -> Void)?) {
        NetworkQueue.instance.enqueue(NetworkTask(task: {
            [weak self] () -> Void in
            self?._getFriends(callback)
            }, description: "getFriends()"))
    }
    
    private func _getFriends(callback: (() -> Void)?) {
        guard let token = self.friendsBestToken else {
            postFacebookTokenAndAuthenticate(nil)
            NetworkQueue.instance.tryAgain()
            NSLog("User has not authenticated")
            return
        }
        
        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = ["Authorization": token]
        let session: NSURLSession = NSURLSession(configuration: configuration)
        
        let queryString: String = "friend/"
        let queryURL: NSURL? = NSURL(string: queryString, relativeToURL: friendsBestAPIurl)
        
        guard let validQueryURL = queryURL else {
            NSLog("Error - FriendsBest API - getFriends() - Bad query URL")
            return
        }
        
        session.dataTaskWithURL(validQueryURL,
                                completionHandler: {
                                    [weak self] (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                                    
                                    if let error = error {
                                        NetworkQueue.instance.tryAgain()
                                        NSLog("Error - FriendsBest API - getQueries() - \(error)")
                                        return
                                    }
                                    
                                    if !FBNetworkDAO.instance.responseHasExpectedStatusCode(response, expectedStatusCodes: [200], funcName: "getQueries") {
                                        NetworkQueue.instance.tryAgain()
                                        return
                                    }
                                    
                                    guard let friendsArray: NSArray = FBNetworkDAO.getNSArrayFromJSONdata(data, funcName: "getQueries") else {
                                        NetworkQueue.instance.tryAgain()
                                        return
                                    }
                                    
                                    var friends: [Friend] = []
                                    
                                    for friendDict in friendsArray {
                                        guard let validFriendDict: NSDictionary = friendDict as? NSDictionary else {
                                            NetworkQueue.instance.tryAgain()
                                            NSLog("Error - FriendsBest API - getFriends - Invalid JSON object")
                                            return
                                        }
                                        
                                        guard let name: String = validFriendDict["name"] as? String,
                                            let id: String = validFriendDict["id"] as? String,
                                            let muted: Bool = validFriendDict["muted"] as? Bool else {
                                                NetworkQueue.instance.tryAgain()
                                                NSLog("Error - FriendsBest API - getFriends - Invalid JSON object")
                                                return
                                        }
                                        
                                        let f: Friend = Friend(facebookID: id, name: name)
                                        f.muted = muted
                                        
                                        friends.append(f)
                                    }
                                    
                                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                                        self?.networkDAODelegate?.friendsFetched(friends)
                                        NetworkQueue.instance.dequeue()
                                        callback?()
                                    })
                                    
            }).resume()
    }
    
    
    func getQuerySolutions(query: Query, callback: (() -> Void)?) {
        NetworkQueue.instance.enqueue(NetworkTask(task: {
            [weak self] () -> Void in
            self?._getQuerySolutions(query, callback: callback)
            }, description: "getQuerySolutions()"))
    }
    
    private func _getQuerySolutions(query: Query, callback: (() -> Void)?) {
        guard let token = self.friendsBestToken else {
            postFacebookTokenAndAuthenticate(nil)
            NetworkQueue.instance.tryAgain()
            NSLog("User has not authenticated")
            return
        }
        
        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = ["Authorization": token]
        let session: NSURLSession = NSURLSession(configuration: configuration)
        
        let queryString: String = "query/\(query.ID)/"
        let queryURL: NSURL! = NSURL(string: queryString, relativeToURL: friendsBestAPIurl)
        
        session.dataTaskWithURL(queryURL,
                                completionHandler: {
                                    [weak self] (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                                    
                                    if let error = error {
                                        NSLog("Error - FriendsBest API - getQuerySolutions() - \(error)")
                                        NetworkQueue.instance.tryAgain()
                                        return
                                    }
                                    
                                    if !FBNetworkDAO.instance.responseHasExpectedStatusCode(response, expectedStatusCodes: [200], funcName: "getQuerySolutions") {
                                        NetworkQueue.instance.tryAgain()
                                        return
                                    }
                                    
                                    guard let validQueryDict = FBNetworkDAO.getNSDictionaryFromJSONdata(data, funcName: "getQuerySolutions") else {
                                        NetworkQueue.instance.tryAgain()
                                        return
                                    }
                                    
                                    guard let solutionsDictArray = validQueryDict["solutions"] as? [NSDictionary] else {
                                        NSLog("Error - FriendsBest API - getQuerySolutions() - Invalid JSON")
                                        NetworkQueue.instance.tryAgain()
                                        return
                                    }
                                    
                                    guard let solutions: Set<Solution> = self?.parseSolutions(solutionsDictArray, funcName: "getQuerySolutions", query: query) else {
                                        NSLog("Error - FriendsBest API - getQuerySolutions() - Invalid JSON")
                                        NetworkQueue.instance.tryAgain()
                                        return
                                    }
                                    
                                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                                        User.instance.queryHistory.setQuerySolutionsForQueryID(solutions, queryID: query.ID)
                                        self?.networkDAODelegate?.querySolutionsFetched(forQueryID: query.ID)
                                        NetworkQueue.instance.dequeue()
                                        callback?()
                                    })
                                    
            }).resume()
    }
    
    func getRecommendationsForUser(callback: (() -> Void)?) {
        NetworkQueue.instance.enqueue(NetworkTask(task: {
            [weak self] () -> Void in
            self?._getRecommendationsForUser(callback)
            }, description: "getRecommendationsForUser()"))
    }
    
    private func _getRecommendationsForUser(callback: (() -> Void)?) {
        guard let token = self.friendsBestToken else {
            postFacebookTokenAndAuthenticate(nil)
            NetworkQueue.instance.tryAgain()
            NSLog("User has not authenticated")
            return
        }
        
        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = ["Authorization": token]
        let session: NSURLSession = NSURLSession(configuration: configuration)
        
        let queryString: String = "recommend/"
        let queryURL: NSURL! = NSURL(string: queryString, relativeToURL: friendsBestAPIurl)
        
        session.dataTaskWithURL(queryURL,
                                completionHandler: {
                                    (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                                    
                                    if let error = error {
                                        NSLog("Error - FriendsBest API - getRecommendationsForUser() - \(error)")
                                        NetworkQueue.instance.tryAgain()
                                        return
                                    }
                                    
                                    if !FBNetworkDAO.instance.responseHasExpectedStatusCode(response, expectedStatusCodes: [200], funcName: "getRecommendationsForUser") {
                                        NetworkQueue.instance.tryAgain()
                                        return
                                    }
                                    
                                    guard let validRecommendationsArray: NSArray = FBNetworkDAO.getNSArrayFromJSONdata(data, funcName: "getRecommendationsForUser") else {
                                        NSLog("Error - FriendsBest API - getRecommendationsForUser() - \(error)")
                                        NetworkQueue.instance.tryAgain()
                                        return
                                    }
                                    
                                    var userRecommendations: [Recommendation] = []
                                    
                                    for recDict in validRecommendationsArray {
                                        guard let recDict: NSDictionary = recDict as? NSDictionary else {
                                            NSLog("Error - FriendsBest API - getRecommendationsForUser()")
                                            NetworkQueue.instance.dequeue()
                                            return
                                        }
                                        
                                        guard let tags: [String] = recDict["tags"] as? [String] else {
                                            NSLog("Error - FriendsBest API - getRecommendationsForUser()")
                                            NetworkQueue.instance.dequeue()
                                            return
                                        }
                                        
                                        guard let id: Int = recDict["id"] as? Int else {
                                            NSLog("Error - FriendsBest API - getRecommendationsForUser()")
                                            NetworkQueue.instance.dequeue()
                                            return
                                        }
                                        
                                        guard let comments: String = recDict["comments"] as? String else {
                                            NSLog("Error - FriendsBest API - getRecommendationsForUser()")
                                            NetworkQueue.instance.dequeue()
                                            return
                                        }
                                        
                                        guard let detail: String = recDict["detail"] as? String else {
                                            NSLog("Error - FriendsBest API - getRecommendationsForUser()")
                                            NetworkQueue.instance.dequeue()
                                            return
                                        }
                                        
                                        guard let typeString: String = recDict["type"] as? String else {
                                            NSLog("Error - FriendsBest API - getRecommendationsForUser()")
                                            NetworkQueue.instance.dequeue()
                                            return
                                        }
                                        
                                        let type: RecommendationType = RecommendationType(rawValue: typeString)!
                                        
                                        guard let user: NSDictionary = recDict["user"] as? NSDictionary else {
                                            NSLog("Error - FriendsBest API - getRecommendationsForUser()")
                                            NetworkQueue.instance.dequeue()
                                            return
                                        }
                                        
                                        guard let userName: String = user["name"] as? String else {
                                            NSLog("Error - FriendsBest API - getRecommendationsForUser()")
                                            NetworkQueue.instance.dequeue()
                                            return
                                        }
                                        
                                        guard let userId: String = user["id"] as? String else {
                                            NSLog("Error - FriendsBest API - getRecommendationsForUser()")
                                            NetworkQueue.instance.dequeue()
                                            return
                                        }
                                        
                                        if userId != User.instance.facebookID {
                                            continue
                                        }
                                        
                                        let friend: Friend = Friend(facebookID: userId, name: userName)
                                        
                                        let recommendation: Recommendation = Recommendation(friend: friend, comment: comments, detail: detail, type: type, ID: id)
                                        recommendation.tags = tags
                                        recommendation.new = true
                                        
                                        userRecommendations.append(recommendation)
                                    }
                                    
                                    NSOperationQueue.mainQueue().addOperationWithBlock({
                                        for recommendation: Recommendation in userRecommendations {
                                            if !User.instance.recommendations.contains(recommendation) {
                                                User.instance.recommendations.append(recommendation)
                                            }
                                        }
                                        self.networkDAODelegate?.userRecommendationsFetched()
                                        NetworkQueue.instance.dequeue()
                                        callback?()
                                    })
                                    
        }).resume()
    }
    
    func postNewQuery(queryTags: [String], callback: ((Query) -> Void)?) {
        NetworkQueue.instance.enqueue(NetworkTask(task: {
            [weak self] () -> Void in
            self?._postNewQuery(queryTags, callback: callback)
            }, description: "postNewQuery()"))
    }
    
    private func _postNewQuery(queryTags: [String], callback: ((Query) -> Void)?) {
        guard let token = self.friendsBestToken else {
            postFacebookTokenAndAuthenticate(nil)
            NetworkQueue.instance.tryAgain()
            NSLog("User has not authenticated")
            return
        }
        
        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = ["Authorization": token]
        let session: NSURLSession = NSURLSession(configuration: configuration)
        
        let queryString: String = "query/"
        let queryURL: NSURL! = NSURL(string: queryString, relativeToURL: friendsBestAPIurl)
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: queryURL)
        let json = ["tags": queryTags]
        let jsonData: NSData
        do {
            jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions())
        } catch {
            NSLog("Error - FriendsBest API - postNewQuery() - Couldn't convert tags to JSON")
            return
        }
        request.HTTPMethod = "POST"
        request.HTTPBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        session.dataTaskWithRequest(request,
                                    completionHandler: {
                                        [weak self] (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                                        
                                        if let error = error {
                                            NSLog("Error - FriendsBest API - postNewQuery() - \(error.localizedDescription)")
                                            NetworkQueue.instance.tryAgain()
                                            return
                                        }
                                        
                                        if !FBNetworkDAO.instance.responseHasExpectedStatusCode(response, expectedStatusCodes: [201], funcName: "postNewQuery") {
                                            NetworkQueue.instance.tryAgain()
                                            return
                                        }
                                        
                                        guard let queryDict: NSDictionary = FBNetworkDAO.getNSDictionaryFromJSONdata(data, funcName: "postNewQuery") else {
                                            NetworkQueue.instance.tryAgain()
                                            return
                                        }
                                        
                                        guard let id: Int = queryDict["id"] as? Int else {
                                            NSLog("Error - FriendsBest API - postNewQuery() - Invalid JSON: id not in dictionary")
                                            NetworkQueue.instance.tryAgain()
                                            return
                                        }
                                        
                                        guard let tags: [String] = queryDict["tags"] as? [String] else {
                                            NSLog("Error - FriendsBest API - postNewQuery() - Invalid JSON: tags not in dictionary")
                                            NetworkQueue.instance.tryAgain()
                                            return
                                        }
                                        
                                        guard let tagHash: String = queryDict["taghash"] as? String else {
                                            NSLog("Error - FriendsBest API - postNewQuery() - Invalid JSON: tagHash not in dictionary")
                                            NetworkQueue.instance.tryAgain()
                                            return
                                        }
                                        
                                        guard let tagString: String = queryDict["tagstring"] as? String else {
                                            NSLog("Error - FriendsBest API - postNewQuery() - Invalid JSON: tagHash not in dictionary")
                                            NetworkQueue.instance.tryAgain()
                                            return
                                        }
                                        
                                        guard let solutionsArray: [NSDictionary] = queryDict["solutions"] as? [NSDictionary] else {
                                            NSLog("Error - FriendsBest API - postNewQuery() - Invalid JSON: solutions not in dictionary")
                                            NetworkQueue.instance.tryAgain()
                                            return
                                        }
                                        
                                        guard let timestampString: String = queryDict["accessed"] as? String else {
                                            NSLog("Error - FriendsBest API - postNewQuery() - Invalid JSON: timestamp not in dictionary")
                                            NetworkQueue.instance.tryAgain()
                                            return
                                        }
                                        
                                        guard let timestamp: NSDate = self!.convertTimestampStringToNSDate(timestampString) else {
                                            NSLog("Error - FriendsBest API - getQueries() - Invalid JSON")
                                            NetworkQueue.instance.tryAgain()
                                            return
                                        }
                                        
                                        let newQuery: Query = Query(tags: tags, tagHash: tagHash, tagString: tagString, ID: id, timestamp: timestamp)
                                        
                                        guard let solutions: Set<Solution> = self!.parseSolutions(solutionsArray, funcName: "postNewQuery", query: newQuery) else {
                                            NetworkQueue.instance.tryAgain()
                                            return
                                        }
                                        
                                        newQuery.setSolutions(solutions)
                                        
                                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                                            User.instance.queryHistory.appendQuery(newQuery)
                                            self?.networkDAODelegate?.newQueryFetched(newQuery.ID)
                                            NetworkQueue.instance.dequeue()
                                            callback?(newQuery)
                                        })
            }).resume()
        
    }
    
    func deleteQuery(queryID: Int, callback: (() -> Void)?) {
        NetworkQueue.instance.enqueue(NetworkTask(task: {
            [weak self] () -> Void in
            self?._deleteQuery(queryID, callback: callback)
            }, description: "deleteQuery()"))
    }
    
    private func _deleteQuery(queryID: Int, callback: (() -> Void)?) {
        guard let token = self.friendsBestToken else {
            postFacebookTokenAndAuthenticate(nil)
            NetworkQueue.instance.tryAgain()
            NSLog("User has not authenticated")
            return
        }
        
        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = ["Authorization": token]
        let session: NSURLSession = NSURLSession(configuration: configuration)
        
        let queryString: String = "query/\(queryID)/"
        let queryURL: NSURL! = NSURL(string: queryString, relativeToURL: friendsBestAPIurl)
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: queryURL)
        
        request.HTTPMethod = "DELETE"
        //        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        session.dataTaskWithRequest(request,
                                    completionHandler: {
                                        (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                                        
                                        if let error = error {
                                            NSLog("Error - FriendsBest API - deleteQuery() - \(error.localizedDescription)")
                                            NetworkQueue.instance.tryAgain()
                                            return
                                        }
                                        
                                        if !FBNetworkDAO.instance.responseHasExpectedStatusCode(response, expectedStatusCodes: [204], funcName: "deleteQuery") {
                                            NetworkQueue.instance.tryAgain()
                                            return
                                        }
                                        
                                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                                            NetworkQueue.instance.dequeue()
                                        })
        }).resume()
        
    }
    
    func deletePrompt(promptID: Int, callback: (() -> Void)?) {
        NetworkQueue.instance.enqueue(NetworkTask(task: {
            [weak self] () -> Void in
            self?._deletePrompt(promptID, callback: callback)
            }, description: "deletePrompt()"))
    }
    
    private func _deletePrompt(promptID: Int, callback: (() -> Void)?) {
        guard let token = self.friendsBestToken else {
            postFacebookTokenAndAuthenticate(nil)
            NetworkQueue.instance.tryAgain()
            NSLog("User has not authenticated")
            return
        }
        
        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = ["Authorization": token]
        let session: NSURLSession = NSURLSession(configuration: configuration)
        
        let queryString: String = "prompt/\(promptID)/"
        let queryURL: NSURL! = NSURL(string: queryString, relativeToURL: friendsBestAPIurl)
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: queryURL)
        
        request.HTTPMethod = "DELETE"
        //        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        session.dataTaskWithRequest(request,
                                    completionHandler: {
                                        (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                                        
                                        if let error = error {
                                            NSLog("Error - FriendsBest API - deletePrompt() - \(error.localizedDescription)")
                                            NetworkQueue.instance.tryAgain()
                                            return
                                        }
                                        
                                        if !FBNetworkDAO.instance.responseHasExpectedStatusCode(response, expectedStatusCodes: [204, 404], funcName: "deletePrompt") {
                                            NetworkQueue.instance.dequeue()
                                            return
                                        }
                                        
                                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                                            NetworkQueue.instance.dequeue()
                                            callback?()
                                        })
        }).resume()
        
    }
    
    func deleteRecommendation(recommendationID: Int, callback: (() -> Void)?) {
        NetworkQueue.instance.enqueue(NetworkTask(task: {
            [weak self] () -> Void in
            self?._deleteRecommendation(recommendationID, callback: callback)
            }, description: "deleteRecommendation()"))
    }
    
    private func _deleteRecommendation(recommendationID: Int, callback: (() -> Void)?) {
        guard let token = self.friendsBestToken else {
            postFacebookTokenAndAuthenticate(nil)
            NetworkQueue.instance.tryAgain()
            NSLog("User has not authenticated")
            return
        }
        
        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = ["Authorization": token]
        let session: NSURLSession = NSURLSession(configuration: configuration)
        
        let queryString: String = "recommend/\(recommendationID)/"
        let queryURL: NSURL! = NSURL(string: queryString, relativeToURL: friendsBestAPIurl)
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: queryURL)
        
        request.HTTPMethod = "DELETE"
        //        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        session.dataTaskWithRequest(request,
                                    completionHandler: {
                                        (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                                        
                                        if let error = error {
                                            NSLog("Error - FriendsBest API - deleteRecommendation() - \(error.localizedDescription)")
                                            NetworkQueue.instance.dequeue()
                                            return
                                        }
                                        
                                        if !FBNetworkDAO.instance.responseHasExpectedStatusCode(response, expectedStatusCodes: [204], funcName: "deleteRecommendation") {
                                            NetworkQueue.instance.dequeue()
                                            return
                                        }
                                        
                                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                                            NetworkQueue.instance.dequeue()
                                            callback?()
                                        })
        }).resume()
        
    }
    
    func postNewRecommendtaion(recommendation: UserRecommendation, callback: (() -> Void)?) {
        NetworkQueue.instance.enqueue(NetworkTask(task: {
            [weak self] () -> Void in
            self?._postNewRecommendtaion(recommendation, callback: callback)
            }, description: "postNewRecommendtaion()"))
    }
    
    private func _postNewRecommendtaion(recommendation: UserRecommendation, callback: (() -> Void)?) {
        guard let token = self.friendsBestToken else {
            postFacebookTokenAndAuthenticate(nil)
            NetworkQueue.instance.tryAgain()
            NSLog("User has not authenticated")
            return
        }
        
        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = ["Authorization": token]
        let session: NSURLSession = NSURLSession(configuration: configuration)
        
        let queryString: String = "recommend/"
        let queryURL: NSURL! = NSURL(string: queryString, relativeToURL: friendsBestAPIurl)
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: queryURL)
        let json = [
            "detail": recommendation.detail!,
            "type": recommendation.type!.rawValue,
            "comments" : recommendation.comments == nil ? "" : recommendation.comments!,
            "tags": recommendation.tags!
        ]
        let jsonData: NSData
        do {
            jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions())
        } catch {
            NSLog("Error - FriendsBest API - postNewRecommendation() - Couldn't convert tags to JSON")
            return
        }
        request.HTTPMethod = "POST"
        request.HTTPBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        session.dataTaskWithRequest(request,
                                    completionHandler: {
                                        // [weak self]
                                        (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                                        
                                        if let error = error {
                                            NSLog("Error - FriendsBest API - postNewRecommendation() - \(error.localizedDescription)")
                                            NetworkQueue.instance.tryAgain()
                                            return
                                        }
                                        
                                        if !FBNetworkDAO.instance.responseHasExpectedStatusCode(response, expectedStatusCodes: [201, 500], funcName: "postNewRecommendation") { // The server is still saving data even after sending a 500 error...
                                            NetworkQueue.instance.tryAgain()
                                            return
                                        }
                                        
                                        // TODO: Could save response data here.
                                        
                                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                                            NetworkQueue.instance.dequeue()
                                            callback?()
                                            FBNetworkDAO.instance.getRecommendationsForUser(nil)
                                        })
                                        
        }).resume()
    }
    
    func getPrompts(callback: (() -> Void)?) {
        NetworkQueue.instance.enqueue(NetworkTask(task: {
            [weak self] () -> Void in
            self?._getPrompts(callback)
            }, description: "getPrompts()"))
    }
    
    private func _getPrompts(callback: (() -> Void)?) {
        guard let token = self.friendsBestToken else {
            postFacebookTokenAndAuthenticate(nil)
            NetworkQueue.instance.tryAgain()
            NSLog("User has not authenticated")
            return
        }
        
        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = ["Authorization": token]
        let session: NSURLSession = NSURLSession(configuration: configuration)
        
        let queryString: String = "prompt/"
        let queryURL: NSURL? = NSURL(string: queryString, relativeToURL: friendsBestAPIurl)
        
        guard let validQueryURL = queryURL else {
            NSLog("Error - FriendsBest API - getPrompts() - Bad query URL")
            return
        }
        
        session.dataTaskWithURL(validQueryURL,
                                completionHandler: {
                                    [weak self] (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                                    
                                    if let error = error {
                                        NSLog("Error - FriendsBest API - getPrompts() - \(error)")
                                        NetworkQueue.instance.tryAgain()
                                        return
                                    }
                                    
                                    if !FBNetworkDAO.instance.responseHasExpectedStatusCode(response, expectedStatusCodes: [200], funcName: "getPrompts") {
                                        NetworkQueue.instance.tryAgain()
                                        return
                                    }
                                    
                                    guard let promptArray: NSArray = FBNetworkDAO.getNSArrayFromJSONdata(data, funcName: "getPrompts") else {
                                        NetworkQueue.instance.tryAgain()
                                        return
                                    }
                                    
                                    var prompts: [Prompt] = []
                                    
                                    for promptDict in promptArray {
                                        guard let promptDict: NSDictionary = promptDict as? NSDictionary else {
                                            NSLog("Error - FriendsBest API - getPrompts() - Invalid JSON object")
                                            NetworkQueue.instance.tryAgain()
                                            return
                                        }
                                        
                                        let article: String? = promptDict["article"] as? String
                                        let tags: [String]? = promptDict["tags"] as? [String]
                                        let friendDict: NSDictionary? = promptDict["friend"] as? NSDictionary
                                        let promptID: Int? = promptDict["id"] as? Int
                                        let tagString: String? = promptDict["tagstring"] as? String
                                        
                                        guard let validArticle = article, let validTags = tags, let validPromptID = promptID, let validTagString = tagString else {
                                            NSLog("Error - FriendsBest API - getPrompts() - Invalid JSON")
                                            NetworkQueue.instance.tryAgain()
                                            return
                                        }
                                        
                                        // friendDict may be nil for anonymous prompts.
                                        
                                        var friend: Friend? = nil
                                        
                                        if friendDict != nil {
                                            friend = Friend(facebookID: friendDict!["id"]! as! String, name: friendDict!["name"]! as! String)
                                        }
                                        
                                        prompts.append(Prompt(article: validArticle, tags: validTags, tagString: validTagString, friend: friend, ID: validPromptID))
                                    }
                                    
                                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                                        for prompt in prompts {
                                            if !User.instance.prompts.prompts.contains(prompt) {
                                                User.instance.prompts.prompts.append(prompt)
                                            }
                                        }
                                        NetworkQueue.instance.dequeue()
                                        self?.networkDAODelegate?.promptsFetched()
                                        callback?()
                                    })
                                    
            }).resume()
    }
    
    func postFacebookTokenAndAuthenticate(callback: (() -> Void)?) {
        NetworkQueue.instance.push(NetworkTask(task: { () -> Void in
            self._postFacebookTokenAndAuthenticate(callback)
            }, description: "postFacebookTokenAndAuthenticate()"))
    }
    
    private func _postFacebookTokenAndAuthenticate(callback: (() -> Void)?) {
        assert(FBSDKAccessToken.currentAccessToken() != nil);
        let queryString: String = "facebook/"
        let queryURL: NSURL! = NSURL(string: queryString, relativeToURL: friendsBestAPIurl)
        let session: NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: queryURL)
        let json = ["access_token": FBSDKAccessToken.currentAccessToken().tokenString]
        let jsonData: NSData
        do {
            jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions())
        } catch {
            NSLog("Error - FriendsBest API - postFacebookToken() - Couldn't convert tags to JSON")
            return
        }
        request.HTTPMethod = "POST"
        request.HTTPBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        session.dataTaskWithRequest(request,
                                    completionHandler: {
                                        [weak self] (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                                        
                                        if let error = error {
                                            NSLog("Error - FriendsBest API - postFacebookToken() - \(error.localizedDescription)")
                                            NSLog("\(error.code)")
                                            NetworkQueue.instance.tryAgain()
                                            return
                                        }
                                        
                                        if !FBNetworkDAO.instance.responseHasExpectedStatusCode(response, expectedStatusCodes: [200], funcName: "postFacebookToken") {
                                            NetworkQueue.instance.tryAgain()
                                            return
                                        }
                                        
                                        guard let keyDict: NSDictionary = FBNetworkDAO.getNSDictionaryFromJSONdata(data, funcName: "postFacebookToken") else {
                                            NetworkQueue.instance.tryAgain()
                                            return
                                        }
                                        
                                        guard let key: NSString = keyDict["key"] as? NSString else {
                                            NSLog("Error - FriendsBest API - postFacebookToken() - key not in JSON dictionary")
                                            NetworkQueue.instance.tryAgain()
                                            return
                                        }
                                        
                                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                                            self?.friendsBestToken = "Token " + (key as String)
                                            self?.authenticatedWithFriendsBestServerDelegate()
                                            NetworkQueue.instance.dequeue()
                                            callback?()
                                        })
                                        
            }).resume()
    }
    
    private func parseSolutions(solutionsArray: [NSDictionary], funcName: String, query: Query) -> Set<Solution>? {
        var solutions: Set<Solution> = Set()
        
        for solutionDict in solutionsArray {
            guard let validSolutionDict: NSDictionary = solutionDict else {
                NSLog("Error - FriendsBest API - \(funcName)() - Invalid JSON object")
                return nil
            }
            
            let solutionDetail: String? = validSolutionDict["detail"] as? String
            let solutionType: String? = validSolutionDict["type"] as? String
            let recommendationArray: [NSDictionary]? = validSolutionDict["recommendations"] as? [NSDictionary]
            
            guard let validSolutionDetail = solutionDetail, let validSolutionType = solutionType, let validRecommendationArray = recommendationArray else {
                NSLog("Error - FriendsBest API - \(funcName)() - Invalid JSON")
                return nil
            }
            
            var recommendations: Set<Recommendation> = Set()
            
            for recommendation: NSDictionary in validRecommendationArray {
                let userDict: NSDictionary? = recommendation["user"] as? NSDictionary
                let comment: String = recommendation["comment"] as! String
                let ID: Int = recommendation["id"] as! Int
                
                
                let userName: String? = userDict?["name"] as? String
                let facebookID: String? = userDict?["id"] as? String
                
                var newFriend: Friend? = nil
                if userName != nil && facebookID != nil {
                    newFriend = Friend(facebookID: facebookID!, name: userName!)
                }
                
                let newRecommendation: Recommendation = Recommendation(
                    friend: newFriend,
                    comment: comment,
                    detail: validSolutionDetail,
                    type: RecommendationType(rawValue: validSolutionType)!,
                    ID: ID
                )
                
                recommendations.insert(newRecommendation)
            }
            
            solutions.insert(Solution(recommendations: recommendations, detail: validSolutionDetail, type: RecommendationType(rawValue: validSolutionType)!, query: query))
        }
        
        return solutions
    }
    
    func responseHasExpectedStatusCode(response: NSURLResponse?, expectedStatusCodes: [Int], funcName: String) -> Bool {
        guard let response = response else {
            NSLog("Error - FriendsBest API - \(funcName)() - No response")
            return false
        }
        
        if let response = response as? NSHTTPURLResponse {
            if expectedStatusCodes.contains(response.statusCode) {
                return true
            } else {
                NSLog("Error - FriendsBest API - \(funcName)() - Status code \(response.statusCode) not expected \(expectedStatusCodes)")
            }
        }
        
        return false
    }
    
    private static func getNSDictionaryFromJSONdata(data: NSData?, funcName: String) -> NSDictionary? {
        var dict: NSDictionary? = nil
        
        guard let data = data else {
            NSLog("Error - FriendsBest API - \(funcName)() - No data")
            return dict
        }
        
        do {
            dict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? NSDictionary
        } catch {
            NSLog("Error - FriendsBest API - \(funcName) - Unable to parse JSON - \(error)")
        }
        
        return dict
    }
    
    private static func getNSArrayFromJSONdata(data: NSData?, funcName: String) -> NSArray? {
        var array: NSArray? = nil
        
        guard let data = data else {
            NSLog("Error - FriendsBest API - \(funcName)() - No data")
            return array
        }
        
        do {
            array = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? NSArray
        } catch {
            NSLog("Error - FriendsBest API - \(funcName) - Unable to parse JSON - \(error)")
        }
        
        return array
    }
    
    private func convertTimestampStringToNSDate(timestampString: String) -> NSDate? {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.dateFromString(timestampString)
    }
}













































