//
//  ContentView.swift
//  LiquidSwipeSwiftUI
//
//  Created by Mark Goldin on 08/08/2019.
//  Copyright © 2019 Exyte. All rights reserved.
//

import SwiftUI
//
//let dragCircleRadius: CGFloat = 30.0
//let pad: CGFloat = 8.0
//
//struct Bloop : View {
//
//    var draggedOffset: CGSize
//    var color: Color
//
//    var body: some View {
//
//        GeometryReader { geometry in
//
//            Path { path in
//                path.move(
//                    to: CGPoint(x: 0, y: 0)
//                )
//
//                path.addLine(
//                    to: CGPoint(x: pad, y: 0)
//                )
//
//                path.addLine(
//                    to: CGPoint(x: self.draggedOffset.width, y: self.draggedOffset.height)
//                )
//
//                path.addLine(
//                    to: CGPoint(x: pad, y: geometry.size.height)
//                )
//
//                path.addLine(
//                    to: CGPoint(x: 0, y: geometry.size.height)
//                )
//            }
//            .foregroundColor(self.color)
//        }
//    }
//}
//
//struct ContentView: View {
//
//    var body: some View {
//        let screenSize = UIScreen.main.bounds.size
//
//        let viewStateLeft = CGSize(width: -screenSize.width / 2 + dragCircleRadius + pad,
//                                   height: -screenSize.height / 4)
//        let lCircle = DragCircle(viewState: viewStateLeft, color: .red)
//
//
//        let viewStateRight = CGSize(width: screenSize.width / 2 - dragCircleRadius - pad,
//                                    height: screenSize.height / 4)
//        let rCircle = DragCircle(viewState: viewStateRight, color: .blue)
//
//        return lCircle
//
////        return ZStack {
////            lCircle
////            rCircle
////        }
//    }
//
//}
//
//struct DragCircle: View {
//
//    enum DragState {
//        case inactive
//        case pressing
//        case dragging(translation: CGSize)
//
//        var translation: CGSize {
//            switch self {
//            case .inactive, .pressing:
//                return .zero
//            case .dragging(let translation):
//                return translation
//            }
//        }
//
//        var isActive: Bool {
//            switch self {
//            case .inactive:
//                return false
//            case .pressing, .dragging:
//                return true
//            }
//        }
//
//        var isDragging: Bool {
//            switch self {
//            case .inactive, .pressing:
//                return false
//            case .dragging:
//                return true
//            }
//        }
//    }
//
//    @GestureState var dragState = DragState.inactive
//    @State var viewState: CGSize
//
//    var color: Color
//
//    var body: some View {
//        let viewStateInitial = viewState
//
//        let minimumLongPressDuration = 0.0
//        let longPressDrag = LongPressGesture(minimumDuration: minimumLongPressDuration)
//            .sequenced(before: DragGesture())
//            .updating($dragState) { value, state, transaction in
//                switch value {
//                // Long press begins.
//                case .first(true):
//                    state = .pressing
//                // Long press confirmed, dragging may begin.
//                case .second(true, let drag):
//                    state = .dragging(translation: drag?.translation ?? .zero)
//                // Dragging ended or the long press cancelled.
//                default:
//                    state = .inactive
//                }
//        }
//        .onEnded { value in
//            guard case .second(true, let drag?) = value else {
//                return
//            }
//
//            self.viewState.width = viewStateInitial.width
//            self.viewState.height += drag.translation.height
//        }
//
//        let bloop = Bloop(draggedOffset: CGSize(width: viewState.width + dragState.translation.width + UIScreen.main.bounds.size.width / 2,
//                                                height: viewState.height + dragState.translation.height + UIScreen.main.bounds.size.height / 2 - dragCircleRadius - pad),
//
//                          color: color)
//
//        let circle = Circle()
//            .fill(self.color)
//            .overlay(Circle().stroke(Color.black, lineWidth: 1))
//            .frame(width: dragCircleRadius * 2, height: dragCircleRadius * 2, alignment: .center)
//            .offset(
//                x: viewState.width + dragState.translation.width,
//                y: viewState.height + dragState.translation.height
//        )
//            .animation(nil)
//            .gesture(longPressDrag)
//
//        let arrow = Text(">")
//        .offset(
//            x: viewState.width + dragState.translation.width,
//            y: viewState.height + dragState.translation.height
//        )
//        .animation(nil)
//
//        return ZStack {
//            bloop
//            circle
//            arrow
//        }
//    }
//}

extension Color {
    init(hex: Int, alpha: Double = 1) {
        let components = (
            R: Double((hex >> 16) & 0xff) / 255,
            G: Double((hex >> 08) & 0xff) / 255,
            B: Double((hex >> 00) & 0xff) / 255
        )
        self.init(
            .sRGB,
            red: components.R,
            green: components.G,
            blue: components.B,
            opacity: alpha
        )
    }
}

class LiquidSwipeSettings {
    static let shared = LiquidSwipeSettings()

    let colors: [Color] = [
        Color(hex: 0x0074D9),
        Color(hex: 0x7FDBFF),
        Color(hex: 0x39CCCC),
        
        Color(hex: 0x3D9970),
        Color(hex: 0x2ECC40),
        Color(hex: 0x01FF70),
        
        Color(hex: 0xFFDC00),
        Color(hex: 0xFF851B),
        Color(hex: 0xFF4136),
        Color(hex: 0xF012BE),
        
        Color(hex: 0xB10DC9),
        Color(hex: 0xAAAAAA),
        Color(hex: 0xDDDDDD)
    ].shuffled()
    
    var nextColor: Color {
        if colorIndex < colors.count - 1 {
            colorIndex += 1
        } else {
            colorIndex = 0
        }
        
        return colors[colorIndex]
    }
    
    private var colorIndex = -1
    
    var prevColor: Color {
        if colorIndex > 0 {
            colorIndex -= 1
        } else {
            colorIndex = colors.count - 1
        }
        
        return colors[colorIndex]
    }
    
}

struct ContentView: View {
    
    @State var backColor: Color = LiquidSwipeSettings.shared.nextColor
    
    @State var leftWaveZIndex: Double = 1
    @State var leftDraggingPoint: CGPoint = CGPoint(x: pad, y: 100)
    @State var leftIsDragging: Bool = false
    @State var leftColor: Color = LiquidSwipeSettings.shared.nextColor
    
    @State var rightWaveZIndex: Double = 2
    @State var rightDraggingPoint: CGPoint = CGPoint(x: pad, y: 300)
    @State var rightIsDragging: Bool = false
    @State var rightColor: Color = LiquidSwipeSettings.shared.nextColor
    
    var body: some View {
        ZStack {
            Rectangle().foregroundColor(backColor)
            leftWave().zIndex(leftWaveZIndex)
            rightWave().zIndex(rightWaveZIndex)
        }
    }

    func leftWave() -> some View {
        func path(in rect: CGRect) -> Path {
            return WaveView(draggingPoint: leftDraggingPoint,
                            isDragging: leftIsDragging,
                            alignment: .left ).path(in: rect)
        }
        
        return GeometryReader { geometry -> AnyView in
            let rect = geometry.frame(in: CoordinateSpace.local)
            return AnyView(SimilarShape(path: path(in: rect)))
        }
        .foregroundColor(leftColor)
            .gesture(DragGesture()
                .onChanged { result in
                    self.leftWaveZIndex = 2
                    self.rightWaveZIndex = 1
                    
                    self.leftIsDragging = true
                    self.leftDraggingPoint = CGPoint(x: result.translation.width, y: result.location.y)
            }
            .onEnded { result in
                withAnimation(.spring()) {
                    self.leftIsDragging = false
                    self.leftDraggingPoint = CGPoint(x: result.translation.width, y: result.location.y)
                }
                self.reload(actionWaveAlignment: .right, dx: self.leftDraggingPoint.x)
            })
    }
    
    func rightWave() -> some View {
        func path(in rect: CGRect) -> Path {
            return WaveView(draggingPoint: rightDraggingPoint,
                            isDragging: rightIsDragging,
                            alignment: .right).path(in: rect)
        }
        
        return GeometryReader { geometry -> AnyView in
            let rect = geometry.frame(in: CoordinateSpace.local)
            return AnyView(SimilarShape(path: path(in: rect)))
        }
        .foregroundColor(rightColor)
            .gesture(DragGesture()
                .onChanged { result in
                    self.leftWaveZIndex = 1
                    self.rightWaveZIndex = 2
                    
                    self.rightIsDragging = true
                    self.rightDraggingPoint = CGPoint(x: result.translation.width, y: result.location.y)
            }
            .onEnded { result in
                withAnimation(.spring()) {
                    self.rightIsDragging = false
                    self.rightDraggingPoint = CGPoint(x: result.translation.width, y: result.location.y)
                }
                self.reload(actionWaveAlignment: .right, dx: self.rightDraggingPoint.x)
            })
    }
    
    private func reload(actionWaveAlignment: WaveAlignment, dx: CGFloat) {
        let progress = WaveView.getProgress(dx: dx)
        if progress > 0.15 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.backColor = actionWaveAlignment == .left ? self.rightColor : self.leftColor
                
                self.leftColor = LiquidSwipeSettings.shared.nextColor
                self.rightColor = LiquidSwipeSettings.shared.nextColor
                
                self.leftDraggingPoint = CGPoint(x: pad, y: 100)
                self.rightDraggingPoint = CGPoint(x: pad, y: 300)
            }
        }
    }
}
