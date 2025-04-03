# Littoral Tracker

A Flutter application for tracking units and their status in wargaming scenarios.

## Features

### Scenarios
- Create, edit, and delete scenarios
- Organize scenarios by faction (USMC or PLA)
- View scenario statistics (task groups, units, markers)
- Import/export scenarios as JSON files
- Duplicate existing scenarios
- Reset database to default state

### Task Groups
- Create, edit, and delete task groups within scenarios
- Organize task groups by faction
- View all units within a task group
- Each task group maintains its own unique set of units

### Units
- Each unit has a unique identifier within its task group
- Units with the same name in different task groups are treated as separate entities
- Track unit attributes:
  - Name
  - Type (Infantry, Armor, Artillery, Air, Naval, Logistics)
  - Attack value
  - Defense value
  - Movement value
  - Special abilities

### Markers
- Place multiple colored markers on unit positions
- Each color can only exist once per unit
- Markers persist between sessions
- Visual representation of unit status
- Each unit maintains its own independent marker state
- Backup and restore marker configurations
- Reset markers to default state

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
- All units with their unique identifiers
- All markers with their unit associations

## License

This project is licensed under the MIT License - see the LICENSE file for details.
