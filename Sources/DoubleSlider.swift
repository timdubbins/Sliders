//
//  DoubleSlider.swift
//  Sliders
//
//  Created by Timothy Dubbins on 11/04/2022.
//


import SwiftUI

/// A control for selecting two values from a bounded linear range of values.
///
/// A slider consists of two “thumb” image that the user moves between two extremes of a linear “track”.
/// The ends of the track represent the minimum and maximum possible values. As the user moves a thumb,
/// the slider updates its bound value. The following example shows a slider bound to the values lowValue and highValue.
/// As the slider updates this value, a bound Text view shows the value updating.
/// The onEditingChanged closure passed to the slider receives callbacks when the user drags the slider.
/// The example uses this to change the color and boolean in the Text view.
///
///  ```
/// @State private var lowValue = 0.0
/// @State private var highValue = 10.0
/// @State private var onEditing = false
///
/// var body: some View {
///    VStack {
///        DoubleSlider(
///            lowValue: $lowValue,
///            highValue: $highValue,
///            in: 0...10) {
///                onEditing = $0
///            }
///         Text(String(onEditing))
///            .foregroundColor(onEditing ? .red : .green)
///    }
/// }
///  ```
///
///  You can also use a step parameter to provide incremental steps along the path of the slider. For example,
///  if you have a slider with a range of 0 to 100, and you set the step value to 5, the slider’s increments would be 0, 5, 10, and so on.
public struct DoubleSlider: View {
    // MARK: - Properties
    
    /// The value of thumb on the left-hand-side.
    @Binding var lowValue: Double

    /// The value of thumb on the right-hand-side.
    @Binding var highValue: Double

    /// The zIndex for the thumb on the right-hand-side.
    @State private var zIndexRHS: Double = 0

    /// The x-coordinate at the start of a drag gesture.
    @State private var startX: CGFloat? = nil

    /// The lower-bound for the slider.
    let minimumValue: Double

    /// The upper-bound for the slider.
    let maximumValue: Double

    /// The distance between the upper and lower bounds.
    let totalDistance: Double

    /// The distance between each value.
    let step: Double?

    /// A callback for when editing begins and ends.
    let onEditingChanged: (Bool) -> Void

    public var body: some View {
        GeometryReader { geo in
            ZStack {
                HStack(spacing: 0) {
                    // Track to the left of the LHS thumb.
                    Track()
                        .foregroundColor(Color.secondary)
                        .opacity(0.3)
                        .frame(width: xPosition(side: .lhs, geo))

                    // Track in-between the two thumbs.
                    Track()
                        .foregroundColor(.pink)

                    // Track to the right of the RHS thumb.
                    Track()
                        .foregroundColor(Color.secondary)
                        .opacity(0.3)
                        .frame(width: geo.size.width - xPosition(side: .rhs, geo))
                }
                .padding(.horizontal, -4.5)

                Thumb(side: .lhs) // lowValue
                    .position(CGPoint(
                        x: xPosition(side: .lhs, geo),
                        y: geo.size.height * 0.5))
                    .zIndex(1)
                    .gesture(dragGesture(side: .lhs, geo: geo))

                Thumb(side: .rhs) // highValue
                    .position(CGPoint(
                        x: xPosition(side: .rhs, geo),
                        y: geo.size.height * 0.5))
                    .zIndex(zIndexRHS)
                    .gesture(dragGesture(side: .rhs, geo: geo))
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 5.5)
    }

    // MARK: - Methods

    /// Creates a slider to select two values from a given range.
    ///
    /// The values of the created instance are equal to the position of the given values within bounds, mapped into 0...1.
    /// The slider calls onEditingChanged when editing begins and ends. For example, on iOS, editing begins when the user starts to drag a thumb along the slider’s track
    ///
    /// - Parameter lowValue: The value of thumb on the left-hand-side.
    /// - Parameter highValue: The value of thumb on the right-hand-side.
    /// - Parameter bounds: The range of the valid values. Defaults to 0...1.
    /// - Parameter step: The distance between each valid value.
    /// - Parameter onEditingChanged: A callback for when editing begins and ends.
    public init(
        lowValue: Binding<Double>,
        highValue: Binding<Double>,
        in bounds: ClosedRange<Double> = 0...1,
        step: Double? = nil,
        onEditingChanged: @escaping (Bool) -> Void) {
            _lowValue = lowValue
            _highValue = highValue
            minimumValue = bounds.lowerBound
            maximumValue = bounds.upperBound
            totalDistance = maximumValue - minimumValue
            self.step = step
            self.onEditingChanged = onEditingChanged
        }

    private func dragGesture(side: Thumb.Side, geo: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { gesture in
                let translationX = gesture.translation.width

                if let newValue = getNewValue(for: side, translationX, geo) {
                    if side == .lhs {
                        lowValue = newValue
                        zIndexRHS = 0
                    } else {
                        highValue = newValue
                        zIndexRHS = 1
                    }
                }
            }
            .onEnded { _ in
                onEditingChanged(false)
                startX = nil

                if side == .lhs {
                    zIndexRHS = 0
                } else {
                    zIndexRHS = 1
                }
            }
    }

    private func getNewValue(for side: Thumb.Side, _ translationX: CGFloat, _ geo: GeometryProxy) -> Double? {
        if startX == nil {
            startX = xPosition(side: side, geo)
            onEditingChanged(true)
        }

        guard let startX = startX else { return nil }

        var newValue: Double {
            var value = Double((startX + translationX) / geo.size.width) * totalDistance

            if let step = step {
                value = value - value.remainder(dividingBy: step)
            }

            return side == .lhs
            ? min(value, highValue)
            : max(lowValue, value)
        }

        return newValue.clamped(to: minimumValue...maximumValue)
    }

    private func xPosition(side: Thumb.Side, _ geo: GeometryProxy) -> CGFloat {
        let value = side == .lhs ? lowValue : highValue
        return geo.size.width * CGFloat((value) / totalDistance)
    }
}

// MARK: - Components

private struct Thumb: View {
    enum Side {
        case lhs
        case rhs
    }

    let side: Side

    // We use a background with a frame set to the
    // desired hit target for the thumbs. This is
    // chosen over using contentShape as it allows
    // us to use zIndexing to prevent the thumbs
    // getting stuck when both are at minimum or
    // maximum values.
    let background: some View = Rectangle()
        .foregroundColor(.clear)
        .frame(width: 44, height: 44)

    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .foregroundColor(.white)
            .shadow(radius: 2)
            .frame(width: 11, height: 24)
            .padding(.top, side == .lhs ? 20 : -20)
            .background(background)
    }
}

private struct Track: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .frame(height: 4)
    }
}
