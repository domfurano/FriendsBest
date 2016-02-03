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
}


class Query: Hashable, Equatable {
    private(set) var tags: [String]
    private(set) var ID: Int
    private(set) var timestamp: NSDate
    var solutions: [Solution]?
    
    var hashValue: Int {
        get {
            return self.ID
        }
    }
    
    init(tags: [String], ID: Int, timestamp: NSDate) {
        self.tags = tags
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
