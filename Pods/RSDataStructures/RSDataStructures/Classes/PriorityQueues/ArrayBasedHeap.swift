//
//  ArrayBasedHeap.swift
//  Algorithmia
//
//  Created by Borja Arias Drake on 04/11/2016.
//  Copyright © 2016 Borja Arias Drake. All rights reserved.
//

import Foundation

public struct ArrayBasedHeap <HeapElement : KeyValuePair> : PriorityQueue {
    
    /// Item is defined in the PriorityQueue protocol.
    public typealias Item = HeapElement
    
    
    // MARK - Properties ------------------
    
    /// Internal structure to represent the heap
    private var array : [HeapElement]
    
    /// Maximum allowed capacity of the heap
    public let defaultaximumCapacity : UInt = 10000
    
    /// Maximum number of elements the heap can contain
    public private(set) var capacity : UInt
    
    /// The actual number of elements in the heap at any given time
    public var count : UInt {
        get {
            return UInt(self.array.count)
        }
    }
    
    
    
    // MARK: PriorityQueue protocol ------------------
    
    public var type : PriorityQueueType
    
    public init(type: PriorityQueueType) {
        self.init(type: type, capacity: 10000)
    }
    
    mutating public func enqueue(item : HeapElement) throws {
        
        guard self.count < self.capacity else {
            throw PriorityQueueError.capacityExceeded
        }
        
        self.array.append(item)        
        self.bubbleUp(startingAtIndex: self.count-1)
    }
    
    public func getFirst() -> HeapElement? {
        
        guard self.count > 0 else {
            return nil
        }
        
        return self.array.first
    }
    
    public mutating func dequeue() -> HeapElement? {
        
        guard self.count > 0 else {
            return nil
        }
        
        // Get the top of the heap
        let topElement = self.array.first
        
        // Replace top with last element
        let lastElement = self.array.last
        self.array.removeLast()
        if self.count > 0 {
            self.array[0]  = lastElement!
        }
        
        // Preserve the heap order
        self.bubbleDown(startingAtIndex: 0)
        
        return topElement
    }
    
    
    
    // MARK: Initializers ------------------

    public init(type: PriorityQueueType, elements: [HeapElement]) {
        self.type = type
        self.array = [HeapElement]()
        self.capacity = self.defaultaximumCapacity
        self.makeHeap(from: elements)
    }

    public init(type: PriorityQueueType, capacity: UInt) {
        self.type = type
        self.capacity = capacity
        self.array = [HeapElement]()
    }

    
    
    // MARK: Helpers ------------------
    
    private func indexOfParentNode(forChildAtIndex indexOfChildNode: UInt) -> UInt? {
        
        guard indexOfChildNode > 0 else {
            return nil
        }
        
        return (indexOfChildNode - 1) / 2 /* Implictit floor operation by Integer division */
    }

    private func indexOfLeftChild(forParentAtIndex indexOfParentNode: UInt) -> UInt {
        return (2 * indexOfParentNode) + 1
    }
    
    mutating private func bubbleUp(startingAtIndex index: UInt) {
        
        guard let parentIndex = self.indexOfParentNode(forChildAtIndex: index) else {
            return
        }
        
        let parentElement = self.array[Int(parentIndex)]
        let childElement = self.array[Int(index)]
        
        switch self.type {
            case .min:
                if childElement.key < parentElement.key { // Swap
                    self.array[Int(parentIndex)] = childElement
                    self.array[Int(index)] = parentElement
                }
                break
            case .max:
                if childElement.key > parentElement.key { // Swap
                    self.array[Int(parentIndex)] = childElement
                    self.array[Int(index)] = parentElement
                }
                break
        }
        
        self.bubbleUp(startingAtIndex: parentIndex)
    }

    mutating private func bubbleDown(startingAtIndex index: UInt) {
        
        let leftChildIndex = self.indexOfLeftChild(forParentAtIndex: index)
        var min_index = Int(index)
        
        for indexIncrement in 0...1 {
            let childIndex = (Int(leftChildIndex) + indexIncrement)
            
            // Check that the child index is not out of bounds
            if (childIndex < Int(self.count)) {
                
                switch self.type {
                case .min:
                    if (self.array[childIndex].key < self.array[min_index].key) {
                        min_index = childIndex
                    }
                    break
                case .max:
                    if (self.array[childIndex].key > self.array[min_index].key) {
                        min_index = childIndex
                    }
                    break
                }
            }
        }
        
        if (min_index != Int(index)) {
            // Swap
            let parentElement = self.array[Int(index)]
            let minChildElement = self.array[min_index]
            self.array[Int(index)] = minChildElement
            self.array[Int(min_index)] = parentElement
            
            bubbleDown(startingAtIndex: UInt(min_index))
        }
    }
    
    private mutating func makeHeap(from elements: [HeapElement] ) {
        for element in elements {
            do {
                try self.enqueue(item: element)
            } catch {
                print("Couldn't add item to the heap.")                
            }
        }
    }
}
