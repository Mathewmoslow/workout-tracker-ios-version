import SwiftUI
import SwiftData

struct NewClientView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Basic Info
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var dateOfBirth = Date()
    @State private var gender: Client.Gender = .male
    
    // Physical Metrics
    @State private var height: Double = 170
    @State private var currentWeight: Double = 70
    @State private var targetWeight: Double = 70
    
    // Goals & Subscription
    @State private var primaryGoal: Client.FitnessGoal = .generalFitness
    @State private var subscriptionType: Client.SubscriptionType = .monthly
    
    // Health Assessment
    @State private var injuries: [Injury] = []
    @State private var painPoints: [PainPoint] = []
    @State private var medicalConditions: Set<String> = []
    @State private var currentMedications = ""
    @State private var allergies = ""
    
    // Lifestyle Assessment
    @State private var activityLevel: Client.ActivityLevel = .moderatelyActive
    @State private var stressLevel: Int = 5
    @State private var averageSleepHours: Double = 7.0
    @State private var nutritionQuality: Client.NutritionQuality = .good
    @State private var smokingStatus: Client.SmokingStatus = .never
    @State private var alcoholConsumption: Client.AlcoholConsumption = .occasional
    
    // Emergency Contact
    @State private var emergencyContactName = ""
    @State private var emergencyContactRelationship = ""
    @State private var emergencyContactPhone = ""
    
    // UI State
    @State private var currentTab = 0
    @State private var showingInjurySheet = false
    @State private var showingPainPointSheet = false
    
    // Predefined options
    let injuryTypes = ["Shoulder", "Back", "Knee", "Hip", "Ankle", "Wrist", "Elbow", "Neck", "Other"]
    let medicalConditionOptions = [
        "High Blood Pressure", "Diabetes", "Heart Disease", "Arthritis",
        "Asthma", "Previous Surgery", "Chronic Pain", "Thyroid Issues", "Other"
    ]
    
    var isValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Selector
                TabSelector(currentTab: $currentTab)
                
                // Tab Content
                TabView(selection: $currentTab) {
                    basicInfoTab.tag(0)
                    physicalMetricsTab.tag(1)
                    healthAssessmentTab.tag(2)
                    lifestyleTab.tag(3)
                    emergencyTab.tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("New Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if currentTab < 4 {
                        Button("Next") {
                            withAnimation {
                                currentTab += 1
                            }
                        }
                    } else {
                        Button("Save") {
                            saveClient()
                        }
                        .fontWeight(.bold)
                        .disabled(!isValid)
                    }
                }
            }
            .sheet(isPresented: $showingInjurySheet) {
                AddInjurySheet(injuries: $injuries)
            }
            .sheet(isPresented: $showingPainPointSheet) {
                AddPainPointSheet(painPoints: $painPoints)
            }
        }
    }
    
    // MARK: - Tab Views
    
    var basicInfoTab: some View {
        Form {
            Section("Personal Information") {
                TextField("First Name", text: $firstName)
                TextField("Last Name", text: $lastName)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                TextField("Phone", text: $phone)
                    .keyboardType(.phonePad)
                
                DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                
                Picker("Gender", selection: $gender) {
                    ForEach(Client.Gender.allCases, id: \.self) { gender in
                        Text(gender.rawValue).tag(gender)
                    }
                }
            }
            
            Section("Goals & Subscription") {
                Picker("Primary Goal", selection: $primaryGoal) {
                    ForEach(Client.FitnessGoal.allCases, id: \.self) { goal in
                        Text(goal.rawValue).tag(goal)
                    }
                }
                
                Picker("Subscription Type", selection: $subscriptionType) {
                    ForEach(Client.SubscriptionType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
            }
        }
    }
    
    var physicalMetricsTab: some View {
        Form {
            Section("Body Measurements") {
                HStack {
                    Text("Height")
                    Spacer()
                    TextField("Height", value: $height, format: .number)
                        .keyboardType(.decimalPad)
                        .frame(width: 80)
                        .multilineTextAlignment(.trailing)
                    Text("cm")
                }
                
                HStack {
                    Text("Current Weight")
                    Spacer()
                    TextField("Weight", value: $currentWeight, format: .number)
                        .keyboardType(.decimalPad)
                        .frame(width: 80)
                        .multilineTextAlignment(.trailing)
                    Text("kg")
                }
                
                HStack {
                    Text("Target Weight")
                    Spacer()
                    TextField("Weight", value: $targetWeight, format: .number)
                        .keyboardType(.decimalPad)
                        .frame(width: 80)
                        .multilineTextAlignment(.trailing)
                    Text("kg")
                }
            }
            
            Section("Calculated Metrics") {
                HStack {
                    Text("BMI")
                    Spacer()
                    Text(String(format: "%.1f", calculateBMI()))
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Weight Change Goal")
                    Spacer()
                    Text(String(format: "%.1f kg", abs(targetWeight - currentWeight)))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    var healthAssessmentTab: some View {
        Form {
            Section("Current Injuries") {
                Button(action: { showingInjurySheet = true }) {
                    Label("Add Injury", systemImage: "plus.circle")
                }
                
                ForEach(injuries) { injury in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(injury.type)
                                .fontWeight(.medium)
                            Spacer()
                            Text(injury.severity.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(severityColor(injury.severity))
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                        
                        if !injury.notes.isEmpty {
                            Text(injury.notes)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete { offsets in
                    injuries.remove(atOffsets: offsets)
                }
            }
            
            Section("Pain Points") {
                Button(action: { showingPainPointSheet = true }) {
                    Label("Add Pain Point", systemImage: "plus.circle")
                }
                
                ForEach(painPoints) { point in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(point.location)
                                .fontWeight(.medium)
                            Text("Level \(point.painLevel)/10 - \(point.frequency.rawValue)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
                .onDelete { offsets in
                    painPoints.remove(atOffsets: offsets)
                }
            }
            
            Section("Medical Conditions") {
                ForEach(medicalConditionOptions, id: \.self) { condition in
                    HStack {
                        Text(condition)
                        Spacer()
                        if medicalConditions.contains(condition) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if medicalConditions.contains(condition) {
                            medicalConditions.remove(condition)
                        } else {
                            medicalConditions.insert(condition)
                        }
                    }
                }
            }
            
            Section("Medications & Allergies") {
                TextField("Current Medications", text: $currentMedications, axis: .vertical)
                    .lineLimit(2...4)
                
                TextField("Allergies", text: $allergies, axis: .vertical)
                    .lineLimit(2...4)
            }
        }
    }
    
    var lifestyleTab: some View {
        Form {
            Section("Activity Level") {
                Picker("Activity Level", selection: $activityLevel) {
                    ForEach(Client.ActivityLevel.allCases, id: \.self) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section("Stress Management") {
                VStack(alignment: .leading) {
                    Text("Stress Level: \(stressLevel)")
                    Slider(value: Binding(
                        get: { Double(stressLevel) },
                        set: { stressLevel = Int($0) }
                    ), in: 1...10, step: 1)
                    
                    HStack {
                        Text("Low")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("High")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section("Sleep") {
                HStack {
                    Text("Average Sleep")
                    Spacer()
                    TextField("Hours", value: $averageSleepHours, format: .number)
                        .keyboardType(.decimalPad)
                        .frame(width: 60)
                        .multilineTextAlignment(.trailing)
                    Text("hours")
                }
            }
            
            Section("Nutrition") {
                Picker("Nutrition Quality", selection: $nutritionQuality) {
                    ForEach(Client.NutritionQuality.allCases, id: \.self) { quality in
                        Text(quality.rawValue).tag(quality)
                    }
                }
            }
            
            Section("Habits") {
                Picker("Smoking Status", selection: $smokingStatus) {
                    ForEach(Client.SmokingStatus.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                
                Picker("Alcohol Consumption", selection: $alcoholConsumption) {
                    ForEach(Client.AlcoholConsumption.allCases, id: \.self) { consumption in
                        Text(consumption.rawValue).tag(consumption)
                    }
                }
            }
        }
    }
    
    var emergencyTab: some View {
        Form {
            Section("Emergency Contact") {
                TextField("Contact Name", text: $emergencyContactName)
                TextField("Relationship", text: $emergencyContactRelationship)
                TextField("Phone Number", text: $emergencyContactPhone)
                    .keyboardType(.phonePad)
            }
            
            Section {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                    
                    Text("Ready to Save")
                        .font(.headline)
                    
                    Text("Review the information above and tap Save when ready")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    func calculateBMI() -> Double {
        guard height > 0 && currentWeight > 0 else { return 0 }
        let heightInMeters = height / 100
        return currentWeight / (heightInMeters * heightInMeters)
    }
    
    func severityColor(_ severity: Injury.InjurySeverity) -> Color {
        switch severity {
        case .mild:
            return .yellow
        case .moderate:
            return Color(.systemIndigo)
        case .severe:
            return .red
        }
    }
    
    func saveClient() {
        print("Starting client save...")
        print("First Name: \(firstName), Last Name: \(lastName), Email: \(email)")
        
        let client = Client(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            dateOfBirth: dateOfBirth,
            gender: gender,
            height: height,
            currentWeight: currentWeight,
            targetWeight: targetWeight,
            primaryGoal: primaryGoal
        )
        
        // Set additional properties
        client.subscriptionType = subscriptionType
        client.injuryHistory = injuries
        client.painPoints = painPoints
        client.medicalConditions = Array(medicalConditions)
        client.currentMedications = currentMedications
        client.allergies = allergies.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
        
        // Lifestyle
        client.activityLevel = activityLevel
        client.stressLevel = stressLevel
        client.averageSleepHours = averageSleepHours
        client.nutritionQuality = nutritionQuality
        client.smokingStatus = smokingStatus
        client.alcoholConsumption = alcoholConsumption
        
        // Emergency Contact
        if !emergencyContactName.isEmpty {
            let contact = EmergencyContact(
                name: emergencyContactName,
                relationship: emergencyContactRelationship,
                phone: emergencyContactPhone
            )
            client.emergencyContact = contact
            modelContext.insert(contact)
            print("Inserted emergency contact")
        }
        
        // Initialize FitScore with real calculations
        let fitScore = FitScore(client: client)
        
        // Calculate initial scores based on client data
        // Body fat and other measurements can be added later via the Metrics tab
        fitScore.updateFromMeasurements(client: client)
        client.fitScore = fitScore
        
        // Insert related entities FIRST
        for injury in injuries {
            modelContext.insert(injury)
        }
        print("Inserted \(injuries.count) injuries")
        
        for point in painPoints {
            modelContext.insert(point)
        }
        print("Inserted \(painPoints.count) pain points")
        
        // Insert FitScore
        modelContext.insert(fitScore)
        print("Inserted FitScore")
        
        // Insert client LAST
        modelContext.insert(client)
        print("Inserted client")
        
        do {
            try modelContext.save()
            print("✅ Client saved successfully!")
            dismiss()
        } catch {
            print("❌ Failed to save client: \(error)")
            print("Error description: \(error.localizedDescription)")
        }
    }
}

// MARK: - Supporting Views

struct TabSelector: View {
    @Binding var currentTab: Int
    let tabs = ["Basic", "Physical", "Health", "Lifestyle", "Emergency"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    withAnimation {
                        currentTab = index
                    }
                }) {
                    VStack(spacing: 8) {
                        Circle()
                            .fill(currentTab >= index ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 30, height: 30)
                            .overlay(
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(currentTab >= index ? .white : .gray)
                            )
                        
                        Text(tabs[index])
                            .font(.caption2)
                            .foregroundColor(currentTab == index ? .blue : .gray)
                    }
                }
                .frame(maxWidth: .infinity)
                
                if index < tabs.count - 1 {
                    Rectangle()
                        .fill(currentTab > index ? Color.blue : Color.gray.opacity(0.3))
                        .frame(height: 2)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct AddInjurySheet: View {
    @Binding var injuries: [Injury]
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType = "Back"
    @State private var severity: Injury.InjurySeverity = .mild
    @State private var notes = ""
    @State private var customType = ""
    @State private var useCustom = false
    
    let injuryTypes = ["Shoulder", "Back", "Knee", "Hip", "Ankle", "Wrist", "Elbow", "Neck", "Other"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Injury Type") {
                    Picker("Select Injury", selection: $selectedType) {
                        ForEach(injuryTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    
                    if selectedType == "Other" {
                        TextField("Specify injury", text: $customType)
                    }
                }
                
                Section("Severity") {
                    Picker("Severity Level", selection: $severity) {
                        ForEach(Injury.InjurySeverity.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Additional Information") {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("Add Injury")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let type = selectedType == "Other" && !customType.isEmpty ? customType : selectedType
                        let injury = Injury(type: type, severity: severity, notes: notes)
                        injuries.append(injury)
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}

struct AddPainPointSheet: View {
    @Binding var painPoints: [PainPoint]
    @Environment(\.dismiss) private var dismiss
    
    @State private var location = ""
    @State private var painLevel = 5
    @State private var frequency: PainPoint.PainFrequency = .occasional
    @State private var notes = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Location") {
                    TextField("Where do you feel pain?", text: $location)
                }
                
                Section("Pain Level") {
                    VStack {
                        Text("Level: \(painLevel)")
                            .font(.headline)
                        
                        Slider(value: Binding(
                            get: { Double(painLevel) },
                            set: { painLevel = Int($0) }
                        ), in: 1...10, step: 1)
                        
                        HStack {
                            Text("Mild")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("Severe")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Frequency") {
                    Picker("When do you feel pain?", selection: $frequency) {
                        ForEach(PainPoint.PainFrequency.allCases, id: \.self) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                }
                
                Section("Additional Information") {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Add Pain Point")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let point = PainPoint(
                            location: location,
                            painLevel: painLevel,
                            frequency: frequency,
                            notes: notes
                        )
                        painPoints.append(point)
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .disabled(location.isEmpty)
                }
            }
        }
    }
}