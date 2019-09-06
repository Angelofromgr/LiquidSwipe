//
//  ContentView.swift
//  LiquidSwipeSwiftUI
//
//  Created by Mark Goldin on 08/08/2019.
//  Copyright © 2019 Exyte. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State var backColor: Color = LiquidSwipeSettings.shared.nextColor
    
    @State var topWave = WaveAlignment.right
  
    @State var leftDraggingPoint: CGPoint = CGPoint(x: 0.01, y: 100)
    @State var leftDraggingPointAdjusted: CGPoint = CGPoint(x: circleRadius + 4, y: 100)
    @State var leftDraggingOpacity: Double = 1
    @State var leftColor: Color = LiquidSwipeSettings.shared.nextColor
    
    @State var rightDraggingPoint: CGPoint = CGPoint(x: 0.01, y: 300)
    @State var rightDraggingPointAdjusted: CGPoint = CGPoint(x: sizeW - circleRadius - 4, y: 300)
    @State var rightDraggingOpacity: Double = 1
    @State var rightColor: Color = LiquidSwipeSettings.shared.nextColor
    
    var body: some View {
        ZStack {
            Rectangle().foregroundColor(backColor)
            
            leftWave().zIndex(topWave == WaveAlignment.left ? 3 : 1)
            leftDragAreaIcon().zIndex(topWave == WaveAlignment.left ? 4 : 2)
            
            rightWave().zIndex(topWave == WaveAlignment.left ? 1 : 3)
            rightDragAreaIcon().zIndex(topWave == WaveAlignment.left ? 2 : 4)
        }
    }
    
    func leftWave() -> some View {
        let wave = WaveView(draggingPoint: leftDraggingPoint, alignment: WaveAlignment.left)

        let dragGesture = DragGesture()
            .onChanged { result in
                self.topWave = WaveAlignment.left

                self.leftDraggingPoint = self.calculatePoint(location: result.location, translation: result.translation, alignment: .left, isDragging: true)

                let data = WaveView.adjustedDragPoint(point: CGPoint(x: result.translation.width, y: result.location.y), alignment: .left)

                self.leftDraggingPointAdjusted = data.0
                self.leftDraggingOpacity = data.1
        }
        .onEnded { result in
            withAnimation(Animation.spring()) {
                self.leftDraggingPoint = self.calculatePoint(location: result.location, translation: result.translation, alignment: .left, isDragging: false)

                self.leftDraggingOpacity = 0
            }
            self.reload(actionWaveAlignment: .left, dx: result.translation.width)
        }

        let tapGesture = TapGesture().onEnded { result in
            withAnimation(Animation.spring()) {
                self.leftDraggingPoint = CGPoint(x: 1, y: 0)
                self.leftDraggingOpacity = 0
            }
            self.reload(actionWaveAlignment: .left, dx: 1000)
        }
        
        return wave
            .foregroundColor(leftColor)
            .gesture(dragGesture.simultaneously(with: tapGesture))
    }
    
    func rightWave() -> some View {
        let wave = WaveView(draggingPoint: rightDraggingPoint, alignment: WaveAlignment.right)

        let dragGesture = DragGesture()
            .onChanged { result in
                self.topWave = WaveAlignment.right

                self.rightDraggingPoint = self.calculatePoint(location: result.location, translation: result.translation, alignment: .right, isDragging: true)

                let data = WaveView.adjustedDragPoint(point: CGPoint(x: result.translation.width, y: result.location.y), alignment: .right)

                self.rightDraggingPointAdjusted = data.0
                self.rightDraggingOpacity = data.1
        }
        .onEnded { result in
            withAnimation(.spring()) {
                self.rightDraggingPoint = self.calculatePoint(location: result.location, translation: result.translation, alignment: .right, isDragging: false)

                self.rightDraggingOpacity = 0
            }
            self.reload(actionWaveAlignment: .right, dx: -result.translation.width)
        }

        let tapGesture = TapGesture().onEnded { result in
            withAnimation(Animation.spring()) {
                self.rightDraggingPoint = CGPoint(x: 1, y: 0)
                self.rightDraggingOpacity = 0
            }
            self.reload(actionWaveAlignment: .right, dx: 1000)
        }

        return wave
            .foregroundColor(rightColor)
            .gesture(dragGesture.simultaneously(with: tapGesture))
    }
    
    func rightDragAreaIcon() -> some View {
        return DragAreaIcon(draggingPoint: rightDraggingPointAdjusted, alignment: WaveAlignment.right)
            .opacity(rightDraggingOpacity)
    }
    
    func leftDragAreaIcon() -> some View {
        return DragAreaIcon(draggingPoint: leftDraggingPointAdjusted, alignment: WaveAlignment.left)
            .opacity(leftDraggingOpacity)
    }
    
    private func reload(actionWaveAlignment: WaveAlignment, dx: CGFloat) {
        let progress = WaveView.getProgress(dx: dx)

        if progress > 0.15 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let waveColor = actionWaveAlignment == .left ? self.leftColor : self.rightColor

                self.backColor = waveColor

                self.leftColor = LiquidSwipeSettings.shared.nextColor
                self.rightColor = LiquidSwipeSettings.shared.nextColor

                self.leftDraggingPoint = self.calculatePoint(location: CGPoint(x: 0, y: 100), translation: CGSize(width: pad, height: 0), alignment: .left, isDragging: false)
     
                self.rightDraggingPoint = self.calculatePoint(location: CGPoint(x: 0, y: 300), translation: CGSize(width: pad, height: 0), alignment: .left, isDragging: false)
               
                self.leftDraggingPointAdjusted = CGPoint(x: circleRadius + 4, y: 100)
                self.rightDraggingPointAdjusted = CGPoint(x: sizeW - circleRadius - 4, y: 300)

                withAnimation(.spring()) {
                    self.leftDraggingOpacity = 1.0
                    self.rightDraggingOpacity = 1.0
                }
            }
        } else {
            withAnimation(.spring()) {
                self.leftDraggingOpacity = 1.0
                self.leftDraggingPointAdjusted = CGPoint(x: circleRadius + 4, y: leftDraggingPoint.y)

                self.rightDraggingOpacity = 1.0
                self.rightDraggingPointAdjusted = CGPoint(x: sizeW - circleRadius - 4, y: rightDraggingPoint.y)
            }
        }
    }
    
    func calculatePoint(location: CGPoint, translation: CGSize, alignment: WaveAlignment, isDragging: Bool) -> CGPoint {
        let dx = alignment == .left ? translation.width : -translation.width
        var progress = WaveView.getProgress(dx: dx)
        
        if !isDragging {
            let success = progress > 0.15
            progress = WaveView.self.adjust(from: progress, to: success ? 1 : 0, p: 1.0)
        }
        
        return CGPoint(x: progress, y: location.y)
    }
}





