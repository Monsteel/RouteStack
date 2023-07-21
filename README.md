# RouteStack

#### SwiftUI에서 navigation 과 presentation 상태를 하나의 Stack으로 관리할 수 있습니다.

[There is also an explanation in English.](https://github.com/Monsteel/RouteStack/tree/main/README_EN.md)

💁🏻‍♂️ iOS16+ 를 지원합니다.<br>
💁🏻‍♂️ 순수한 SwiftUI 를 사용하여 구현되었습니다.<br>
💁🏻‍♂️ NavigationStack을 기반으로 하여 구현되었습니다.<br>
💁🏻‍♂️ sheet의 다양한 옵션(Presentation Detents, Presentation Drag Indicator)을 지원합니다.<br>

## 장점

✅ RouteStack을 사용하면, SwiftUI에서 **Coordinator 개념을 쉽게 적용시킬 수 있습니다.**<br>
✅ RouteStack과 Deeplink를 함께 사용하여, **화면(Scene) : Deeplink = 1:1 을 구현할 수 있습니다.**<br>
✅ RouteStack을 사용하면, 상황에 따라 노출 방식(push, sheet, cover..)을 선택하여 **쉽게 보여줄 수 있습니다.**<br>

## 사용방법

간단한 코드로, 멋진 Routing을 구현할 수 있습니다.<br>
자세한 사용방법은 [예제코드](https://github.com/Monsteel/RouteStack/tree/main/Example)를 참고해주세요.

### 기본 구조

```swift
enum Path: Hashable {
  case first(String)
  case second(String)
  case third(String)
}

struct ContentView: View {
  @State var routePaths: RoutePaths = .init()

  @ViewBuilder
  func root() -> some View {
    // root view를 정의합니다.
  }

  var body: some View {
    RouteStack($routePaths, root: root, for: Path.self) { path in
      switch path {
        // path view 를 정의합니다. path에 따라 분기하여 정의할 수 있습니다.
      }
    }
  }
}
```

### 기본적인 화면 전환 방법

제공되는 API를 통해, routePaths를 업데이트 할 수 있습니다.

> ⚠️ 제공되는 API이외에, Array 기반 함수를 직접적으로 사용할 경우 예기치 못한 작동을 일으킬 수 있습니다.

```swift
struct ContentView: View {
  @State var routePaths: RoutePaths = .init()

  @ViewBuilder
  func root() -> some View {
    Button("push") {
      routePaths.moveTo(.init(data: Path.first("value"), style: .push))
    }

    Button("custom-sheet") {
      routePaths.moveTo(.init(data: Path.first("value"), style: .sheet([.medium, .large], .visible)))
    }

    Button("normal") {
      routePaths.moveTo(.init(data: Path.first("value"), style: .sheet()))
    }

    Button("cover") {
      routePaths.moveTo(.init(data: Path.first("value"), style: .push))
    }

    Button("cover -> push -> push") {
      routePaths.moveTo([
        .init(data: Path.first("value"), style: .cover),
        .init(data: Path.first("value"), style: .push),
        .init(data: Path.first("value"), style: .push),
      ])
    }

    Button("backToRoot") {
      routePaths.backToRoot()
    }

    Button("back") {
      routePaths.back()
    }
  }

  var body: some View {
    // 생략
  }
}

```

### deeplink를 사용한 화면 전환 방법

routePaths에 직접적으로 접근하지 않고, deeplink를 활용해 화면을 전환할 수 있습니다.

```swift
struct ContentView: View {
  @State var routePaths: RoutePaths = .init()

  @ViewBuilder
  func root() -> some View {
    // 생략
  }

  var body: some View {
    RouteStack($routePaths, root: root, for: Path.self) { path in
      // 생략
      Button("work") {
        UIApplication.shared.open(URL(string: "routeStackExample://backToRoot")!)
      }
      // 생략
    }
    .onOpenURL { url in
      // deeplink로 전달받은 url 정보를 바탕으로 routePaths 값을 업데이트 해줍니다.
    }
  }
}

```

## Swift Package Manager(SPM) 을 통해 사용할 수 있어요

```swift
dependencies: [
  .package(url: "https://github.com/Monsteel/RouteStack.git", .upToNextMajor(from: "0.0.1"))
]
```

## 함께 만들어 나가요

개선의 여지가 있는 모든 것들에 대해 열려있습니다.<br>
PullRequest를 통해 기여해주세요. 🙏

## License

RouteStack 는 MIT 라이선스로 이용할 수 있습니다. 자세한 내용은 [라이선스](https://github.com/Monsteel/RouteStack/tree/main/LICENSE) 파일을 참조해 주세요.<br>
RouteStack is available under the MIT license. See the [LICENSE](https://github.com/Monsteel/RouteStack/tree/main/LICENSE) file for more info.

## Auther

이영은(Tony) | dev.e0eun@gmail.com

[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2FMonsteel%2FRouteStack&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false)](https://hits.seeyoufarm.com)
