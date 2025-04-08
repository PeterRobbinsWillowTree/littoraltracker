# Littoral Tracker

A Flutter application for tracking units and their status in wargaming scenarios. The app allows you to manage scenarios, task groups, units, and their status markers.

## Features

### Scenarios
- Create, edit, and delete scenarios
- Duplicate existing scenarios
- Import/export scenarios as JSON files
- View scenario statistics (task groups, units, markers)
- Assign factions (USMC or PLAN) to scenarios

### Task Groups
- Create, edit, and delete task groups within scenarios
- Assign factions to task groups
- Organize units into task groups
- View task group details and unit status

### Units
- Add, edit, and delete units within task groups
- Customize unit properties:
  - Name
  - Type (Infantry, Armor, Artillery, Air, Naval, Logistics)
  - Attack value
  - Defense value
  - Movement value
  - Special abilities
- Track unit status using a 4x5 grid system
- Place and move colored markers on the grid:
  - Black
  - Red
  - Purple
  - Green
  - Blue
- Backup and restore unit marker configurations

### Markers
- Place multiple colored markers on each grid position
- Move markers by clicking on different positions
- Remove markers by clicking their current position
- Visual feedback for selected marker color
- Automatic saving of marker positions

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

- `sqflite`: SQLite database for local storage
- `path_provider`: Access to device file system
- `share_plus`: Share functionality for scenario export
- `file_picker`: File selection for scenario import
- `intl`: Date formatting utilities

## Data Structure

### Scenarios
| Field | Type | Description |
|-------|------|-------------|
| id | TEXT | Unique identifier |
| name | TEXT | Scenario name |
| description | TEXT | Optional description |
| created_at | INTEGER | Creation timestamp |
| faction | TEXT | USMC or PLAN |

### Task Groups
| Field | Type | Description |
|-------|------|-------------|
| id | TEXT | Unique identifier |
| scenario_id | TEXT | Parent scenario ID |
| name | TEXT | Task group name |
| description | TEXT | Optional description |
| created_at | INTEGER | Creation timestamp |
| faction | TEXT | USMC or PLAN |

### Units
| Field | Type | Description |
|-------|------|-------------|
| id | TEXT | Unique identifier |
| task_group_id | TEXT | Parent task group ID |
| name | TEXT | Unit name |
| type | TEXT | Unit type (infantry, armor, etc.) |
| attack | INTEGER | Attack value |
| defense | INTEGER | Defense value |
| movement | INTEGER | Movement value |
| special | TEXT | Special abilities |

### Markers
| Field | Type | Description |
|-------|------|-------------|
| unit_id | TEXT | Parent unit ID |
| position | INTEGER | Grid position (1-20) |
| color | TEXT | Marker color |

## Import/Export

Scenarios can be exported and imported as JSON files. The export includes:
- Scenario details
- Task groups
- Units
- Marker configurations

## License

This project is licensed under the MIT License.
