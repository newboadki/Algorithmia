//
//  BoundedHeightPriorityQueue.swift
//  Algorithmia
//
//  Created by Borja Arias Drake on 07/11/2016.
//  Copyright © 2016 Borja Arias Drake. All rights reserved.
//

import Foundation

public struct BoundedHeightPriorityQueue<Element: KeyValuePair> : PriorityQueue {

    /// Item is defined in the PriorityQueue protocol.
    public typealias Item = Element
    
    /// Valid Indexes go from
    private (set) var maximumKey : Int = 10000
    
    private var topIndex : Int?
    
    private var array : Array<Array<Element>?>
    
    private var topPriorityQueue : BasicBinarySearchTree<IntegerPair>?
    
    
    // MARK : PriorityQueue Protocol
    
    public var type : PriorityQueueType
    
    
    public init(type: PriorityQueueType) {
        self.init(type : type, maximumKey: 1000)
    }
    
    public mutating func enqueue(item: Item) throws {
        
        let key = item.key as! Int
        
        guard (key >= 0 && key<=self.maximumKey) else {
            throw PriorityQueueError.invalidOperationForType
        }
        
        if var arrayForKey = self.array[Int(key)] {
            // append it to the existing array
            arrayForKey.append(item)
            self.array[Int(key)] = arrayForKey
        } else {
            // need to create an array of items for that key
            self.array[key] = [item]
            self.addElementToTopQueue(element: key)
        }
        
        // Update the top index if necessary
        if let top = self.topIndex {
            if key < top {
                self.topIndex = key
            }
        } else {
            self.topIndex = key
        }
    }
    
    public func getFirst() -> Item? {
        if let top = self.topIndex {
            return self.array[Int(top)]?.first
        } else {
            return nil
        }
    }
    
    public mutating func dequeue() -> Item? {
        var result : Item
        
        guard self.topIndex != nil else {
            // There are no element in the queue
            return nil
        }
        
        if var arrayForTop = self.array[self.topIndex!] {
            // append it to the existing array
            result = arrayForTop.removeFirst()
            let key = result.key as! Int
            self.array[key] = arrayForTop
            if arrayForTop.isEmpty {
                
                // release the array
                self.array[key] = nil
                
                // we need to find a new top
                _ = self.removeElementToTopQueue(element: key)
                if let min = self.minimumElementFromTopQueue() {
                    self.topIndex = min
                } else {
                    self.topIndex = nil
                }
            }
            
            return result
            
        } else {
            // Should not happen, throw exception
            return nil
        }
    }

    
    
    // MARK : Public API
    
    public init(type: PriorityQueueType, maximumKey: Int) {
        self.type = type
        self.maximumKey = maximumKey
        self.array = Array<Array<Element>?>(repeating: nil, count: Int(maximumKey + 1))
    }

    
    
    // MARK:  Top priority queue
    private mutating func addElementToTopQueue(element : Int) {
        let treeNode = BasicBinarySearchTree<IntegerPair>(parent: nil,
                                                     leftChild: nil,
                                                     rightChild: nil,
                                                     value: IntegerPair(key: element, value: 0))

        if let topQueue = self.topPriorityQueue {
            topQueue.insert(newElement: treeNode)
        } else {
            self.topPriorityQueue = treeNode
        }
    }

    private func removeElementToTopQueue(element : Int) {
        _ = self.topPriorityQueue?.delete(elementWithKey: element)
    }

    private func minimumElementFromTopQueue() -> Int? {
        if let result = self.topPriorityQueue?.minimum() {
            return result.item?.key
        }
        
        return nil
    }

}
