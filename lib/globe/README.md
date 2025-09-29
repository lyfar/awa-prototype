# AWA Globe Widget System

## Overview

The AWA mindfulness app uses a unified globe visualization system with 3 distinct states representing different stages of the user's journey, featuring smooth animated transitions between states:

## 🌟 Globe States

### 1. **Light** - Inner Light Pulse
- **Purpose**: Welcome flow step 1
- **Visual**: Extreme close-up of a single luminous point, satellites fully hidden
- **Usage**: `GlobeConfig.light()`

### 2. **Awa Soul** - Orbital Particle Field  
- **Purpose**: Welcome flow step 2 / meditation atmosphere
- **Visual**: Darkened globe silhouette wrapped in a drifting particle halo (no earth texture yet)
- **Usage**: `GlobeConfig.awaSoul()`

### 3. **Globe** - Global Community
- **Purpose**: Welcome flow step 3 + Home screen
- **Visual**: Real earth texture with clustered community lights and optional user light (satellite halo hides once the map appears)
- **Usage**: `GlobeConfig.globe(showUserLight: true/false)`

## 📁 File Structure

```
lib/globe/
├── globe_states.dart      # State definitions and config factories
├── globe_widget.dart      # Universal widget wrapper
├── globe_widget_web.dart  # Web implementation with Globe.gl
├── globe_widget_stub.dart # Non-web fallback implementation
└── README.md             # This documentation
```

## 🚀 Usage

### Basic Usage
```dart
// Light state (welcome step 1)
GlobeWidget(
  config: GlobeConfig.light(height: 300),
)

// Awa Soul state (welcome step 2, practice mode)
GlobeWidget(
  config: GlobeConfig.awaSoul(height: 300),
)

// Globe state (welcome step 3, home screen)
GlobeWidget(
  config: GlobeConfig.globe(
    height: 300,
    showUserLight: true,
    userLatitude: 37.7749,
    userLongitude: -122.4194,
  ),
)
```

### Welcome Screen Transitions
```dart
// Trigger smooth transitions during onboarding flow
GlobeWidget.transitionToAwaSoul();      // Light → Awa Soul (zoom out + particles)
GlobeWidget.transitionToGlobe();       // Awa Soul → Globe (earth texture + community)
GlobeWidget.transitionToLight();       // Awa Soul → Light (zoom in + particles fade)
GlobeWidget.transitionGlobeToAwaSoul(); // Globe → Awa Soul (earth fade + particles)
```

### Transition Configurations
```dart
// Use transition factory methods for smooth animations
GlobeWidget(
  config: GlobeConfig.lightToAwaSoul(
    height: 300,
    transitionDuration: Duration(milliseconds: 2500),
  ),
)

GlobeWidget(
  config: GlobeConfig.awaSoulToGlobe(
    height: 300,
    showUserLight: true,
    userLatitude: 37.7749,
    userLongitude: -122.4194,
    transitionDuration: Duration(milliseconds: 2000),
  ),
)
```

### Dynamic Configuration
```dart
// Home screen with practice mode switching
GlobeWidget(
  config: inPracticeMode
    ? GlobeConfig.awaSoul(disableInteraction: true)
    : GlobeConfig.globe(
        showUserLight: hasPracticedToday,
        userLatitude: userLat,
        userLongitude: userLng,
      ),
)
```

## 🎯 Key Features

- **Unified Interface**: Single `GlobeWidget` handles all 3 states
- **Platform Adaptive**: Web uses Globe.gl, other platforms show fallback UI
- **Smooth Transitions**: Animated transitions between all states with customizable timing
- **Transition States**: Dedicated transition configurations for seamless animations
- **Practice Integration**: Seamlessly switches between earth and particle modes
- **User Location**: Shows user's light after practice completion
- **Community Visualization**: Displays global community particles
- **Interaction Control**: Can disable interactions when needed (e.g., overlays)
- **Easing Functions**: Smooth cubic easing for natural-feeling animations

## 🔧 Technical Details

### Web Implementation
- Uses Globe.gl library with Three.js
- Custom SVG earth textures
- Animated particles with emissive materials
- Enhanced lighting for "fancy" appearance
- Real-time state transitions via postMessage
- Smooth camera movements and particle animations
- Cubic easing functions for natural transitions
- Transition state management with duration control

### Non-Web Implementation  
- Fallback UI with colored circles and descriptive text
- Maintains visual consistency across platforms
- Console logging for debugging state transitions
- Transition state descriptions for user feedback

## 🎨 Visual Progression

```
Step 1: Light        Transition 1         Step 2: Awa Soul       Transition 2         Step 3: Globe
    ✨              ✨ → 🌟 🌟 🌟 🌟      🌟 🌟 🌟 🌟           🌟 🌟 🌟 🌟 → 🌍      🌍 with ✨
   (dot)           (zoom out + particles)  (particle cloud)      (earth fade in)       (earth + particles)
```

### Transition Details
- **Light → Awa Soul**: Camera zooms out, orbiting particles fade in
- **Awa Soul → Globe**: Earth texture fades in, community particles appear, orbiting particles fade
- **Globe → Awa Soul**: Earth texture fades out, orbiting particles return
- **Awa Soul → Light**: Camera zooms in, particles fade out

## 🔄 State Management

The globe state is managed through:

1. **GlobeConfig**: Immutable configuration objects with transition support
2. **Factory Methods**: Convenient constructors for common scenarios and transitions
3. **Transition States**: Dedicated enum for smooth animation states
4. **didUpdateWidget**: Automatic state updates when config changes
5. **Static Transitions**: Global methods for welcome screen flow
6. **PostMessage API**: Communication between Flutter and iframe with transition data
7. **Duration Control**: Customizable transition timing for different use cases
8. **Easing Functions**: Smooth cubic easing for natural-feeling animations

This unified system eliminates the previous scattered approach with multiple separate globe widgets, providing better maintainability, smoother transitions, and clearer documentation.
