//
//  File.swift
//  Algorithmia
//
//  Created by Borja Arias Drake on 06/05/2017.
//  Copyright © 2017 Borja Arias Drake. All rights reserved.
//

import Foundation
import RSDataStructures

func sample() {
    var queue = SinglyLinkedList<Int>()
    add(34, to: &queue)
    add(100, to: &queue)
    
    var q2 = SinglyLinkedList<Int>()
    try! q2.enqueue(item: 900)
    try! q2.enqueue(item: 901)
    
    let array = [queue,q2]
    add(78, to: array)
}


/// Really interesting example. On how to use a protocol with associated types (Queue)
/// It only seems that we need to constraint the parameters enough(queue's element type and the argument of the method)
/// so that the the compiler can have enough information. I think, at least it needs to be able to constraint the
/// Types a little bit, to guarantee that they could not be from different types
func add<E, Q: Queue>(_ element: E, to queue: inout Q) where Q.Item == E {
    try! queue.enqueue(item: element)
}

func add<E, C: Container>(_ element: E, to array: [C]) where C.Element == E {
    for bin in array {
        bin.addPlease(element: element)
    }
}

func add<E:Comparable, Q: Queue>(_ element: E, to array: [Q]) where Q.Item == E {
    for queue in array {
        print(queue.getFirst()!)
    }
}

protocol Container {
    
    associatedtype Element : Comparable
    
    func addPlease(element: Element)
}

class Bin<T:Comparable> : Container {
    typealias Element = T
    
    func addPlease(element: T) {
        
    }
}

