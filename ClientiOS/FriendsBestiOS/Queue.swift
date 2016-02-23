//
//  Queue.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 2/6/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import Foundation

class Queue<T> {
    private(set) var first: Node<T>? = nil
    private(set) var last: Node<T>? = nil
    
    private(set) var count: Int = 0
    
    func enqueue(item: T) -> Void {
        if self.first == nil {
            self.last = Node(item: item)
            self.first = self.last
        } else {
            self.last!.next = Node(item: item)
            self.last = self.last!.next
        }
        self.count++
    }
    
    func dequeue() -> T? {
        if self.first != nil {
            let item: T = first!.item
            self.first = self.first!.next
            self.count--
            return item
        }
        return nil
    }
    
    func push(item: T) -> Void {
        if self.first == nil {
            self.last = Node(item: item)
            self.first = self.last
        } else {
            let node: Node = Node(item: item)
            node.next = self.first
            self.first = node
        }
        self.count++
    }
}

class Node<T> {
    var item: T
    var next: Node?
    
    init(item: T) {
        self.item = item
    }
}
