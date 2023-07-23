//
//  RouteStack.swift
//  RouteStack
//
//  Created by Tony on 2023/07/12.
//  Copyright © 2023 Tony. All rights reserved.
//

import Foundation
import SwiftUI

public struct RouteStack<Root: View, Destination: View, Data: Equatable>: View {
  var paths: Binding<[RoutePath<Data>]>
  var root: Root
  var destination: (RoutePath<Data>.ID?, Data?) -> Destination?
  
  /// navigationStack에 반영 될 스택
  @State var pushStack: [RoutePath<Data>]

  /// push 할 패스 데이터
  var nextPushPathData: Binding<RoutePath<Data>?> {
    return Binding(
      get: {
        let index = self.$pushStack.wrappedValue.count
        return self.$pushStack.wrappedValue[safe: index - 1]
      },
      set: { newValue in
        let index = self.$pushStack.wrappedValue.count
        self.$pushStack.wrappedValue[safe: index - 1] = newValue
      }
    )
  }
  
  /// present 할 패스 데이터
  var nextPresentPathData: Binding<RoutePath<Data>?> {
    return Binding(
      get: {
        if let index = paths.wrappedValue.lastIndex(where: { $0.isPresentable }) {
          return self.paths.wrappedValue[safe: index]
        } else {
          return nil
        }
      }, set: { newValue in
        if let index = paths.wrappedValue.lastIndex(where: { $0.isPresentable }) {
          self.paths.wrappedValue[safe: index] = newValue
        }
      }
    )
  }
  
  /// 시트 바인딩
  var sheetBinding: Binding<Bool> {
    guard case .sheet = nextPresentPathData.wrappedValue?.style else {
      return .constant(false)
    }
    return .constant(true)
  }
  
  /// 커버 바인딩
  var coverBinding: Binding<Bool> {
    guard case .cover = nextPresentPathData.wrappedValue?.style else {
      return .constant(false)
    }
    return .constant(true)
  }
  
  public var body: some View {
    NavigationStack(path: $pushStack) {
      NavigationLink(value: self.nextPushPathData.wrappedValue, label: EmptyView.init).hidden()
        .navigationDestination(for: RoutePath<Data>.self, destination: { nextPushPathData in
          if self.nextPushPathData.wrappedValue != nil && self.nextPushPathData.wrappedValue?.id == nextPushPathData.id {
            PathView(path: self.nextPushPathData, destination: destination)
          } else {
            PathView(path: Binding(get: { nextPushPathData }, set: { _, _ in}), destination: destination)
          }
        })
      root
    }
    .sheet(
      isPresented: sheetBinding,
      onDismiss: {
        paths.wrappedValue.removeAll(where: { $0.id == nextPresentPathData.wrappedValue?.id })
      },
      content: {
        if case let .sheet(detents, indicatorVisibility) = nextPresentPathData.wrappedValue?.style {
          PathView(path: nextPresentPathData, destination: destination)
            .presentationDetents(detents)
            .presentationDragIndicator(indicatorVisibility)
        }
      }
    )
    .fullScreenCover(
      isPresented: coverBinding,
      onDismiss: {
        paths.wrappedValue.removeAll(where: { $0.id == nextPresentPathData.wrappedValue?.id })
      },
      content: { PathView(path: nextPresentPathData, destination: destination) }
    )
    .onAppear {
      var stack: [RoutePath<Data>] = []
      
      for path in self.paths.wrappedValue {
        if path.style == .push {
          stack.append(path)
        } else {
          break
        }
      }
      
      if case .sheet = self.nextPresentPathData.wrappedValue?.style {
        self.pushStack = stack
      }
    }
    .onChange(of: paths.wrappedValue, perform: { newValue in
      var stack: [RoutePath<Data>] = []
      
      for path in self.paths.wrappedValue {
        if path.style == .push {
          stack.append(path)
        } else {
          break
        }
      }
      
      self.pushStack = stack
    })
    .onChange(of: pushStack) { newValue in
      // TODO: 문제있을수도 있음. 순서가 보장되지않아서.. 잘 작동하길,, 안되면 나중에 고민해보자고~
      var updatedStack = self.paths.wrappedValue.filter { $0.style != .push }
      
      for path in newValue {
        updatedStack.append(path)
      }
      
      self.paths.wrappedValue = updatedStack
    }
  }
  
  public init(
    _ paths: Binding<RoutePaths<Data>>,
    @ViewBuilder root: () -> Root,
    @ViewBuilder destination: @escaping (RoutePath<Data>.ID, Data) -> Destination
  ) {
    self.paths = paths
    self.root = root()
    
    self.destination = { id, data in
      if let id = id, let data = data {
        return destination(id, data)
      } else {
        return nil
      }
    }
    
    if let path = paths.last(where: { $0.wrappedValue.style == .cover }) {
      self._pushStack = .init(wrappedValue: path.pushStack.wrappedValue)
    } else {
      self._pushStack = .init(wrappedValue: [])
    }
  }
}
