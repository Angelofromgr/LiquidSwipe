//
//  LiquidSwipeView.swift
//  LiquidSwipeSwiftUI
//
//  Created by Mark Goldin on 12/08/2019.
//  Copyright © 2019 Exyte. All rights reserved.
//

import SwiftUI

struct WaveView: Shape {

    internal var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(progress, y) }
        set {
            progress = newValue.first
            y = newValue.second
        }
    }

    private let side: WaveSide
    private var progress: CGFloat
    private var y: CGFloat

    init(data: WaveData) {
        self.side = data.side
        self.progress = CGFloat(data.progress)
        self.y = CGFloat(data.y)
    }

    func path(in rect: CGRect) -> Path {
        return build(cy: y, progress: progress)
    }
    
    private func build(cy: CGFloat, progress: CGFloat) -> Path {
        let side = WaveView.adjust(from: 15, to: WaveView.bounds.width, p: progress, min: 0.2, max: 0.8)
        let hr = WaveView.getHr(from: 48, to: WaveView.bounds.width * 0.8, p: progress)
        let vr = WaveView.adjust(from: 82, to: WaveView.bounds.height * 0.9, p: progress, max: 0.4)
        return build(cy: cy, hr: hr, vr: vr, side: side)
    }

    private func build(cy: CGFloat, hr: CGFloat, vr: CGFloat, side: CGFloat) -> Path {
        let isLeft = self.side == .left
        let xSide = isLeft ? side : WaveView.bounds.width - side
        let curveStartY = vr + cy
        let sign: CGFloat = isLeft ? 1.0 : -1.0

        var path = Path()
        let x = isLeft ? -50 : WaveView.bounds.width + 50
        path.move(to: CGPoint(x: xSide, y: -100))
        path.addLine(to: CGPoint(x: x, y: -100))
        path.addLine(to: CGPoint(x: x, y: WaveView.bounds.height))
        path.addLine(to: CGPoint(x: xSide, y: WaveView.bounds.height))
        path.addLine(to: CGPoint(x: xSide, y: curveStartY))

        var index = 0
        while index < WaveView.data.count {
            let x1 = xSide + sign * hr * WaveView.data[index]
            let y1 = curveStartY - vr * WaveView.data[index + 1]
            let x2 = xSide + sign * hr * WaveView.data[index + 2]
            let y2 = curveStartY - vr * WaveView.data[index + 3]
            let x = xSide + sign * hr * WaveView.data[index + 4]
            let y = curveStartY - vr * WaveView.data[index + 5]

            let point = CGPoint(x: x, y: y)
            let control1 = CGPoint(x: x1, y: y1)
            let control2 = CGPoint(x: x2, y: y2)

            path.addCurve(to: point, control1: control1, control2: control2)

            index += 6
        }

        return path
    }

    static func getProgress(dx: CGFloat) -> CGFloat {
        return min(1.0, max(0, dx * 0.45 / UIScreen.main.bounds.size.width))
    }

    static func getHr(from: CGFloat, to: CGFloat, p: CGFloat) -> CGFloat {
        let p1: CGFloat = 0.4
        if p <= p1 {
            return adjust(from: from, to: to, p: p, max: p1)
        } else if p >= 1 {
            return to
        }
        let t = (p - p1) / (1 - p1)
        let m: CGFloat = 9.8
        let beta: CGFloat = 40.0 / (2 * m)
        let omega = pow(-pow(beta, 2) + pow(50.0 / m, 2), 0.5)
        return to * exp(-beta * t) * cos(omega * t)
    }
    
    static func adjust(from: CGFloat, to: CGFloat, p: CGFloat, min: CGFloat = 0, max: CGFloat = 1) -> CGFloat {
        if p <= min {
            return from
        } else if p >= max {
            return to
        }
        return from + (to - from) * (p - min) / (max - min)
    }

    static var bounds: CGRect {
        return UIScreen.main.bounds
    }

    private static let data: [CGFloat] = [
        0, 0.13461, 0.05341, 0.24127, 0.15615, 0.33223,
        0.23616, 0.40308, 0.33052, 0.45611, 0.50124, 0.53505,
        0.51587, 0.54182, 0.56641, 0.56503, 0.57493, 0.56896,
        0.72837, 0.63973, 0.80866, 0.68334, 0.87740, 0.73990,
        0.96534, 0.81226,       1, 0.89361,       1,       1,
        1, 1.10014, 0.95957, 1.18879, 0.86084, 1.27048,
        0.78521, 1.33305, 0.70338, 1.37958, 0.52911, 1.46651,
        0.52418, 1.46896, 0.50573, 1.47816, 0.50153, 1.48026,
        0.31874, 1.57142, 0.23320, 1.62041, 0.15411, 1.68740,
        0.05099, 1.77475,       0, 1.87092,       0,       2]
}
