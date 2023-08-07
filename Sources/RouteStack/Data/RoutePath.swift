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

  /// Data
  var data: Data { get set }

  /// 해당 path 화면의 노출 스타일
  var style: Style { get }

  /// presnt된(될) 화면인지 여부(sheet 혹은 cover)
  var isPresented: Bool { get }

  /// push된(될) 화면인지 여부
  var isPushed: Bool { get }
}

public struct RoutePath<T: Equatable>: RoutePathProtocol {
  public let id: AnyHashable

  public func hash(into hasher: inout Hasher) { hasher.combine(id) }

  public var data: T

  public let style: Style

  public var isPresented: Bool {
    switch self.style {
    case .cover:
      return true
    case .sheet:
      return true
    case .push:
      return false
    }
  }

  public var isPushed: Bool {
    switch self.style {
    case .cover:
      return false
    case .sheet:
      return false
    case .push:
      return true
    }
  }

  public init(
    id: AnyHashable = UUID(),
    data: T = UUID(),
    style: Style
  ) {
    self.id = id
    self.data = data
    self.style = style
  }
}
