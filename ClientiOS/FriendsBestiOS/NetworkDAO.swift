//
//  NetworkDataModel.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 1/12/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import Foundation
import CoreData


protocol NetworkDAODelegate: class {
    func queriesFetched()
    func querySolutionsFetched(forQueryID queryID: Int)
    func newQueryFetched(queryID: Int)
}


class NetworkDAO {
    
    /* Singleton instance */
    static let instance: NetworkDAO = NetworkDAO()
    
    /* Instance members */    
    #if DEBUG
    private let friendsBestAPIurl: NSURL! = NSURL(string: "http://localhost:8000/fb/api/")
    #else
    private let friendsBestAPIurl: NSURL! = NSURL(string: "https://www.friendsbest.net/fb/api/")
    #endif
    
    /* Delegation */
    weak var networkDAODelegate: NetworkDAODelegate? = nil
    
    /* Private constructor */
    private init() { }
    
    
    func testAPIconnection() {
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        session.dataTaskWithURL(friendsBestAPIurl,
            completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                // Closure does not execute on the main thread.
                // NSLog(NSThread.isMainThread().description)
                
                if error != nil {
                    NSLog("API error: \(error)")
                    return
                }
                
                if let data = data {
                    do {
                        try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
                        NSLog("API connection successful")
                    } catch _ {
                        NSLog("API error. Unable to parse JSON.")
                    }
                }
        }).resume()
    }
    
    func getQueries() {
        let queryString: String = "query/"
        let queryURL: NSURL? = NSURL(string: queryString, relativeToURL: friendsBestAPIurl)
        
        guard let validQueryURL = queryURL else {
            NSLog("Error - FriendsBest API - getQueries() - Bad query URL")
            return
        }
        
        let session: NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        session.dataTaskWithURL(validQueryURL,
            completionHandler: {
                [weak self] (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                
                if let error = error {
                    NSLog("Error - FriendsBest API - getQueries() - \(error)")
                    return
                }
                
                if !NetworkDAO.responseHasExpectedStatusCode(response, expectedStatusCode: 200, funcName: "getQueries") {
                    return
                }
                
                guard let queriesArray: NSArray = NetworkDAO.getNSArrayFromJSONdata(data, funcName: "getQueries") else {
                    return
                }
                
                var queries: [Query] = []
                
                for queryDict in queriesArray {
                    guard let validQueryDict: NSDictionary = queryDict as? NSDictionary else {
                        NSLog("Error - FriendsBest API - getQueries - Invalid JSON object")
                        return
                    }
                    
                    let tags: [String]? = validQueryDict["tags"] as? [String]
                    let id: Int? = validQueryDict["id"] as? Int
                    let timestampString: String? = validQueryDict["timestamp"] as? String
                    
                    guard let validTags = tags, let validId = id, let validTimestampString = timestampString,
                        let validTimestamp: NSDate = self!.convertTimestampStringToNSDate(validTimestampString) else {
                            NSLog("Error - FriendsBest API - getQueries() - Invalid JSON")
                            return
                    }
                    
                    queries.append(Query(tags: validTags, ID: validId, timestamp: validTimestamp))
                }
                
                for query in queries {
                    User.instance.queryHistory.appendQuery(query)
                }
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self?.networkDAODelegate?.queriesFetched()
                })
                
            }).resume()
    }
    
    func getQuerySolutions(queryID: Int) {
        let queryString: String = "query/\(queryID)"
        let queryURL: NSURL! = NSURL(string: queryString, relativeToURL: friendsBestAPIurl)
        let session: NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        session.dataTaskWithURL(queryURL,
            completionHandler: {
                [weak self] (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                
                if let error = error {
                    NSLog("Error - FriendsBest API - getQuerySolutions() - \(error)")
                    return
                }
                
                if !NetworkDAO.responseHasExpectedStatusCode(response, expectedStatusCode: 200, funcName: "getQuerySolutions") {
                    return
                }
                
                guard let validQueryDict = NetworkDAO.getNSDictionaryFromJSONdata(data, funcName: "getQuerySolutions") else {
                    return
                }
                
                guard let solutionsDict = validQueryDict["solutions"] as? [NSDictionary] else {
                    NSLog("Error - FriendsBest API - getQuerySolutions() - Invalid JSON")
                    return
                }
                
                var solutions: [Solution] = []
                
                for solutionDict in solutionsDict {
                    guard let validSolutionDict: NSDictionary = solutionDict else {
                        NSLog("Error - FriendsBest API - getQuerySolutions() - Invalid JSON object")
                        return
                    }
                    
                    let solutionName: String? = validSolutionDict["name"] as? String
                    let recommendationArray: [NSDictionary]? = validSolutionDict["recommendation"] as? [NSDictionary]
                    
                    guard let validSolutionName = solutionName, let validRecommendationArray = recommendationArray else {
                        NSLog("Error - FriendsBest API - getQuerySolutions() - Invalid JSON")
                        return
                    }
                    
                    var recommendations: [Recommendation] = []
                    
                    for recommendation: NSDictionary in validRecommendationArray {
                        let comment: String? = recommendation["comment"] as? String
                        let userName: String? = recommendation["name"] as? String
                        
                        guard let validComment = comment, validUserName = userName else {
                            NSLog("Error - FriendsBest API - getQuerySolutions() - Invalid JSON")
                            return
                        }
                        
                        let newRecommendation: Recommendation = Recommendation(userName: validUserName, comment: validComment)
                        recommendations.append(newRecommendation)
                    }
                    
                    solutions.append(Solution(name: validSolutionName, recommendations: recommendations))
                }
                
                for query in User.instance.queryHistory.queries {
                    if query.ID == queryID {
                        query.solutions = solutions
                        break
                    }
                }
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self?.networkDAODelegate?.querySolutionsFetched(forQueryID: queryID)
                })
                
            }).resume()
    }
    
    func postNewQuery(queryTags: [String]) {
        let queryString: String = "query/"
        let queryURL: NSURL! = NSURL(string: queryString, relativeToURL: friendsBestAPIurl)
        let session: NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: queryURL)
        let json = ["tags": queryTags, "user": 1]
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
                    return
                }
                
                if !NetworkDAO.responseHasExpectedStatusCode(response, expectedStatusCode: 201, funcName: "postNewQuery") {
                    return
                }
                
                guard let queryDict: NSDictionary = NetworkDAO.getNSDictionaryFromJSONdata(data, funcName: "postNewQuery") else {
                    return
                }
                
                guard let id: Int = queryDict["id"] as? Int else {
                    NSLog("Error - FriendsBest API - postNewQuery() - Invalid JSON: id not in dictionary")
                    return
                }
                
                guard let tags: [String] = queryDict["tags"] as? [String] else {
                    NSLog("Error - FriendsBest API - postNewQuery() - Invalid JSON: tags not in dictionary")
                    return
                }
                
                guard let solutionsArray: [NSDictionary] = queryDict["solutions"] as? [NSDictionary] else {
                    NSLog("Error - FriendsBest API - postNewQuery() - Invalid JSON: solutions not in dictionary")
                    return
                }
                
                guard let solutions: [Solution] = self!.parseSolutions(solutionsArray, funcName: "postNewQuery") else {
                    return
                }
                
                // TODO: THIS API SHOULD RETURN A TIMESTAMP!
                let newQuery: Query = Query(tags: tags, ID: id, timestamp: NSDate())
                newQuery.solutions = solutions                
                User.instance.queryHistory.appendQuery(newQuery)
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self?.networkDAODelegate?.newQueryFetched(newQuery.ID)
                })
            }).resume()
        
    }
    
    func postNewRecommendtaion(description: String, comments: String, recommendationTags: [String]) {
        let queryString: String = "recommend/"
        let queryURL: NSURL! = NSURL(string: queryString, relativeToURL: friendsBestAPIurl)
        let session: NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: queryURL)
        let json = ["user": 1, "description": description, "comments" : comments, "tags": recommendationTags, ]
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
                [weak self] (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                
                if let error = error {
                    NSLog("Error - FriendsBest API - postNewRecommendation() - \(error.localizedDescription)")
                    return
                }
                
                if !NetworkDAO.responseHasExpectedStatusCode(response, expectedStatusCode: 201, funcName: "postNewRecommendation") {
                    return
                }
                
                guard let recommendationDict: NSDictionary = NetworkDAO.getNSDictionaryFromJSONdata(data, funcName: "postNewRecommendation") else {
                    return
                }
                
                guard let recommendationIdDict: NSDictionary = recommendationDict["recommendationId"] as? NSDictionary else {
                    NSLog("Error - FriendsBest API - postNewRecommendation() - recommendationId not in JSON dictionary")
                    return
                }
                
                guard let description: String = recommendationIdDict["description"] as? String else {
                    NSLog("Error - FriendsBest API - postNewRecommendation() - decription not in JSON dictionary")
                    return
                }
                
                guard let tags: [String] = recommendationIdDict["tags"] as? [String] else {
                    NSLog("Error - FriendsBest API - postNewRecommendation() - tags not in JSON dictionary")
                    return
                }
                
                guard let comments: String = recommendationIdDict["comments"] as? String else {
                    NSLog("Error - FriendsBest API - postNewRecommendation() - comments not in JSON dictionary")
                    return
                }
                
                guard let id: Int = recommendationIdDict["id"] as? Int else {
                    NSLog("Error - FriendsBest API - postNewRecommendation() - id not in JSON dictionary")
                    return
                }
                
                // TODO: Do something?

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
    
    private static func responseHasExpectedStatusCode(response: NSURLResponse?, expectedStatusCode statusCode: Int, funcName: String) -> Bool {
        guard let response = response else {
            NSLog("Error - FriendsBest API - \(funcName)() - No response")
            return false
        }
        
        if let response = response as? NSHTTPURLResponse {
            if response.statusCode == statusCode {
                return true
            } else {
                NSLog("Error - FriendsBest API - \(funcName)() - Status code \(response.statusCode) not expected \(statusCode)")
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












































