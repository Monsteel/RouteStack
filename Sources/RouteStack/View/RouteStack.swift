//
//  RouteStack.swift
//  RouteStack
//
//  Created by Tony on 2023/07/12.
//  Copyright © 2023 Tony. All rights reserved.
//

import SwiftUI

public struct RouteStack<Root: View, Destination: View, Data: Equatable>: View {
  /// [Binding] 모든 path 들
  private var allPaths: Binding<[RoutePath<Data>]>

  /// 목적지 화면
  private var destination: (RoutePath<Data>.ID, Data) -> Destination

  /// root 화면
  private var root: Root

  /// 현재 path에서 다룰 수 있는 path들
  private var scopePaths: Binding<[RoutePath<Data>]> {
    return Binding(
      get: {
        let remainingPaths = allPaths.wrappedValue
        
        // 현재 path부터 다룰 수 있는 범위까지의 배열
        var filteredPaths: [RoutePath<Data>] = []
        
        // 배열의 첫번째가 presentable하거나, 그렇지 않은 경우에 따라 분기
        if let firstPresentablePath = remainingPaths.first, firstPresentablePath.isPresented == true {
          // 배열의 첫번째가 presentable한 경우, 해당 path만 포함시겨 반환
          filteredPaths = [firstPresentablePath]
        } else {
          // 배열의 첫번째가 presentable하지 않고, currentPath가 presentable한 경우,
          // presentable 값을 만나기 전까지의 isPushable한 path를 반환
          filteredPaths = remainingPaths.prefix { $0.isPushed }
        }
        
        return filteredPaths
      },
      set: { newValue in
        var updatedPaths = allPaths.wrappedValue
        
        // 배열의 첫번째가 presentable하거나, 그렇지 않은 경우에 따라 분기
        if let firstPresentableIndex = newValue.firstIndex(where: { $0.isPresented }) {
          // 배열의 첫번째가 presentable한 경우, 해당 path만 업데이트
          updatedPaths.replaceSubrange(0 ..< firstPresentableIndex, with: newValue)
        } else {
          // 배열의 첫번째가 presentable하지 않은 경우, newValue의 크기만큼 paths 업데이트
          for (index, newPath) in newValue.enumerated() {
            if index < updatedPaths.count {
              let existingPath = updatedPaths[index]
              if existingPath.id == newPath.id {
                updatedPaths[index] = newPath
              }
            }
          }
        }
        
        allPaths.wrappedValue = updatedPaths
      }
    )
  }


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

  public init(
    _ paths: Binding<[RoutePath<Data>]>,
    @ViewBuilder root: () -> Root,
    @ViewBuilder destination: @escaping (RoutePath<Data>.ID, Data) -> Destination
  ) {
    self.allPaths = paths
    self.root = root()
    self.destination = destination
  }

  public var body: some View {
    NavigationStack(path: pushStack) {
      NavigationLink(value: self.pushablePath.wrappedValue, label: EmptyView.init).hidden()
        .navigationDestination(for: RoutePath<Data>.self) { pushablePath in
          PathView(
            allPaths: self.allPaths,
            currentPath: pushablePath,
            destination: self.destination
          )
        }
      root
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
  }
}
