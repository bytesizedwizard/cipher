import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let privacyOverlayTag = 0xC1F3

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(
      self,
      selector: #selector(maskPrivacy),
      name: UIApplication.willResignActiveNotification,
      object: nil
    )
    notificationCenter.addObserver(
      self,
      selector: #selector(unmaskPrivacy),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  @objc private func maskPrivacy() {
    for window in applicationWindows() {
      guard window.viewWithTag(privacyOverlayTag) == nil else {
        continue
      }

      let overlay = UIView(frame: window.bounds)
      overlay.tag = privacyOverlayTag
      overlay.backgroundColor = .systemBackground
      overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      window.addSubview(overlay)
    }
  }

  @objc private func unmaskPrivacy() {
    for window in applicationWindows() {
      window.viewWithTag(privacyOverlayTag)?.removeFromSuperview()
    }
  }

  private func applicationWindows() -> [UIWindow] {
    var windows: [UIWindow] = []
    for scene in UIApplication.shared.connectedScenes {
      guard let windowScene = scene as? UIWindowScene else {
        continue
      }
      windows.append(contentsOf: windowScene.windows)
    }
    return windows
  }
}
