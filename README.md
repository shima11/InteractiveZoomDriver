# InteractiveZoomDriver
This repo is view to zoomable by pinch gesture.

## Installation

### Carthage

```
github "shima11/InteractiveZoomDriver"
```

### CocoaPods

```
pod 'InteractiveZoomDriver', :git => 'https://github.com/shima11/InteractiveZoomDriver.git'
```

## Usage

```
import InteractiveZoomDriver

let zoomView = UIImageView()

// method1: driver
let driver = InteractiveZoomDriver(gestureTargetView: zoomView, sourceView: zoomView, targetViewFactory: InteractiveZoomView.clone, shouldZoomTransform: InteractiveZoomView.shouldZoomTransform)
zoomView.isUserInteractionEnabled = true

// method2: overlay view
let overlayZoomView = InteractiveZoomView(
    sourceView: zoomView
)
view.addSubView(overlayZoomView)

```
