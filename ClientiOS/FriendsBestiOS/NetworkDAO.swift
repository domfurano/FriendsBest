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


class NetworkDAO {
    
    /* Singleton instance */
    static let instance: NetworkDAO = NetworkDAO()
    
    /* Instance members */
    private let friendsBestAPIurl: NSURL! = NSURL(string: "https://www.friendsbest.net/fb/api/")
    
    /* Delegation */
    weak var queriesFetchedDelegate: QueriesFetchedDelegate? = nil
    weak var querySolutionsFetchedDelegate: QuerySolutionsFetchedDelegate? = nil
    
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
                        let validTimestamp: NSDate = NetworkDAO.convertTimestampStringToNSDate(validTimestampString) else {
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
        let jsonData: NSData
        
        do {
            jsonData = try NSJSONSerialization.dataWithJSONObject(queryTags, options: NSJSONWritingOptions())
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
                
                if let validError = error {
                    NSLog("Error - FriendsBest API - postNewQuery() - \(validError.localizedDescription)")
                    return
                }
                print(response!)
                print(data!)
            }).resume()
        
    }
    
    private static func convertTimestampStringToNSDate(timestampString: String) -> NSDate? {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.dateFromString(timestampString)
    }
}













































