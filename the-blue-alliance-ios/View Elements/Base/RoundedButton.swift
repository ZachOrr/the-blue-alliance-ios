import Foundation
import UIKit

class RoundedButton: UIButton {

    init(title: String, titleColor: UIColor, backgroundColor: UIColor) {
        super.init(frame: .zero)

        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)

        titleLabel?.font = titleLabel!.font.bold()
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

        self.backgroundColor = backgroundColor
        layer.cornerRadius = 22.0
        clipsToBounds = true
        autoSetDimension(.height, toSize: 44.0) // TODO: Needs to support dynamic text
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
