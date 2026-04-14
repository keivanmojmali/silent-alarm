# Silent Alarm

A minimalist macOS menubar app for setting visual-only alarms. Perfect for when you need a silent timer that won't disturb others around you.

## Features

- **Visual Only**: No sound - just visual alerts
- **Menubar Integration**: Lives quietly in your Mac's menubar
- **Dual Timer Modes**: 
  - Duration-based (up to 24 hours)
  - Specific time scheduling
- **Multiple Alarms**: Add as many timers as you need
- **Color-Coded**: Choose from 10 preset colors for each alarm
- **Smooth Animations**: Gentle flashing with slow transitions

## How to Use

1. Click the timer icon in your menubar
2. Choose between "Duration" or "Specific Time" mode
3. Set your desired time
4. Pick a color for the alarm
5. Click "Add Alarm"
6. When time's up, the dropdown will open and flash your chosen color
7. Click the flashing "STOP" button to dismiss

## Building from Source

1. Open `SilentAlarm.xcodeproj` in Xcode
2. Build and run (⌘+R)
3. The app will appear in your menubar

## Requirements

- macOS 13.0 or later
- Xcode 15.0 or later (for building)

## Contributing

This project is designed to be simple and focused. When contributing:

- **Adding Colors**: Modify the `AlarmColor` enum in `ContentView.swift`
- **Changing Flash Speed**: Adjust the animation duration in `AlarmRowView`
- **Timer Display Format**: Update `updateRemainingTime()` in `AlarmManager.swift`
- **Custom Icon**: Replace the SF Symbol in `SilentAlarmApp.swift`

## License

MIT License - feel free to use and modify as needed.