//
//  BaseStack.swift
//  Algorithmia
//
//  Created by Borja Arias Drake on 07/05/2017.
//  Copyright © 2017 Borja Arias Drake. All rights reserved.
//

import Foundation

public class StackBasedOnLinkedList<T> : Stack
{
    public typealias Item = T
    
    /// Internal data structure
    private var list = SinglyLinkedList<T>()

    public init()
    {
        
    }
    
    /// Adds a new element in Last In First Out order
    ///
    /// - Parameter item: new element to be added
    public func push(item: Item)
    {
        self.list.prepend(value: item)
    }
    
    
    /// Removes and returns the item at the top of the stack
    public func pop() -> Item?
    {
        guard (self.list.count > 0) else {
            return nil
        }

        return self.list.deleteItem(at: 0)
    }
    
    /// Returns without removing the item at the top of the stack
    public func peek() -> Item?
    {
        return self.list.first
    }
    
    public func count() -> Int {
        return self.list.count
    }
}
