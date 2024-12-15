import UIKit

class PaddedTextField: UITextField {
    
    var padding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureDefaultSettings()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureDefaultSettings()
    }
    
    private func configureDefaultSettings() {
        autocorrectionType = .no
        spellCheckingType = .no
        keyboardType = .default
    }
}
