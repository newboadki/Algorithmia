//
//  TopologiaclSortingTests.swift
//  UnitTests
//
//  Created by Borja Arias Drake on 15/06/2017.
//  Copyright © 2017 Borja Arias Drake. All rights reserved.
//

import XCTest

class IterativeTopologiacalSortingTests: XCTestCase {
    
    func testValidTopologicalSorting() {
        let vertices = [p(0),p(1),p(2),p(3),p(4),p(5)]
        let edges = [(p(0),p(1)),
                     (p(0),p(2)),
                     (p(1),p(3)),
                     (p(3),p(4)),
                     (p(3),p(5))]
        let g = AdjacencyListGraph<IntegerPair>(vertices: vertices, edges:edges, directed: true)
        let result = g.iterativeTopologicalSort(graph: g)
        
        let expectation = [0,1,3,4,5,2]
        let resultKeys = array(fromStack: result!)
        XCTAssertTrue(resultKeys == expectation)
    }
    
    func testTopologicalSortingWithCycle() {
        let vertices = [p(0),p(1),p(2),p(3),p(4),p(5)]
        let edges = [(p(0),p(1)),
                     (p(0),p(2)),
                     (p(1),p(3)),
                     (p(3),p(4)),
                     (p(3),p(5)),
                     (p(3),p(0))]
        
        let g = AdjacencyListGraph<IntegerPair>(vertices: vertices, edges:edges, directed: true)
        let result = g.iterativeTopologicalSort(graph: g)
        XCTAssertNil(result)
    }
    
    func testTopologicalSortingWithForDisconnectedGraph() {
        let vertices = [p(0),p(1),p(2),p(3),p(4),p(5),p(6),p(7),p(8)]
        let edges = [(p(0),p(1)),
                     (p(0),p(2)),
                     (p(1),p(3)),
                     (p(3),p(4)),
                     (p(3),p(5)),
                     (p(7),p(6))]
        
        let g = AdjacencyListGraph<IntegerPair>(vertices: vertices, edges:edges, directed: true)
        let result = g.iterativeTopologicalSort(graph: g)
        
        let expectation = [8,7,6,0,1,3,4,5,2]
        let resultKeys = array(fromStack: result!)
        XCTAssertTrue(resultKeys == expectation)
    }
    
}

class RecursiveTopologiacalSortingTests: XCTestCase {
    
    func testValidTopologicalSorting() {
        let vertices = [p(0),p(1),p(2),p(3),p(4),p(5)]
        let edges = [(p(0),p(1)),
                     (p(0),p(2)),
                     (p(1),p(3)),
                     (p(3),p(4)),
                     (p(3),p(5))]
        let g = AdjacencyListGraph<IntegerPair>(vertices: vertices, edges:edges, directed: true)
        let result = g.recursiveTopologicalSort(graph: g)
        
        let expectation = [0,2,1,3,5,4]
        let resultKeys = array(fromStack: result!)
        XCTAssertTrue(resultKeys == expectation)
    }
    
    func testTopologicalSortingWithCycle() {
        let vertices = [p(0),p(1),p(2),p(3),p(4),p(5)]
        let edges = [(p(0),p(1)),
                     (p(0),p(2)),
                     (p(1),p(3)),
                     (p(3),p(4)),
                     (p(3),p(5)),
                     (p(3),p(0))]
        
        let g = AdjacencyListGraph<IntegerPair>(vertices: vertices, edges:edges, directed: true)
        let result = g.recursiveTopologicalSort(graph: g)
        
        XCTAssertNil(result)
    }
    
    func testTopologicalSortingWithForDisconnectedGraph() {
        let vertices = [p(5),p(1),p(3),p(8),p(4),p(0),p(6),p(7),p(2)]
        let edges = [(p(0),p(1)),
                     (p(0),p(2)),
                     (p(1),p(3)),
                     (p(3),p(4)),
                     (p(3),p(5)),
                     (p(7),p(6))]
        
        let g = AdjacencyListGraph<IntegerPair>(vertices: vertices, edges:edges, directed: true)
        let result = g.recursiveTopologicalSort(graph: g)
        
        let expectation = [8,7,6,0,2,1,3,5,4]
        let resultKeys = array(fromStack: result!)
        XCTAssertTrue(resultKeys == expectation)
    }
}

func array<S: Stack, E: KeyValuePair>(fromStack: S) -> [Int] where S.Item == E, E.K == Int {
    
    var resultKeys = [Int]()
    while let item = fromStack.pop() {
        resultKeys.append(item.key)
    }
    
    return resultKeys
}
