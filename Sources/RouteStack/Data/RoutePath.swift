//
//  RoutePath.swift
//  RouteStack
//
//  Created by Tony on 2023/07/12.
//  Copyright © 2023 Tony. All rights reserved.
//

import Foundation

public protocol RoutePathProtocol: Hashable, Identifiable {
  associatedtype Data = Equatable

  var data: Data { get set }

  /// 해당 node에 해당하는 화면의 노출 스타일
  var style: Style { get }

  /// 하위 node Stack
  var stack: [Self] { get set }

  /// navigationStack에 반영 될 스택
  var pushStack: [Self] { get set }

  /// 푸시 가능 여부 | navigationStack은 중첩되지 않으니까.. | 이게 true면 해당 path의 stack에다가 push node 쌓기
  var canPush: Bool { get }

  /// 프레젠트 가능 여부 | 이게 true면 해당 path의 stack에다가 present node 쌓기
  var canPresent: Bool { get }
  
  /// sheet 혹은 cover 인가?
  var isPresentable: Bool { get }
}

public struct RoutePath<T: Equatable>: RoutePathProtocol {
  /// ID
  public let id: AnyHashable
  
  public func hash(into hasher: inout Hasher) { hasher.combine(id) }

  /// Data
  public var data: T

  /// 해당 node에 해당하는 화면의 노출 스타일
  public let style: Style

  /// 하위 node Stack
  public var stack: [RoutePath]
  
  /// navigationStack에 반영 될 스택
  public var pushStack: [RoutePath] {
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
  public var canPush: Bool {
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
  public var canPresent: Bool {
    return true
  }
  
  /// sheet 혹은 cover 인가?
  public var isPresentable: Bool {
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
    data: T = UUID(),
    style: Style,
    stack: [RoutePath] = []
  ) {
    self.id = id
    self.data = data
    self.style = style
    self.stack = stack
  }
}
