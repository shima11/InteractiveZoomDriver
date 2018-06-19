# InteractiveZoomDriver
This repo is view to zoomable by pinch gesture.

## Overview

![](demo.gif)

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

let zoomView = UIImageView() // UIView or SubClass of UIView
zoomView.isUserInteractionEnabled = true
```

### case1: driver
Add zoom function to target UIView.

gestureTargetView: added tap and pan gesture.
sourceView: source view.
targetViewFactory: Transformed View during zooming.
shouldZoomTransform: Delegate to the outside whether zooming is possible.

```
let driver = InteractiveZoomDriver(gestureTargetView: zoomView, sourceView: zoomView, targetViewFactory: InteractiveZoomView.clone, shouldZoomTransform: InteractiveZoomView.shouldZoomTransform)

view.addSubView(zoomView)
```

### case2: overlay view 

InteractiveZoomView is able to only UIImageView now.
If you want to use custom UIView, you need to create extension of InteractiveZoomView with reference to InteractiveZoomView.

```
let overlayZoomView = InteractiveZoomView(
    sourceView: zoomView
)
view.addSubView(overlayZoomView)
```
