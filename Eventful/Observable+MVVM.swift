//
//  Observable+MVVM.swift
//  Eventful
//
//  Created by Thomas Bouldin on 6/2/15.
//  Copyright (c) 2015 Inlined. All rights reserved.
//

import Foundation

infix operator ~> {
  associativity right
  precedence 90
  assignment
}

func ~>(observable: Observable<String>, label: UILabel!) {
  observable.tap {
    if label == nil {
      return
    }
    label.text = $0
  }
}

func ~>(observable: Observable<UIImage>, view: UIImageView!) {
  observable.tap {
    if view == nil {
      return
    }
    view.image = $0
  }
}