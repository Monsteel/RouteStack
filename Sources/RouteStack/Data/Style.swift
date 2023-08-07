//
//  Style.swift
//  RouteStack
//
//  Created by Tony on 2023/07/12.
//  Copyright © 2023 Tony. All rights reserved.
//

import SwiftUI

public enum Style: Hashable {
  /// sheet
  case sheet(_ detents: Set<PresentationDetent> = [.large], _ indicatorVisibility: Visibility = .hidden)

  /// fullscreenCover
  case cover

  /// navigation
  case push
}
