import AuthenticationServices
import GoogleSignIn
import Foundation
import UIKit

class MyTBASignInViewController: UIViewController {

    private let signInWithGoogleCallback: () -> ()
    private let signInWithAppleCallback: () -> ()

    @IBOutlet var rootStackView: UIStackView!
    @IBOutlet var starImageView: UIImageView! {
        didSet {
            starImageView.tintColor = UIColor.myTBAStarColor
        }
    }
    @IBOutlet var favoriteImageView: UIImageView!
    @IBOutlet var subscriptionImageView: UIImageView!
    @IBOutlet var providersStackView: UIStackView!

    var signInWithGoogleButton = GIDSignInButton()
    var signInWithAppleButton = ASAuthorizationAppleIDButton(type: .signIn, style: .whiteOutline)

    init(signInWithGoogleCallback: @escaping () -> (), signInWithAppleCallback: @escaping () -> ()) {
        self.signInWithGoogleCallback = signInWithGoogleCallback
        self.signInWithAppleCallback = signInWithAppleCallback

        super.init(nibName: String(describing: type(of: self)), bundle: Bundle.main)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        styleInterface()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)

        // Show/hide our images for compact size classes
        let shouldHideImages = newCollection.verticalSizeClass == .compact
        let newImageAlpha: CGFloat = shouldHideImages ? 0.0 : 1.0
        let images = [starImageView, favoriteImageView, subscriptionImageView].filter({ $0.isHidden != shouldHideImages })
        coordinator.animate(alongsideTransition: { (_) in
            images.forEach {
                $0.alpha = newImageAlpha
                $0.isHidden = shouldHideImages
            }
        })
    }

    // MARK: - Interface Methods

    private func styleInterface() {
        view.backgroundColor = UIColor.systemGroupedBackground

        signInWithGoogleButton.colorScheme = .light
        signInWithGoogleButton.style = .wide
        // signInWithGoogleButton.setTitleColor(UIColor.googleSignInTextColor, for: .normal)
        providersStackView.addArrangedSubview(signInWithGoogleButton)

        providersStackView.addArrangedSubview(signInWithAppleButton)
        signInWithAppleButton.autoMatch(.width, to: .width, of: signInWithGoogleButton)
        signInWithAppleButton.autoMatch(.height, to: .height, of: signInWithGoogleButton)
    }

    // MARK: - IBActions

    private func signInWithGoogle() {
        signInWithGoogleCallback()
    }

    private func signInWithApple() {
        signInWithAppleCallback()
    }

}
