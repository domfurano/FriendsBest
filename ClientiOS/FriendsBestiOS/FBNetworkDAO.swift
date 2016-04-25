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
    func promptsFetched(prompts: [Prompt])
    func promptDeleted(prompt: Prompt)
    func queryFetched(query: Query)
    func queriesFetched(queries: [Query])
    func queryDeleted(query: Query)
    func querySolutionsFetched(forYourQuery query: Query, solutions: [Solution])
    func userRecommendationFetched(userRecommendation: UserRecommendation)
    func userRecommendationsFetched(userRecommendations: [UserRecommendation])
    func userRecommendationDeleted(userRecommendation: UserRecommendation)
    func friendsFetched(friends: [Friend])
    func friendMutingSet(friend: Friend, muted: Bool)
}


class FBNetworkDAO {
    
    // MARK: singleton instance
    static let instance: FBNetworkDAO = FBNetworkDAO()
    
    // MARK: properties
    private let friendsBestAPIurl: NSURL! = NSURL(string: "https://www.friendsbest.net/fb/api/")
    private var friendsBestToken: String? = nil
    private let jsonReadingOptions: NSJSONReadingOptions = NSJSONReadingOptions()
    private let dateFormatter: NSDateFormatter = NSDateFormatter()
    
    // MARK: delegation
    weak var networkDAODelegate: NetworkDAODelegate? = nil
    var getFriend: ((facebookID: String, name: String, muted: Bool?) -> Friend)? = nil
    var authenticatedWithFriendsBestServerDelegate: () -> Void = { }
    
    // MARK: constructor
    private init() { }
    
    
    // MARK: Queries
    func getQueries(callback: (() -> Void)?) {
        NetworkQueue.instance.enqueue(NetworkTask(task: {
            [weak self] () -> Void in
            self?._getQueries(false, callback: callback)
            }, description: "getQueries()"))
    }
    
    func _getQueries(async: Bool, callback: (() -> Void)?) {
        guard let token = self.friendsBestToken else {
            postFacebookTokenAndAuthenticate(nil)
            if !async {
                NetworkQueue.instance.tryAgain()
            }
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
        
        session.dataTaskWithURL(validQueryURL, completionHandler: {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let error = error {
                if !async {
                    NetworkQueue.instance.tryAgain()
                }
                NSLog("Error - FriendsBest API - getQueries() - \(error.description)")
                return
            }
            
            if !self.responseHasExpectedStatusCodes(response, expectedStatusCodes: [200], funcName: "getQueries") {
                if !async {
                    NetworkQueue.instance.tryAgain()
                }
                return
            }
            
            let queriesArray: [NSDictionary] = self.getNSArrayFromJSONdata(data, funcName: "getQueries") as! [NSDictionary]
            
            var queries: [Query] = []
            for queryDict: NSDictionary in queriesArray {
                let query: Query = self.getQuery(queryDict)
                queries.append(query)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.networkDAODelegate?.queriesFetched(queries)
                callback?()
            })
            if !async {
                NetworkQueue.instance.dequeue()
            }
        }).resume()
    }
    
    func postNewQuery(queryTags: [String], callback: (() -> Void)?) {
        NetworkQueue.instance.enqueue(NetworkTask(task: {
            [weak self] () -> Void in
            self?._postNewQuery(queryTags, callback: callback)
            }, description: "postNewQuery()"))
    }
    
    private func _postNewQuery(queryTags: [String], callback: (() -> Void)?) {
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
        
        session.dataTaskWithRequest(request, completionHandler: {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let error = error {
                NSLog("Error - FriendsBest API - postNewQuery() - \(error.localizedDescription)")
                NetworkQueue.instance.tryAgain()
                return
            }
            
            if !self.responseHasExpectedStatusCodes(response, expectedStatusCodes: [201], funcName: "postNewQuery") {
                NetworkQueue.instance.tryAgain()
                return
            }
            
            guard let queryDict: NSDictionary = self.getNSDictionaryFromJSONdata(data, funcName: "postNewQuery") else {
                NetworkQueue.instance.tryAgain()
                return
            }
            
            let query: Query = self.getQuery(queryDict)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.networkDAODelegate?.queryFetched(query)
                callback?()
            })
            NetworkQueue.instance.dequeue()
        }).resume()
    }
    
    func deleteQuery(query: Query, callback: (() -> Void)?) {
        NetworkQueue.instance.enqueue(NetworkTask(task: {
            [weak self] () -> Void in
            self?._deleteQuery(query, callback: callback)
            }, description: "deleteQuery()"))
    }
    
    private func _deleteQuery(query: Query, callback: (() -> Void)?) {
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
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: queryURL)
        
        request.HTTPMethod = "DELETE"
        
        session.dataTaskWithRequest(request, completionHandler: {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let error = error {
                NSLog("Error - FriendsBest API - deleteQuery() - \(error.localizedDescription)")
                NetworkQueue.instance.tryAgain()
                return
            }
            
            if !self.responseHasExpectedStatusCodes(response, expectedStatusCodes: [204], funcName: "deleteQuery") {
                NetworkQueue.instance.tryAgain()
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.networkDAODelegate?.queryDeleted(query)
                callback?()
            })
            NetworkQueue.instance.dequeue()
        }).resume()
    }
    
    private func getQuery(queryDictionary: NSDictionary) -> Query {
        let ID: Int = queryDictionary["id"] as! Int
        let accessed: NSDate = convertTimestampStringToNSDate(queryDictionary["accessed"] as! String)!
        let tags: [String] = queryDictionary["tags"] as! [String]
        let tagString: String = queryDictionary["tagstring"] as! String
        let tagHash: String = queryDictionary["taghash"] as! String
        let notificationCount: Int = queryDictionary["notifications"] as! Int
        let solutionsDict: [NSDictionary] = queryDictionary["solutions"] as! [NSDictionary]
        let solutions: [Solution] = parseSolutions(solutionsDict)
        
        let query: Query = Query(
            ID: ID,
            accessed: accessed,
            tags: tags,
            tagString: tagString,
            tagHash: tagHash,
            solutions: solutions,
            notificationCount: notificationCount
        )
        
        return query
    }
    
    
    // MARK: Friends
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
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: validQueryURL)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        session.dataTaskWithRequest(request, completionHandler: {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let error = error {
                NetworkQueue.instance.tryAgain()
                NSLog("Error - FriendsBest API - getQueries() - \(error)")
                return
            }
            
            if !self.responseHasExpectedStatusCodes(response, expectedStatusCodes: [200], funcName: "getQueries") {
                NetworkQueue.instance.tryAgain()
                return
            }
            
            let friendsArray: [NSDictionary] = self.getNSArrayFromJSONdata(data, funcName: "getQueries") as! [NSDictionary]
            
            var friends: [Friend] = []
            for friendDict: NSDictionary in friendsArray {
                let name: String = friendDict["name"] as! String
                let id: String = friendDict["id"] as! String
                let muted: Bool = friendDict["muted"] as! Bool
                let friend: Friend = Friend(facebookID: id, name: name, muted: muted)
                friends.append(friend)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.networkDAODelegate?.friendsFetched(friends)
                callback?()
            })
            NetworkQueue.instance.dequeue()
        }).resume()
    }
    
    func setMutingForFriend(friend: Friend, mute: Bool, callback: (() -> Void)?) {
        NetworkQueue.instance.enqueue(NetworkTask(task: {
            [weak self] () -> Void in
            self?._setMutingForFriend(friend, mute: mute, callback: callback)
            }, description: "setMutingForFriend()"))
    }
    
    private func _setMutingForFriend(friend: Friend, mute: Bool, callback: (() -> Void)?) {
        guard let token = self.friendsBestToken else {
            postFacebookTokenAndAuthenticate(nil)
            NetworkQueue.instance.tryAgain()
            NSLog("User has not authenticated")
            return
        }
        
        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = ["Authorization": token]
        let session: NSURLSession = NSURLSession(configuration: configuration)
        
        let queryString: String = "friend/\(friend.facebookID)/"
        let queryURL: NSURL! = NSURL(string: queryString, relativeToURL: friendsBestAPIurl)
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: queryURL)
        
        let json = ["muted": mute]
        let jsonData: NSData
        do {
            jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions())
        } catch {
            NSLog("Error - FriendsBest API - setMutingForFriend() - Couldn't convert tags to JSON")
            return
        }
        request.HTTPMethod = "PUT"
        request.HTTPBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        session.dataTaskWithRequest(request, completionHandler: {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let error = error {
                NSLog("Error - FriendsBest API - setMutingForFriend() - \(error.localizedDescription)")
                NetworkQueue.instance.tryAgain()
                return
            }
            
            if !self.responseHasExpectedStatusCodes(response, expectedStatusCodes: [200], funcName: "setMutingForFriend") {
                NetworkQueue.instance.tryAgain()
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.networkDAODelegate?.friendMutingSet(friend, muted: mute)
                callback?()
            })
            NetworkQueue.instance.dequeue()
        }).resume()
    }
    
    
    // Mark: Solutions
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
        
        session.dataTaskWithURL(queryURL, completionHandler: {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let error = error {
                NSLog("Error - FriendsBest API - getQuerySolutions() - \(error)")
                NetworkQueue.instance.tryAgain()
                return
            }
            
            if !self.responseHasExpectedStatusCodes(response, expectedStatusCodes: [200], funcName: "getQuerySolutions") {
                NetworkQueue.instance.tryAgain()
                return
            }
            
            let queryDict: NSDictionary = self.getNSDictionaryFromJSONdata(data, funcName: "getQuerySolutions")!
            
            let solutionsDictArray: [NSDictionary] = queryDict["solutions"] as! [NSDictionary]
            
            let solutions: [Solution] = self.parseSolutions(solutionsDictArray)
            
            for solution: Solution in solutions {
                solution.query = query
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.networkDAODelegate?.querySolutionsFetched(forYourQuery: query, solutions: solutions)
                callback?()
            })
            NetworkQueue.instance.dequeue()
            
        }).resume()
    }
    
    
    // MARK: Recommendation
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
        
        session.dataTaskWithURL(queryURL, completionHandler: {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let error = error {
                NSLog("Error - FriendsBest API - getRecommendationsForUser() - \(error)")
                NetworkQueue.instance.tryAgain()
                return
            }
            
            if !self.responseHasExpectedStatusCodes(response, expectedStatusCodes: [200], funcName: "getRecommendationsForUser") {
                NetworkQueue.instance.tryAgain()
                return
            }
            
            let validRecommendationsArray: [NSDictionary] = self.getNSArrayFromJSONdata(data, funcName: "getRecommendationsForUser")! as! [NSDictionary]
            
            var userRecommendations: [UserRecommendation] = []
            
            for recDict: NSDictionary in validRecommendationsArray {
                let userRecommendation: UserRecommendation = self.getUserRecommendations(recDict)
                userRecommendations.append(userRecommendation)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.networkDAODelegate?.userRecommendationsFetched(userRecommendations)
                callback?()
            })
            NetworkQueue.instance.dequeue()
            
        }).resume()
    }
    
    func postNewRecommendtaion(newRecommendation: NewRecommendation, callback: (() -> Void)?) {
        NetworkQueue.instance.enqueue(NetworkTask(task: {
            [weak self] () -> Void in
            self?._postNewRecommendtaion(newRecommendation, callback: callback)
            }, description: "postNewRecommendtaion()"))
    }
    
    private func _postNewRecommendtaion(newRecommendation: NewRecommendation, callback: (() -> Void)?) {
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
            "detail": newRecommendation.detail!,
            "type": newRecommendation.type!.rawValue,
            "comments" : newRecommendation.comments != nil ? newRecommendation.comments! : "",
            "tags": newRecommendation.tags!
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
        
        session.dataTaskWithRequest(request, completionHandler: {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let error = error {
                NSLog("Error - FriendsBest API - postNewRecommendation() - \(error.localizedDescription)")
                NetworkQueue.instance.tryAgain()
                return
            }
            
            // The server is still saving data even after sending a 500 error... :(
            if !self.responseHasExpectedStatusCodes(response, expectedStatusCodes: [201, 500], funcName: "postNewRecommendation") {
                NetworkQueue.instance.tryAgain()
                return
            }
            
            let userRecommendationDict: NSDictionary = self.getNSDictionaryFromJSONdata(data, funcName: "postNewRecommendtaion")!
            let userRecommendation: UserRecommendation = self.getUserRecommendations(userRecommendationDict)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.networkDAODelegate?.userRecommendationFetched(userRecommendation)
                callback?()
            })
            
            NetworkQueue.instance.dequeue()
        }).resume()
    }
    
    
    func deleteUserRecommendation(userRecommendation: UserRecommendation, callback: (() -> Void)?) {
        NetworkQueue.instance.enqueue(NetworkTask(task: {
            [weak self] () -> Void in
            self?._deleteUserRecommendation(userRecommendation, callback: callback)
            }, description: "deleteRecommendation()"))
    }
    
    private func _deleteUserRecommendation(userRecommendation: UserRecommendation, callback: (() -> Void)?) {
        guard let token = self.friendsBestToken else {
            postFacebookTokenAndAuthenticate(nil)
            NetworkQueue.instance.tryAgain()
            NSLog("User has not authenticated")
            return
        }
        
        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = ["Authorization": token]
        let session: NSURLSession = NSURLSession(configuration: configuration)
        
        let queryString: String = "recommend/\(userRecommendation.ID)/"
        let queryURL: NSURL! = NSURL(string: queryString, relativeToURL: friendsBestAPIurl)
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: queryURL)
        
        request.HTTPMethod = "DELETE"
        //        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        session.dataTaskWithRequest(request, completionHandler: {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let error = error {
                NSLog("Error - FriendsBest API - deleteRecommendation() - \(error.localizedDescription)")
                NetworkQueue.instance.dequeue()
                return
            }
            
            if !self.responseHasExpectedStatusCodes(response, expectedStatusCodes: [204], funcName: "deleteRecommendation") {
                NetworkQueue.instance.dequeue()
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.networkDAODelegate?.userRecommendationDeleted(userRecommendation)
                callback?()
            })
            NetworkQueue.instance.dequeue()
        }).resume()
    }
    
    
    func putRecommendation(newRecommendation: NewRecommendation, callback: (() -> Void)?) {
        deleteUserRecommendation(newRecommendation.userRecommendation()) {
            self.postNewRecommendtaion(newRecommendation, callback: {
                callback?()
            })
        }
    }
    
    private func getUserRecommendations(recommendationDict: NSDictionary) -> UserRecommendation {
        let ID: Int = recommendationDict["id"] as! Int
        let tags: [String] = recommendationDict["tags"] as! [String]
        let detail: String = recommendationDict["detail"] as! String
        let comments: String = recommendationDict["comments"] as! String
        let type: SolutionType = SolutionType(rawValue: recommendationDict["type"] as! String)!
        let userRecommendation: UserRecommendation = UserRecommendation(
            ID: ID,
            tags: tags,
            detail: detail,
            comments: comments,
            type: type
        )
        return userRecommendation
    }
    
    
    // MARK: Prompt
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
        
        session.dataTaskWithURL(validQueryURL, completionHandler: {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let error = error {
                NSLog("Error - FriendsBest API - getPrompts() - \(error)")
                NetworkQueue.instance.tryAgain()
                return
            }
            
            if !self.responseHasExpectedStatusCodes(response, expectedStatusCodes: [200], funcName: "getPrompts") {
                NetworkQueue.instance.tryAgain()
                return
            }
            
            let promptArray: [NSDictionary] = self.getNSArrayFromJSONdata(data, funcName: "getPrompts") as! [NSDictionary]
            
            var prompts: [Prompt] = []
            for promptDict: NSDictionary in promptArray {
                let prompt: Prompt = self.getPrompt(promptDict)
                prompts.append(prompt)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.networkDAODelegate?.promptsFetched(prompts)
                callback?()
            })
            
            NetworkQueue.instance.dequeue()
        }).resume()
    }
    
    
    func deletePrompt(prompt: Prompt, callback: (() -> Void)?) {
        NetworkQueue.instance.enqueue(NetworkTask(task: {
            [weak self] () -> Void in
            self?._deletePrompt(false, prompt: prompt, callback: callback)
            }, description: "deletePrompt()"))
    }
    
    func deletePromptAsync(prompt: Prompt, callback: (() -> Void)?) {
        _deletePrompt(true, prompt: prompt, callback: callback)
    }
    
    private func _deletePrompt(async: Bool, prompt: Prompt, callback: (() -> Void)?) {
        guard let token = self.friendsBestToken else {
            NSLog("User has not authenticated")
            postFacebookTokenAndAuthenticate(nil)
            if !async {
                NetworkQueue.instance.tryAgain()
            }
            return
        }
        
        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = ["Authorization": token]
        let session: NSURLSession = NSURLSession(configuration: configuration)
        
        let queryString: String = "prompt/\(prompt.ID)/"
        let queryURL: NSURL! = NSURL(string: queryString, relativeToURL: friendsBestAPIurl)
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: queryURL)
        request.HTTPMethod = "DELETE"
        
        session.dataTaskWithRequest(request, completionHandler: {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let error = error {
                NSLog("Error - FriendsBest API - deletePrompt() - \(error.localizedDescription)")
                if !async {
                    NetworkQueue.instance.tryAgain()
                }
                return
            }
            
            if !self.responseHasExpectedStatusCodes(response, expectedStatusCodes: [204, 404], funcName: "deletePrompt") {
                if !async {
                    NetworkQueue.instance.dequeue()
                }
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.networkDAODelegate?.promptDeleted(prompt)
                callback?()
            })
            
            if !async {
                NetworkQueue.instance.dequeue()
            }
        }).resume()
    }
    
    
    private func getPrompt(promptDict: NSDictionary) -> Prompt {
        let ID: Int = promptDict["id"] as! Int
        let article: String = promptDict["article"] as! String
        let tags: [String] = promptDict["tags"] as! [String]
        let tagString: String = promptDict["tagstring"] as! String
        let urgent: Bool = promptDict["urgent"] as! Bool
        let friendDict: NSDictionary? = promptDict["friend"] as? NSDictionary
        var friend: Friend? = nil
        if let friendDict = friendDict {
            friend = self.getFriend?(
                facebookID: friendDict["id"] as! String,
                name: friendDict["name"] as! String,
                muted: nil
            )
        }
        let prompt: Prompt = Prompt(
            ID: ID,
            article: article,
            tags: tags,
            tagString: tagString,
            urgent: urgent,
            friend: friend
        )
        return prompt
    }
    
    
    // MARK: Notification
    func deleteNotification(recommedation: FriendRecommendation, callback: (() -> Void)?) {
        NetworkQueue.instance.enqueue(NetworkTask(task: {
            [weak self] () -> Void in
            self?._deleteNotification(recommedation, callback: callback)
            }, description: "deletePrompt()"))
    }
    
    private func _deleteNotification(recommedation: FriendRecommendation, callback: (() -> Void)?) {
        guard let token = self.friendsBestToken else {
            NSLog("User has not authenticated")
            postFacebookTokenAndAuthenticate(nil)
            NetworkQueue.instance.tryAgain()
            return
        }
        
        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = ["Authorization": token]
        let session: NSURLSession = NSURLSession(configuration: configuration)
        
        let queryString: String = "notification/\(recommedation.ID)/"
        let queryURL: NSURL! = NSURL(string: queryString, relativeToURL: friendsBestAPIurl)
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: queryURL)
        request.HTTPMethod = "DELETE"
        
        session.dataTaskWithRequest(request, completionHandler: {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let error = error {
                NSLog("Error - FriendsBest API - deleteNotification() - \(error.localizedDescription)")
                NetworkQueue.instance.tryAgain()
                return
            }
            
            if !self.responseHasExpectedStatusCodes(response, expectedStatusCodes: [204], funcName: "deleteNotification") {
                NetworkQueue.instance.dequeue()
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                callback?()
            })
            NetworkQueue.instance.dequeue()
            
        }).resume()
    }
    
    
    // MARK: Authentication
    func postFacebookTokenAndAuthenticate(callback: (() -> Void)?) {
        NetworkQueue.instance.push(NetworkTask(task: { () -> Void in
            self._postFacebookTokenAndAuthenticate(callback)
            }, description: "postFacebookTokenAndAuthenticate()"))
    }
    
    private func _postFacebookTokenAndAuthenticate(callback: (() -> Void)?) {
        assert(FBSDKAccessToken.currentAccessToken() != nil)
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
        
        session.dataTaskWithRequest(request, completionHandler: {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let error = error {
                NSLog("Error - FriendsBest API - postFacebookToken() - \(error.localizedDescription)")
                NSLog("\(error.code)")
                NetworkQueue.instance.tryAgain()
                return
            }
            
            if !self.responseHasExpectedStatusCodes(response, expectedStatusCodes: [200], funcName: "postFacebookToken") {
                NetworkQueue.instance.tryAgain()
                return
            }
            
            let keyDict: NSDictionary = self.getNSDictionaryFromJSONdata(data, funcName: "postFacebookToken")!
            let key: NSString = keyDict["key"] as! NSString
            self.friendsBestToken = "Token \(key as String)"
            
            dispatch_async(dispatch_get_main_queue(), {
                self.authenticatedWithFriendsBestServerDelegate()
                callback?()
            })
            NetworkQueue.instance.dequeue()            
        }).resume()
    }
    
    // Mark: Helper
    private func parseSolutions(solutionsDictArray: [NSDictionary]) -> [Solution] {
        var solutions: [Solution] = []
        
        for solutionDict in solutionsDictArray {
            var recommendations: [FriendRecommendation] = []
            
            let solutionID: Int = solutionDict["id"] as! Int
            let detail: String = solutionDict["detail"] as! String
            let pinid: Bool = solutionDict["pinid"] as! Bool
            let typeString: String = solutionDict["type"] as! String
            let notificationCount: Int = solutionDict["notifications"] as! Int
            let recommendationDictArray: [NSDictionary] = solutionDict["recommendations"] as! [NSDictionary]
            
            for recommendationDict: NSDictionary in recommendationDictArray {
                let recommendationID: Int = recommendationDict["id"] as! Int
                let comment: String = recommendationDict["comment"] as! String
                let isNew: Bool = recommendationDict["isNew"] as! Bool
                let friendDict: NSDictionary? = recommendationDict["user"] as? NSDictionary // nil if anonymous
                
                var friend: Friend? = nil
                if let friendDict = friendDict {
                    let facebookID: String = friendDict["id"] as! String
                    let name: String = friendDict["name"] as! String
                    let muted: Bool? = friendDict["muted"] as? Bool
                    friend = Friend(facebookID: facebookID, name: name, muted: muted)
                }
                
                let recommendation: FriendRecommendation = FriendRecommendation(
                    ID: recommendationID,
                    comment: comment,
                    isNew: isNew,
                    friend: friend
                )
                
                recommendations.append(recommendation)
            }
            
            let solution: Solution = Solution(
                ID: solutionID,
                detail: detail,
                pinid: pinid,
                type: SolutionType(rawValue: typeString)!,
                notificationCount: notificationCount,
                recommendations: recommendations
            )
            
            
            for recommendation in solution.recommendations {
                recommendation.setSolution(solution)
            }
            
            solutions.append(solution)
        }
        
        return solutions
    }
    
    func responseHasExpectedStatusCodes(response: NSURLResponse?, expectedStatusCodes: [Int], funcName: String) -> Bool {
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
    
    private func getNSDictionaryFromJSONdata(data: NSData?, funcName: String) -> NSDictionary? {
        var dict: NSDictionary? = nil
        
        guard let data = data else {
            NSLog("Error - FriendsBest API - \(funcName)() - No data")
            return dict
        }
        
        do {
            dict = try NSJSONSerialization.JSONObjectWithData(data, options: jsonReadingOptions) as? NSDictionary
        } catch {
            NSLog("Error - FriendsBest API - \(funcName)() - Unable to parse JSON - \(error)")
            return dict
        }
        
        return dict
    }
    
    private func getNSArrayFromJSONdata(data: NSData?, funcName: String) -> NSArray? {
        var array: NSArray? = nil
        
        guard let data = data else {
            NSLog("Error - FriendsBest API - \(funcName)() - No data")
            return array
        }
        
        do {
            array = try NSJSONSerialization.JSONObjectWithData(data, options: jsonReadingOptions) as? NSArray
        } catch {
            NSLog("Error - FriendsBest API - \(funcName)() - Unable to parse JSON - \(error)")
            return array
        }
        
        return array
    }
    
    private func convertTimestampStringToNSDate(timestampString: String) -> NSDate? {
        let formatter = dateFormatter
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.dateFromString(timestampString)
    }
}













































