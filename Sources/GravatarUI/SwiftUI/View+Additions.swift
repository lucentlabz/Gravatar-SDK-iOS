import SwiftUI

@MainActor
extension View {
    public func shape(_ shape: some Shape, borderColor: Color = .clear, borderWidth: CGFloat = 0) -> some View {
        self
            .clipShape(shape)
            .overlay(
                shape
                    .stroke(borderColor, lineWidth: borderWidth)
            )
    }

    @available(iOS, deprecated: 16.0, message: "Use the new method that takes in `AvatarPickerContentLayout` for `contentLayout`.")
    public func avatarPickerSheet(
        isPresented: Binding<Bool>,
        email: String,
        authToken: String,
        customImageEditor: ImageEditorBlock<some ImageEditorView>? = nil as NoCustomEditorBlock?
    ) -> some View {
        let avatarPickerView = AvatarPickerView(
            model: AvatarPickerViewModel(email: Email(email), authToken: authToken),
            isPresented: isPresented,
            contentLayoutProvider: AvatarPickerContentLayoutType.vertical,
            customImageEditor: customImageEditor
        )
        let navigationWrapped = NavigationView { avatarPickerView }
        return modifier(ModalPresentationModifier(isPresented: isPresented, modalView: navigationWrapped))
    }

    @available(iOS 16.0, *)
    public func avatarPickerSheet(
        isPresented: Binding<Bool>,
        email: String,
        authToken: String,
        contentLayout: AvatarPickerContentLayout,
        customImageEditor: ImageEditorBlock<some ImageEditorView>? = nil as NoCustomEditorBlock?
    ) -> some View {
        let avatarPickerView = AvatarPickerView(
            model: AvatarPickerViewModel(email: Email(email), authToken: authToken),
            isPresented: isPresented,
            contentLayoutProvider: contentLayout,
            customImageEditor: customImageEditor
        )
        let navigationWrapped = NavigationView { avatarPickerView }
        return modifier(AvatarPickerModalPresentationModifier(isPresented: isPresented, modalView: navigationWrapped, contentLayout: contentLayout))
    }

    func avatarPickerBorder(colorScheme: ColorScheme, borderWidth: CGFloat = 1) -> some View {
        self
            .shape(
                RoundedRectangle(cornerRadius: 8),
                borderColor: Color(UIColor.label).opacity(colorScheme == .dark ? 0.16 : 0.08),
                borderWidth: borderWidth
            )
            .padding(.vertical, borderWidth) // to prevent borders from getting clipped
    }

    @available(iOS, deprecated: 16.0, message: "Use the new method that takes in `QuickEditorScope`.")
    public func gravatarQuickEditorSheet(
        isPresented: Binding<Bool>,
        email: String,
        scope: QuickEditorScopeType,
        customImageEditor: ImageEditorBlock<some ImageEditorView>? = nil as NoCustomEditorBlock?,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        let editor = QuickEditor(
            email: .init(email),
            scope: scope,
            isPresented: isPresented,
            customImageEditor: customImageEditor,
            contentLayoutProvider: AvatarPickerContentLayoutType.vertical
        )
        return modifier(ModalPresentationModifier(isPresented: isPresented, onDismiss: onDismiss, modalView: editor))
    }

    @available(iOS 16.0, *)
    public func gravatarQuickEditorSheet(
        isPresented: Binding<Bool>,
        email: String,
        scope: QuickEditorScope,
        customImageEditor: ImageEditorBlock<some ImageEditorView>? = nil as NoCustomEditorBlock?,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        switch scope {
        case .avatarPicker(let config):
            let editor = QuickEditor(
                email: .init(email),
                scope: scope.scopeType,
                isPresented: isPresented,
                customImageEditor: customImageEditor,
                contentLayoutProvider: config.contentLayout
            )
            return modifier(AvatarPickerModalPresentationModifier(
                isPresented: isPresented,
                onDismiss: onDismiss,
                modalView: editor,
                contentLayout: config.contentLayout
            ))
        }
    }

    func presentationContentInteraction(shouldPrioritizeScrolling: Bool) -> some View {
        if #available(iOS 16.4, *) {
            let behavior: PresentationContentInteraction = shouldPrioritizeScrolling ? .scrolls : .automatic
            return self
                .presentationContentInteraction(behavior)
        } else {
            return self
        }
    }

    /// Caution: `InnerHeightPreferenceKey` accumulates the values so DO NOT use this on  a View and one of its ancestors at the same time.
    @ViewBuilder
    func accumulateIntrinsicHeight() -> some View {
        self.background {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: InnerHeightPreferenceKey.self,
                    value: proxy.size.height
                )
            }
        }
    }
}
