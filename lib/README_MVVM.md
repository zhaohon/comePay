# MVVM Architecture Implementation

This Flutter project follows the Model-View-ViewModel (MVVM) architectural pattern for better separation of concerns and maintainability.

## Folder Structure

```
lib/
├── core/                    # Base classes and common functionality
│   ├── base_model.dart      # Base class for models with ChangeNotifier
│   ├── base_viewmodel.dart  # Base class for viewmodels
│   └── base_service.dart     # Base class for services
├── models/                  # Data models and business logic
│   └── counter_model.dart   # Example: Counter data model
├── viewmodels/              # ViewModels for UI state management
│   └── counter_viewmodel.dart # Example: Counter viewmodel
├── views/                   # UI components and screens
│   └── counter_view.dart    # Example: Counter screen
├── services/                # API calls, local storage, etc.
│   └── counter_service.dart # Example: Counter service
├── utils/                   # Helper functions, constants, navigation
│   ├── constants.dart       # App constants
│   └── navigation.dart      # Navigation utilities
└── main.dart               # App entry point
```

## Key Components

### 1. Models
- Contain business logic and data structures
- Should be independent of UI concerns
- Example: `CounterModel` handles counter operations

### 2. ViewModels
- Manage UI state and business logic
- Extend `BaseViewModel` for common functionality
- Use Provider pattern for state management
- Example: `CounterViewModel` manages counter state

### 3. Views
- Pure UI components
- Use Provider/Consumer to listen to ViewModel changes
- Should not contain business logic
- Example: `CounterView` displays counter UI

### 4. Services
- Handle external operations (API calls, storage, etc.)
- Extend `BaseService` for common functionality
- Injected into ViewModels as needed
- Example: `CounterService` for data persistence

## Usage Example

### Creating a New Feature

1. **Create Model** (lib/models/feature_model.dart)
```dart
class FeatureModel {
  // Business logic here
}
```

2. **Create ViewModel** (lib/viewmodels/feature_viewmodel.dart)
```dart
class FeatureViewModel extends BaseViewModel {
  final FeatureModel _model = FeatureModel();

  // UI state and logic here
}
```

3. **Create View** (lib/views/feature_view.dart)
```dart
class FeatureView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FeatureViewModel(),
      child: Consumer<FeatureViewModel>(
        builder: (context, viewModel, child) {
          // UI implementation
        },
      ),
    );
  }
}
```

4. **Add Route** (lib/utils/navigation.dart)
```dart
case '/feature':
  return MaterialPageRoute(builder: (_) => const FeatureView());
```

## Benefits

- **Separation of Concerns**: Clear separation between UI, business logic, and data
- **Testability**: Each layer can be tested independently
- **Maintainability**: Changes in one layer don't affect others
- **Reusability**: Models and services can be reused across different views
- **Scalability**: Easy to add new features following the same pattern

## Dependencies

Make sure to add Provider to your `pubspec.yaml`:

```yaml
dependencies:
  provider: ^6.0.5
```

## Running the Project

```bash
flutter pub get
flutter run
