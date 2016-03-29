//
//  FriendsBestUser.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 1/17/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import Foundation
import FBSDKCoreKit


class User: NetworkDAODelegate {
    
    /* Singleton instance */
    static let instance: User = User()
    
    
    /* Member variables */
    var name: String? = nil
    var facebookID: String? = nil
    private(set) var queryHistory: QueryHistory = QueryHistory()
    private(set) var prompts: Prompts = Prompts()
    private(set) var friends: [Friend] = []
    var recommendations: [Recommendation] = []


    /* Delegation */
    var queryHistoryUpdatedClosure: () -> Void = {}
    var querySolutionsUpdatedClosure: (queryID: Int) -> Void = { _ in }
    var promptsFetchedClosure: () -> Void = {}
    var newSolutionAlert: () -> Void = {}
    var newRecommendationAlert: () -> Void = {}
    var userRecommendationsFetchedClosure: () -> Void = {}
    var friendsFetchedClosure: () -> Void = {}
    
    
    /* Private constructor */
    private init() {
        // Delegate assignment
        FBNetworkDAO.instance.networkDAODelegate = self
    }
    
    
    func getFriendByID(id: String) -> Friend? {
        for friend in friends {
            if friend.facebookID == id {
                return friend
            }
        }
        return nil
    }
    
    
    /* Delegate implementations */
    func queriesFetched() {
        queryHistoryUpdatedClosure()
    }
    
    func querySolutionsFetched(forQueryID queryID: Int) {
        querySolutionsUpdatedClosure(queryID: queryID)
    }
    
    func newQueryFetched(queryID: Int) {
        querySolutionsUpdatedClosure(queryID: queryID)
    }
    
    func promptsFetched() {
        promptsFetchedClosure()
    }
    
    func userRecommendationsFetched() {
        userRecommendationsFetchedClosure()
    }
    
    func friendsFetched(friends: [Friend]) {
        for friend in friends {
            if !self.friends.contains(friend) {
                self.friends.append(friend)
            }
        }
    }
    
    
    /* Serialization */
    private func serialize() {
        
    }
}


class Friend: Equatable, Hashable {
    private(set) var facebookID: String
    private(set) var name: String
    var muted: Bool?
    private(set) var squarePicture: UIImage?
    
    var hashValue: Int {
        return facebookID.hashValue
    }
    
    init(facebookID: String, name: String) {
        self.facebookID = facebookID
        self.name = name
        
        FacebookNetworkDAO.instance.getFacebookProfileImage(
            facebookID,
            size: FacebookNetworkDAO.FacbookImageSize.square
        ) { (profileImage: UIImage) in
            self.squarePicture = profileImage
        }
    }
}

func ==(lhs: Friend, rhs: Friend) -> Bool {
    return lhs.facebookID == rhs.facebookID
}


class QueryHistory {
    private var _queries: Set<Query>
    
    var queries: [Query] {
        get {
            return self._queries.sort({
                return $0.timestamp.compare($1.timestamp) == NSComparisonResult.OrderedDescending
            })
        }
    }
    
    init() {
        self._queries = []
    }
    
    init(queries: [Query]) {
        self._queries = Set(queries)
    }
    
    func appendQuery(query: Query) {
        self._queries.insert(query)
    }
    
    func deleteQueryByID(queryID: Int) {
        for query in self._queries {
            if query.ID == queryID {
                self._queries.remove(query)
                break
            }
        }
    }
    
    func getQueryByID(ID: Int) -> Query? {
        for query in self._queries {
            if query.ID == ID {
                return query
            }
        }
        return nil
    }
    
    func getQueryFromTagHash(tagHash: String) -> Query? {
        for query in self._queries {
            if query.tagHash == tagHash {
                return query
            }
        }
        return nil
    }
    
    func getQueryFromTags(tags: [String]) -> Query? {
        for query in self._queries {
            if tagsEqual(query.tags, tag2: tags) {
                return query
            }
        }
        return nil
    }
    
    func tagsEqual(tag1: [String], tag2: [String]) -> Bool {
        if (tag1.count != tag2.count) {
            return false
        }
        var tagsEqual: Bool = true
        for tag1_tag in tag1 {
            var tagFound: Bool = false
            for tag2_tag in tag2 {
                if tag1_tag == tag2_tag {
                    tagFound = true
                    break
                }
            }
            tagsEqual = tagsEqual && tagFound
        }
        return tagsEqual
    }
    
    func setQuerySolutionsForQueryID(solutions: Set<Solution>, queryID: Int) {
        for query in self._queries {
            if query.ID == queryID {
                query.setSolutions(solutions)
                break
            }
        }
    }
}



class Query: Hashable, Equatable {
    private(set) var tags: [String]
    private(set) var tagHash: String
    private(set) var tagString: String
    private(set) var ID: Int
    private(set) var timestamp: NSDate
    private var _solutions: Set<Solution>?
    var solutions: [Solution]? {
        get {
            guard self._solutions != nil else {
                return nil
            }
            return Array(self._solutions!)
        }
    }
    
    func setSolutions (newSolutions: Set<Solution>) {
        if self._solutions == nil {
            self._solutions = Set(newSolutions)
        } else {
            for newSolution in newSolutions {
                if self._solutions!.contains(newSolution) { // The solution is not new, but it may have new recommendations.
                    let existingSolutionArray: [Solution]? = self._solutions?.filter({ (solution: Solution) -> Bool in
                        solution == newSolution // They have the same detail
                    })
                    let existingSolution: Solution = existingSolutionArray!.first!
                    
                    for recommendation in newSolution.recommendations {
                        if !existingSolution.recommendations.contains(recommendation) {
                            // Insert it and trigger the alert
                            existingSolution.insertRecommendation(recommendation)
                            User.instance.newRecommendationAlert()
                        }
                    }
                    
                } else { // The solution is new!
                    // Insert it and trigger the alert.
                    self._solutions!.insert(newSolution)
                    User.instance.newSolutionAlert()
                }
            }
        }
    }
    
    var hashValue: Int {
        get {
            return self.ID
        }
    }
    
    init(tags: [String], tagHash: String, tagString: String, ID: Int, timestamp: NSDate) {
        self.tags = tags
        self.tagHash = tagHash
        self.tagString = tagString
        self.ID = ID
        self.timestamp = timestamp
    }
}

func ==(lhs: Query, rhs: Query) -> Bool {
    return lhs.ID == rhs.ID
}


class Solution: Equatable, Hashable {
    private(set) var _recommendations: Set<Recommendation>
    private(set) var detail: String
    private(set) var type: Recommendation.RecommendationType
    
    var recommendations: [Recommendation] {
        get {
            return Array(_recommendations)
        }
    }
    
    func insertRecommendation(recommendation: Recommendation) {
        _recommendations.insert(recommendation)
    }
    
    var hashValue: Int {
        return self.detail.hash
    }
    
    init(recommendations: Set<Recommendation>, detail: String, type: Recommendation.RecommendationType) {
        self._recommendations = recommendations
        self.detail = detail
        self.type = type
    }
}

func ==(lhs: Solution, rhs: Solution) -> Bool {
    return lhs.detail == rhs.detail
}


class Recommendation: Equatable, Hashable {
    enum RecommendationType: String {
        case TEXT
    }
    
    private(set) var friend: Friend
    private(set) var comment: String
    private(set) var detail: String
    private(set) var type: RecommendationType
    var ID: Int
    var tags: [String]?
    var new: Bool?
    
    var hashValue: Int {
        return self.ID
    }
    
    init(friend: Friend, comment: String, detail: String, type: RecommendationType, ID: Int) {
        self.friend = friend
        self.comment = comment
        self.detail = detail
        self.type = type
        self.ID = ID
    }
}

func ==(lhs: Recommendation, rhs: Recommendation) -> Bool {
    return lhs.ID == rhs.ID
}


class Prompts {
    private var _prompts: Set<Prompt>
    
    var prompts: [Prompt] {
        get {
            return Array(self._prompts)
        }
        set(prompts) {
            for prompt in prompts {
                self._prompts.insert(prompt)
            }
        }
    }
    
    init() {
        self._prompts = Set<Prompt>()
    }
    
    func deletePrompt(ID: Int) {
        for prompt in self._prompts {
            if prompt.ID == ID {
                self._prompts.remove(prompt)
                // TODO: Call network function to delete prompt
                return
            }
        }
        assert(false)
    }
    
}


class Prompt: Equatable, Hashable {
    private(set) var article: String
    private(set) var tags: [String]
    private(set) var tagString: String
    private(set) var friend: Friend
    private(set) var ID: Int
    var new: Bool
    
    var hashValue: Int {
        return self.ID
    }

    init(article: String, tags: [String], tagString: String, friend: Friend, ID: Int) {
        self.article = article
        self.tags = tags
        self.tagString = tagString
        self.friend = friend
        self.ID = ID
        self.new = true
    }
}

func ==(lhs: Prompt, rhs: Prompt)-> Bool {
    return lhs.ID == rhs.ID
}
































