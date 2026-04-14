import SwiftUI

struct ContentView: View {
    @ObservedObject var alarmManager: AlarmManager
    @State private var selectedColor = Color.red
    @State private var hours = 0
    @State private var minutes = 0

    var body: some View {
        VStack(spacing: 0) {
            if let activeAlarm = alarmManager.activeAlarm {
                AlarmCountdownView(alarm: activeAlarm, alarmManager: alarmManager)
            } else {
                timerSetupView
            }
        }
        .padding(20)
        .frame(width: 300, height: 380)
    }

    // MARK: - Timer Setup

    private var timerSetupView: some View {
        VStack(spacing: 20) {
            timeInputSection
            colorPickerSection
            startButton
        }
    }

    private var timeInputSection: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Duration")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
            }

            HStack(spacing: 12) {
                TimeStepperView(value: $hours, range: 0...23, label: "hr")
                TimeStepperView(value: $minutes, range: 0...59, label: "min")
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var colorPickerSection: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Flash Color")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 10) {
                ForEach(AlarmColor.allCases, id: \.self) { alarmColor in
                    ColorSwatchButton(
                        color: alarmColor.color,
                        isSelected: selectedColor == alarmColor.color
                    ) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedColor = alarmColor.color
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var startButton: some View {
        Button(action: startAlarm) {
            HStack(spacing: 8) {
                Image(systemName: "play.fill")
                    .font(.system(size: 12, weight: .semibold))
                Text("Start Timer")
                    .font(.system(size: 14, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
        .tint(selectedColor)
        .controlSize(.large)
        .disabled(hours == 0 && minutes == 0)
    }

    private func startAlarm() {
        let totalSeconds = (hours * 3600) + (minutes * 60)
        let targetDate = Date().addingTimeInterval(TimeInterval(totalSeconds))
        alarmManager.startAlarm(targetDate: targetDate, color: selectedColor)
        hours = 0
        minutes = 0
    }
}

// MARK: - Time Stepper

struct TimeStepperView: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let label: String
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 0) {
            Button {
                if value > range.lowerBound { value -= 1 }
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                    .frame(width: 32, height: 40)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            VStack(spacing: 1) {
                Text("\(value)")
                    .font(.system(size: 28, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.snappy(duration: 0.2), value: value)
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.tertiary)
                    .textCase(.uppercase)
            }

            Spacer(minLength: 0)

            Button {
                if value < range.upperBound { value += 1 }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                    .frame(width: 32, height: 40)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isHovering ? Color.primary.opacity(0.05) : Color.clear)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - Color Swatch Button

struct ColorSwatchButton: View {
    let color: Color
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isHovering = false

    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.gradient)
                    .frame(width: 40, height: 40)
                    .shadow(color: isSelected ? color.opacity(0.5) : .clear, radius: 6, y: 2)
                    .scaleEffect(isHovering ? 1.1 : 1.0)
                    .scaleEffect(isSelected ? 1.05 : 1.0)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 1, y: 1)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
        .accessibilityLabel("Select \(color.description) color")
    }
}

// MARK: - Countdown View

struct AlarmCountdownView: View {
    let alarm: AlarmItem
    @ObservedObject var alarmManager: AlarmManager
    @State private var isHovering = false

    private var buttonLabel: String {
        alarm.isTriggered ? "Stop" : "Cancel"
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                Text(alarm.isTriggered ? "Time's Up" : "Timer Running")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(1)

                Text(alarm.remainingTime)
                    .font(.system(size: 52, weight: .ultraLight, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(alarm.isTriggered ? alarm.color : .primary)
                    .contentTransition(.numericText())
                    .animation(.linear(duration: 0.3), value: alarm.remainingTime)
            }
            .padding(.top, 8)

            Button {
                alarmManager.stopAlarm()
            } label: {
                RoundedRectangle(cornerRadius: 14)
                    .fill(alarm.color.opacity(isHovering ? 1.0 : 0.15).gradient)
                    .overlay(
                        Text(buttonLabel)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(isHovering ? .white : alarm.color)
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                withAnimation(.easeOut(duration: 0.2)) {
                    isHovering = hovering
                }
            }
        }
    }
}

// MARK: - Color Definitions

enum AlarmColor: CaseIterable {
    case red, orange, yellow, green, blue, purple, pink, cyan, mint, indigo

    var color: Color {
        switch self {
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .blue: return .blue
        case .purple: return .purple
        case .pink: return .pink
        case .cyan: return .cyan
        case .mint: return .mint
        case .indigo: return .indigo
        }
    }
}

#Preview {
    ContentView(alarmManager: AlarmManager())
}
