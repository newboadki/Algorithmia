//
//  File.swift
//  Algorithmia
//
//  Created by Borja Arias Drake on 07/05/2017.
//  Copyright © 2017 Borja Arias Drake. All rights reserved.
//

import Foundation

public class MinMaxStack<T: Comparable> : StackBasedOnLinkedList<T> {
    
    fileprivate var peekType: StackPeekType
    fileprivate var minMaxStack: StackBasedOnLinkedList<T>
    
    required public init(type: StackPeekType)
    {
        peekType = type
        minMaxStack = StackBasedOnLinkedList<T>()
        super.init()
    }
    
    override public func push(item: T) {
        
        if let _ = self.minMaxStack.peek() {
            let shouldBeAdded = self.comparisonBlock()(item, self.minMaxStack.peek()!)
            if shouldBeAdded {                
                self.minMaxStack.push(item: item)
            }
        } else {
            self.minMaxStack.push(item: item)
        }
        
        super.push(item: item)        
    }

    override public func pop() -> T? {

        if self.peek() == self.minMaxStack.peek() {
            let _ = self.minMaxStack.pop()
        }
        
        return super.pop()
    }

    func comparisonBlock() -> ((_ p1: T, _ p2: T) -> (Bool)) {
        
        switch self.peekType
        {
            case .min:
                return {(_ p1, _ p2) -> Bool in
                    p1 <= p2
                }            
            case .max:
                return {(_ p1, _ p2) -> Bool in
                    p1 >= p2
                }
        }
    }
}

extension MinMaxStack : MinMaxPeekStack {
    
    public var type: StackPeekType {
        get {
            return peekType
        }
    }    
    
    public func minMaxPeek() -> T? {
        return self.minMaxStack.peek()
    }

}
