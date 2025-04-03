# Littoral Tracker

A Flutter application for tracking units and their status in wargaming scenarios.

## Features

### Scenarios
- Create, edit, and delete scenarios
- Organize scenarios by faction (USMC or PLA)
- View scenario statistics (task groups, units, markers)
- Import/export scenarios as JSON files
- Duplicate existing scenarios

### Task Groups
- Create, edit, and delete task groups within scenarios
- Organize task groups by faction
- View all units within a task group

### Units
- Create, edit, and delete units within task groups
- Track unit attributes:
  - Name
  - Type
  - Attack value
  - Defense value
  - Movement value
  - Special abilities

### Markers
- Place multiple colored markers on unit positions
- Each color can only exist once per unit
- Markers persist between sessions
- Visual representation of unit status

## Getting Started

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Dependencies

- `sqflite`: For local database storage
- `path`: For file path handling
- `path_provider`: For accessing device storage
- `intl`: For date formatting
- `share_plus`: For file sharing
- `file_picker`: For file selection

## Data Structure

The app uses SQLite for data persistence with the following tables:

- `scenarios`: Stores scenario information
- `task_groups`: Stores task group information with scenario references
- `units`: Stores unit information with task group references
- `unit_markers`: Stores marker positions and colors with unit references

## Import/Export

Scenarios can be exported as JSON files and imported back into the app. The export includes:
- Scenario details
- All task groups
- All units
- All markers

## License

This project is licensed under the MIT License - see the LICENSE file for details.
