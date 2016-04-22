//
//  FriendsBestUser.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 1/17/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import Foundation
import FBSDKCoreKit

//var MODEL_QUEUE: dispatch_queue_t = dispatch_queue_create("MODEL_QUEUE", nil)

//protocol NetworkDAODelegate: class {
//    func queriesFetched(query: [Query])
//    func querySolutionsFetched(forQuery query: Query, solutions: [Solution])
//    func newQueryFetched(query: Query)
//    func queryDeleted(query: Query)
//    func promptsFetched(prompts: [Prompt])
//    func promptDeleted(prompt: Prompt)
//    func userRecommendationsFetched(userRecommendations: [UserRecommendation])
//    func userRecommendationFetched(userRecommendation: UserRecommendation)
//    func userRecommendationDeleted(userRecommendation: UserRecommendation)
//    func friendsFetched(friends: [Friend])
//}

class User: NetworkDAODelegate {
    
    /* Singleton instance */
    static let instance: User = User()
    
    
    /* Member variables */
    var myName: String? = nil
    var myFacebookID: String {
        return FBSDKAccessToken.currentAccessToken().userID
    }
    var myQueries: [Query] = []
    var myPrompts: [Prompt] = []
    var myFriends: [Friend] = []
    var myRecommendations: [UserRecommendation] = []
    
    
    /* Private constructor */
    private init() {
        // Delegate assignment
        FBNetworkDAO.instance.networkDAODelegate = self
        FBNetworkDAO.instance.getFriend = { (facebookID: String, name: String, muted: Bool?) in
            for friend: Friend in self.myFriends {
                if friend.facebookID == facebookID {
                    return friend
                }
            }
            return Friend(facebookID: facebookID, name: name, muted: muted == nil ? false : muted!)
        }
    }

    
//    func getFriendByID(id: String) -> Friend? {
//        for friend in myFriends {
//            if friend.facebookID == id {
//                return friend
//            }
//        }
//        return nil
//    }
    
    
    /* Delegation */
//    var queryHistoryUpdatedClosure: () -> Void = {}
//    var promptsFetchedClosure: () -> Void = {}
//    var userRecommendationsFetchedClosure: () -> Void = {}
//    var friendsFetchedClosure: () -> Void = {}
    
    var closureSolutionUpdated: (forQuery: Query, index: Int) -> Void = {_ in }
    var closureRecommendationUpdated: (forSolution: Solution, index: Int) -> Void = {_ in }
    var closureNewRecommendation: (forSolution: Solution, index: Int) -> Void = {_ in }
    var closureNewSolution: (forQuery: Query, index: Int) -> Void = {_ in }
    
    var closureNewQuery: (index: Int) -> Void = {_ in }
//    var closureNewSolutions: (queryID: Int) -> Void = {_ in }
    var closureDeletedQuery: (index: Int) -> Void = {_ in }
    
    var closureNewPrompts: () -> Void = { }
    var closureDeletedPrompt: (index: Int) -> Void = {_ in }
    
    var closureNewUserRecommendation: (index: Int) -> Void = {_ in }
    var closureDeletedUserRecommendation: (index: Int) -> Void = {_ in }
    
    var closureNewFriend: (index: Int) -> Void = {_ in }
    
    /* Delegate implementations */
    
    
//    func setQueries(networkQueries: [Query]) {
//        for networkQuery: Query in networkQueries {
//            if let queryIndex: Int = myQueries.indexOf(networkQuery) {
//                let query: Query = myQueries[queryIndex]
//                query.setSolutions(networkQuery.solutions)
//                // Don't have to update the query because it is immutable.
//                // TODO: call a closure?
//            } else {
//                myQueries.insert(networkQuery, atIndex: 0)
//            }
//        }
//    }
    
    func queriesFetched(queries: [Query]) {
        for query: Query in queries {
            queryFetched(query)
        }
//        for query: Query in queries {
//            queryFetched(query)
//        }
    }
    func queryFetched(query: Query) {
        if let queryIndex: Int = myQueries.indexOf(query) {
            let myQuery: Query = myQueries[queryIndex]
            myQuery.setSolutions(query.solutions)
            // Don't have to update the query because it is immutable.
        } else {
            myQueries.insert(query, atIndex: 0)
            closureNewQuery(index: 0)
        }
//        if !myQueries.contains(query) {
//            myQueries.insert(query, atIndex: 0)
//            closureNewQuery(index: 0)
//        }
    }
    func querySolutionsFetched(forYourQuery query: Query, solutions: [Solution]) {
        query.setSolutions(solutions)
    }
    func queryDeleted(query: Query) {
        if let queryIndex: Int = myQueries.indexOf(query) {
            myQueries.removeAtIndex(queryIndex)
            closureDeletedQuery(index: queryIndex)
        }
    }
    func promptsFetched(prompts: [Prompt]) {
        for prompt: Prompt in prompts {
            if !myPrompts.contains(prompt) {
                myPrompts.append(prompt)
            }
        }
        closureNewPrompts()
    }
    func promptDeleted(prompt: Prompt) {
        if let promptIndex: Int = myPrompts.indexOf(prompt) {
            myPrompts.removeAtIndex(promptIndex)
            closureDeletedPrompt(index: promptIndex)
        }
    }
    func userRecommendationsFetched(userRecommendations: [UserRecommendation]) {
        for userRecommendation: UserRecommendation in userRecommendations {
            userRecommendationFetched(userRecommendation)
        }
    }
    func userRecommendationFetched(userRecommendation: UserRecommendation) {
        if !myRecommendations.contains(userRecommendation) {
            myRecommendations.insert(userRecommendation, atIndex: 0)
            closureNewUserRecommendation(index: 0)
        }
    }
    func userRecommendationDeleted(userRecommendation: UserRecommendation) {
        if let userRecommendationIndex: Int = myRecommendations.indexOf(userRecommendation) {
            myRecommendations.removeAtIndex(userRecommendationIndex)
            closureDeletedUserRecommendation(index: userRecommendationIndex)
        }        
    }
    func friendsFetched(friends: [Friend]) {
        for friend: Friend in friends {
            if !myFriends.contains(friend) {
                myFriends.append(friend)
                closureNewFriend(index: myFriends.endIndex - 1)
            }
        }
    }
//    func queriesFetched() {
//        queryHistoryUpdatedClosure()
//    }
//    
//    func querySolutionsFetched(forQueryID queryID: Int) {
//        querySolutionsUpdatedClosure(queryID: queryID)
//    }
//    
//    func newQueryFetched(query: Query) {
////        querySolutionsUpdatedClosure(queryID: queryID)
//    }
//    
//    func promptsFetched() {
//        promptsFetchedClosure()
//    }
//    
//    func userRecommendationsFetched() {
//        userRecommendationsFetchedClosure()
//    }
//    
//    func friendsFetched(friends: [Friend]) {
//        for friend in friends {
//            if !self.myFriends.contains(friend) {
//                self.myFriends.append(friend)
//            }
//        }
//    }
    
    
    /* Serialization */
    private func serialize() {
        
    }
}


class Friend: Equatable, Hashable {
    private(set) var facebookID: String
    private(set) var name: String
    var muted: Bool?
    private(set) var squarePicture: UIImageView
    var hashValue: Int {
        return facebookID.hashValue
    }
    
    init(facebookID: String, name: String, muted: Bool?) {
        self.facebookID = facebookID
        self.name = name
        self.muted = muted
        self.squarePicture = CommonUI.instance.getFacebookProfileUIImageView(facebookID, facebookSize: .square, closure: nil, payload: nil)
        
    }
}

func ==(lhs: Friend, rhs: Friend) -> Bool {
    return lhs.facebookID == rhs.facebookID
}


//class QueryHistory {
//    private var _queries: Set<Query>
//    
//    var queries: [Query] {
//        get {
//            return self._queries.sort({
//                return $0.accessed.compare($1.accessed) == NSComparisonResult.OrderedDescending
//            })
//        }
//    }
//    
//    init() {
//        self._queries = []
//    }
//    
//    init(queries: [Query]) {
//        self._queries = Set(queries)
//    }
//    
//    func appendQuery(query: Query) {
//        self._queries.insert(query)
//    }
//    
//    func deleteQueryByID(queryID: Int) {
//        for query in self._queries {
//            if query.ID == queryID {
//                self._queries.remove(query)
//                break
//            }
//        }
//    }
//    
//    func getQueryByID(ID: Int) -> Query? {
//        for query in self._queries {
//            if query.ID == ID {
//                return query
//            }
//        }
//        return nil
//    }
//    
//    func getQueryFromTagHash(tagHash: String) -> Query? {
//        for query in self._queries {
//            if query.tagHash == tagHash {
//                return query
//            }
//        }
//        return nil
//    }
//    
//    func getQueryFromTags(tags: [String]) -> Query? {
//        for query in self._queries {
//            if tagsEqual(query.tags, tag2: tags) {
//                return query
//            }
//        }
//        return nil
//    }
//    
//    func tagsEqual(tag1: [String], tag2: [String]) -> Bool {
//        if (tag1.count != tag2.count) {
//            return false
//        }
//        var tagsEqual: Bool = true
//        for tag1_tag in tag1 {
//            var tagFound: Bool = false
//            for tag2_tag in tag2 {
//                if tag1_tag == tag2_tag {
//                    tagFound = true
//                    break
//                }
//            }
//            tagsEqual = tagsEqual && tagFound
//        }
//        return tagsEqual
//    }
//    
////    func setQuerySolutionsForQueryID(solutions: Set<Solution>, queryID: Int) {
////        for query in self._queries {
////            if query.ID == queryID {
////                query.setSolutions(solutions)
////                break
////            }
////        }
////    }
//}



class Query: Hashable, Equatable {
    private(set) var ID: Int
    private(set) var accessed: NSDate
    private(set) var tags: [String]
    private(set) var tagString: String
    private(set) var tagHash: String
    private(set) var notificationCount: Int
    private(set) var solutions: [Solution]
    
    var hashValue: Int {
        get {
            return self.ID
        }
    }
    
    init(ID: Int, accessed: NSDate, tags: [String], tagString: String, tagHash: String, solutions: [Solution], notificationCount: Int) {
        self.ID = ID
        self.accessed = accessed
        self.tags = tags
        self.tagString = tagString
        self.tagHash = tagHash        
        self.notificationCount = notificationCount
        self.solutions = solutions
        
        self.solutions.forEach({ (solution: Solution) in
            solution.setQuery(self)
        })
    }
    
    func setSolutions(networkSolutions: [Solution]) {
        for networkSolution: Solution in networkSolutions {
            if let existingSolutionIndex: Int = self.solutions.indexOf(networkSolution) {
                let existingSolution: Solution = self.solutions[existingSolutionIndex]
                if updateSolution(existingSolution, networkSolution: networkSolution) {
                    User.instance.closureSolutionUpdated(forQuery: self, index: existingSolutionIndex)
                }
                
                for networkRecommendation in networkSolution.recommendations {
                    if let existingRecommendationIndex: Int = existingSolution.recommendations.indexOf(networkRecommendation) {
                        let existingRecommendation = existingSolution.recommendations[existingRecommendationIndex]
                        if updateRecommendation(existingRecommendation, networkRecommendation: networkRecommendation) {
                            User.instance.closureRecommendationUpdated(forSolution: existingSolution, index: existingRecommendationIndex)
                        }
                    } else {
                        existingSolution.recommendations.insert(networkRecommendation, atIndex: 0)
                        User.instance.closureNewRecommendation(forSolution: existingSolution, index: 0)
                    }
                }
                
            } else {
                self.solutions.append(networkSolution)
                networkSolution.query = self
                User.instance.closureNewSolution(forQuery: self, index: self.solutions.endIndex)
            }
        }
    }
    
    @warn_unused_result
    private func updateSolution(solution: Solution, networkSolution: Solution) -> Bool {
        assert(solution.ID == networkSolution.ID)
        
        var changed: Bool = false
        
        if solution.detail != networkSolution.detail {
            solution.detail = networkSolution.detail
            changed = true
        }
        
        if solution.pinid != networkSolution.pinid {
            solution.pinid = networkSolution.pinid
            changed = true
        }
        
        if solution.type != networkSolution.type {
            solution.type = networkSolution.type
            changed = true
        }
        
        if solution.notificationCount != networkSolution.notificationCount {
            solution.notificationCount = networkSolution.notificationCount
            changed = true
        }
        
        if solution.query != networkSolution.query {
            solution.query = networkSolution.query
            changed = true
        }
        
        return changed
    }
    
    @warn_unused_result
    private func updateRecommendation(recommendation: FriendRecommendation, networkRecommendation: FriendRecommendation) -> Bool {
        assert(recommendation.ID == networkRecommendation.ID)
        
        var changed: Bool = false
        
        if recommendation.comment != networkRecommendation.comment {
            recommendation.comment = networkRecommendation.comment
            changed = true
        }
        
        if recommendation.isNew != networkRecommendation.isNew {
            recommendation.isNew = networkRecommendation.isNew
            changed = true
        }
        
        // Friend
        if recommendation.friend != nil {
            if networkRecommendation.friend != nil {
                assert(recommendation.friend == networkRecommendation.friend)
            } else {
                recommendation.friend = nil
                changed = true
            }
        } else {
            if networkRecommendation.friend != nil {
                recommendation.friend = networkRecommendation.friend
                changed = true
            } else {
                // Both are nil and nothing is to be done.
            }
        }
        
        if recommendation.comment != networkRecommendation.comment {
            recommendation.comment = networkRecommendation.comment
            changed = true
        }
        
        if recommendation.comment != networkRecommendation.comment {
            recommendation.comment = networkRecommendation.comment
            changed = true
        }
        
        return changed
    }
}
func ==(lhs: Query, rhs: Query) -> Bool {
    return lhs.ID == rhs.ID
}


enum SolutionType: String {
    case text
    case place
    case url
}
class Solution: Equatable, Hashable {
    private(set) var ID: Int
    private(set) var detail: String
    private(set) var pinid: Bool
    private(set) var type: SolutionType
    private(set) var notificationCount: Int
    private(set) var query: Query?
    private(set) var recommendations: [FriendRecommendation]
    
    var hashValue: Int {
        return self.ID
    }
    
    init(ID: Int, detail: String, pinid: Bool, type: SolutionType, notificationCount: Int, recommendations: [FriendRecommendation]) {
        self.ID = ID
        self.detail = detail
        self.pinid = pinid
        self.type = type
        self.notificationCount = notificationCount
        self.recommendations = recommendations
        
        self.recommendations.forEach { (recommendation: FriendRecommendation) in
            recommendation.solution = self
        }
    }
    
    func setQuery(query: Query) {
        self.query = query
    }
}
func ==(lhs: Solution, rhs: Solution) -> Bool {
    return lhs.ID == rhs.ID
}


class FriendRecommendation: Equatable, Hashable {
    private(set) var ID: Int
    private(set) var comment: String
    private(set) var isNew: Bool
    private(set) var friend: Friend? // nil if anonymous
    private(set) var solution: Solution? // reference to Solution
    var hashValue: Int {
        return self.ID
    }
    
    init(ID: Int, comment: String, isNew: Bool, friend: Friend?) {
        self.ID = ID
        self.comment = comment
        self.isNew = isNew
        self.friend = friend
    }
    
    func setSolution(solution: Solution) {
        self.solution = solution
    }
}
func ==(lhs: FriendRecommendation, rhs: FriendRecommendation) -> Bool {
    return lhs.ID == rhs.ID
}


class UserRecommendation: Equatable, Hashable {
    private(set) var ID: Int
    private(set) var tags: [String]
    private(set) var tagString: String
    private(set) var detail: String
    private(set) var comments: String
    private(set) var type: SolutionType
    var hashValue: Int {
        return self.ID
    }
    
    init(ID: Int, tags: [String], detail: String, comments: String, type: SolutionType) {
        self.ID = ID
        self.tags = tags
        self.tagString = tags.joinWithSeparator(" ")
        self.detail = detail
        self.comments = comments
        self.type = type
    }
    
    func newRecommendation() -> NewRecommendation {
        let newRecommendation: NewRecommendation = NewRecommendation()
        newRecommendation.tags = tags
        newRecommendation.tagString = tagString
        newRecommendation.detail = detail
        newRecommendation.comments = comments
        newRecommendation.type = type
        return newRecommendation
    }
}
func ==(lhs: UserRecommendation, rhs: UserRecommendation) -> Bool {
    return lhs.ID == rhs.ID
}


class NewRecommendation {
    var tags: [String]?
    var tagString: String?
    var detail: String?
    var comments: String?
    var type: SolutionType?
}


class Prompt: Equatable, Hashable {
    private(set) var ID: Int
    private(set) var article: String
    private(set) var tags: [String]
    private(set) var tagString: String
    private(set) var urgent: Bool
    private(set) var friend: Friend? // nil if anonymous
    var hashValue: Int {
        return self.ID
    }
    
    init(ID: Int, article: String, tags: [String], tagString: String, urgent: Bool, friend: Friend?) {
        self.ID = ID
        self.article = article
        self.tags = tags
        self.tagString = tagString.isEmpty ? tags.joinWithSeparator(" ") : tagString
        self.urgent = urgent
        self.friend = friend
    }
}
func ==(lhs: Prompt, rhs: Prompt)-> Bool {
    return lhs.ID == rhs.ID
}
































