//
//  ObservableTests.swift
//  Eventful
//
//  Created by Thomas Bouldin on 6/4/15.
//  Copyright (c) 2015 Inlined. All rights reserved.
//

import XCTest
import Eventful

func expectSequence<T : Equatable, V>(
  values expectations: [T],
  from input: [V!],
  block: (Observable<V>) -> Observable<T>)
{
  let source = Observable<V>()
  let sink = block(source)

  var iter = 0
  sink.tap { (value) in
    XCTAssertEqual(
      value,
      expectations[iter],
      "Unexpected value \(value); was expecting \(expectations[iter])"
    )
    iter++
  }

  for val in input {
    source.yield(val)
  }
  
  XCTAssertEqual(
    iter,
    expectations.count,
    "Only satisfied \(iter) of \(expectations.count) expectations. Unresolved expectations: " +
    "\(expectations[iter..<expectations.count])"
  )
}

func yieldSequence<T>(o: Observable<T>, values: T...) {
  for val in values {
    o.yield(val)
  }
}

class ObservableTests: XCTestCase {
  func testTap() {
    var didObserve = false
    let oracle = 42
    Observable<Int>().tap {
      XCTAssertEqual($0, 42, "")
      didObserve = true
    }.yield(oracle)
    
    XCTAssertTrue(didObserve, "")
  }
  
  func testMap() {
    expectSequence(values:["1", "2", "3"], from:[1, 2,3]) { observable in
      return observable.map { "\($0)" }
    }
  }
  
  func testSkip() {
    expectSequence(values: [], from: [1, 2, 3]) { $0.skip(4) }
    expectSequence(values: [2, 3], from: [1, 2, 3]) { $0.skip(1) }
  }
  
  func testNil() {
    let input: [Int!] = [1, nil, 2, nil]
    expectSequence(values: [1, 2], from: input) { $0.nonNil() }
    expectSequence(values: [1, 0, 2, 0], from: input) { $0.withDefault(0) }
  }
  
  func testSelect() {
    expectSequence(values: [2, 4, 6], from: [1, 2, 3, 4, 5, 6, 7]) { observable in
      observable.select { $0 % 2 == 0 }
    }
  }
  
  /* FIX: why isn't this operator seen outside of the Eventful package?
     FIX: Fix; (after locally defining the operator) why is parsed no longer inout
          inside the tap closure?
  func testPushToScalar() {
    var parsed: Int = -1
    var o = Observable<String>()
    
    o.map { $0.toInt() }.withDefault(-1) ~> parsed
    o.yield("1")
    XCTAssertEqual(parsed, "1", "")
    o.yield("2")
    XCTAssertEqual(parsed, "2", "")
    o.yield("NAN")
    XCTAssertEqual(parsed, "-1", "")
  }
   */
}