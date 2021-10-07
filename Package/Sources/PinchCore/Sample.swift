import MultitouchSupport

public func testMultitouch() {
    let list = MTDeviceCreateList() as! [MTDevice]
    
    print(list.count)   
}
