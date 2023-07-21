//
//  Binding+Extensions.swift
//  RouteStack
//
//  Created by Tony on 2023/07/13.
//  Copyright © 2023 Tony. All rights reserved.
//

import Foundation
import SwiftUI

extension Binding: Equatable where Value == RoutePath {
  public static func == (lhs: Binding<Value>, rhs: Binding<Value>) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension Binding: Hashable where Value == RoutePath {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.wrappedValue)
  }
}
