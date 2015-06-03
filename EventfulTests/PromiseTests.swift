//
//  eventfulTests.swift
//  eventfulTests
//
//  Created by Thomas Bouldin on 6/2/15.
//  Copyright (c) 2015 Inlined. All rights reserved.
//

import XCTest
import Eventful

class PromiseTests: XCTestCase {
  func testResolveBeforeAttach() {
    let expectation = expectationWithDescription("resolve then attach")
    Promise(42).then { (val) -> () in
      XCTAssertEqual(val, 42, "")
      expectation.fulfill()
    }
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testResolveAfterAttach() {
    let expectation = expectationWithDescription("resolve before attach")
    let p = Promise<Int>()
    p.then { (val) -> () in
      XCTAssertEqual(val, 42, "")
      expectation.fulfill()
    }
    p.resolve(42)
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testErrorBeforeAttach() {
    let expectation = expectationWithDescription("error then attach")
    let err = NSError()
    let p = Promise<Int>()
    p.fail(err)
    p.error {
      XCTAssertEqual(err, $0, "")
      expectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testErrorAfterAttach() {
    let expectation = expectationWithDescription("error before attach")
    let err = NSError()
    let p = Promise<Int>()
    p.error {
      XCTAssertEqual(err, $0, "")
      expectation.fulfill()
    }
    p.fail(err)
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testAlwaysResolved() {
    let expectation = expectationWithDescription("always resolved")
    Promise(42).always { (val, err) in
      XCTAssertNil(err, "")
      XCTAssertEqual(val, 42, "")
      expectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testAlwaysFailed() {
    let expectation = expectationWithDescription("always failed")
    let err = NSError()
    Promise<Int>().always { (val, anErr) in
      XCTAssertEqual(err, anErr!, "")
      XCTAssertNil(val, "")
      expectation.fulfill()
    }.fail(err)
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testChainedSuccess() {
    let expectation = expectationWithDescription("chaining success")
    Promise<Int>(42).then {
      return "\($0)"
    }.then {
      return $0.toInt() ?? 0
    }.then { (val: Int!) -> () in
      XCTAssertEqual(42, val, "")
      expectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testChainedFailure() {
    let expectation = expectationWithDescription("chaining failure")
    var hitNestedAlways = false
    let p = Promise<Int>()
    let anErr = NSError()
    p.then {
      XCTFail("Should bypass success handler")
      return "\($0)"
    }.then { (val: String!) ->Int in
      XCTFail("Should bypass success handler")
      return val.toInt() ?? 0
    }.always { (val, err) in
      hitNestedAlways = true
      XCTAssertNil(val, "")
      XCTAssertEqual(err!, anErr, "")
    }.then { (val: Int!) -> Int in
      XCTFail("Should bypass success handler")
      return 0
    }.error { (err: NSError!) -> Void in
      XCTAssertEqual(err, anErr, "")
      expectation.fulfill()
    }
    
    p.fail(anErr)
    waitForExpectationsWithTimeout(5, handler: nil)
    XCTAssert(hitNestedAlways, "")
  }
  
  func testNestedSuccess() {
    let expectation = expectationWithDescription("nested promises")
    Promise(42).then { (val: Int!) -> Promise<Int> in
      XCTAssertEqual(42, val, "")
      return Promise(1337)
    }.then { (val: Int!) -> Void in
      XCTAssertEqual(1337, val, "")
      expectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
}
