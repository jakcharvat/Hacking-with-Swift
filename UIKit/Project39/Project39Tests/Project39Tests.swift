//
//  Project39Tests.swift
//  Project39Tests
//
//  Created by Jakub Charvat on 27/04/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import XCTest
@testable import Project39

class Project39Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    func testAllWordsLoaded() {
        let playData = PlayData()
        XCTAssertEqual(playData.filteredWords.count, 18440, "allWords wasn't 18440")
    }
    
    
    func testWordCountsAreCorrect() {
        let playData = PlayData()
        XCTAssertEqual(playData.wordCounts.count(for: "stain"), 18, "\"stain\" doesn't appear 18 times")
        XCTAssertEqual(playData.wordCounts.count(for: "both"), 218, "\"both\" doesn't appear 218 times")
        XCTAssertEqual(playData.wordCounts.count(for: "suspicion"), 12, "\"suspicion\" doesn't appear 12 times")
    }
    
    
    func testSortingIsCorrect() {
        let playData = PlayData()
        XCTAssertLessThan(playData.filteredWords.firstIndex(of: "I") ?? 0, playData.filteredWords.firstIndex(of: "the") ?? 0, "\"I\" did not appear before \"the\"")
        XCTAssertLessThan(playData.filteredWords.firstIndex(of: "hath") ?? 0, playData.filteredWords.firstIndex(of: "were") ?? 0, "\"hath\" did not appear before \"were\"")
        XCTAssertLessThan(playData.filteredWords.firstIndex(of: "soul") ?? 0, playData.filteredWords.firstIndex(of: "swear") ?? 0, "\"soul\" did not appear before \"swear\"")
    }
    

    func testUserFilterWorks() {
        let playData = PlayData()

        playData.applyUserFilter("100")
        XCTAssertEqual(playData.filteredWords.count, 495)

        playData.applyUserFilter("1000")
        XCTAssertEqual(playData.filteredWords.count, 55)

        playData.applyUserFilter("10000")
        XCTAssertEqual(playData.filteredWords.count, 1)

        playData.applyUserFilter("test")
        XCTAssertEqual(playData.filteredWords.count, 56)

        playData.applyUserFilter("swift")
        XCTAssertEqual(playData.filteredWords.count, 7)

        playData.applyUserFilter("objective-c")
        XCTAssertEqual(playData.filteredWords.count, 0)
    }
    
    
    func testWordLoadTime() {
        measure {
            _ = PlayData()
        }
    }

}
