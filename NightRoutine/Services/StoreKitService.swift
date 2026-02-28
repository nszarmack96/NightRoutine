import Foundation
import StoreKit

@MainActor
final class StoreKitService: ObservableObject {
    static let shared = StoreKitService()

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let productIDs: Set<String> = [
        AppConstants.ProductID.lifetimePremium.rawValue
    ]

    private var transactionListener: Task<Void, Error>?
    private let persistence: PersistenceService

    var isPremium: Bool {
        purchasedProductIDs.contains(AppConstants.ProductID.lifetimePremium.rawValue)
    }

    var lifetimeProduct: Product? {
        products.first { $0.id == AppConstants.ProductID.lifetimePremium.rawValue }
    }

    private init(persistence: PersistenceService = .shared) {
        self.persistence = persistence
        transactionListener = listenForTransactions()

        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Load Products

    func loadProducts() async {
        isLoading = true
        errorMessage = nil

        // StoreKit 2 can return an empty array on first launch while it initializes
        // its connection to the App Store. Retry up to 3 times with delays.
        var loaded: [Product] = []
        for attempt in 1...3 {
            do {
                loaded = try await Product.products(for: productIDs)
                if !loaded.isEmpty {
                    print("StoreKitService: Loaded \(loaded.count) products on attempt \(attempt)")
                    break
                }
                print("StoreKitService: Empty response on attempt \(attempt), retrying...")
            } catch {
                print("StoreKitService: Error on attempt \(attempt): \(error)")
            }

            if attempt < 3 {
                try? await Task.sleep(nanoseconds: 2_000_000_000) // wait 2s before retry
            }
        }

        products = loaded

        if products.isEmpty {
            print("StoreKitService: Failed to load products after 3 attempts")
            errorMessage = "Unable to load products. Please try again."
        }

        isLoading = false
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async throws -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updatePurchasedProducts()
                await transaction.finish()
                isLoading = false
                return true

            case .userCancelled:
                print("StoreKitService: User cancelled purchase")
                isLoading = false
                return false

            case .pending:
                print("StoreKitService: Purchase pending")
                isLoading = false
                return false

            @unknown default:
                isLoading = false
                return false
            }
        } catch {
            print("StoreKitService: Purchase failed: \(error)")
            errorMessage = "Purchase failed. Please try again."
            isLoading = false
            throw error
        }
    }

    // MARK: - Restore Purchases

    func restorePurchases() async {
        isLoading = true
        errorMessage = nil

        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            // Reload products after sign-in - fixes "Unable to load price" on first open
            if products.isEmpty {
                await loadProducts()
            }
            print("StoreKitService: Restore completed")
        } catch {
            print("StoreKitService: Restore failed: \(error)")
            errorMessage = "Unable to restore purchases. Please try again."
        }

        isLoading = false
    }

    func signInAndLoadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            try await AppStore.sync()
            await loadProducts()
        } catch {
            print("StoreKitService: Sign in failed: \(error)")
            await loadProducts()
        }

        isLoading = false
    }

    // MARK: - Update Purchased Products

    func updatePurchasedProducts() async {
        var purchased: Set<String> = []

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                if transaction.revocationDate == nil {
                    purchased.insert(transaction.productID)
                }
            } catch {
                print("StoreKitService: Failed to verify transaction: \(error)")
            }
        }

        purchasedProductIDs = purchased

        // Update persistence
        let status = PremiumStatus(
            isPremium: isPremium,
            purchaseDate: isPremium ? Date() : nil
        )
        persistence.savePremiumStatus(status)

        print("StoreKitService: Updated purchased products: \(purchased)")
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                } catch {
                    print("StoreKitService: Transaction verification failed: \(error)")
                }
            }
        }
    }

    // MARK: - Verification

    private nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Errors

enum StoreKitError: LocalizedError {
    case failedVerification
    case purchaseFailed

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Transaction verification failed"
        case .purchaseFailed:
            return "Purchase could not be completed"
        }
    }
}
