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
            errorMessage = "Product not available"
            showingError = true
            return
        }

        isPurchasing = true

        do {
            let success = try await storeKitService.purchase(product)
            if success {
                purchaseSuccessful = true
            }
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }

        isPurchasing = false
    }

    func restore() async {
        isPurchasing = true
        await storeKitService.restorePurchases()

        if storeKitService.isPremium {
            purchaseSuccessful = true
        } else {
            errorMessage = "No previous purchase found"
            showingError = true
        }

        isPurchasing = false
    }

    func loadProducts() async {
        await storeKitService.loadProducts()
    }
}
