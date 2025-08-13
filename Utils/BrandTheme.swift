import SwiftUI

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    static let shared = ThemeManager()
    
    private init() {}
}

// MARK: - Brand Colors
extension Color {
    // Primary Colors from Logo
    static let brandSageGreen = Color(red: 111/255, green: 143/255, blue: 114/255)  // Muted sage green
    static let brandCoral = Color(red: 241/255, green: 143/255, blue: 127/255)      // Warm coral/salmon
    
    // Extended Palette
    static let brandDarkGreen = Color(red: 71/255, green: 103/255, blue: 74/255)    // Darker variant
    static let brandLightGreen = Color(red: 151/255, green: 183/255, blue: 154/255) // Lighter variant
    static let brandLightCoral = Color(red: 251/255, green: 183/255, blue: 167/255) // Lighter coral
    static let brandCream = Color(red: 250/255, green: 248/255, blue: 245/255)      // Off-white background
    
    // Dark Mode Colors
    static let brandDarkBackground = Color(red: 28/255, green: 28/255, blue: 30/255)
    static let brandDarkCard = Color(red: 44/255, green: 44/255, blue: 46/255)
    static let brandDarkDivider = Color(red: 58/255, green: 58/255, blue: 60/255)
    
    // Adaptive Semantic Colors
    static func brandBackground(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? brandDarkBackground : brandCream
    }
    
    static func brandCard(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? brandDarkCard : Color.white
    }
    
    static func brandText(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white : Color(red: 45/255, green: 45/255, blue: 45/255)
    }
    
    static func brandSecondaryText(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 174/255, green: 174/255, blue: 178/255) : Color(red: 110/255, green: 110/255, blue: 110/255)
    }
    
    static func brandDivider(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? brandDarkDivider : Color(red: 230/255, green: 230/255, blue: 230/255)
    }
    
    // Legacy static colors (for backwards compatibility)
    static let brandBackground = brandCream
    static let brandCard = Color.white
    static let brandText = Color(red: 45/255, green: 45/255, blue: 45/255)
    static let brandSecondaryText = Color(red: 110/255, green: 110/255, blue: 110/255)
    static let brandDivider = Color(red: 230/255, green: 230/255, blue: 230/255)
    
    // Status Colors
    static let brandSuccess = brandSageGreen
    static let brandWarning = Color(red: 245/255, green: 166/255, blue: 35/255)
    static let brandError = brandCoral
}

// MARK: - Typography
struct BrandTypography {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let callout = Font.system(size: 16, weight: .regular, design: .default)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let caption1 = Font.system(size: 12, weight: .regular, design: .default)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
}

// MARK: - Custom Button Styles
struct BrandPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BrandTypography.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isEnabled ? Color.brandSageGreen : Color.brandSecondaryText)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct BrandSecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BrandTypography.headline)
            .foregroundColor(isEnabled ? .brandSageGreen : .brandSecondaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isEnabled ? Color.brandSageGreen : Color.brandSecondaryText, lineWidth: 2)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct BrandAccentButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BrandTypography.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isEnabled ? Color.brandCoral : Color.brandSecondaryText)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct BrandCompactButtonStyle: ButtonStyle {
    var color: Color = .brandSageGreen
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BrandTypography.callout)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Card Styles
struct BrandCardModifier: ViewModifier {
    var padding: CGFloat = 16
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.brandCard(colorScheme))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 8, x: 0, y: 2)
    }
}

struct BrandOutlineCardModifier: ViewModifier {
    var padding: CGFloat = 16
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.brandCard(colorScheme))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.brandDivider(colorScheme), lineWidth: 1)
            )
    }
}

// MARK: - TextField Styles
struct BrandTextFieldModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .font(BrandTypography.body)
            .padding(12)
            .background(Color.brandBackground(colorScheme))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.brandDivider(colorScheme), lineWidth: 1)
            )
    }
}

// MARK: - Navigation Bar Styling
struct BrandNavigationBarModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .toolbarBackground(Color.brandCard(colorScheme), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(colorScheme, for: .navigationBar)
    }
}

// MARK: - Tab Bar Styling
struct BrandTabBarModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(Color.brandCard(colorScheme))
                
                // Normal state
                appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.brandSecondaryText(colorScheme))
                appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                    .foregroundColor: UIColor(Color.brandSecondaryText(colorScheme))
                ]
                
                // Selected state
                appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.brandSageGreen)
                appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                    .foregroundColor: UIColor(Color.brandSageGreen)
                ]
                
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
    }
}

// MARK: - Badge Styles
struct BrandBadge: View {
    let text: String
    var color: Color = .brandCoral
    
    var body: some View {
        Text(text)
            .font(BrandTypography.caption1)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(color)
            )
    }
}

// MARK: - Progress Indicators
struct BrandProgressBar: View {
    let progress: Double
    var height: CGFloat = 8
    var backgroundColor: Color = .brandDivider
    var progressColor: Color = .brandSageGreen
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(backgroundColor)
                    .frame(height: height)
                
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(progressColor)
                    .frame(width: geometry.size.width * min(max(progress, 0), 1), height: height)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: height)
    }
}

// MARK: - View Extensions
extension View {
    func brandCard(padding: CGFloat = 16) -> some View {
        modifier(BrandCardModifier(padding: padding))
    }
    
    func brandOutlineCard(padding: CGFloat = 16) -> some View {
        modifier(BrandOutlineCardModifier(padding: padding))
    }
    
    func brandTextField() -> some View {
        modifier(BrandTextFieldModifier())
    }
    
    func brandNavigationBar() -> some View {
        modifier(BrandNavigationBarModifier())
    }
    
    func brandTabBar() -> some View {
        modifier(BrandTabBarModifier())
    }
}

// MARK: - Logo View
struct BrandLogo: View {
    var height: CGFloat = 40
    
    var body: some View {
        Image("logo-horizontal")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: height)
    }
}

// MARK: - Spacing Constants
struct BrandSpacing {
    static let xxSmall: CGFloat = 4
    static let xSmall: CGFloat = 8
    static let small: CGFloat = 12
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let xLarge: CGFloat = 32
    static let xxLarge: CGFloat = 48
}