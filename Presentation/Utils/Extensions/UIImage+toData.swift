import UIKit

extension UIImage {
    func toData() -> Data? {
        return self.jpegData(compressionQuality: 0.8)
    }
    
    func toDistinguishableData() -> Data? {
        return self.pngData()
    }
}
