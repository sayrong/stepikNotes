//
//  MyTests.swift
//  NotesTests
//
//  Created by Dmitriy on 02/07/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import XCTest
@testable import Notes

class MyTests: XCTestCase {
    
    var myNote: Note!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        myNote = Note(uid: UUID().uuidString, title: "Example title", content: "test content", color: .red, importance: .important, destructDate: Date())
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        myNote = nil
    }
    
    func testExampleFull() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let json = myNote.json
        let parsed = Note.parse(json: json)
        
        XCTAssertEqual(myNote.title, parsed?.title)
        XCTAssertEqual(myNote.content, parsed?.content)
        XCTAssertEqual(myNote.uid, parsed?.uid)
        XCTAssertEqual(myNote.color, parsed?.color)
        XCTAssertEqual(myNote.importance, parsed?.importance)
        XCTAssertNotNil(myNote.selfDestructDate)
        XCTAssertNotNil(parsed?.selfDestructDate)
        XCTAssertEqual(myNote.selfDestructDate!.timeIntervalSinceNow, parsed!.selfDestructDate!.timeIntervalSinceNow, accuracy: 0.0001)
    }
    
    func testWrongJson() {
        let json:[String: Any] = ["test": 1, "qq" : "c"]
        let result = Note.parse(json: json)
        XCTAssertNil(result)
    }
    
    func testNoFileNoteBook() {
        let book = FileNotebook(filename: "test")
        let notes = book.notes
        XCTAssert(notes.isEmpty)
        
        book.loadFromFile()
        XCTAssert(notes.isEmpty)
    }
    
    func testRemoveWrongUid() {
        let book = FileNotebook(filename: "test1")
        let note = Note(title: "a", content: "b", importance: .normal)
        book.add(note)
        
        book.remove(with: "qq")
        
        XCTAssert(!book.notes.isEmpty)
    }
}

