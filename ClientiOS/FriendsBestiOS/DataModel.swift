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
    
    
    /* Delegation */
    var queryHistoryUpdatedClosure: () -> Void = {}
    var querySolutionsUpdatedClosure: (queryID: Int) -> Void = {_ in }
    
    
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
    
    
    /* Serialization */
    private func serialize() {
        
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
    private(set) var userName: String
    private(set) var comment: String
    
    init(userName: String, comment: String) {
        self.userName = userName
        self.comment = comment
    }
}
