import Gravatar
import UIKit

/// ![](largeProfileSummaryView.view)
/// A  profile view with large avatar image and sumarized information..
public class LargeProfileSummaryView: BaseProfileView {
    private enum Constants {
        static let avatarLength: CGFloat = 132.0
        static let displayNamePlaceholderHeight: CGFloat = 32
    }

    public static var personalInfoLines: [PersonalInfoLine] {
        [
            .init([.namePronunciation, .pronouns, .location]),
        ]
    }

    override public class var avatarLength: CGFloat {
        Constants.avatarLength
    }

    override public func arrangeSubviews() {
        [avatarView, displayNameLabel, personalInfoLabel, profileButton].forEach(rootStackView.addArrangedSubview)
        setRootStackViewSpacing()
        rootStackView.alignment = .center
    }

    private func setRootStackViewSpacing() {
        rootStackView.setCustomSpacing(.DS.Padding.double, after: avatarView)
        rootStackView.setCustomSpacing(0, after: displayNameLabel)
        rootStackView.setCustomSpacing(0, after: personalInfoLabel)
        rootStackView.setCustomSpacing(0, after: profileButton)
    }

    public func update(with model: ProfileSummaryModel?) {
        self.model = model
        guard let model else { return }
        displayNameLabel.textAlignment = .center
        personalInfoLabel.textAlignment = .center
        Configure(displayNameLabel).asDisplayName().content(model).palette(paletteType)
        Configure(personalInfoLabel).asPersonalInfo().content(model, lines: Self.personalInfoLines).palette(paletteType)
        Configure(profileButton).asProfileButton().style(profileButtonStyle).palette(paletteType)
    }

    override public func update(with config: ProfileViewConfiguration) {
        super.update(with: config)
        update(with: config.summaryModel)
    }

    override public func showPlaceholders() {
        super.showPlaceholders()
        rootStackView.setCustomSpacing(.DS.Padding.split, after: displayNameLabel)
        rootStackView.setCustomSpacing(.DS.Padding.single, after: personalInfoLabel)
    }

    override public func hidePlaceholders() {
        super.hidePlaceholders()
        setRootStackViewSpacing()
    }

    override public var displayNamePlaceholderHeight: CGFloat {
        Constants.displayNamePlaceholderHeight
    }
}
