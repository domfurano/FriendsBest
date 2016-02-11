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


protocol NetworkDAODelegate: class {
    func queriesFetched()
    func querySolutionsFetched(forQueryID queryID: Int)
    func newQueryFetched(queryID: Int)
    func promptsFetched()
}


class NetworkDAO {
    
    /* Singleton instance */
    static let instance: NetworkDAO = NetworkDAO()
    
    /* Instance members */    
    #if DEBUG
//    private let friendsBestAPIurl: NSURL! = NSURL(string: "http://localhost:8000/fb/api/")
    #else
    private let friendsBestAPIurl: NSURL! = NSURL(string: "https://www.friendsbest.net/fb/api/")
    #endif
    
    private var friendsBestToken: String? = nil
    
    /* Delegation */
    weak var networkDAODelegate: NetworkDAODelegate? = nil
    
    /* Private constructor */
    private init() {
        postFacebookTokenAndAuthenticate()
    }
    
    
    func getQueries() {
        NetworkQueue.instance.enqueue(NetworkTask(task: {
            [weak self] () -> Void in
            self?._getQueries()
        }, description: "getQueries()"))
    }
    
    private func _getQueries() {
        guard let token = self.friendsBestToken else {
            postFacebookTokenAndAuthenticate()
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
                
                if !NetworkDAO.responseHasExpectedStatusCode(response, expectedStatusCode: 200, funcName: "getQueries") {
                    NetworkQueue.instance.tryAgain()
                    return
                }
                
                guard let queriesArray: NSArray = NetworkDAO.getNSArrayFromJSONdata(data, funcName: "getQueries") else {
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
                    let id: Int? = validQueryDict["id"] as? Int
                    let timestampString: String? = validQueryDict["timestamp"] as? String
                    
                    guard let validTags = tags, let validId = id, let validTimestampString = timestampString,
                        let validTimestamp: NSDate = self!.convertTimestampStringToNSDate(validTimestampString) else {
                            NSLog("Error - FriendsBest API - getQueries() - Invalid JSON")
                            NetworkQueue.instance.tryAgain()
                            return
                    }
                    
                    // TODO: fix taghash and tagstring when API is updated
                    queries.append(Query(tags: validTags, tagHash: tags!.joinWithSeparator(""), tagString: tags!.joinWithSeparator(" "), ID: validId, timestamp: validTimestamp))
                }
                
                for query in queries {
                    User.instance.queryHistory.appendQuery(query)
                }
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
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
                
                if !NetworkDAO.responseHasExpectedStatusCode(response, expectedStatusCode: 200, funcName: "getQuerySolutions") {
                    NetworkQueue.instance.tryAgain()
                    return
                }
                
                guard let validQueryDict = NetworkDAO.getNSDictionaryFromJSONdata(data, funcName: "getQuerySolutions") else {
                    NetworkQueue.instance.tryAgain()
                    return
                }
                
                guard let solutionsDict = validQueryDict["solutions"] as? [NSDictionary] else {
                    NSLog("Error - FriendsBest API - getQuerySolutions() - Invalid JSON")
                    NetworkQueue.instance.tryAgain()
                    return
                }
                
                var solutions: [Solution] = []
                
                for solutionDict in solutionsDict {
                    guard let validSolutionDict: NSDictionary = solutionDict else {
                        NSLog("Error - FriendsBest API - getQuerySolutions() - Invalid JSON object")
                        NetworkQueue.instance.tryAgain()
                        return
                    }
                    
                    let solutionName: String? = validSolutionDict["name"] as? String
                    let recommendationArray: [NSDictionary]? = validSolutionDict["recommendation"] as? [NSDictionary]
                    
                    guard let validSolutionName = solutionName, let validRecommendationArray = recommendationArray else {
                        NSLog("Error - FriendsBest API - getQuerySolutions() - Invalid JSON")
                        NetworkQueue.instance.tryAgain()
                        return
                    }
                    
                    var recommendations: [Recommendation] = []
                    
                    for recommendation: NSDictionary in validRecommendationArray {
                        let comment: String? = recommendation["comment"] as? String
                        let userName: String? = recommendation["name"] as? String
                        
                        guard let validComment = comment, validUserName = userName else {
                            NSLog("Error - FriendsBest API - getQuerySolutions() - Invalid JSON")
                            NetworkQueue.instance.tryAgain()
                            return
                        }
                        
                        let newRecommendation: Recommendation = Recommendation(userName: validUserName, comment: validComment)
                        recommendations.append(newRecommendation)
                    }
                    
                    solutions.append(Solution(name: validSolutionName, recommendations: recommendations))
                }
                
                User.instance.queryHistory.setQuerySolutionsForQueryID(solutions, queryID: queryID)
                                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
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
                
                if !NetworkDAO.responseHasExpectedStatusCode(response, expectedStatusCode: 201, funcName: "postNewQuery") {
                    NetworkQueue.instance.tryAgain()
                    return
                }
                
                guard let queryDict: NSDictionary = NetworkDAO.getNSDictionaryFromJSONdata(data, funcName: "postNewQuery") else {
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
                
                guard let solutions: [Solution] = self!.parseSolutions(solutionsArray, funcName: "postNewQuery") else {
                    NetworkQueue.instance.tryAgain()
                    return
                }
                
                guard let timestampString: String = queryDict["timestamp"] as? String else {
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
                newQuery.solutions = solutions                
                User.instance.queryHistory.appendQuery(newQuery)
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self?.networkDAODelegate?.newQueryFetched(newQuery.ID)
                    NetworkQueue.instance.dequeue()
                })
            }).resume()
        
    }
    
    func postNewRecommendtaion(description: String, comments: String, recommendationTags: [String]) {
        NetworkQueue.instance.enqueue(NetworkTask(task: {
            [weak self] () -> Void in
            self?._postNewRecommendtaion(description, comments: comments, recommendationTags: recommendationTags)
        }, description: "postNewRecommendtaion()"))
    }
    
    private func _postNewRecommendtaion(description: String, comments: String, recommendationTags: [String]) {
        guard let token = self.friendsBestToken else {
            postFacebookTokenAndAuthenticate()
            NSLog("User has not authenticated")
            return
        }
        
        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = ["Authorization": token]
        let session: NSURLSession = NSURLSession(configuration: configuration)
        
        let queryString: String = "recommend/"
        let queryURL: NSURL! = NSURL(string: queryString, relativeToURL: friendsBestAPIurl)
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: queryURL)
        let json = ["description": description, "comments" : comments, "tags": recommendationTags, ]
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
//                [weak self]
                (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                
                if let error = error {
                    NSLog("Error - FriendsBest API - postNewRecommendation() - \(error.localizedDescription)")
                    NetworkQueue.instance.tryAgain()
                    return
                }
                
                if !NetworkDAO.responseHasExpectedStatusCode(response, expectedStatusCode: 201, funcName: "postNewRecommendation") {
                    NetworkQueue.instance.tryAgain()
                    return
                }
                
//                guard let recommendationDict: NSDictionary = NetworkDAO.getNSDictionaryFromJSONdata(data, funcName: "postNewRecommendation") else {
//                    return
//                }
//                
//                guard let recommendationIdDict: NSDictionary = recommendationDict["recommendationId"] as? NSDictionary else {
//                    NSLog("Error - FriendsBest API - postNewRecommendation() - recommendationId not in JSON dictionary")
//                    return
//                }
//                
//                guard let description: String = recommendationIdDict["description"] as? String else {
//                    NSLog("Error - FriendsBest API - postNewRecommendation() - decription not in JSON dictionary")
//                    return
//                }
//                
//                guard let tags: [String] = recommendationIdDict["tags"] as? [String] else {
//                    NSLog("Error - FriendsBest API - postNewRecommendation() - tags not in JSON dictionary")
//                    return
//                }
//                
//                guard let comments: String = recommendationIdDict["comments"] as? String else {
//                    NSLog("Error - FriendsBest API - postNewRecommendation() - comments not in JSON dictionary")
//                    return
//                }
//                
//                guard let id: Int = recommendationIdDict["id"] as? Int else {
//                    NSLog("Error - FriendsBest API - postNewRecommendation() - id not in JSON dictionary")
//                    return
//                }
                
                // TODO: Do something?
                NetworkQueue.instance.dequeue()

        }).resume()
    }
    
    func getPrompt() {
        NetworkQueue.instance.enqueue(NetworkTask(task: {
            [weak self] () -> Void in
            self?._getPrompt()
            }, description: "getPrompts()"))
    }
    
    private func _getPrompt() {
        guard let token = self.friendsBestToken else {
            postFacebookTokenAndAuthenticate()
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
                
                if !NetworkDAO.responseHasExpectedStatusCode(response, expectedStatusCode: 200, funcName: "getPrompts") {
                    NetworkQueue.instance.tryAgain()
                    return
                }
                
                guard let promptArray: NSArray = NetworkDAO.getNSArrayFromJSONdata(data, funcName: "getPrompts") else {
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
                    let friend: String? = promptDict["friend"] as? String
                    let ID: Int? = promptDict["id"] as? Int
                    let tagString: String? = promptDict["tagstring"] as? String
                    
                    guard let validArticle = article, let validTags = tags, let validFriend = friend, let validID = ID, let validTagString = tagString else {
                            NSLog("Error - FriendsBest API - getPrompts() - Invalid JSON")
                            NetworkQueue.instance.tryAgain()
                            return
                    }
                    
                    prompts.append(Prompt(article: validArticle, tags: validTags, tagString: validTagString, friend: validFriend, ID: validID))
                }
                
                User.instance.prompts = prompts
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self?.networkDAODelegate?.promptsFetched()
                    NetworkQueue.instance.dequeue()
                })
                
            }).resume()
    }
    
    func postFacebookTokenAndAuthenticate() {
        NetworkQueue.instance.enqueue(NetworkTask(task: { () -> Void in
            self._postFacebookTokenAndAuthenticate()
        }, description: "postFacebookTokenAndAuthenticate()"))
    }
    
    private func _postFacebookTokenAndAuthenticate() {
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
                
                if !NetworkDAO.responseHasExpectedStatusCode(response, expectedStatusCode: 200, funcName: "postFacebookToken") {
                    NetworkQueue.instance.tryAgain()
                    return
                }
                
                guard let keyDict: NSDictionary = NetworkDAO.getNSDictionaryFromJSONdata(data, funcName: "postFacebookToken") else {
                    NetworkQueue.instance.tryAgain()
                    return
                }
                
                guard let key: NSString = keyDict["key"] as? NSString else {
                    NSLog("Error - FriendsBest API - postFacebookToken() - key not in JSON dictionary")
                    NetworkQueue.instance.tryAgain()
                    return
                }
                
                self?.friendsBestToken = "Token " + (key as String)
                
                NetworkQueue.instance.dequeue()
            }).resume()
    }
    
    private func parseSolutions(solutionsArray: [NSDictionary], funcName: String) -> [Solution]? {
        var solutions: [Solution] = []
        
        for solutionDict in solutionsArray {
            guard let validSolutionDict: NSDictionary = solutionDict else {
                NSLog("Error - FriendsBest API - \(funcName)() - Invalid JSON object")
                return nil
            }
            
            let solutionName: String? = validSolutionDict["name"] as? String
            let recommendationArray: [NSDictionary]? = validSolutionDict["recommendation"] as? [NSDictionary]
            
            guard let validSolutionName = solutionName, let validRecommendationArray = recommendationArray else {
                NSLog("Error - FriendsBest API - \(funcName)() - Invalid JSON")
                return nil
            }
            
            var recommendations: [Recommendation] = []
            
            for recommendation: NSDictionary in validRecommendationArray {
                let comment: String? = recommendation["comment"] as? String
                let userName: String? = recommendation["name"] as? String
                
                guard let validComment = comment, validUserName = userName else {
                    NSLog("Error - FriendsBest API - \(funcName)() - Invalid JSON")
                    return nil
                }
                
                let newRecommendation: Recommendation = Recommendation(userName: validUserName, comment: validComment)
                recommendations.append(newRecommendation)
            }
            
            solutions.append(Solution(name: validSolutionName, recommendations: recommendations))
        }
        
        return solutions
    }
    
    private static func responseHasExpectedStatusCode(response: NSURLResponse?, expectedStatusCode: Int, funcName: String) -> Bool {
        guard let response = response else {
            NSLog("Error - FriendsBest API - \(funcName)() - No response")
            return false
        }
        
        if let response = response as? NSHTTPURLResponse {
            if response.statusCode == expectedStatusCode {
                return true
            } else if response.statusCode == 500 {
                fatalError("Server error")
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













































