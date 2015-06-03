//
//  Observable.swift
//  Eventful
//
//  Created by Thomas Bouldin on 6/2/15.
//  Copyright (c) 2015 Inlined. All rights reserved.
//

import Foundation

// Observable is like a promise for an event which may change many times.
// Observables are managed much like Observable processing. Because a value may
// be observed many times, values which are yielded before an observable is
// observed are dropped; this is because it is unknown what level of caching
// may be desirable in the Observable type. To change this, sublcasses should
// overload didAddObserver.
// TODO: Is there any value in removing the yielder from the Observable?
public class Observable<T> {
  private var callbacks: [(T!)->()] = []
  private var lock = Lock()
  
  private func addCallback(block: (T!) ->()) {
    lock.synchronized {
      self.callbacks.append(block)
      self.didAddObserver(block)
    }
  }
  
  // Method for sublcasses; useful for sending initial values
  func didAddObserver(block: (T!) -> ()) {}
  
  public func yield(value: T!) {
    lock.synchronized {
      for callback in self.callbacks {
        callback(value)
      }
    }
  }
  
  // default transforms a Observable into one which replaces all nil values with defaultValue
  public func defaultValue(defaultValue: T) -> Observable<T> {
    let observable = Observable<T>()
    addCallback {
      if $0 == nil {
        observable.yield(defaultValue)
      } else {
        observable.yield($0)
      }
    }
    return observable
  }
  
  // map transforms a Observable from one type to another
  public func map<Y>(block: (T!) -> Y) -> Observable<Y> {
    let observable = Observable<Y>()
    addCallback {
      let result = block($0)
      observable.yield(result)
    }
    return observable
  }
  
  // then is like a delayed version of map. It transforms a Observable from
  // observed<X> to observed<y> via an asynchronous promise.
  public func then<Y>(block: (T!) -> Promise<Y>) -> Observable<Y> {
    let observable = Observable<Y>()
    addCallback {
      block($0).then { (result: Y!) -> Void in
        observable.yield(result)
      }
    }
    return observable
  }
  
  // tap provides a way to observe a Observable without changing it.
  // the closure will be run for each yielded value, but tap returns
  // the original observed Observable.
  public func tap(block: (T!) -> ()) -> Observable<T> {
    addCallback(block)
    return self
  }
  
  // select returns an observed Observable where only values for which
  // the closure returns true are yielded.
  public func select(block: (T!) -> (Bool)) -> Observable<T> {
    let observable = Observable<T>()
    addCallback {
      if block($0) {
        observable.yield($0)
      }
    }
    return observable
  }
  
  public func skip(var amount: Int) -> Observable<T> {
    let observable = Observable<T>()
    addCallback {
      if amount > 0 {
        --amount
      } else {
        observable.yield($0)
      }
    }
    return observable
  }
}