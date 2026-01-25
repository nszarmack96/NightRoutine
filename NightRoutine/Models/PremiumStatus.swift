import Foundation

struct PremiumStatus: Codable {
    var isPremium: Bool
    var purchaseDate: Date?

    init(isPremium: Bool = false, purchaseDate: Date? = nil) {
        self.isPremium = isPremium
        self.purchaseDate = purchaseDate
    }

    static let free = PremiumStatus()
}
