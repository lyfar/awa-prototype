import 'package:flutter/material.dart';
import 'globe_states.dart';
import 'globe_widget.dart';

/// Example demonstrating the globe transition system
/// This shows how to use transitions for welcome flow and home screen switching
class GlobeTransitionExample extends StatefulWidget {
  const GlobeTransitionExample({super.key});

  @override
  State<GlobeTransitionExample> createState() => _GlobeTransitionExampleState();
}

class _GlobeTransitionExampleState extends State<GlobeTransitionExample> {
  GlobeConfig _currentConfig = GlobeConfig.light(height: 300);
  int _currentStep = 1;

  void _nextStep() {
    setState(() {
      switch (_currentStep) {
        case 1:
          // Step 1: Light state
          _currentConfig = GlobeConfig.light(height: 300);
          break;
        case 2:
          // Transition: Light → Awa Soul
          _currentConfig = GlobeConfig.lightToAwaSoul(
            height: 300,
            transitionDuration: const Duration(milliseconds: 2000),
          );
          break;
        case 3:
          // Step 2: Awa Soul state
          _currentConfig = GlobeConfig.awaSoul(height: 300);
          break;
        case 4:
          // Transition: Awa Soul → Globe
          _currentConfig = GlobeConfig.awaSoulToGlobe(
            height: 300,
            showUserLight: true,
            userLatitude: 37.7749,
            userLongitude: -122.4194,
            transitionDuration: const Duration(milliseconds: 2000),
          );
          break;
        case 5:
          // Step 3: Globe state
          _currentConfig = GlobeConfig.globe(
            height: 300,
            showUserLight: true,
            userLatitude: 37.7749,
            userLongitude: -122.4194,
          );
          break;
        case 6:
          // Transition: Globe → Awa Soul (practice mode)
          _currentConfig = GlobeConfig.globeToAwaSoul(
            height: 300,
            transitionDuration: const Duration(milliseconds: 1500),
          );
          break;
        case 7:
          // Transition: Awa Soul → Light (end practice)
          _currentConfig = GlobeConfig.awaSoulToLight(
            height: 300,
            transitionDuration: const Duration(milliseconds: 1500),
          );
          break;
      }
      _currentStep = (_currentStep % 7) + 1;
    });
  }

  void _resetToStep(int step) {
    setState(() {
      _currentStep = step;
      switch (step) {
        case 1:
          _currentConfig = GlobeConfig.light(height: 300);
          break;
        case 2:
          _currentConfig = GlobeConfig.lightToAwaSoul(height: 300);
          break;
        case 3:
          _currentConfig = GlobeConfig.awaSoul(height: 300);
          break;
        case 4:
          _currentConfig = GlobeConfig.awaSoulToGlobe(height: 300);
          break;
        case 5:
          _currentConfig = GlobeConfig.globe(height: 300);
          break;
        case 6:
          _currentConfig = GlobeConfig.globeToAwaSoul(height: 300);
          break;
        case 7:
          _currentConfig = GlobeConfig.awaSoulToLight(height: 300);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Globe Transitions Demo'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Globe Widget
          Expanded(child: GlobeWidget(config: _currentConfig)),

          // Controls
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black,
            child: Column(
              children: [
                Text(
                  'Step $_currentStep: ${_getStepDescription()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // Step buttons
                Wrap(
                  spacing: 8,
                  children: List.generate(7, (index) {
                    final step = index + 1;
                    return ElevatedButton(
                      onPressed: () => _resetToStep(step),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _currentStep == step
                                ? Colors.blue
                                : Colors.grey[800],
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Step $step'),
                    );
                  }),
                ),

                const SizedBox(height: 16),

                // Next button
                ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Next Step'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStepDescription() {
    switch (_currentStep) {
      case 1:
        return 'Light State - Single bright dot';
      case 2:
        return 'Transition - Light → Awa Soul';
      case 3:
        return 'Awa Soul State - Particle cloud';
      case 4:
        return 'Transition - Awa Soul → Globe';
      case 5:
        return 'Globe State - Earth with particles';
      case 6:
        return 'Transition - Globe → Awa Soul (Practice)';
      case 7:
        return 'Transition - Awa Soul → Light (End)';
      default:
        return 'Unknown step';
    }
  }
}
