import SwiftUI

struct SettingsView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Logo Header
                VStack(spacing: BrandSpacing.medium) {
                    BrandLogo(height: 50)
                        .padding(.top, BrandSpacing.large)
                    
                    Text("Professional Fitness Tracking")
                        .font(BrandTypography.subheadline)
                        .foregroundColor(.brandSecondaryText)
                        .padding(.bottom, BrandSpacing.medium)
                }
                .frame(maxWidth: .infinity)
                .background(Color.brandBackground)
                
                Form {
                    Section {
                        HStack {
                            Label("Version", systemImage: "info.circle")
                                .foregroundColor(.brandText)
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.brandSecondaryText)
                        }
                        
                        HStack {
                            Label("Build", systemImage: "hammer")
                                .foregroundColor(.brandText)
                            Spacer()
                            Text("2025.1")
                                .foregroundColor(.brandSecondaryText)
                        }
                    } header: {
                        Text("Application")
                            .font(BrandTypography.caption1)
                            .foregroundColor(.brandSageGreen)
                    }
                    .listRowBackground(Color.brandCard)
                    
                    Section {
                        Toggle(isOn: $themeManager.isDarkMode) {
                            HStack {
                                Image(systemName: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                                    .foregroundColor(.brandSageGreen)
                                Text("Dark Mode")
                                    .foregroundColor(.brandText)
                            }
                        }
                        .tint(.brandSageGreen)
                    } header: {
                        Text("Appearance")
                            .font(BrandTypography.caption1)
                            .foregroundColor(.brandSageGreen)
                    }
                    .listRowBackground(Color.brandCard)
                    
                    Section {
                        Button(action: {}) {
                            HStack {
                                Label("Export Data", systemImage: "square.and.arrow.up")
                                    .foregroundColor(.brandSageGreen)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.brandSecondaryText)
                            }
                        }
                        
                        Button(action: {}) {
                            HStack {
                                Label("Clear Test Data", systemImage: "trash")
                                    .foregroundColor(.brandError)
                                Spacer()
                            }
                        }
                    } header: {
                        Text("Data Management")
                            .font(BrandTypography.caption1)
                            .foregroundColor(.brandSageGreen)
                    }
                    .listRowBackground(Color.brandCard)
                    
                    Section {
                        VStack(alignment: .leading, spacing: BrandSpacing.xSmall) {
                            Text("Together Fitness")
                                .font(BrandTypography.headline)
                                .foregroundColor(.brandText)
                            Text("Personal Training Management System")
                                .font(BrandTypography.caption1)
                                .foregroundColor(.brandSecondaryText)
                            
                            HStack {
                                BrandBadge(text: "Pro", color: .brandSageGreen)
                                BrandBadge(text: "v1.0", color: .brandCoral)
                            }
                            .padding(.top, BrandSpacing.xxSmall)
                        }
                        .padding(.vertical, BrandSpacing.xSmall)
                    } header: {
                        Text("About")
                            .font(BrandTypography.caption1)
                            .foregroundColor(.brandSageGreen)
                    }
                    .listRowBackground(Color.brandCard)
                }
                .scrollContentBackground(.hidden)
                .background(Color.brandBackground)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .brandNavigationBar()
        }
    }
}

#Preview {
    SettingsView()
}