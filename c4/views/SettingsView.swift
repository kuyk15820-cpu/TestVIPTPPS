import SwiftUI
import UIKit

// MARK: - Main Settings View
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appLanguage) private var language
    @EnvironmentObject private var appState: AppState
    @AppStorage(AppLanguage.storageKey) private var languageCode = AppLanguage.english.rawValue

    // State ควบคุมการแสดง Alert
    @State private var showAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 14) {
                        AppLogo()

                        VStack(alignment: .leading, spacing: 3) {
                            Text("c4").font(.headline)
                            Text(language.text("common.version", appVersion))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // ปุ่มทดสอบเรียกแสดง Alert
                    Button("ทดสอบแสดง Alert") {
                        showAlert = true
                    }
                }

                Section(language.text("settings.language")) {
                    Picker(language.text("settings.language"), selection: $languageCode) {
                        ForEach(AppLanguage.allCases) { option in
                            Text(option.displayName).tag(option.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                }

                Section(language.text("common.device")) {
                    LabeledContent(language.text("dashboard.hardware_model"), value: AppInfo.displayMachineName)
                    LabeledContent(language.text("settings.ios_version"), value: "\(AppInfo.osVersion) (\(AppInfo.osBuild))")
                }

                Section {
                    HStack {
                        Text(language.text("settings.current_version"))
                        Spacer()
                        Text(language.text(appState.isSupported ? "settings.supported" : "settings.unsupported"))
                        .foregroundStyle(appState.isSupported ? Color.green : Color.red)
                    }
                    LabeledContent("iOS 17", value: ExploitSupportPolicy.verifiedIOS17Range)
                    LabeledContent("iOS 18", value: ExploitSupportPolicy.verifiedIOS18Range)
                    LabeledContent("iOS 26", value: ExploitSupportPolicy.verifiedIOS26Range)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("iOS 27.0")
                            .font(.body)
                        ForEach(ExploitSupportPolicy.verifiedIOS27Builds, id: \.build) { version in
                            Text(versionLabel(version))
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 2)
                } header: {
                    Text(language.text("settings.verified_versions"))
                } footer: {
                    Text(language.text("settings.supported_versions_footer"))
                }

                Section(language.text("settings.social_media")) {
                    creditsRow(
                        name: "GitHub",
                        role: language.text("social.github_role"),
                        url: "https://github.com/YangJiiii/3105"
                    )
                    creditsRow(
                        name: "Cộng Đồng IOSVN",
                        role: language.text("social.iosvn_role"),
                        url: "https://t.me/ioscrackvn"
                    )
                }

                Section(language.text("settings.credits")) {
                    creditsRow(
                        name: "YangJiii",
                        role: language.text("credit.yangjiii"),
                        url: "https://x.com/duongduong0908"
                    )
                    creditsRow(
                        name: "0xjohnnydev",
                        role: language.text("credit.filzaslop"),
                        url: "https://github.com/0xjohnnydev/FilzaSlop"
                    )
                    creditsRow(
                        name: "LeminLimez",
                        role: language.text("credit.pocket_poster"),
                        url: "https://github.com/leminlimez/Pocket-Poster"
                    )
                    creditsRow(
                        name: "CrazyMind90",
                        role: language.text("credit.sandbox_escape"),
                        url: "https://github.com/CrazyMind90"
                    )
                    creditsRow(
                        name: "forcequitOS",
                        role: language.text("credit.forcequit"),
                        url: "https://github.com/forcequitOS"
                    )
                }
            }
            .tint(AppTheme.accent)
            .navigationTitle(language.text("settings.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(language.text("common.done")) { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
        // เรียกใช้ Custom Alert
        .pokerAlert(
            isPresented: $showAlert,
            title: "BHTikTok, Hi",
            detail: "Are you sure?"
        )
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "AppReleaseDisplayVersion") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            ?? "1.0"
    }

    private func versionLabel(
        _ version: (beta: Int, publicBeta: Int?, build: String)
    ) -> String {
        if let publicBeta = version.publicBeta {
            return language.text(
                "settings.developer_public_beta_build",
                Int64(version.beta),
                Int64(publicBeta),
                version.build
            )
        }
        return language.text(
            "settings.developer_beta_build",
            Int64(version.beta),
            version.build
        )
    }

    @ViewBuilder
    private func creditsRow(name: String, role: String, url: String) -> some View {
        if let destination = URL(string: url) {
            Link(destination: destination) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(role)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.accent)
                        .frame(width: 28, height: 28)
                }
                .contentShape(Rectangle())
            }
            .accessibilityLabel(language.text("accessibility.open_profile", name))
        }
    }
}

// MARK: - SwiftUI View Modifier & Extension
extension View {
    func pokerAlert(
        isPresented: Binding<Bool>,
        title: String,
        detail: String? = nil,
        buttonTitle: String = "ตกลง",
        onConfirm: (() -> Void)? = nil
    ) -> some View {
        self.modifier(
            PokerAlertModifier(
                isPresented: isPresented,
                title: title,
                detail: detail,
                buttonTitle: buttonTitle,
                onConfirm: onConfirm
            )
        )
    }
}

struct PokerAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let detail: String?
    let buttonTitle: String
    var onConfirm: (() -> Void)?

    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isPresented = false
                        }
                    }

                PokerAlertRepresentable(
                    title: title,
                    detail: detail,
                    buttonTitle: buttonTitle
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isPresented = false
                    }
                    onConfirm?()
                }
                .transition(.scale(scale: 0.9).combined(with: .opacity))
                .zIndex(999)
            }
        }
    }
}

// MARK: - SwiftUI Representable Bridge
struct PokerAlertRepresentable: UIViewRepresentable {
    let title: String
    let detail: String?
    let buttonTitle: String
    var onConfirm: () -> Void

    func makeUIView(context: Context) -> PokerAlertView {
        let alertView = PokerAlertView(title: title, detail: detail)
        alertView.confirmButton.setTitle(buttonTitle, for: .normal)
        alertView.confirmButton.addTarget(context.coordinator, action: #selector(Coordinator.didTapConfirm), for: .touchUpInside)
        return alertView
    }

    func updateUIView(_ uiView: PokerAlertView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onConfirm: onConfirm)
    }

    class Coordinator: NSObject {
        var onConfirm: () -> Void
        init(onConfirm: @escaping () -> Void) {
            self.onConfirm = onConfirm
        }
        @objc func didTapConfirm() {
            onConfirm()
        }
    }
}

// MARK: - Custom UIKit Alert View
public class PokerAlertView: PokerView, PokerTitleRepresentable, PokerConfirmRepresentable {
    
    public var titleLabel: UILabel = PKLabel(fontSize: 18)
    public var detailLabel: UILabel?
    public var confirmButton: UIButton = PKButton(title: "ตกลง", fontSize: 16)
    
    private let horizontalSeparator = UIView()
    
    public convenience init(title: String, detail: String? = nil) {
        self.init()
        
        self.backgroundColor = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 0.95)
        self.layer.cornerRadius = 14
        self.clipsToBounds = true
        
        titleLabel = setupTitleLabel(for: self, with: title)
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        
        setupDetail(with: detail)
        
        widthAnchor.constraint(equalToConstant: baseWidth).isActive = true
        
        setupButtonsLayout()
    }

    private func setupDetail(with detail: String?) {
        guard let detail = detail, !detail.isEmpty else { return }
        
        let label = PKLabel(fontSize: 15)
        label.text = detail
        label.textColor = UIColor(white: 0.85, alpha: 1.0)
        label.textAlignment = .center
        label.numberOfLines = 0
        addSubview(label)
        detailLabel = label
        
        label.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
        label.constraint(withLeadingTrailing: 16)
    }
    
    private func setupButtonsLayout() {
        let separatorColor = UIColor(white: 1.0, alpha: 0.15)
        horizontalSeparator.backgroundColor = separatorColor
        horizontalSeparator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(horizontalSeparator)
        
        let topAnchorView = detailLabel ?? titleLabel
        horizontalSeparator.topAnchor.constraint(equalTo: topAnchorView.bottomAnchor, constant: 20).isActive = true
        horizontalSeparator.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        horizontalSeparator.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        horizontalSeparator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        confirmButton.setTitle("ตกลง", for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        confirmButton.layer.cornerRadius = 0
        confirmButton.backgroundColor = .clear
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            confirmButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            confirmButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            confirmButton.topAnchor.constraint(equalTo: horizontalSeparator.bottomAnchor),
            confirmButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            confirmButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}
