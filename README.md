# Sliders

<div align="center">
  
  
<p align="center">
    <img src="https://img.shields.io/badge/iOS-14.0+-blue.svg" />
    <img src="https://img.shields.io/badge/Swift-5.0-brightgreen.svg" />
</p>
  
</div>

Current version: 1.0.0 [[Download](https://github.com/timdubbins/Sliders/archive/refs/tags/1.0.0.zip)]

A collection of custom sliders for SwiftUI. 
- *RoundSlider* gives you a slider that acts as a dial or knob. 
- *DoubleSlider* lets you select a range using a slider with two thumbs.

![me](https://github.com/timdubbins/demo_content/blob/master/Sliders/slider_demo.gif)

## Getting Started 

To use *Sliders* in a project, add this descriptor to the `dependencies` list in your `Package.swift` file:

```swift
.package(url: "https://github.com/timdubbins/sliders", .exact("1.0.0")) 
```

Alternatively, in Xcode, go to:
```
File > Add Packages...
``` 
and enter
```
https://github.com/timdubbins/sliders
```
as the package URL.

## Examples

### RoundSlider

```
@State private var myValue = 30.0
@State private var isEditing = false

var body: some View {
    RoundSlider(
        "title",
        value: $myValue,
        in: 10...70,
        displayBounds: 0...10,
        color: .green) {
            isEditing = $0
        }
}
```

### DoubleSlider

```
@State private var lowValue = 0.0
@State private var highValue = 10.0
@State private var onEditing = false

var body: some View {
    VStack {
        DoubleSlider(
            lowValue: $lowValue,
            highValue: $highValue,
            in: 0...10) {
                onEditing = $0
            }
        Text(String(onEditing))
            .foregroundColor(onEditing ? .red : .green)
    }
}
```


Happy coding!
