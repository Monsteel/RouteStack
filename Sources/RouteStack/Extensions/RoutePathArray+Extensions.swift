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
  
  /// 사이즈 계산
  public var size: Int {
    return self.flatten.count
  }
  
  /// 복잡한 재귀 배열을 1차원 배열로 사용합니다.
  public var flatten: [Element] {
    get {
      var flattenedArray: [Element] = []
      flattenRecursive(array: self, resultArray: &flattenedArray)
      return flattenedArray
    }
    set {
      var updatedArray: [Element] = []
      var setArray: [Element] = newValue
      setRecursive(array: &updatedArray, setArray: &setArray)
      self = updatedArray
    }
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

extension Array where Element: RoutePathProtocol {
  private func flattenRecursive(array: [Element], resultArray: inout [Element]) {
    for element in array {
      resultArray.append(element)
      flattenRecursive(array: element.stack, resultArray: &resultArray)
    }
  }
  
  private func setRecursive(array: inout [Element], setArray: inout [Element]) {
    guard !setArray.isEmpty else { return }
    
    if let first = setArray.first, let index = array.firstIndex(where: { $0.id == first.id }) {
      array[index] = first
      setArray.removeFirst()
      setRecursive(array: &array[index].stack, setArray: &setArray)
    } else {
      for i in 0..<array.count {
        setRecursive(array: &array[i].stack, setArray: &setArray)
      }
    }
  }
}
