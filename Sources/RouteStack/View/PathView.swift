//
//  PathView.swift
//  RouteStack
//
//  Created by Tony on 2023/07/12.
//  Copyright © 2023 Tony. All rights reserved.
//

import SwiftUI

public struct PathView<Destination: View, Data: Equatable>: View {
  /// [Binding] 모든 path 들
  private var allPaths: Binding<[RoutePath<Data>]>

  /// 현재 path
  private var currentPath: RoutePath<Data>

  /// 목적지 화면
  private var destination: (RoutePath<Data>.ID, Data) -> Destination

  /// 현재 path에서 다룰 수 있는 path들
  private var scopePaths: Binding<[RoutePath<Data>]> {
    return Binding(
      get: {
        // scopePaths를 기반으로 현재 path에서 다룰 수 있는 paths를 반환합니다.

        if let currentIndex = allPaths.wrappedValue.firstIndex(of: currentPath) {
          // 현재 path부터 모든 배열
          let remainingPaths = allPaths.wrappedValue.suffix(from: currentIndex + 1)

          // 현재 path부터 다룰 수 있는 범위까지의 배열
          var scopePaths: [RoutePath<Data>] = []

          // 배열의 첫번째가 presentable하거나, 그렇지 않은 경우에 따라 분기
          if let firstPresentablePath = remainingPaths.first, firstPresentablePath.isPresented == true {
            // 배열의 첫번째가 presentable한 경우, 해당 path만 포함시겨 반환
            scopePaths = [firstPresentablePath]
          } else if self.currentPath.isPresented {
            // 배열의 첫번째가 presentable하지 않고, currentPath가 presentable한 경우,
            // presentable 값을 만나기 전까지의 isPushable한 path를 반환
            scopePaths = remainingPaths.prefix { $0.isPushed }
          }

          return scopePaths
        }
        return []
      },
      set: { newValue in
        // newValue를 기반으로 현재 path 이후의 paths를 업데이트합니다.

        if let currentIndex = allPaths.wrappedValue.firstIndex(of: currentPath) {
          // 현재 path부터 모든 배열
          let remainingPaths = allPaths.wrappedValue.suffix(from: currentIndex + 1)

          // 현재 path부터 다룰 수 있는 범위까지의 배열
          var scopePaths: [RoutePath<Data>] = []

          // 배열의 첫번째가 presentable하거나, 그렇지 않은 경우에 따라 분기
          if let firstPresentablePath = remainingPaths.first, firstPresentablePath.isPresented == true {
            // 배열의 첫번째가 presentable한 경우, 해당 path만 포함시겨 반환
            scopePaths = [firstPresentablePath]
          } else if self.currentPath.isPresented {
            // 배열의 첫번째가 presentable하지 않고, currentPath가 presentable한 경우,
            // presentable 값을 만나기 전까지의 isPushable한 path를 반환
            scopePaths = remainingPaths.prefix { $0.isPushed }
          }

          let startIndex = currentIndex + 1
          var updatedPaths = allPaths.wrappedValue

          updatedPaths.replaceSubrange(startIndex ..< startIndex + scopePaths.count, with: newValue)

          self.allPaths.wrappedValue = updatedPaths
        }
      }
    )
  }


  /// 현재 path에서 navigationStack에 사용될 navigationStack
  @State
  private var navigationStack: [RoutePath<Data>]

  /// [Binding] navigationStack에 sync될 stack
  /// NOTE: 현재 path가 sheet로 열린 경우, 하위 navigationStack을 onAppear에서 초기화해주어야 정상적으로 navigationStack이 반영되기 때문에 pushStack과 navigationStack으로 나누어 관리하게 됨
  private var pushStack: Binding<[RoutePath<Data>]> {
    return Binding(
      get: {
        let stack = self.scopePaths.wrappedValue.prefix { $0.style == .push }
        return Array(stack)
      },
      set: { newValue in
        self.scopePaths.wrappedValue = newValue
      }
    )
  }


  /// [Binding] present될 path
  private var presentablePath: Binding<RoutePath<Data>?> {
    return Binding(
      get: {
        self.scopePaths.wrappedValue.last { $0.isPresented }
      },
      set: { newValue in
        self.scopePaths.wrappedValue = newValue.map { [$0] } ?? []
      }
    )
  }

  /// [Binding] push될 path
  private var pushablePath: Binding<RoutePath<Data>?> {
    return Binding(
      get: {
        self.pushStack.wrappedValue.last { $0.isPushed }
      },
      set: { newValue in
        self.pushStack.wrappedValue = newValue.map { [$0] } ?? []
      }
    )
  }

  /// sheet 바인딩
  private var sheetBinding: Binding<Bool> {
    guard case .sheet = presentablePath.wrappedValue?.style else {
      return .constant(false)
    }
    return .constant(true)
  }

  /// cover 바인딩
  private var coverBinding: Binding<Bool> {
    guard case .cover = presentablePath.wrappedValue?.style else {
      return .constant(false)
    }
    return .constant(true)
  }

  /// pushable 화면
  private var pushableDestination: some View {
    NavigationStack(path: $navigationStack) {
      NavigationLink(value: self.pushablePath.wrappedValue, label: EmptyView.init).hidden()
        .navigationDestination(for: RoutePath<Data>.self) { pushablePath in
          PathView(
            allPaths: self.allPaths,
            currentPath: pushablePath,
            destination: self.destination
          )
        }
      destination(currentPath.id, currentPath.data)
    }
  }

  public init(
    allPaths: Binding<[RoutePath<Data>]>,
    currentPath: RoutePath<Data>,
    destination: @escaping (RoutePath<Data>.ID, Data) -> Destination
  ) {
    self.allPaths = allPaths
    self.currentPath = currentPath
    self.destination = destination
    if currentPath.style == .cover {
      var scopePaths: [RoutePath<Data>] {
        if let currentIndex = allPaths.wrappedValue.firstIndex(of: currentPath) {
          // 현재 path부터 모든 배열
          let remainingPaths = allPaths.wrappedValue.suffix(from: currentIndex + 1)

          // 현재 path부터 다룰 수 있는 범위까지의 배열
          var filteredPaths: [RoutePath<Data>] = []

          // 배열의 첫번째가 presentable하거나, 그렇지 않은 경우에 따라 분기
          if let firstPresentablePath = remainingPaths.first, firstPresentablePath.isPresented == true {
            // 배열의 첫번째가 presentable한 경우, 해당 path만 포함시겨 반환
            filteredPaths = [firstPresentablePath]
          } else if currentPath.isPresented {
            // 배열의 첫번째가 presentable하지 않고, currentPath가 presentable한 경우,
            // presentable 값을 만나기 전까지의 isPushable한 path를 반환
            filteredPaths = remainingPaths.prefix { $0.isPushed }
          }

          return filteredPaths
        }
        return []
      }
      let stack = scopePaths.prefix { $0.isPushed }
      self._navigationStack = .init(wrappedValue: Array(stack))
    } else {
      self._navigationStack = .init(initialValue: [])
    }
  }

  public var body: some View {
    Group {
      if self.currentPath.isPresented {
        pushableDestination
      } else {
        destination(self.currentPath.id, self.currentPath.data)
      }
    }
    .sheet(
      isPresented: sheetBinding,
      onDismiss: {
        self.presentablePath.wrappedValue = nil
      },
      content: {
        if let presentablePath = presentablePath.wrappedValue,
           case let .sheet(detents, indicatorVisibility) = presentablePath.style
        {
          PathView(
            allPaths: self.allPaths,
            currentPath: presentablePath,
            destination: self.destination
          )
          .presentationDetents(detents)
          .presentationDragIndicator(indicatorVisibility)
        }
      }
    )
    .fullScreenCover(
      isPresented: coverBinding,
      onDismiss: {
        self.presentablePath.wrappedValue = nil
      },
      content: {
        if let presentablePath = presentablePath.wrappedValue {
          PathView(
            allPaths: self.allPaths,
            currentPath: presentablePath,
            destination: self.destination
          )
        }
      }
    )
    .onAppear {
      if case .sheet = currentPath.style {
        self.navigationStack = self.pushStack.wrappedValue
      }
    }
    .onChange(of: pushStack.wrappedValue) { pushStack in
      self.navigationStack = pushStack
    }
    .onChange(of: navigationStack) { navigationStack in
      self.pushStack.wrappedValue = navigationStack
    }
  }
}
