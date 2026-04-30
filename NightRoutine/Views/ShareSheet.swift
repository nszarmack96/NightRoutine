import SwiftUI
import UIKit

/// Thin SwiftUI wrapper around UIActivityViewController.
/// Shares the streak card image alongside an App Store link.
struct ShareSheet: UIViewControllerRepresentable {
    let image: UIImage

    private let appStoreURL = URL(string: "https://apps.apple.com/app/id\(AppConstants.appStoreID)")!

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: [image, appStoreURL],
            applicationActivities: nil
        )
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
