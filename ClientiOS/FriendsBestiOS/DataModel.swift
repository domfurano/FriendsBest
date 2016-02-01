//
//  FriendsBestUser.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 1/17/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import Foundation

protocol QueryHistoryUpdatedDelegate: class {
    func queryHistoryUpdated()
}

protocol QuerySolutionsUpdatedDelegate: class {
    func querySolutionsUpdated(forQueryID queryID: Int)
}


class User: QueriesFetchedDelegate, QuerySolutionsFetchedDelegate, NewQueryFetchedDelegate {

    /* Singleton instance */
    static let instance: User = User()
    
    /* Member variables */
    var queryHistory: QueryHistory = QueryHistory()
    
    /* Delegation */
    weak var queryHistoryUpdatedDelegate: QueryHistoryUpdatedDelegate? = nil
    weak var querySolutionsUpdatedDelegate: QuerySolutionsUpdatedDelegate? = nil
    
    /* Private constructor */
    private init() {
        // Delegate assignment
        NetworkDAO.instance.queriesFetchedDelegate = self
        NetworkDAO.instance.querySolutionsFetchedDelegate = self
        NetworkDAO.instance.newQueryFetchedDelegate = self
    }
    
    /* Delegate implementations */
    func queriesFetched(queryHistory: QueryHistory) {
        self.queryHistory = queryHistory
        queryHistoryUpdatedDelegate?.queryHistoryUpdated()
    }
    
    func querySolutionsFetched(forQueryID queryID: Int, solutions: [Solution]) {
        for query in self.queryHistory.queries {
            if query.ID == queryID {
                query.solutions = solutions
                break
            }
        }
        querySolutionsUpdatedDelegate?.querySolutionsUpdated(forQueryID: queryID)
    }
    
    func newQueryFetched(query: Query) {
        self.queryHistory._queries.append(query)
        querySolutionsUpdatedDelegate?.querySolutionsUpdated(forQueryID: query.ID)
    }
}


class QueryHistory {
    private var _queries: [Query]
    
    var queries: [Query] {
        get {
            return self._queries.sort({
                return $0.timestamp.compare($1.timestamp) == NSComparisonResult.OrderedDescending
            })
        }
        set(queries) {
            self._queries = queries
        }
    }
    
    init() {
        self._queries = []
    }
    
    init(queries: [Query]) {
        self._queries = queries
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


class Query {
    var tags: [String]
    var ID: Int
    var timestamp: NSDate
    var solutions: [Solution]?
    
    init(tags: [String], ID: Int, timestamp: NSDate) {
        self.tags = tags
        self.ID = ID
        self.timestamp = timestamp
    }
}


class Solution {
    var name: String
    var recommendations: [Recommendation]
    
    init(name: String, recommendations: [Recommendation]) {
        self.name = name
        self.recommendations = recommendations
    }
}


class Recommendation {
    var userName: String
    var comment: String
    
    init(userName: String, comment: String) {
        self.userName = userName
        self.comment = comment
    }
}
