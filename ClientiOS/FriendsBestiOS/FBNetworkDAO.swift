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
}


class FBNetworkDAO {
    
    /* Singleton instance */
    static let instance: FBNetworkDAO = FBNetworkDAO()
    
    /* Instance members */
    #if DEBUG
    private let friendsBestAPIurl: NSURL! = NSURL(string: "http://localhost:8000/fb/api/")
    #else
    private let friendsBestAPIurl: NSURL! = NSURL(string: "https://www.friendsbest.net/fb/api/")
    #endif
    
    private let updater: UpdateBullshitter = UpdateBullshitter.instance
    
    private var friendsBestToken: String? = nil
    
    /* Delegation */
    weak var networkDAODelegate: NetworkDAODelegate? = nil
    
    var authenticatedWithFriendsBestServerDelegate: () -> Void = {}
    
    
    /* Private constructor */
    private init() { }
    
    
    func getQueries() {
        NetworkQueue.instance.enqueue(NetworkTask(task: {
            [weak self] () -> Void in
            self?._getQueries()
            }, description: "getQueries()"))
    }
    
    private func _getQueries() {
        guard let token = self.friendsBestToken else {
            postFacebookTokenAndAuthenticate()
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
                
                if !FBNetworkDAO.instance.responseHasExpectedStatusCode(response, expectedStatusCode: 200, funcName: "getQueries") {
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
                    
                    queries.append(Query(
                        tags: validTags,
                        tagHash: validTagHash,
                        tagString: validTagString,
                        ID: validId,
                        timestamp: validTimestamp
                        )
                    )
                }
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    for query in queries {
                        User.instance.queryHistory.appendQuery(query)
                    }
                    self?.networkDAODelegate?.queriesFetched()
                    NetworkQueue.instance.dequeue()
                })
                
            }).resume()
    }
    
    
    func getQuerySolutions(queryID: Int) {
        NetworkQueue.instance.enqueue(NetworkTask(task: {
            [weak self] () -> Void in
            self?._getQuerySolutions(queryID)
            }, description: "getQuerySolutions()"))
    }
    
    private func _getQuerySolutions(queryID: Int) {
        guard let token = self.friendsBestToken else {
            postFacebookTokenAndAuthenticate()
            NetworkQueue.instance.tryAgain()
            NSLog("User has not authenticated")
            return
        }
        
        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = ["Authorization": token]
        let session: NSURLSession = NSURLSession(configuration: configuration)
        
        let queryString: String = "query/\(queryID)/"
        let queryURL: NSURL! = NSURL(string: queryString, relativeToURL: friendsBestAPIurl)
        
        session.dataTaskWithURL(queryURL,
            completionHandler: {
                [weak self] (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                
                if let error = error {
                    NSLog("Error - FriendsBest API - getQuerySolutions() - \(error)")
                    NetworkQueue.instance.tryAgain()
                    return
                }
                
                if !FBNetworkDAO.instance.responseHasExpectedStatusCode(response, expectedStatusCode: 200, funcName: "getQuerySolutions") {
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
                
                guard let solutions: Set<Solution> = self?.parseSolutions(solutionsDictArray, funcName: "getQuerySolutions") else {
                    NSLog("Error - FriendsBest API - getQuerySolutions() - Invalid JSON")
                    NetworkQueue.instance.tryAgain()
                    return
                }
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    User.instance.queryHistory.setQuerySolutionsForQueryID(solutions, queryID: queryID)
                    self?.networkDAODelegate?.querySolutionsFetched(forQueryID: queryID)
                    NetworkQueue.instance.dequeue()
                })
                
            }).resume()
    }
    
    func postNewQuery(queryTags: [String]) {
        NetworkQueue.instance.enqueue(NetworkTask(task: {
            [weak self] () -> Void in
            self?._postNewQuery(queryTags)
            }, description: "postNewQuery()"))
    }
    
    private func _postNewQuery(queryTags: [String]) {
        guard let token = self.friendsBestToken else {
            postFacebookTokenAndAuthenticate()
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
                
                if !FBNetworkDAO.instance.responseHasExpectedStatusCode(response, expectedStatusCode: 201, funcName: "postNewQuery") {
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
                
                guard let solutions: Set<Solution> = self!.parseSolutions(solutionsArray, funcName: "postNewQuery") else {
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
                newQuery.setSolutions(solutions)
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    User.instance.queryHistory.appendQuery(newQuery)
                    self?.networkDAODelegate?.newQueryFetched(newQuery.ID)
                    NetworkQueue.instance.dequeue()
                })
            }).resume()
        
    }
    
    func deleteQuery(queryID: Int) {
        NetworkQueue.instance.enqueue(NetworkTask(task: {
            [weak self] () -> Void in
            self?._deleteQuery(queryID)
            }, description: "deleteQuery()"))
    }
    
    private func _deleteQuery(queryID: Int) {
        guard let token = self.friendsBestToken else {
            postFacebookTokenAndAuthenticate()
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
                
                if !FBNetworkDAO.instance.responseHasExpectedStatusCode(response, expectedStatusCode: 204, funcName: "deleteQuery") {
                    NetworkQueue.instance.tryAgain()
                    return
                }
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    NetworkQueue.instance.dequeue()
                })
            }).resume()
        
    }
    
    func postNewRecommendtaion(detail: String, type: String, comments: String, recommendationTags: [String]) {
        NetworkQueue.instance.enqueue(NetworkTask(task: {
            [weak self] () -> Void in
            self?._postNewRecommendtaion(detail, type: type, comments: comments, recommendationTags: recommendationTags)
            }, description: "postNewRecommendtaion()"))
    }
    
    private func _postNewRecommendtaion(detail: String, type: String, comments: String, recommendationTags: [String]) {
        guard let token = self.friendsBestToken else {
            postFacebookTokenAndAuthenticate()
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
        let json = ["detail": detail, "type": type, "comments" : comments, "tags": recommendationTags]
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
                
                if !FBNetworkDAO.instance.responseHasExpectedStatusCode(response, expectedStatusCode: 201, funcName: "postNewRecommendation") {
                    NetworkQueue.instance.tryAgain()
                    return
                }
                
                // TODO: Could save response data here.
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    NetworkQueue.instance.dequeue()
                })
                
        }).resume()
    }
    
    func getPrompts() {
        NetworkQueue.instance.enqueue(NetworkTask(task: {
            [weak self] () -> Void in
            self?._getPrompts()
            }, description: "getPrompts()"))
    }
    
    private func _getPrompts() {
        guard let token = self.friendsBestToken else {
            postFacebookTokenAndAuthenticate()
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
                
                if !FBNetworkDAO.instance.responseHasExpectedStatusCode(response, expectedStatusCode: 200, funcName: "getPrompts") {
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
                    
                    guard let validFriendDict: NSDictionary = friendDict else {
                        NSLog("Error - FriendsBest API - getPrompts() - Error unwrapping friend dictionary")
                        NetworkQueue.instance.tryAgain()
                        return
                    }
                    
                    let facebookID: String? = validFriendDict["id"] as? String
                    let userName: String? = validFriendDict["name"] as? String
                    
                    guard let validFacebookID = facebookID, let validUserName = userName else {
                        NSLog("Error - FriendsBest API - getPrompts() - Friend dictionary elements invalid")
                        NetworkQueue.instance.tryAgain()
                        return
                    }
                    
                    let friend: Friend = Friend(facebookID: validFacebookID, name: validUserName)
                    
                    prompts.append(Prompt(article: validArticle, tags: validTags, tagString: validTagString, friend: friend, ID: validPromptID))
                }
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    User.instance.prompts.prompts = prompts
                    // The queue doesn't have to wait on the delegate...
                    NetworkQueue.instance.dequeue()
                    self?.networkDAODelegate?.promptsFetched()
                })
                
            }).resume()
    }
    
    func postFacebookTokenAndAuthenticate() {
        NetworkQueue.instance.push(NetworkTask(task: { () -> Void in
            self._postFacebookTokenAndAuthenticate()
            }, description: "postFacebookTokenAndAuthenticate()"))
    }
    
    private func _postFacebookTokenAndAuthenticate() {
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
                
                if !FBNetworkDAO.instance.responseHasExpectedStatusCode(response, expectedStatusCode: 200, funcName: "postFacebookToken") {
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
                })
                
            }).resume()
    }
    
    private func _getFacebookPicture(facebookID: String) {
        
    }
    
    private func parseSolutions(solutionsArray: [NSDictionary], funcName: String) -> Set<Solution>? {
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
                let comment: String? = recommendation["comment"] as? String
                let ID: Int? = recommendation["id"] as? Int
                
                guard let validUserDict = userDict, validComment = comment, validID = ID else {
                    NSLog("Error - FriendsBest API - \(funcName)() - Invalid JSON")
                    return nil
                }
                
                let userName: String? = validUserDict["name"] as? String
                let facebookID: String? = validUserDict["id"] as? String
                
                guard let validUserName = userName, let validFacebookID = facebookID else {
                    NSLog("Error - FriendsBest API - \(funcName)() - Invalid JSON")
                    return nil
                }
                
                let newFriend: Friend = Friend(facebookID: validFacebookID, name: validUserName)
                
                let newRecommendation: Recommendation = Recommendation(
                    friend: newFriend,
                    comment: validComment,
                    detail: validSolutionDetail,
                    type: Recommendation.RecommendationType(rawValue: validSolutionType.uppercaseString)!,
                    ID: validID
                )
                
                recommendations.insert(newRecommendation)
            }
            
            solutions.insert(Solution(recommendations: recommendations, detail: validSolutionDetail, type: Recommendation.RecommendationType(rawValue: validSolutionType.uppercaseString)!))
        }
        
        return solutions
    }
    
    func responseHasExpectedStatusCode(response: NSURLResponse?, expectedStatusCode: Int, funcName: String) -> Bool {
        guard let response = response else {
            NSLog("Error - FriendsBest API - \(funcName)() - No response")
            return false
        }
        
        if let response = response as? NSHTTPURLResponse {
            if response.statusCode == expectedStatusCode {
                return true
            } else {
                NSLog("Error - FriendsBest API - \(funcName)() - Status code \(response.statusCode) not expected \(expectedStatusCode)")
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













































