//
//  RoutePathArray+Extensions.swift
//  RouteStack
//
//  Created by Tony on 2023/07/12.
//  Copyright © 2023 Tony. All rights reserved.
//

import Foundation

// public API

public typealias RoutePaths<T: Equatable> = [RoutePath<T>]

extension Array where Element: RoutePathProtocol {
  
  /// 다음화면 이동 하나만
  public mutating func moveTo(_ routePath: Element) {
    self.appendLastPath(in: &self, element: routePath)
  }

  /// 다음화면 여러개 이동
  public mutating func moveTo(_ routePaths: [Element]) {
    var newArray: [Element] = self
    for routePath in routePaths {
      newArray.appendLastPath(in: &newArray, element: routePath)
    }
    self = newArray
  }

  /// 이전화면 이동
  public mutating func back() {
    if self.size <= 1 || self.removeLastPath(in: &self[self.count - 1]) == nil {
      self.removeLast()
    }
  }
  
  /// 최상위 화면으로 이동
  public mutating func backToRoot() {
    self.removeAll()
  }
  
  /// 사이즈 반환
  public var size: Int {
    return self.calculateSum(in: self)
  }
}


// private API

extension Array where Element: RoutePathProtocol {
  
  /// 마지막 path 제거
  private func removeLastPath(in node: inout Element) -> Element? {
    guard !node.stack.isEmpty else { return nil }
    
    if node.stack.last?.stack.isEmpty == true {
      return node.stack.removeLast()
    } else {
      var lastElement = node.stack.last!
      let removedElement = removeLastPath(in: &lastElement)
      node.stack[node.stack.count - 1] = lastElement
      return removedElement
    }
  }
  
  /// 마지막 path 추가
  private func appendLastPath(in nodes: inout [Element], element: Element) {
    if nodes.last == nil {
      return nodes.append(element)
    }
    if (element.isPresentable) && nodes[nodes.count - 1].canPresent {
      return appendLastPath(in: &nodes[nodes.count - 1].stack, element: element)
    } else if element.style == .push && nodes[nodes.count - 1].canPush {
      return appendLastPath(in: &nodes[nodes.count - 1].stack, element: element)
    } else if nodes[nodes.count - 1].stack.isEmpty {
      return nodes.append(element)
    } else {
      return appendLastPath(in: &nodes[nodes.count - 1].stack, element: element)
    }
  }
  
  /// 사이즈 계산
  private func calculateSum(in nodes: [Element]) -> Int {
    var sum = nodes.count
    
    for node in nodes {
      sum += calculateSum(in: node.stack)
    }
    
    return sum
  }
}

extension Array where Element: RoutePathProtocol {
  subscript (safe index: Index) -> Element? {
    get {
      return indices.contains(index) ? self[index] : nil
    }
    set {
      if let newValue = newValue, indices.contains(index) {
        self[index] = newValue
      }
    }
  }
}
