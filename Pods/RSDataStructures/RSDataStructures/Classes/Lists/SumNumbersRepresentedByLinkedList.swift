//
//  SumNumbersRepresentedByLinkedList.swift
//  Algorithmia
//
//  Created by Borja Arias Drake on 04/05/2017.
//  Copyright © 2017 Borja Arias Drake. All rights reserved.
//

import Foundation

struct PartialSum {
    var index : Int?
    var carriage : Int
    var sum: SinglyLinkedList<Int> // list representing the partial sum to be read from left to right
}

// Assuming they both have the same number of digits (zeros on the shortest's right have been added).
// This also assumes the numbers are stored in the list in reversed order
func sumLeftToRight(l1: SinglyLinkedList<Int>, l2: SinglyLinkedList<Int>) -> SinglyLinkedList<Int>
{
    var carriage = false
    var offset = 0
    var idx1 = l1.index(l1.startIndex, offsetBy: offset)
    var idx2 = l1.index(l2.startIndex, offsetBy: offset)
    var n1 = l1[idx1]
    var n2 = l2[idx2]
    var sumList = SinglyLinkedList<Int>()
    
    while(offset < l1.count) {
        var sum = (n1 + n2)
        if (carriage == true) {
            sum += 1
        }
        
        if (sum >= 10) {
            carriage = true
            sum = sum - 10
        } else {
            carriage = false
        }
        
        sumList.append(value: sum)
        
        offset += 1
        idx1 = l1.index(l1.startIndex, offsetBy: offset)
        idx2 = l1.index(l2.startIndex, offsetBy: offset)
        if (offset < l1.count) {
            n1 = l1[idx1]
            n2 = l2[idx2]
        }
    }
        
    
    return sumList
}


func sumRightToLeft(l1: SinglyLinkedList<Int>, l2: SinglyLinkedList<Int>) -> SinglyLinkedList<Int> {
    
    // TODO. Pad with zeros
    
    var result = sumHelper(l1: l1, l2: l2, index: 0)
    
    if result.carriage == 1 {
        result.sum.prepend(value: 1)
    }
    
    return result.sum
}

func sumHelper(l1: SinglyLinkedList<Int>,
               l2: SinglyLinkedList<Int>, index: Int?) -> PartialSum {
    
    // BASE CASE
    if (index == l1.count) {
        return PartialSum(index: nil, carriage: 0, sum: [])
    }
    
    var result = sumHelper(l1: l1, l2: l2, index: (index! + 1))
    let n1 = l1[l1.index(l1.startIndex, offsetBy: index!)]
    let n2 = l2[l2.index(l2.startIndex, offsetBy: index!)]
    var sum = n1 + n2 + result.carriage    
    
    if (sum >= 10) {
        result.carriage = 1
        sum = sum - 10
    } else {
        result.carriage = 0
    }
    
    result.sum.prepend(value: sum)
    return result
}


