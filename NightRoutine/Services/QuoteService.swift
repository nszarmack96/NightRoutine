import Foundation

enum QuoteService {
    // MARK: - Completion Quotes by Theme

    static func randomQuote(for theme: QuoteTheme) -> (quote: String, author: String) {
        let quotes = quotes(for: theme)
        return quotes.randomElement() ?? quotes[0]
    }

    static func quotes(for theme: QuoteTheme) -> [(quote: String, author: String)] {
        switch theme {
        case .calm:
            return calmQuotes
        case .romantic:
            return romanticQuotes
        case .stoic:
            return stoicQuotes
        case .minimal:
            return minimalQuotes
        case .encouraging:
            return encouragingQuotes
        }
    }

    // MARK: - Skip Without Guilt Quotes

    static func skipQuote() -> (quote: String, author: String) {
        let quotes: [(String, String)] = [
            ("Rest when you're weary. Refresh and renew yourself.", "Unknown"),
            ("Sometimes the most productive thing you can do is relax.", "Mark Black"),
            ("It's okay to not be okay.", "Unknown"),
            ("Tomorrow is a new day with no mistakes in it yet.", "L.M. Montgomery"),
            ("Be gentle with yourself. You're doing the best you can.", "Unknown")
        ]
        return quotes.randomElement() ?? quotes[0]
    }

    // MARK: - Tomorrow Preview Messages

    static func tomorrowMessage() -> String {
        let messages = [
            "You've already set yourself up for tomorrow.",
            "Tomorrow will thank you for tonight.",
            "A peaceful night leads to a brighter day.",
            "You're investing in tomorrow's energy.",
            "Rest well. Tomorrow awaits with possibility."
        ]
        return messages.randomElement() ?? messages[0]
    }

    // MARK: - Quote Collections

    private static let calmQuotes: [(String, String)] = [
        ("Rest is not idleness.", "John Lubbock"),
        ("Sleep is the best meditation.", "Dalai Lama"),
        ("Let go of the day. Tomorrow will take care of itself.", "Unknown"),
        ("In the silence of night, we find our deepest peace.", "Unknown"),
        ("Breathe. Let go. And remind yourself that this moment is the only one you know you have for sure.", "Oprah Winfrey"),
        ("The night is the hardest time to be alive and 4am knows all my secrets.", "Poppy Z. Brite"),
        ("Peace is always beautiful.", "Walt Whitman")
    ]

    private static let romanticQuotes: [(String, String)] = [
        ("Good night, good night! Parting is such sweet sorrow.", "Shakespeare"),
        ("I love the silent hour of night, for blissful dreams may then arise.", "Anne Brontë"),
        ("The moon will guide you through the night with her brightness.", "Shannon L. Alder"),
        ("Night is a world lit by itself.", "Antonio Porchia"),
        ("In dreams, we enter a world that's entirely our own.", "Albus Dumbledore"),
        ("The stars are the land-marks of the universe.", "John Frederick Herschel"),
        ("Touch the stars, my love.", "Unknown")
    ]

    private static let stoicQuotes: [(String, String)] = [
        ("True happiness is to enjoy the present, without anxious dependence upon the future.", "Seneca"),
        ("The happiness of your life depends upon the quality of your thoughts.", "Marcus Aurelius"),
        ("It is not that we have a short time to live, but that we waste a lot of it.", "Seneca"),
        ("We suffer more in imagination than in reality.", "Seneca"),
        ("Begin at once to live, and count each separate day as a separate life.", "Seneca"),
        ("The best revenge is not to be like your enemy.", "Marcus Aurelius"),
        ("Waste no more time arguing about what a good person should be. Be one.", "Marcus Aurelius")
    ]

    private static let minimalQuotes: [(String, String)] = [
        ("Less is more.", "Ludwig Mies van der Rohe"),
        ("Simplify.", "Henry David Thoreau"),
        ("Rest.", "Unknown"),
        ("Be still.", "Unknown"),
        ("Enough.", "Unknown"),
        ("This moment.", "Unknown"),
        ("Peace.", "Unknown")
    ]

    private static let encouragingQuotes: [(String, String)] = [
        ("You did great today.", "Unknown"),
        ("Every day is a fresh start.", "Unknown"),
        ("You are stronger than you know.", "Unknown"),
        ("Progress, not perfection.", "Unknown"),
        ("You showed up for yourself today. That matters.", "Unknown"),
        ("Small steps lead to big changes.", "Unknown"),
        ("Believe you can and you're halfway there.", "Theodore Roosevelt"),
        ("You are enough, just as you are.", "Unknown")
    ]
}
