//
//  IsLinkedListPalindrome.swift
//  Algorithmia
//
//  Created by Borja Arias Drake on 02/05/2017.
//  Copyright © 2017 Borja Arias Drake. All rights reserved.
//

import Foundation
import RSDataStructures

func isPalindrome<T: Comparable>(list: SinglyLinkedList<T>) -> Bool
{
    guard list.count > 0 else {
        return false
    }
    
    let result = isPalindromeRecursive(list: list, index: 0, length: UInt(list.count))
    
    return result.isPalindrome
}



func isPalindromeRecursive<T: Comparable>(list: SinglyLinkedList<T>, index: Int, length: UInt) -> (nextIndex: Int, isPalindrome: Bool)
{
    // BASE CASE
    if (length == 0) {
        // Even number of elements
        return (nextIndex: index, isPalindrome: true)
        
    } else if (length == 1) {
        // Odd number of elements
        return (nextIndex: (index+1), isPalindrome: true)
    }
    
    // RECURSIVE STEP
    var result = isPalindromeRecursive(list: list, index: (index+1), length: length - 2)
    let value = list[list.index(list.startIndex, offsetBy:index)]
    let resultValue = list[list.index(list.startIndex, offsetBy:result.nextIndex)]
    if (value != resultValue) {
        result.isPalindrome = false
    }
    
    result.nextIndex = (result.nextIndex + 1)
    
    return result
}


