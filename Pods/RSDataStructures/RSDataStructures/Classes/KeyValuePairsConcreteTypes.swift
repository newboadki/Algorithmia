//
//  KeyValuePairsConcreteTypes.swift
//  UnitTests
//
//  Created by Borja Arias Drake on 16/09/2017.
//  Copyright © 2017 Borja Arias Drake. All rights reserved.
//

import Foundation


/// Concrete impletation of a KeyValuePair where  both the key and the value
/// are Integers.
public struct IntegerPair : KeyValuePair {
    
    // MARK - KeyValuePair protocol
    public var key : Int
    public var value : Int
    
    public init(key: Int, value: Int) {
        self.key = key
        self.value = value
    }
    
    public func copy() -> IntegerPair {
        return IntegerPair(key: self.key, value: self.value)
    }
}


public struct StringKeyedPair : KeyValuePair {
    
    // MARK - KeyValuePair protocol
    public var key : String
    public var value : Int
    
    public init(key: String, value: Int) {
        self.key = key
        self.value = value
    }

    public func copy() -> StringKeyedPair {
        return StringKeyedPair(key: self.key, value: self.value)
    }
}
