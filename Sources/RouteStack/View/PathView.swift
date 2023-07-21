//
//  PathView.swift
//  RouteStack
//
//  Created by Tony on 2023/07/12.
//  Copyright © 2023 Tony. All rights reserved.
//

import SwiftUI

public struct PathView<Destination: View>: View {
  var path: Binding<RoutePath?>
  var destination: (AnyHashable) -> Destination
  @State var pushStack: [RoutePath]
  
  public init(
    path: Binding<RoutePath?>,
    destination: @escaping (AnyHashable) -> Destination
  ) {
    self.path = path
    self.destination = destination
    if path.wrappedValue?.style == .cover {
      self._pushStack = .init(wrappedValue: path.wrappedValue!.pushStack)
    } else {
      self._pushStack = .init(wrappedValue: [])
    }
  }
  
  /// push 가능 여부
  var canPush: Bool {
    self.path.wrappedValue?.canPush ?? false
  }
  
  /// present 가능 여부
  var canPresent: Bool {
    self.path.wrappedValue?.canPresent ?? false
  }
  
  /// push 할 path data
  var nextPushPathData: Binding<RoutePath?> {
    return Binding(
      get: {
        if let index = self.path.wrappedValue?.pushStack.count {
          return self.path.wrappedValue?.pushStack[safe: index - 1]
        } else {
          return nil
        }
      },
      set: { newValue in
        if let index = self.path.wrappedValue?.pushStack.count {
          self.path.wrappedValue?.pushStack[safe: index - 1] = newValue
        }
      }
    )
  }
  
  /// present 할 path 데이터
  var nextPresentPathData: Binding<RoutePath?> {
    return Binding(
      get: {
        if let index = self.path.wrappedValue?.stack.lastIndex(where: { $0.canPresent }) {
          return self.self.path.wrappedValue?.stack[safe: index]
        } else {
          return nil
        }
      },
      set: { newValue in
        if let index = self.path.wrappedValue?.stack.lastIndex(where: { $0.canPresent }) {
          self.self.path.wrappedValue?.stack[safe: index] = newValue
        }
      }
    )
  }
  
  /// sheet 바인딩
  var sheetBinding: Binding<Bool> {
    guard case .sheet = nextPresentPathData.wrappedValue?.style else {
      return .constant(false)
    }
    return .constant(true)
  }
  
  /// cover 바인딩
  var coverBinding: Binding<Bool> {
    guard case .cover = nextPresentPathData.wrappedValue?.style else {
      return .constant(false)
    }
    return .constant(true)
  }
  
  /// pushable
  private var pushableDestination: some View {
    NavigationStack(path: $pushStack) {
      NavigationLink(value: self.nextPushPathData.wrappedValue, label: EmptyView.init).hidden()
        .navigationDestination(for: RoutePath.self, destination: { nextPushPathData in
          if self.nextPushPathData.wrappedValue != nil && self.nextPushPathData.wrappedValue?.id == nextPushPathData.id {
            PathView(path: self.nextPushPathData, destination: destination)
          } else {
            PathView(path: Binding(get: { nextPushPathData }, set: { _, _ in}), destination: destination)
          }
        })
      destination(path.wrappedValue?.data)
    }
  }
  
  public var body: some View {
    VStack {
      if canPush {
        pushableDestination
      } else {
        destination(path.wrappedValue?.data)
      }
    }
    .sheet(
      isPresented: sheetBinding,
      onDismiss: {
        self.path.wrappedValue?.stack.removeAll(where: { $0.id == nextPresentPathData.wrappedValue?.id })
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
        self.path.wrappedValue?.stack.removeAll(where: { $0.id == nextPresentPathData.wrappedValue?.id })
      },
      content: { PathView(path: nextPresentPathData, destination: destination) }
    )
    .onAppear {
      if case .sheet = path.wrappedValue?.style {
        self.pushStack = path.wrappedValue?.pushStack ?? []
      }
    }
    .onChange(of: path.wrappedValue, perform: { newValue in
      self.pushStack = path.wrappedValue?.pushStack ?? []
    })
    .onChange(of: pushStack) { newValue in
      self.path.wrappedValue?.pushStack = newValue
    }
  }
}
