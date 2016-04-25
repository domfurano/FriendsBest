//
//  FriendsBestUser.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 1/17/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import Foundation
import FBSDKCoreKit

var USER: User = User()

class User: NetworkDAODelegate {
    
    /* Singleton instance */
//    static let instance: User = User()
    
    
    /* Member variables */
    var myName: String? = nil
    var myFacebookID: String {
        NSLog("My facebook id: \(FBSDKAccessToken.currentAccessToken().userID)")
        return FBSDKAccessToken.currentAccessToken().userID
    }
    var myQueries: [Query] = []
    var myPrompts: [Prompt] = []
    var myFriends: [Friend] = []
    var myRecommendations: [UserRecommendation] = []
    var myLargeRoundedImage: UIImageView!
    var mySmallRoundedImage: UIImageView!
    
    
    /* Private constructor */
    init() {
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
        myLargeRoundedImage = CommonUI.instance.getLargeRoundedFacebookProfileImageView(myFacebookID, closure: nil)
        mySmallRoundedImage = CommonUI.instance.getSmallRoundedFacebookProfileImageView(myFacebookID, closure: nil)
    }
    
    func notificationsTotal() -> Int {
        var count: Int = 0
        for query in myQueries {
            count += query.notificationCount
        }
        return count
    }
    
    
    private func notifyIfNeeded() {
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "notifications", object: nil))
    }
    
    private func sortQueries() {
        for query: Query in myQueries {
            for solution: Solution in query.solutions {
                solution.recommendations = solution.recommendations.reverse()
                solution.recommendations.sortInPlace({ (rec1: FriendRecommendation, rec2: FriendRecommendation) -> Bool in
                    return rec1.isNew
                })
            }
            query.solutions = query.solutions.reverse()
            query.solutions.sortInPlace({ (sol1: Solution, sol2: Solution) -> Bool in
                return sol1.notificationCount > sol2.notificationCount
            })
        }
        myQueries = myQueries.reverse()
        myQueries.sortInPlace { (q1: Query, q2: Query) -> Bool in
            return q1.notificationCount > q2.notificationCount
        }
    }
    
    /* Delegation */

    var closurePromptsNew: () -> Void = { }
    func promptsFetched(prompts: [Prompt]) {
        self.myPrompts = prompts
        closurePromptsNew()
    }
    var closurePromptDeleted: () -> Void = { }
    func promptDeleted(prompt: Prompt) {
        closurePromptDeleted()
    }
    var closureQueryNew: (query: Query) -> Void = { _ in }
    func queryFetched(query: Query) {
        self.myQueries.insert(query, atIndex: 0)
        sortQueries()
        closureQueryNew(query: query)
    }
    var closureQueriesNew: () -> Void = { }
    func queriesFetched(queries: [Query]) {
        self.myQueries = queries
        sortQueries()
        closureQueriesNew()
        notifyIfNeeded()
    }
    var closureQueryDeleted: () -> Void = { }
    func queryDeleted(query: Query) {
        if let index: Int = self.myQueries.indexOf(query) {
            myQueries.removeAtIndex(index)
            closureQueryDeleted()
        }
    }
    var closureSolutionsFetchedForQuery: (query: Query) -> Void = { _ in }
    func querySolutionsFetched(forYourQuery query: Query, solutions: [Solution]) {
        query.solutions = solutions
        sortQueries()
        closureSolutionsFetchedForQuery(query: query)
    }
    var closureUserRecommendationNew: () -> Void = { }
    func userRecommendationFetched(userRecommendation: UserRecommendation) {
        self.myRecommendations.insert(userRecommendation, atIndex: 0)
        sortQueries()
        closureUserRecommendationNew()
    }
    var closureUserRecommendationsNew: () -> Void = { }
    func userRecommendationsFetched(userRecommendations: [UserRecommendation]) {
        self.myRecommendations = userRecommendations
        sortQueries()
        closureUserRecommendationsNew()
    }
    var closureUserRecommendationDeleted: () -> Void = { }
    func userRecommendationDeleted(userRecommendation: UserRecommendation) {
        if let index: Int = self.myRecommendations.indexOf(userRecommendation) {
            myRecommendations.removeAtIndex(index)
            closureUserRecommendationDeleted()
        }
    }
    var closureFriendsNew: () -> Void = { }
    func friendsFetched(friends: [Friend]) {
        self.myFriends = friends
        closureFriendsNew()
    }
    var closureFriendMutingSet: () -> Void = { }
    func friendMutingSet(friend: Friend, muted: Bool) {
        friend.muted = muted
        closureFriendMutingSet()
    }
}


class Friend: Equatable, Hashable {
    private(set) var facebookID: String
    private(set) var name: String
    var muted: Bool?
    private(set) var smallRoundedPicture: UIImageView
    private(set) var largeSquarePicture: UIImageView
    var hashValue: Int {
        return facebookID.hashValue
    }
    
    init(facebookID: String, name: String, muted: Bool?) {
        self.facebookID = facebookID
        self.name = name
        self.muted = muted
        self.smallRoundedPicture = CommonUI.instance.getSmallRoundedFacebookProfileImageView(facebookID, closure: nil)
        self.largeSquarePicture = CommonUI.instance.getLargeRoundedFacebookProfileImageView(facebookID, closure: nil)
    }
}
func ==(lhs: Friend, rhs: Friend) -> Bool {
    return lhs.facebookID == rhs.facebookID
}


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
        self.solutions = networkSolutions
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
    var query: Query?
    private(set) var recommendations: [FriendRecommendation]
    var placeName: String
    var placeAddress: String
    var latitude: Double = 39.4997605
    var longitude: Double = -111.547028
    var urlTitle: String
    var urlSubtitle: String
    
    var hashValue: Int {
        return self.ID
    }
    
    var closureSolutionUpdated: () -> Void = { }
    
    init(ID: Int, detail: String, pinid: Bool, type: SolutionType, notificationCount: Int, recommendations: [FriendRecommendation]) {
        self.ID = ID
        self.detail = detail
        self.pinid = pinid
        self.type = type
        self.notificationCount = notificationCount
        self.recommendations = recommendations
        
        self.placeName = detail
        self.placeAddress = ""
        
        self.urlTitle = detail
        self.urlSubtitle = ""
        if type == .url {
            if let url: NSURL = NSURL(string: detail) {
                if let host: String = url.host {
                    self.urlTitle = host
                    self.urlSubtitle = detail
                }
            }
        }
        
        if self.type == .place {
            GooglePlace.loadPlace(self.detail, callback: { (successful, place) in
                if successful {
                    self.placeName = place!.name
                    self.placeAddress = place!.formattedAddress == nil ? " " : place!.formattedAddress!
                    self.latitude = place!.latitude
                    self.longitude = place!.longitude
                    self.closureSolutionUpdated()
                }
            })
        }
        
        
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
    var placeName: String
    var placeAddress: String
    var latitude: Double = 39.4997605
    var longitude: Double = -111.547028
    var urlTitle: String
    var urlSubtitle: String
    var hashValue: Int {
        return self.ID
    }
    
    var closureUserRecommendationUpdated: () -> Void = { }
    
    init(ID: Int, tags: [String], detail: String, comments: String, type: SolutionType) {
        self.ID = ID
        self.tags = tags
        self.tagString = tags.joinWithSeparator(" ")
        self.detail = detail
        self.comments = comments
        self.type = type
        self.placeName = self.detail
        self.placeAddress = " "
        self.urlTitle = detail
        self.urlSubtitle = ""
        if type == .url {
            if let url: NSURL = NSURL(string: detail) {
                if let host: String = url.host {
                    urlTitle = host
                    urlSubtitle = detail
                }
            }
        }
        
        if self.type == .place {
            GooglePlace.loadPlace(self.detail, callback: { (successful, place) in
                if successful {
                    self.placeName = place!.name
                    self.placeAddress = place!.formattedAddress == nil ? " " : place!.formattedAddress!
                    self.latitude = place!.latitude
                    self.longitude = place!.longitude
                    self.closureUserRecommendationUpdated()
                }
            })
        }        
    }
    
    func newRecommendation() -> NewRecommendation {
        let newRecommendation: NewRecommendation = NewRecommendation()
        newRecommendation.tags = tags
        newRecommendation.tagString = tagString
        newRecommendation.detail = detail
        newRecommendation.comments = comments
        newRecommendation.type = type
        newRecommendation.placeName = placeName
        newRecommendation.IDFromEditedUserRecommendation = ID
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
    var placeName: String?
    var IDFromEditedUserRecommendation: Int?
    
    func userRecommendation() -> UserRecommendation {
        return UserRecommendation(ID: IDFromEditedUserRecommendation!, tags: tags!, detail: detail!, comments: comments!, type: type!)
    }
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
































