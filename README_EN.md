# RouteStack

#### RouteStack allows you to manage navigation and presentation states as a single stack in SwiftUI.

RouteStack allows you to manage navigation and presentation states as a single stack in SwiftUI.
💁🏻‍♂️ It supports iOS 16 and later.<br>
💁🏻‍♂️ Implemented purely using SwiftUI.<br>
💁🏻‍♂️ Based on NavigationStack implementation.<br>
💁🏻‍♂️ Supports various options for sheets (Presentation Detents, Presentation Drag Indicator).<br>

## Advantages

✅ With RouteStack, you can easily apply the Coordinator pattern in SwiftUI.<br>
✅ By using RouteStack and Deeplinks together, you can achieve a one-to-one relationship between scenes and deeplinks.<br>
✅ RouteStack allows you to easily present views using different methods such as push, sheet, cover, etc.

## How to Use

You can achieve sophisticated routing with simple code.<br>
For detailed usage, please refer to the [example code](https://github.com/Monsteel/RouteStack/tree/main/Example).

### Basic Structure

```swift
enum Path: Hashable {
  case first(String)
  case second(String)
  case third(String)
}

struct ContentView: View {
  @State var routePaths: RoutePaths<Path> = .init()

  @ViewBuilder
  func root() -> some View {
    // Define the root view here.
  }

  var body: some View {
    RouteStack($routePaths, root: root) { id, path in
      switch path {
        // Define path views here. You can use a switch statement to define views based on the path.
      }
    }
  }
}
```

### Basic Screen Transition Methods

You can update routePaths using the provided API:

> ⚠️ Be cautious when using Array-based functions directly as they may cause unexpected behavior.

```swift
struct ContentView: View {
  @State var routePaths: RoutePaths<Path> = .init()

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
    // Omitted
  }
}

```

### Screen Transition with Deeplinks

You can use deeplinks to transition between views without directly accessing routePaths.

```swift
struct ContentView: View {
  @State var routePaths: RoutePaths<Path> = .init()

  @ViewBuilder
  func root() -> some View {
    // Omitted
  }

  var body: some View {
    RouteStack($routePaths, root: root) { id, path in
      // Omitted
      Button("work") {
        UIApplication.shared.open(URL(string: "routeStackExample://backToRoot")!)
      }
      // Omitted
    }
    .onOpenURL { url in
      // Update the routePaths value based on the information received from the deeplink URL.
    }
  }
}

```

## Swift Package Manager (SPM) Installation

```swift
dependencies: [
  .package(url: "https://github.com/Monsteel/RouteStack.git", .upToNextMajor(from: "0.0.1"))
]
```

## Let's Build Together

I'm open to contributions and improvements for anything that can be enhanced.<br>
Feel free to contribute through Pull Requests. 🙏

## License

RouteStack is available under the MIT license. See the [LICENSE](https://github.com/Monsteel/RouteStack/tree/main/LICENSE) file for more info.

## Auther

Tony | dev.e0eun@gmail.com
