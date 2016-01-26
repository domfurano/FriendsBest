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


class User: QueriesFetchedDelegate, QuerySolutionsFetchedDelegate {

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
        for query in self.queries {
            if query.ID == ID {
                return query
            }
        }
        return nil
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
