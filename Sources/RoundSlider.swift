//
//  RoundSlider.swift
//  Sliders
//
//  Created by Timothy Dubbins on 11/04/2022.
//

import SwiftUI

/// A control for selecting a value from a bounded linear range of values.
///
/// A round slider consists of a “thumb” image that the user moves between two extremes of a round “track”.
/// The ends of the track represent the minimum and maximum possible values. As the user moves the thumb,
/// the slider updates its bound value.
/// The following example shows a slider bound to the value myValue. As the slider updates this value,
/// the title shows the value updating. The onEditingChanged closure passed to the slider receives callbacks
/// when the user drags the slider.
///
/// ```
/// @State private var myValue = 30.0
/// @State private var isEditing = false
///
/// var body: some View {
///     RoundSlider(
///         "title",
///         value: $myValue,
///         in: 10...70,
///         displayBounds: 0...10,
///         color: .green) {
///             isEditing = $0
///         }
/// }
///  ```
///
/// Using iOS drawing orientation, dragging the thumb in  the positive-x or negative-y direction corresponds to an increase in
/// the value of the created instance. Similarly, dragging the thumb in the negative-x or positive-y direction decreases the value.
public struct RoundSlider: View {
    // MARK: - Properties

    /// The selected value within bounds.
    @Binding var value: Double

    /// The title of the slider that is currently being displayed.
    @State private var displayTitle: String

    /// The x-coordinate of the slider.
    @State private var start: CGPoint? = nil

    /// The title of the slider.
    let title: String

    /// The range of the valid values.
    let bounds: ClosedRange<Double>

    /// The range of values to display.
    let displayBounds: ClosedRange<Double>?

    /// A callback for when editing begins and ends.
    let onEditingChanged: (Bool) -> Void

    /// The width of the sliders track.
    let lineWidth: CGFloat

    /// The title font.
    let font: Font

    /// The length of the arc, in range [0, 1].
    let arcLength: CGFloat

    /// The diameter of the slider. Defaults to 80.
    let width: CGFloat?

    /// The sensitivity of the drag gesture, in range [0, 1].
    let sensitivity: Double

    /// The color used to highlight current the value.
    let color: Color
    
    /// Whether or not the display value is shown when editing.
    let showValueOnEditing: Bool

    private let style: StrokeStyle
    private let rotation: Angle

    private var normalValue: CGFloat {
        CGFloat((value - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound))
    }

    private var displayValue: Double? {
        guard let display = displayBounds else { return nil }
        return display.lowerBound + (display.upperBound - display.lowerBound) * normalValue
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { gesture in
                updateValue(with: gesture.location)

                if showValueOnEditing {
                    displayTitle = String(format: "%0.2f", displayValue ?? value)
                }
            }
            .onEnded { _ in
                onEditingChanged(false)
                start = nil

                if showValueOnEditing {
                    withAnimation(.easeInOut(duration: 0.5).delay(0.25)) {
                        displayTitle = title
                    }
                }
            }
    }

    public var body: some View {
        VStack(spacing: 0) {
            Text(displayTitle)
                .fontWeight(.semibold)
                .font(font)
                .foregroundColor(.secondary)
                .padding(.bottom, lineWidth)
                .transition(.opacity)

                // We change the id parameter of the view when
                // we change its title. This resets the views
                // state, allowing us to animate this change.
                .id("RoundSlider" + displayTitle)

            ZStack {
                // Track remaining to be filled.
                Circle()
                    .inset(by: lineWidth * 0.5)
                    .trim(from: 0, to: arcLength)
                    .stroke(style: style)
                    .rotation(rotation)
                    .foregroundColor(.secondary)
                    .opacity(0.3)

                // Track filled to current value.
                Circle()
                    .inset(by: lineWidth * 0.5)
                    .trim(from: 0, to: arcLength * normalValue)
                    .stroke(style: style)
                    .rotation(rotation)
                    .foregroundColor(color)
            }
            .frame(width: width, height: width)
        }
        .contentShape(Rectangle())
        .gesture(dragGesture)
    }

    // MARK: - Methods

    /// Creates a round slider to select a value from a given range.
    ///
    /// The value of the created instance is equal to the position of the given value within bounds, mapped into 0...1.
    /// The slider calls onEditingChanged when editing begins and ends. For example, on iOS,
    /// editing begins when the user starts to drag the thumb along the slider’s track.
    ///
    /// - Parameter title: The title of the slider.
    /// - Parameter value: The selected value within bounds.
    /// - Parameter bounds: The range of the valid values. Defaults to 0...1.
    /// - Parameter displayBounds: The range of values to display. If nil then `bounds` is used. Defaults to nil.
    /// - Parameter lineWidth: The line width for the slider. Defaults to 8.
    /// - Parameter arcLength: The fractional length of the slider arc, with a value of 1 being a circle. Defaults to 0.8.
    /// - Parameter width: The width of the slider frame. Defaults to 60.
    /// - Parameter sensitivity: The sensitivity of the drag gesture, in range [0, 1]. Defaults to 0.5.
    /// - Parameter color: The accent color for the slider. Defaults to the primary color.
    /// - Parameter showValueOnEditing: Replaces the title with the current value when true. Defaults to true.
    /// - Parameter onEditingChanged: A callback for when editing begins and ends.
    public init(
        _ title: String,
        value: Binding<Double>,
        in bounds: ClosedRange<Double>,
        displayBounds: ClosedRange<Double>? = nil,
        lineWidth: CGFloat = 7,
        arcLength: CGFloat = 0.8,
        font: Font = .body,
        width: CGFloat = 80,
        sensitivity: Double = 0.5,
        color: Color = .blue,
        showValueOnEditing: Bool = true,
        onEditingChanged: @escaping (Bool) -> Void
    ) {
        _displayTitle = State(initialValue: title)
        _value = value
        self.title = title
        self.bounds = bounds
        self.displayBounds = displayBounds
        self.lineWidth = lineWidth
        self.arcLength = arcLength.clamped(to: 0...1)
        self.font = font
        self.width = width
        self.sensitivity = sensitivity.clamped(to: 0.05...1) * 0.005 * (bounds.upperBound - bounds.lowerBound)
        self.color = color
        self.showValueOnEditing = showValueOnEditing
        self.onEditingChanged = onEditingChanged

        style = StrokeStyle(lineWidth: lineWidth, lineCap: .round)
        rotation = Angle(radians: Double(1 - arcLength) * .pi + 0.5 * .pi)
    }

    private func updateValue(with translation: CGPoint) {
        guard let _start = start else {
            start = translation
            onEditingChanged(true)
            return
        }

        let delta = (translation.x - _start.x) - (translation.y - _start.y)
        let newValue = value + delta * sensitivity

        value = newValue.clamped(to: bounds.lowerBound...bounds.upperBound)
        start = translation
    }
}
