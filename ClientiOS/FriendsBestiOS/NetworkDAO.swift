//
//  NetworkDataModel.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 1/12/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import Foundation
import CoreData


protocol QueriesFetchedDelegate: class {
    func queriesFetched(queries: QueryHistory)
}

protocol QuerySolutionsFetchedDelegate: class {
    func querySolutionsFetched(forQueryID queryID: Int, solutions: [Solution])
}

protocol NewQueryFetchedDelegate: class {
    func newQueryFetched(query: Query)
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
    weak var queriesFetchedDelegate: QueriesFetchedDelegate? = nil
    weak var querySolutionsFetchedDelegate: QuerySolutionsFetchedDelegate? = nil
    weak var newQueryFetchedDelegate: NewQueryFetchedDelegate? = nil
    
    /* Private constructor */
    private init() { }
    
    
    func testAPIconnection() {
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        session.dataTaskWithURL(friendsBestAPIurl,
            completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                // Closure does not execute on the main thread.
                // NSLog(NSThread.isMainThread().description)
                
                if error != nil {
                    NSLog("API error.")
                    return
                }
                
                if let validData = data {
                    do {
                        try NSJSONSerialization.JSONObjectWithData(validData, options: NSJSONReadingOptions())
                        NSLog("API connection successful")
                    } catch _ {
                        NSLog("API error. Unable to parse JSON.")
                    }
                }
        }).resume()
    }
    
    func getQueries() {
        let queryString: String = "query/"
        let queryURL: NSURL! = NSURL(string: queryString, relativeToURL: friendsBestAPIurl)
        let session: NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        session.dataTaskWithURL(queryURL,
            completionHandler: {
                [weak self] (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                
                if let validError = error {
                    NSLog("Error - FriendsBest API - getQueries() - \(validError.localizedDescription)")
                    return
                }
                
                guard let validData = data else {
                    NSLog("Error - FriendsBest API - getQuery() - Invalid data")
                    return
                }
                
                let queriesArray: NSArray?
                do {
                    queriesArray = try NSJSONSerialization.JSONObjectWithData(validData, options: NSJSONReadingOptions()) as? NSArray
                } catch {
                    NSLog("Error - FriendsBest API - getQueries() - Unable to parse JSON - \(error)")
                    return
                }
                
                guard let validQueriesArray: NSArray = queriesArray else {
                    NSLog("Error - FriendsBest API - getQueries() - Invalid JSON")
                    return
                }
                
                // TODO: decouple this from the data model
                let queryHistory: QueryHistory = QueryHistory()
                
                for queryDict in validQueriesArray {
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
                    
                    queryHistory.queries.append(Query(tags: validTags, ID: validId, timestamp: validTimestamp))
                }
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self?.queriesFetchedDelegate?.queriesFetched(queryHistory)
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
                
                if let validError = error {
                    NSLog("Error - FriendsBest API - getQuery() - \(validError.localizedDescription)")
                    return
                }
                
                guard let validData = data else {
                    NSLog("Error - FriendsBest API - getQuery() - Invalid data")
                    return
                }
                
                let queryDict: NSDictionary?
                do {
                    queryDict = try NSJSONSerialization.JSONObjectWithData(validData, options: NSJSONReadingOptions()) as? NSDictionary
                } catch {
                    NSLog("Error - FriendsBest API - getQuery() - Unable to parse JSON - \(error)")
                    return
                }
                
                guard let validQueryDict = queryDict else {
                    NSLog("Error - FriendsBest API - getQuery() - Invalid JSON")
                    return
                }
                
                let solutionsDict: [NSDictionary]? = validQueryDict["solutions"] as? [NSDictionary]
                
                guard let validSolutionsDict = solutionsDict else {
                    NSLog("Error - FriendsBest API - getQuery() - Invalid JSON")
                    return
                }
                
                // ToDo: decouple this from the data model.
                var solutions: [Solution] = []
                
                for solutionDict in validSolutionsDict {
                    guard let validSolutionDict: NSDictionary = solutionDict else {
                        NSLog("Error - FriendsBest API - getQuery() - Invalid JSON object")
                        return
                    }
                    
                    let solutionName: String? = validSolutionDict["name"] as? String
                    let recommendationArray: [NSDictionary]? = validSolutionDict["recommendation"] as? [NSDictionary]
                    
                    guard let validSolutionName = solutionName, let validRecommendationArray = recommendationArray else {
                        NSLog("Error - FriendsBest API - getQuery() - Invalid JSON")
                        return
                    }
                    
                    var recommendations: [Recommendation] = []
                    
                    for recommendation: NSDictionary in validRecommendationArray {
                        let comment: String? = recommendation["comment"] as? String
                        let userName: String? = recommendation["name"] as? String
                        
                        guard let validComment = comment, validUserName = userName else {
                            NSLog("Error - FriendsBest API - getQuery() - Invalid JSON")
                            return
                        }
                        
                        let newRecommendation: Recommendation = Recommendation(userName: validUserName, comment: validComment)
                        recommendations.append(newRecommendation)
                    }
                    
                    solutions.append(Solution(name: validSolutionName, recommendations: recommendations))
                }
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self?.querySolutionsFetchedDelegate?.querySolutionsFetched(forQueryID: queryID, solutions: solutions)
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
                
                guard let data = data else {
                    NSLog("Error - FriendsBest API - postNewQuery() - Invalid data")
                    return
                }
                
                guard let queryDict = self!.getNSDictionaryFromJSONdata(data, funcName: "postNewQuery") else {
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
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self?.newQueryFetchedDelegate?.newQueryFetched(newQuery)
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
                
                guard let response = response else {
                    NSLog("Error - FriendsBest API - postNewRecommendation() - No response")
                    return
                }
                
                if let response = response as? NSHTTPURLResponse {
                    if response.statusCode != 201 {
                        NSLog("Error - FriendsBest API - postNewRecommendation() - Status code not 201")
                        return
                    }
                }
                
                guard let data = data else {
                    NSLog("Error - FriendsBest API - postNewRecommendation() - Invalid data")
                    return
                }
                
                guard let recommendationDict: NSDictionary = self!.getNSDictionaryFromJSONdata(data, funcName: "postNewRecommendation") else {
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
                
                // Do something?

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
    
    private func getNSDictionaryFromJSONdata(data: NSData, funcName: String) -> NSDictionary? {
        var queryDict: NSDictionary? = nil
        do {
            queryDict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? NSDictionary
        } catch {
            NSLog("Error - FriendsBest API - \(funcName) - Unable to parse JSON - \(error)")
        }
        return queryDict
    }
    
    private func convertTimestampStringToNSDate(timestampString: String) -> NSDate? {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.dateFromString(timestampString)
    }
}













































