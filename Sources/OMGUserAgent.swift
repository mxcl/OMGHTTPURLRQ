import Foundation
#if os(iOS)
import UIKit
#endif

public let OMGUserAgent: String = {
    let info = NSBundle.mainBundle().infoDictionary
    let name = info?["CFBundleDisplayName"] as? String ?? info?[kCFBundleIdentifierKey as String] as? String ?? "App"
    let vers = info?[kCFBundleVersionKey as String] as? String ?? "1.0"
    #if os(iOS)
        let scale = UIScreen.mainScreen().scale
        return String(format: "%@/%@ (%@; iOS %@; Scale/%0.2f)", name, vers, UIDevice.currentDevice().model, UIDevice.currentDevice().systemVersion, scale)
    #else
        return "\(name)/\(vers)"
    #endif
}()
