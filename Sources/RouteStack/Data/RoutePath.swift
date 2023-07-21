//
//  RoutePath.swift
//  RouteStack
//
//  Created by Tony on 2023/07/12.
//  Copyright © 2023 Tony. All rights reserved.
//

import Foundation

public struct RoutePath: Hashable {
  /// ID
  let id: AnyHashable

  /// Data
  let data: AnyHashable

  /// 해당 node에 해당하는 화면의 노출 스타일
  let style: Style

  /// 하위 node Stack
  var stack: [RoutePath]
  
  /// navigationStack에 반영 될 스택
  var pushStack: [RoutePath] {
    get {
      var stack: [RoutePath] = []
      
      for path in self.stack {
        if path.style == .push {
          stack.append(path)
        } else {
          break
        }
      }
      
      return stack
    }
    set {
      // TODO: 문제있을수도 있음. 순서가 보장되지않아서.. 잘 작동하길,, 안되면 나중에 고민해보자고~
      var updatedStack = self.stack.filter { $0.style != .push }

      for path in newValue {
        updatedStack.append(path)
      }

      self.stack = updatedStack
    }
  }

  /// 푸시 가능 여부 | navigationStack은 중첩되지 않으니까.. | 이게 true면 해당 path의 stack에다가 push node 쌓기
  var canPush: Bool {
    switch self.style {
    case .cover:
      return true
    case .sheet:
      return true
    case .push:
      return false
    }
  }

  /// 프레젠트 가능 여부 | 이게 true면 해당 path의 stack에다가 present node 쌓기
  var canPresent: Bool {
    return true
  }
  
  /// sheet 혹은 cover 인가?
  var isPresentable: Bool {
    switch self.style {
    case .cover:
      return true
    case .sheet:
      return true
    case .push:
      return false
    }
  }

  public init(
    id: AnyHashable = UUID(),
    data: AnyHashable,
    style: Style,
    stack: [RoutePath] = []
  ) {
    self.id = id
    self.data = data
    self.style = style
    self.stack = stack
  }
}
