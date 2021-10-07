import MultitouchSupport
import Foundation

public final class MultitouchManager {
    public static let shared = MultitouchManager()
    
    private init() { }
    
    public typealias Listener = ([MTTouch]) -> Void
    
    internal var listeners: [Listener] = []
    
    public func addListener(_ listener: @escaping Listener) {
        listeners.append(listener)
    }
    
    public func start() {
        devices
            .forEach { device in
                device.register(contactFrameCallback: frameCallback)
                device.start(runMode: 0)
            }
    }
    
    public func stop() {
        devices
            .filter(\.isRunning)
            .forEach { device in
                device.unregister(contactFrameCallback: frameCallback)
                device.stop()
            }
    }
    
    private lazy var devices: [MTDevice] = {
        (MTDeviceCreateList() as? [MTDevice]) ?? []
            .filter(\.isMTHIDDevice) // To ignore Touch Bar display
    }()
}

private func frameCallback(
    device: MTDevice,
    touches: UnsafeMutablePointer<MTTouch>!,
    numTouches: Int32,
    timestamp: TimeInterval,
    frame: Int32
) -> Void {
    let touches = (0..<Int(numTouches)).map { touches[$0] }
    MultitouchManager.shared.listeners.forEach { $0(touches) }
}
