import SwiftUI

struct LaunchScreen: View {
    @State private var isAnimating = false
    @State private var showApp = false
    
    var body: some View {
        if showApp {
            ContentView()
        } else {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.brandSageGreen, Color.brandDarkGreen],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: BrandSpacing.large) {
                    Spacer()
                    
                    // Logo
                    BrandLogo(height: 80)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .opacity(isAnimating ? 1.0 : 0.3)
                    
                    // Loading indicator
                    HStack(spacing: BrandSpacing.xSmall) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(Color.brandCoral)
                                .frame(width: 10, height: 10)
                                .scaleEffect(isAnimating ? 1.0 : 0.5)
                                .opacity(isAnimating ? 1.0 : 0.3)
                                .animation(
                                    Animation.easeInOut(duration: 0.6)
                                        .repeatForever()
                                        .delay(Double(index) * 0.2),
                                    value: isAnimating
                                )
                        }
                    }
                    .padding(.top, BrandSpacing.large)
                    
                    Spacer()
                    
                    // Tagline
                    VStack(spacing: BrandSpacing.xSmall) {
                        Text("Comprehensive Client Tracking")
                            .font(BrandTypography.headline)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("An ickle app for Aaron and his Clients")
                            .font(BrandTypography.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.bottom, BrandSpacing.xxLarge)
                }
                .padding()
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                    isAnimating = true
                }
                
                // Transition to main app after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showApp = true
                    }
                }
            }
        }
    }
}

#Preview {
    LaunchScreen()
}
