import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Client.firstName) private var clients: [Client]
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    
    @State private var selectedDate = Date()
    @State private var selectedClient: Client?
    @State private var showingNewSession = false
    @State private var selectedSession: Session?
    @State private var viewMode: ViewMode = .week
    
    enum ViewMode: String, CaseIterable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
    }
    
    var filteredSessions: [Session] {
        let calendar = Calendar.current
        
        return sessions.filter { session in
            let matchesClient = selectedClient == nil || session.client?.id == selectedClient?.id
            
            let matchesDate: Bool
            switch viewMode {
            case .day:
                matchesDate = calendar.isDate(session.date, inSameDayAs: selectedDate)
            case .week:
                matchesDate = calendar.isDate(session.date, equalTo: selectedDate, toGranularity: .weekOfYear)
            case .month:
                matchesDate = calendar.isDate(session.date, equalTo: selectedDate, toGranularity: .month)
            }
            
            return matchesClient && matchesDate
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Calendar Header
                CalendarHeader(
                    selectedDate: $selectedDate,
                    viewMode: $viewMode
                )
                
                // Client Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(
                            title: "All Clients",
                            isSelected: selectedClient == nil,
                            action: { selectedClient = nil }
                        )
                        
                        ForEach(clients) { client in
                            FilterChip(
                                title: client.firstName,
                                isSelected: selectedClient?.id == client.id,
                                action: { selectedClient = client }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color.brandBackground)
                
                // Calendar View
                switch viewMode {
                case .day:
                    DayView(date: selectedDate, sessions: filteredSessions)
                case .week:
                    WeekView(selectedDate: $selectedDate, sessions: filteredSessions)
                case .month:
                    MonthView(selectedDate: $selectedDate, sessions: sessions, selectedClient: selectedClient)
                }
                
                Spacer()
            }
            .navigationTitle("Training Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .brandNavigationBar()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewSession = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.brandSageGreen)
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingNewSession) {
                NewSessionView(client: selectedClient, preselectedDate: selectedDate)
            }
            .sheet(item: $selectedSession) { session in
                SessionDetailView(session: session)
            }
        }
    }
}

struct CalendarHeader: View {
    @Binding var selectedDate: Date
    @Binding var viewMode: CalendarView.ViewMode
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        switch viewMode {
        case .day:
            formatter.dateFormat = "EEEE, MMMM d"
        case .week:
            formatter.dateFormat = "MMMM d"
        case .month:
            formatter.dateFormat = "MMMM yyyy"
        }
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // View Mode Picker
            Picker("View Mode", selection: $viewMode) {
                ForEach(CalendarView.ViewMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // Date Navigation
            HStack {
                Button(action: previousPeriod) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(dateFormatter.string(from: selectedDate))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if viewMode == .week {
                        Text(weekRangeText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: nextPeriod) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Button(action: { selectedDate = Date() }) {
                    Text("Today")
                        .font(BrandTypography.caption1)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.brandCoral)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color.brandBackground)
    }
    
    var weekRangeText: String {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? selectedDate
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
    }
    
    func previousPeriod() {
        withAnimation {
            switch viewMode {
            case .day:
                selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
            case .week:
                selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
            case .month:
                selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
            }
        }
    }
    
    func nextPeriod() {
        withAnimation {
            switch viewMode {
            case .day:
                selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
            case .week:
                selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
            case .month:
                selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
            }
        }
    }
}

struct DayView: View {
    let date: Date
    let sessions: [Session]
    
    let hours = Array(6...22) // 6 AM to 10 PM
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(hours, id: \.self) { hour in
                    HStack(alignment: .top) {
                        // Time label
                        Text(formatHour(hour))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 50, alignment: .trailing)
                            .padding(.trailing, 8)
                        
                        // Time slot
                        VStack(alignment: .leading, spacing: 4) {
                            Divider()
                            
                            // Sessions in this hour
                            ForEach(sessionsInHour(hour)) { session in
                                DaySessionCard(session: session)
                                    .padding(.vertical, 2)
                            }
                            
                            if sessionsInHour(hour).isEmpty {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 40)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top)
        }
    }
    
    func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        
        guard let date = Calendar.current.date(from: components) else { return "" }
        return formatter.string(from: date)
    }
    
    func sessionsInHour(_ hour: Int) -> [Session] {
        sessions.filter { session in
            guard let startTime = session.startTime else { return false }
            let sessionHour = Calendar.current.component(.hour, from: startTime)
            return sessionHour == hour
        }
    }
}

struct DaySessionCard: View {
    let session: Session
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(Color.brandSageGreen)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(session.workout.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    if let startTime = session.startTime {
                        Text(startTime, style: .time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("No time set")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let client = session.client {
                    Text(client.fullName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label("\(session.totalSets) sets", systemImage: "number")
                    Label("\(Int(session.duration / 60)) min", systemImage: "clock")
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
        }
        .brandOutlineCard(padding: 0)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
    }
}

struct WeekView: View {
    @Binding var selectedDate: Date
    let sessions: [Session]
    
    var weekDays: [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Week header
                HStack(spacing: 0) {
                    ForEach(weekDays, id: \.self) { day in
                        WeekDayHeader(date: day, isSelected: Calendar.current.isDate(day, inSameDayAs: selectedDate))
                            .onTapGesture {
                                selectedDate = day
                            }
                    }
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.vertical)
                
                // Sessions by day
                ForEach(weekDays, id: \.self) { day in
                    let daySessions = sessionsForDay(day)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        // Day label
                        HStack {
                            Text(day.formatted(.dateTime.weekday(.wide)))
                                .font(.headline)
                            
                            Text(day.formatted(.dateTime.day()))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            if !daySessions.isEmpty {
                                Text("\(daySessions.count) session\(daySessions.count > 1 ? "s" : "")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal)
                        
                        if daySessions.isEmpty {
                            Text("No sessions scheduled")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(daySessions) { session in
                                        WeekSessionCard(session: session)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    
                    Divider()
                }
            }
        }
    }
    
    func sessionsForDay(_ day: Date) -> [Session] {
        sessions.filter { session in
            Calendar.current.isDate(session.date, inSameDayAs: day)
        }
    }
}

struct WeekDayHeader: View {
    let date: Date
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(date.formatted(.dateTime.weekday(.abbreviated)))
                .font(BrandTypography.caption1)
                .foregroundColor(.brandSecondaryText)
            
            Text(date.formatted(.dateTime.day()))
                .font(BrandTypography.headline)
                .fontWeight(isSelected ? .bold : .medium)
                .foregroundColor(isSelected ? .white : .brandText)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(isSelected ? Color.brandSageGreen : Color.clear)
                )
        }
        .frame(maxWidth: .infinity)
    }
}

struct WeekSessionCard: View {
    let session: Session
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(Color.brandCoral)
                    .frame(width: 8, height: 8)
                
                if let startTime = session.startTime {
                    Text(startTime, style: .time)
                        .font(.caption)
                        .fontWeight(.medium)
                } else {
                    Text("No time")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(session.workout.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)
            
            if let client = session.client {
                Text(client.fullName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 8) {
                Label("\(Int(session.duration / 60))m", systemImage: "clock")
                Label("\(session.totalSets)", systemImage: "number")
            }
            .font(.caption2)
            .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 150)
        .brandCard()
    }
}

struct MonthView: View {
    @Binding var selectedDate: Date
    let sessions: [Session]
    let selectedClient: Client?
    
    let calendar = Calendar.current
    
    var monthDays: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: monthInterval.start) - 1
        let numberOfDays = calendar.dateComponents([.day], from: monthInterval.start, to: monthInterval.end).day! + 1
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        
        for day in 0..<numberOfDays {
            if let date = calendar.date(byAdding: .day, value: day, to: monthInterval.start) {
                days.append(date)
            }
        }
        
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
                ForEach(Array(monthDays.enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        MonthDayCell(
                            date: date,
                            sessions: sessionsForDay(date),
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date)
                        )
                        .onTapGesture {
                            selectedDate = date
                        }
                    } else {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 60)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    func sessionsForDay(_ day: Date) -> [Session] {
        sessions.filter { session in
            let matchesDate = calendar.isDate(session.date, inSameDayAs: day)
            let matchesClient = selectedClient == nil || session.client?.id == selectedClient?.id
            return matchesDate && matchesClient
        }
    }
}

struct MonthDayCell: View {
    let date: Date
    let sessions: [Session]
    let isSelected: Bool
    let isToday: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.subheadline)
                .fontWeight(isToday ? .bold : .medium)
                .foregroundColor(isSelected ? .white : (isToday ? .blue : .primary))
            
            if !sessions.isEmpty {
                HStack(spacing: 2) {
                    ForEach(0..<min(sessions.count, 3), id: \.self) { _ in
                        Circle()
                            .fill(Color.brandCoral)
                            .frame(width: 4, height: 4)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 60)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.brandSageGreen : (isToday ? Color.brandSageGreen.opacity(0.1) : Color.clear))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isToday && !isSelected ? Color.brandSageGreen : Color.clear, lineWidth: 2)
        )
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(BrandTypography.caption1)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.brandSageGreen : Color.brandBackground)
                .foregroundColor(isSelected ? .white : .brandText)
                .cornerRadius(16)
        }
    }
}