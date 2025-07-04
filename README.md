# InteractiveZoomDriver
This repo is view to zoomable by pinch gesture.

## Overview

![](demo.gif)

## Requirements

- iOS 13.0+
- Swift 5.5+

## Installation

### Swift Package Manager

For installing with SPM, add it to your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/shima11/InteractiveZoomDriver.git", from: "1.2.6"))
]
```

### Carthage

For installing with Carthage, add it to your `Cartfile`.

```
github "shima11/InteractiveZoomDriver"
```

### CocoaPods

For installing with CocoaPods, add it to your `Podfile`.

```
pod 'InteractiveZoomDriver'
```

## Usage

```
import InteractiveZoomDriver

let zoomView = UIImageView() // UIView or SubClass of UIView
zoomView.isUserInteractionEnabled = true
```

### Case1: driver
Add zoom function to target UIView.

`gestureTargetView`: added tap and pan gesture.  
`sourceView`: source view.  
`targetViewFactory`: Transformed View during zooming.  
`shouldZoomTransform`: Delegate to the outside whether zooming is possible.  

```
let driver = InteractiveZoomDriver(
  gestureTargetView: imageView2,
  sourceView: imageView2,
  targetViewFactory: { (fromImageView: UIImageView) -> UIView in
    let view = UIImageView()
    view.image = fromImageView.image
    view.clipsToBounds = fromImageView.clipsToBounds
    view.contentMode = fromImageView.contentMode
    return view
  },
  shouldZoomTransform: {(sourceView: UIImageView) -> Bool in
    if sourceView.image == nil {
      return false
    }
    return true
  }
)
```
This is also no problem.
`InteractiveZoomView.clone` and `InteractiveZoomView.shouldZoomTransform` is default implementation of protocol extension.
`InteractiveZoomView` corresponds to `UIImageView` only.
To support other than `UIImageView`, add an implementation in extension.

```
let driver = InteractiveZoomDriver(
  gestureTargetView: zoomView, 
  sourceView: zoomView, 
  targetViewFactory: InteractiveZoomView.clone, 
  shouldZoomTransform: InteractiveZoomView.shouldZoomTransform
)
```

### Case2: overlay view 

InteractiveZoomView is able to only UIImageView now.  
If you want to use custom UIView, you need to create extension of InteractiveZoomView with reference to InteractiveZoomView.

```
let overlayZoomView = InteractiveZoomView(
    sourceView: zoomView
)
view.addSubView(overlayZoomView)
```

### Case3: SwiftUI support

Starting with iOS 13, you can use InteractiveZoomSwiftUIView to add zoom functionality to your SwiftUI views.

```swift
import SwiftUI
import InteractiveZoomDriver

struct ContentView: View {
    // Store UIImageView as a member variable to prevent recreation when body is reevaluated
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "sample"))
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var body: some View {
        InteractiveZoomSwiftUIView(sourceView: imageView)
            .frame(width: 300, height: 300)
    }
}
```

For custom UIView support, you can provide the targetViewFactory and shouldZoomTransform parameters:

```swift
struct CustomContentView: View {
    // Store custom UIView as a member variable
    private let customView: CustomUIView = {
        let view = CustomUIView()
        // Configure the view
        return view
    }()
    
    var body: some View {
        InteractiveZoomSwiftUIView(
            sourceView: customView,
            targetViewFactory: { sourceView in
                // Create a clone of the source view
                let clonedView = CustomUIView()
                // Configure the cloned view
                return clonedView
            },
            shouldZoomTransform: { sourceView in
                // Determine if the view should be zoomable
                return true
            }
        )
        .frame(width: 300, height: 300)
    }
}
```
