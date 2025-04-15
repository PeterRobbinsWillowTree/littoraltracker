# Littoral Commander Unit Tracker

A Flutter-based mobile application designed to help track units for the Littoral Commander wargame. This app serves as a digital companion for managing scenarios and unit positions during gameplay.

## Features

### Scenario Management
- Create new scenarios with faction selection (USMC/PLAN)
- Import/Export scenarios as JSON files
- Duplicate existing scenarios
- Edit scenario details
- Delete scenarios
- View scenario statistics

### Task Group Management
- Create multiple task groups within a scenario
- Edit task group details
- Delete task groups
- Organize units within task groups

### Unit Management
- Add units with different types:
  - Infantry
  - Armor
  - Artillery
  - Air
  - Naval
  - Logistics
- Customize unit details:
  - Name
  - Type
  - Attached JCC Cards
  - Description
- Track unit positions using a 4x5 grid system
- Use color markers (black, red, purple, green, blue, orange) to mark unit positions

### Data Management
- Export scenarios to JSON files (saves to device storage)
- Import scenarios from JSON files
- Share scenario data with other users
- Database reset functionality

## Technical Details

### Storage
- Uses SQLite database for local storage
- JSON import/export functionality for data portability
- Automatic backup system through file sharing

### User Interface
- Custom splash screen featuring Littoral Commander artwork
- Intuitive grid-based unit tracking system
- Color-coded faction identification
- Easy-to-use marker placement system

### Platform Support
- Android devices
- iOS devices (iPhone and iPad)

## Getting Started

1. Launch the app
2. Create a new scenario by tapping the '+' button
3. Select your faction (USMC or PLAN)
4. Add task groups to your scenario
5. Add units to your task groups
6. Use the grid system to track unit positions with colored markers

## Data Backup

To backup your scenarios:
1. Use the export function (download icon) on any scenario
2. Save the generated JSON file to your preferred location
3. Import the file later using the import function

## Requirements

- Android device or iOS device
- Storage permission for importing/exporting scenarios

## Version
1.0.0

---
Developed using Flutter
