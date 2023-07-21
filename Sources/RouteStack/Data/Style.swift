//
//  Style.swift
//  RouteStack
//
//  Created by Tony on 2023/07/12.
//  Copyright © 2023 Tony. All rights reserved.
//

import Foundation
import SwiftUI

public enum Style: Hashable {
  /// fullscreenCover
  case sheet(_ detents: Set<PresentationDetent> = [.large], _ indicatorVisibility: Visibility = .hidden)
  
  /// fullscreenCover
  case cover
  
  /// navigationStack push
  case push
}
