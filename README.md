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
- Export scenarios directly to Downloads folder for easy access

### Task Group Management
- Create multiple task groups within a scenario
- Edit task group details
- Delete task groups
- Organize units within task groups
- View comprehensive task group summary in table format
- Quick navigation to specific units from summary view

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
- Responsive layout that adapts to both portrait and landscape orientations

### Unit Tracking Features
- Interactive 4x5 grid for precise unit positioning
- Six distinct color markers for different tracking purposes
- Color markers show their grid position number in the summary view
- Ability to move markers to different positions
- Clear visual feedback for marker placement

### Task Group Summary View
- Access comprehensive overview by tapping task group name
- Table view showing all units in the task group
- Displays unit details including:
  - Unit Name
  - Description
  - Attached JCC Cards
  - Current position of each color marker (0 if not placed)
- Click any row to navigate directly to that unit for editing
- Full-screen view for better readability
- Horizontally scrollable for all information

### Data Management
- Export scenarios to JSON files (saves directly to Downloads folder)
- Import scenarios from JSON files
- Share scenario data with other users
- Database reset functionality
- Automatic data persistence

### User Interface
- Custom splash screen featuring Littoral Commander artwork
- Intuitive grid-based unit tracking system
- Color-coded faction identification
- Easy-to-use marker placement system
- Responsive design that adapts to device orientation
- Clear navigation between units and task groups

### Platform Support
- Android devices
- iOS devices (iPhone and iPad)
- Optimized for both portrait and landscape orientations

## Getting Started

1. Launch the app
2. Create a new scenario by tapping the '+' button
3. Select your faction (USMC or PLAN)
4. Add task groups to your scenario
5. Add units to your task groups
6. Use the grid system to track unit positions with colored markers
7. Access the task group summary by tapping the task group name
8. Navigate to specific units by clicking their row in the summary view

## Data Backup

To backup your scenarios:
1. Use the export function (download icon) on any scenario
2. The JSON file will be saved to your device's Downloads folder
3. Import the file later using the import function

## Requirements

- Android device or iOS device
- Storage permission for importing/exporting scenarios
- Access to Downloads folder for scenario export

## Version
1.0.0

---
Developed using Flutter
