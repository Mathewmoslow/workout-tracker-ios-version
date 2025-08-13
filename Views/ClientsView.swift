import SwiftUI
import SwiftData

struct ClientsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Client.firstName) private var clients: [Client]
    @State private var showingNewClient = false
    @State private var searchText = ""
    @State private var selectedClient: Client?
    @State private var refreshID = UUID()
    
    var filteredClients: [Client] {
        if searchText.isEmpty {
            return clients
        }
        return clients.filter { client in
            client.fullName.localizedCaseInsensitiveContains(searchText) ||
            client.email.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with Logo
                HStack {
                    BrandLogo(height: 30)
                    Spacer()
                    Text("\(clients.count) clients")
                        .font(BrandTypography.caption1)
                        .foregroundColor(.brandSecondaryText)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.brandCard)
                .onAppear {
                    print("ClientsView appeared - Found \(clients.count) clients")
                    for client in clients {
                        print("  - \(client.fullName)")
                    }
                }
                
                if clients.isEmpty {
                    EmptyClientsView(onAddClient: { showingNewClient = true })
                } else {
                    List {
                        ForEach(filteredClients) { client in
                            ClientRowView(client: client)
                                .listRowBackground(Color.brandCard)
                                .listRowSeparatorTint(.brandDivider)
                                .onTapGesture {
                                    selectedClient = client
                                }
                        }
                        .onDelete(perform: deleteClients)
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.brandBackground)
                    .searchable(text: $searchText, prompt: "Search clients")
                }
            }
            .navigationTitle("Clients")
            .navigationBarTitleDisplayMode(.inline)
            .brandNavigationBar()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewClient = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.brandSageGreen)
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingNewClient) {
                NewClientView()
            }
            .onChange(of: showingNewClient) { oldValue, newValue in
                if oldValue == true && newValue == false {
                    // Sheet was dismissed, refresh the view
                    refreshID = UUID()
                    print("Refreshing view after client creation - Found \(clients.count) clients")
                }
            }
            .id(refreshID)
            .sheet(item: $selectedClient) { client in
                NavigationStack {
                    ClientDetailView(client: client)
                }
            }
        }
    }
    
    func deleteClients(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredClients[index])
        }
        try? modelContext.save()
    }
}

struct ClientRowView: View {
    let client: Client
    
    var body: some View {
        HStack {
            // Profile Circle
            Circle()
                .fill(LinearGradient(
                    colors: [.brandSageGreen, .brandDarkGreen],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(client.firstName.prefix(1) + client.lastName.prefix(1))
                        .font(BrandTypography.headline)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(client.fullName)
                    .font(BrandTypography.headline)
                    .foregroundColor(.brandText)
                
                HStack {
                    Label("\(client.sessions.count) sessions", systemImage: "calendar")
                    
                    if let fitScore = client.fitScore {
                        Label("Score: \(Int(fitScore.overallScore))", systemImage: "chart.line.uptrend.xyaxis")
                    }
                }
                .font(BrandTypography.caption1)
                .foregroundColor(.brandSecondaryText)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Circle()
                    .fill(client.isActive ? Color.brandSageGreen : Color.brandSecondaryText)
                    .frame(width: 8, height: 8)
                
                Text(client.subscriptionType.rawValue)
                    .font(BrandTypography.caption2)
                    .foregroundColor(.brandSecondaryText)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EmptyClientsView: View {
    let onAddClient: () -> Void
    
    var body: some View {
        VStack(spacing: BrandSpacing.large) {
            Image(systemName: "person.3")
                .font(.system(size: 60))
                .foregroundColor(.brandLightGreen)
            
            Text("No Clients Yet")
                .font(BrandTypography.title2)
            
            Text("Add your first client to start tracking their fitness journey")
                .font(BrandTypography.subheadline)
                .foregroundColor(.brandSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: onAddClient) {
                Label("Add Client", systemImage: "plus.circle.fill")
            }
            .buttonStyle(BrandPrimaryButtonStyle())
            .padding(.horizontal, BrandSpacing.xLarge)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// NewClientView moved to separate file