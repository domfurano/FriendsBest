//
//  FriendsBestUser.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 1/17/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import Foundation


class User: NetworkDAODelegate {
    
    /* Singleton instance */
    static let instance: User = User()
    
    
    /* Member variables */
    private(set) var queryHistory: QueryHistory = QueryHistory()
    private(set) var prompts: Prompts = Prompts()
    private(set) var friends: [Friend] = []


    /* Delegation */
    var queryHistoryUpdatedClosure: () -> Void = {}
    var querySolutionsUpdatedClosure: (queryID: Int) -> Void = {_ in }
    var promptsFetchedClosure: () -> Void = {}
    
    
    /* Private constructor */
    private init() {
        // Delegate assignment
        NetworkDAO.instance.networkDAODelegate = self
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
    
    
    /* Serialization */
    private func serialize() {
        
    }
}


class Friend {
    private(set) var facebookID: String
    private(set) var djangoID: Int
    private(set) var name: String
    
    init(facebookID: String, djangoID: Int, name: String) {
        self.facebookID = facebookID
        self.djangoID = djangoID
        self.name = name
    }
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
    
    private func tagsEqual(tag1: [String], tag2: [String]) -> Bool {
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
    
    func setQuerySolutionsForQueryID(solutions: [Solution], queryID: Int) {
        for query in self._queries {
            if query.ID == queryID {
                query.solutions = solutions
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
    private var _solutions: [Solution]?
    var solutions: [Solution]? {
        get {
            if let solutions = self._solutions {
                return solutions
            } else {
                return nil
            }
        }
        set (solutions) {
            // TODO: only insert solution if it doesn't exist in order to demarcate new from old solutions
            self._solutions = solutions
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


class Solution {
    private(set) var name: String
    private(set) var recommendations: [Recommendation]
    
    init(name: String, recommendations: [Recommendation]) {
        self.name = name
        self.recommendations = recommendations
    }
}


class Recommendation {
    private(set) var friend: Friend
    private(set) var comment: String
    
    init(friend: Friend, comment: String) {
        self.friend = friend
        self.comment = comment
    }
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
    
    var hashValue: Int {
        return self.ID
    }

    init(article: String, tags: [String], tagString: String, friend: Friend, ID: Int) {
        self.article = article
        self.tags = tags
        self.tagString = tagString
        self.friend = friend
        self.ID = ID
    }
}

func ==(lhs: Prompt, rhs: Prompt)-> Bool {
    return lhs.ID == rhs.ID
}
































