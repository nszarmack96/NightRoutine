import Foundation
import StoreKit

@MainActor
final class PaywallViewModel: ObservableObject {
    @Published var isPurchasing = false
    @Published var showingError = false
    @Published var errorMessage = ""
    @Published var purchaseSuccessful = false

    private let storeKitService: StoreKitService

    var product: Product? {
        storeKitService.lifetimeProduct
    }

    var isLoading: Bool {
        storeKitService.isLoading
    }

    var priceString: String {
        product?.displayPrice ?? "$4.99"
    }

    var isPremium: Bool {
        storeKitService.isPremium
    }

    init(storeKitService: StoreKitService = .shared) {
        self.storeKitService = storeKitService
    }

    func purchase() async {
        guard let product = product else {
            errorMessage = "Unable to load product. Please check your internet connection and try again."
            showingError = true
            return
        }

        isPurchasing = true

        do {
            let success = try await storeKitService.purchase(product)
            if success {
                HapticService.purchaseSuccess()
                purchaseSuccessful = true
            }
        } catch StoreKitError.failedVerification {
            errorMessage = "Purchase verification failed. Please try again or contact support."
            showingError = true
        } catch {
            errorMessage = "Purchase could not be completed. Please try again."
            showingError = true
        }

        isPurchasing = false
    }

    func restore() async {
        isPurchasing = true
        await storeKitService.restorePurchases()

        if storeKitService.isPremium {
            HapticService.purchaseSuccess()
            purchaseSuccessful = true
        } else {
            errorMessage = "No previous purchase found. If you believe this is an error, please contact support."
            showingError = true
        }

        isPurchasing = false
    }

    func loadProducts() async {
        await storeKitService.loadProducts()
    }

    func signInAndLoad() async {
        await storeKitService.signInAndLoadProducts()
    }
}
