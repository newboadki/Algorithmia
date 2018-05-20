//
//  FindNumberThatHaveGivenSumTests.swift
//  Algorithmia
//
//  Created by Borja Arias Drake on 12/04/2017.
//  Copyright © 2017 Borja Arias Drake. All rights reserved.
//

import XCTest


class FindNumberThatHaveGivenSumTests: XCTestCase {
    
    func testExampleWithSolutions() {
        let result = numbersThatSum(to: 8, from: [3, 6, 1, 7, 5 ,-2, 33, 22, 10])
        let expected = [(3,5), (1,7), (-2,10)]
        
        for (index, value) in result.enumerated() {
            XCTAssert(value == expected[index])
        }
    }
    
    func testExampleWithoutSolutions() {
        let result = numbersThatSum(to: 100, from: [3, 6, 1, 7, 5 ,-2, 33, 22, 10])
        XCTAssertTrue(result.isEmpty)
    }

    func testExampleWithEmptyInput() {
        let result = numbersThatSum(to: 100, from: [0])
        XCTAssertTrue(result.isEmpty)
    }

}
