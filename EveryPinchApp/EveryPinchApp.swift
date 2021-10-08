//
//  EveryPinchApp.swift
//  EveryPinchApp
//
//  Created by Mikhail Apurin on 2021/10/07.
//

import SwiftUI
import PinchCore
import MultitouchSupport

@main
struct PinchApp: App {
    @StateObject var container: Container = .init()
    
    @Environment(\.openURL) var openURL
    
    var body: some Scene {
        WindowGroup("Trackpad") {
            TrackpadView()
                .frame(minWidth: 100, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
                .environmentObject(container.contentModel)
        }.commands {
            CommandGroup(before: .windowArrangement) {
                Button("Log") { openURL(URL(string: "EveryPinch://Log")!) }
                    .keyboardShortcut("l", modifiers: .command)
            }
        }
        
        WindowGroup("Log") {
            LogView()
                .environmentObject(container.contentModel)
                .frame(minWidth: 100, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity, alignment: .topLeading)
        }.handlesExternalEvents(matching: ["Log"])
    }
}

struct TrackpadView: View {
    @EnvironmentObject var model: ContentModel
    
    var body: some View {
        GeometryReader { proxy in
            if model.touches.count > 1 {
                let avg = CGPoint(
                    x: CGFloat(model.touches.map(\.normalizedVector.position.x).reduce(0, +) / Float(model.touches.count)),
                    y: CGFloat(model.touches.map(\.normalizedVector.position.y).reduce(0, +) / Float(model.touches.count))
                )
                
                let distances = model.touches
                    .map { distance(p1: CGPoint(x: CGFloat($0.normalizedVector.position.x), y: CGFloat($0.normalizedVector.position.y)), p2: avg) }
                let text = "\(distances.reduce(0, +) / CGFloat(model.touches.count))"
                
                Text("Average: \(text)")
                
                Circle()
                    .fill(Color.yellow)
                    .position(CGPoint(
                        x: proxy.size.width * avg.x,
                        y: proxy.size.height * (1 - avg.y) // flip Y
                    ))
                    .frame(width: 10, height: 10)
            }
            
            ForEach(model.touches, id: \.identifier) { touch in
                Ellipse()
                    .fill(Color.red)
                    .rotationEffect(.radians(Double(-touch.angle))) // flip rotation
                    .position(CGPoint(
                        x: proxy.size.width * CGFloat(touch.normalizedVector.position.x),
                        y: proxy.size.height * CGFloat(1 - touch.normalizedVector.position.y) // flip Y
                    ))
                    .frame(
                        width: CGFloat(touch.total * touch.majorAxis),
                        height: CGFloat(touch.total * touch.minorAxis)
                    )
                
                Path { path in
                    path.move(to: CGPoint(
                        x: proxy.size.width * CGFloat(touch.normalizedVector.position.x),
                        y: proxy.size.height * CGFloat(1 - touch.normalizedVector.position.y) // flip Y
                    ))
                    path.addLine(to: CGPoint(
                        x: proxy.size.width * CGFloat(touch.normalizedVector.position.x + touch.normalizedVector.velocity.x / 3),
                        y: proxy.size.height * CGFloat(1 - touch.normalizedVector.position.y - touch.normalizedVector.velocity.y / 3) // flip Y
                    ))
                    
                }
                .stroke(lineWidth: 1.0)
                .fill(Color.blue)
            }
        }
        .compositingGroup()
    }
    
    /// Calculate [Euclidean distance](https://en.wikipedia.org/wiki/Euclidean_distance) between two points
    func distance(p1: CGPoint, p2: CGPoint) -> CGFloat {
        sqrt(
            (p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y)
        )
    }
}

struct LogView: View {
    @EnvironmentObject var model: ContentModel
    
    var body: some View {
        Text(text)
            .font(.system(.body, design: .monospaced))
            .padding()
    }
    
    var text: String {
        "[\n"
            .appending(model.touches.map(\.logEntry).joined(separator: "\n"))
            .appending("\n]")
    }
}


final class Container: ObservableObject {
    let contentModel: ContentModel = .init()
}


final class ContentModel: ObservableObject {
    private let manager: MultitouchManager = .shared
    
    @Published var touches: [MTTouch] = []
    
    init() {
        manager.addListener { [weak self] touches in
            DispatchQueue.main.async {
                self?.touches = touches
            }
        }
        manager.start()
    }
    
    deinit {
        // TODO: Remove listener
        manager.stop()
    }
}

private extension MTPathStage {
    var name: String {
        switch self {
        case .notTracking: return "notTracking"
        case .startInRange: return "startInRange"
        case .hoverInRange: return "hoverInRange"
        case .makeTouch: return "makeTouch"
        case .touching: return "touching"
        case .breakTouch: return "breakTouch"
        case .lingerInRange: return "lingerInRange"
        case .outOfRange: return "outOfRange"
        @unknown default: return "unknown"
        }
    }
}

private extension MTTouch {
    var logEntry: String {
        """
        \(frame).\(identifier) (H\(handID), F\(fingerID)) \(stage.name)
        \tNPos (\(normalizedVector.position.x, formatter: .custom.doublePrecision), \(normalizedVector.position.y, formatter: .custom.doublePrecision)) NVel (\(normalizedVector.velocity.x, formatter: .custom.velocity), \(normalizedVector.velocity.y, formatter: .custom.velocity))
        \tAPos (\(absoluteVector.position.x, formatter: .custom.doublePrecision), \(absoluteVector.position.y, formatter: .custom.doublePrecision)) AVel (\(absoluteVector.velocity.x, formatter: .custom.velocity), \(absoluteVector.velocity.y, formatter: .custom.velocity))
        \tTotal \(total, formatter: .custom.doublePrecision) Pressure \(pressure, formatter: .custom.doublePrecision) Density \(density, formatter: .custom.doublePrecision)
        \tAngle \(angle, formatter: .custom.doublePrecision) MajorAxis: \(majorAxis, formatter: .custom.doublePrecision) MinorAxis: \(minorAxis, formatter: .custom.doublePrecision) U14: \(unknown14), U15: \(unknown15)
        """
    }
}

extension NumberFormatter {
    enum custom {
        static let doublePrecision: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            return formatter
        }()
        
        static let velocity: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            formatter.positivePrefix = "+"
            return formatter
        }()
        
        static let axis: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            formatter.minimumIntegerDigits = 2
            return formatter
        }()
    }
}

extension DefaultStringInterpolation {
    mutating func appendInterpolation(_ number: Float, formatter: NumberFormatter) {
        appendLiteral(formatter.string(for: number) ?? "nil")
    }
}
