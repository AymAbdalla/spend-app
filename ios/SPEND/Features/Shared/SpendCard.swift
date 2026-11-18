import SwiftUI

/// The shared visual rules as numbers and colors. `docs/DESIGN.md` explains
/// each one; change a value here and every screen follows.
enum SpendDesign {
    /// Space between the screen edge and the content.
    static let pageMargin: CGFloat = 20
    /// Space between sections (cards) on a screen.
    static let sectionGap: CGFloat = 24
    /// Space between a card's edge and its content.
    static let cardPadding: CGFloat = 20
    /// Corner radius of a card.
    static let cardRadius: CGFloat = 20
    /// Space between rows inside a card, on each side of a divider.
    static let rowGap: CGFloat = 16
    /// The page behind the cards; stays distinct from the cards in both appearances.
    static let pageBackground = Color(uiColor: .systemGroupedBackground)
    /// The card surface.
    static let cardSurface = Color(uiColor: .secondarySystemGroupedBackground)
}

/// One card: full width, leading-aligned content, the card padding, the card
/// surface and radius. Every Dashboard section uses it, so they all match.
struct SpendCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(SpendDesign.cardPadding)
            .background(SpendDesign.cardSurface, in: RoundedRectangle(cornerRadius: SpendDesign.cardRadius))
    }
}

extension View {
    /// Puts the view on a card. See `SpendCard`.
    func spendCard() -> some View { modifier(SpendCard()) }
}
