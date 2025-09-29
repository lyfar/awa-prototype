// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'globe_states.dart';

// Global controller for welcome screen transitions
_GlobeRendererState? _globeController;

class GlobeRenderer extends StatefulWidget {
  final GlobeConfig config;

  const GlobeRenderer({super.key, required this.config});

  @override
  State<GlobeRenderer> createState() => _GlobeRendererState();

  /// Static method to trigger transitions from welcome screen
  static void transitionToAwaSoul() {
    _globeController?.triggerTransition(GlobeState.awaSoul);
  }

  /// Static method to trigger transitions from welcome screen
  static void transitionToGlobe() {
    _globeController?.triggerTransition(GlobeState.globe);
  }

  /// Static method to trigger transition back to light state
  static void transitionToLight() {
    _globeController?.triggerTransition(GlobeState.light);
  }

  /// Static method to trigger transition from globe to awaSoul
  static void transitionGlobeToAwaSoul() {
    _globeController?.triggerTransition(GlobeState.awaSoul);
  }
}

class _GlobeRendererState extends State<GlobeRenderer> {
  late final String _viewType;
  late final html.IFrameElement _iframe;
  StreamSubscription<html.MessageEvent>? _messageSubscription;
  bool _iframeReady = false;

  @override
  void initState() {
    super.initState();

    // Register this instance for welcome screen transitions (only if it's a light/welcome globe)
    if (widget.config.state == GlobeState.light) {
      _globeController = this;
    }

    print(
      'GlobeRenderer: Initializing with state=${widget.config.state.name}, showUserLight=${widget.config.showUserLight}',
    );

    _viewType = 'globe-view-${UniqueKey()}';
    final htmlContent = _buildHtml();

    _iframe =
        html.IFrameElement()
          ..style.border = '0'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.zIndex = '0'
          ..style.pointerEvents =
              widget.config.disableInteraction ? 'none' : 'auto';

    _messageSubscription = html.window.onMessage.listen((event) {
      final data = event.data;
      if (data is! Map) {
        return;
      }

      final type = data['type'];
      if (type is! String || !type.startsWith('AWA_')) {
        return;
      }

      print('GlobeRenderer: Message received - type=$type, data=$data');
      if (type == 'AWA_READY') {
        print('GlobeRenderer: iframe reported ready');
        _iframeReady = true;
        _postUpdate();
      } else if (type == 'AWA_ACK') {
        print('GlobeRenderer: iframe acknowledged ${data['command']}');
      }
    });

    _iframe.srcdoc = htmlContent;

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _iframe,
    );
  }

  @override
  void dispose() {
    // Clear the global controller when disposed
    if (_globeController == this) {
      _globeController = null;
    }
    _messageSubscription?.cancel();
    _iframeReady = false;
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GlobeRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update iframe when config changes
    if (oldWidget.config.state != widget.config.state ||
        oldWidget.config.transitionState != widget.config.transitionState ||
        oldWidget.config.showUserLight != widget.config.showUserLight ||
        oldWidget.config.disableInteraction !=
            widget.config.disableInteraction ||
        oldWidget.config.isTransitioning != widget.config.isTransitioning) {
      print('GlobeRenderer: Config changed - updating iframe');
      print(
        'GlobeRenderer: State: ${widget.config.state.name}, Transition: ${widget.config.transitionState?.name}, Transitioning: ${widget.config.isTransitioning}',
      );
      _updateGlobeState();
      _iframe.style.pointerEvents =
          widget.config.disableInteraction ? 'none' : 'auto';
    }
  }

  // Ensure iframe content refreshes on hot reload
  @override
  void reassemble() {
    super.reassemble();
    try {
      print('GlobeRenderer: reassemble - refreshing iframe srcdoc');
      _iframeReady = false;
      _iframe.srcdoc = _buildHtml();
    } catch (e) {
      print('GlobeRenderer: reassemble error: $e');
    }
  }

  void triggerTransition(GlobeState newState) {
    print('GlobeRenderer: Triggering transition to ${newState.name}');

    if (_iframe.contentWindow == null) {
      print('GlobeRenderer: Transition skipped - iframe window is null');
      return;
    }

    if (!_iframeReady) {
      print('GlobeRenderer: Transition skipped - iframe not ready');
      return;
    }

    String command;
    switch (newState) {
      case GlobeState.light:
        command = 'goToLight';
        break;
      case GlobeState.awaSoul:
        command = 'goToAwaSoul';
        break;
      case GlobeState.globe:
        command = 'goToGlobe';
        break;
    }

    try {
      _iframe.contentWindow!.postMessage({'type': command}, '*');
      print('GlobeRenderer: $command message sent via postMessage');
    } catch (e) {
      print('GlobeRenderer: PostMessage error: $e');
    }
  }

  void _updateGlobeState() {
    _postUpdate();
  }

  void _postUpdate() {
    if (_iframe.contentWindow == null) {
      print('GlobeRenderer: Cannot post update - iframe window is null');
      return;
    }

    if (!_iframeReady) {
      print(
        'GlobeRenderer: Iframe not ready, skipping post update (ready: $_iframeReady)',
      );
      return;
    }

    try {
      final message = {
        'type': 'updateState',
        'state': widget.config.state.name,
        'transitionState': widget.config.transitionState?.name,
        'showUserLight': widget.config.showUserLight,
        'userLatitude': widget.config.userLatitude,
        'userLongitude': widget.config.userLongitude,
        'isTransitioning': widget.config.isTransitioning,
        'transitionDuration': widget.config.transitionDuration.inMilliseconds,
      };
      print(
        'GlobeRenderer: Sending update - state: ${widget.config.state.name}, transition: ${widget.config.transitionState?.name}, transitioning: ${widget.config.isTransitioning}',
      );
      _iframe.contentWindow!.postMessage(message, '*');
      print('GlobeRenderer: State update sent via postMessage');
    } catch (e) {
      print('GlobeRenderer: State update error: $e');
    }
  }

  String _buildHtml() {
    final currentState = widget.config.state.name;
    final showUserLight = widget.config.showUserLight;
    final userLat = widget.config.userLatitude ?? 0.0;
    final userLng = widget.config.userLongitude ?? 0.0;

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AWA Globe</title>
    <style>
        html, body {
            margin: 0;
            padding: 0;
            width: 100%;
            height: 100%;
        }
        body {
            background: black;
            overflow: hidden;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            filter: none !important;
            opacity: 1.0 !important;
        }
        #globe-container {
            width: 100%;
            height: 100%;
            background: black;
        }
    </style>
</head>
<body>
    <div id="globe-container"></div>
    
    <script src="https://unpkg.com/three@0.158.0/build/three.min.js"></script>
    <script src="https://unpkg.com/globe.gl@2.27.1/dist/globe.gl.min.js"></script>
    
    <script>
        console.log('AWA Globe: Script starting - initial state: $currentState');
        
        // Force maximum brightness
        document.body.style.filter = 'none';
        document.body.style.opacity = '1.0';
        
        // Globe instance
        let globe;
        let currentGlobeState = '$currentState';
        let currentTransitionState = null;
        let showUserLight = $showUserLight;
        let userLatitude = $userLat;
        let userLongitude = $userLng;
        let isTransitioning = false;
        let transitionDuration = 2000;
        
        // Check if we're starting with a transition state
        const initialTransitionState = '${widget.config.transitionState?.name ?? 'null'}';
        console.log('AWA Globe: Initial transition state:', initialTransitionState);
        if (initialTransitionState !== 'null') {
          currentTransitionState = initialTransitionState;
          isTransitioning = true;
          console.log('AWA Globe: Starting with transition:', initialTransitionState);
        }
        
        // Animation state
        let animationFrameId;
        let startTime = Date.now();
        let lastFrameTime = performance.now();
        
        // Particles data
        const EARTH_TEXTURE_URL = 'https://cdn.jsdelivr.net/npm/three-globe/example/img/earth-blue-marble.jpg';

        let communityParticles = [];
        let orbitingParticles = [];
        let userLightData = null;
        const RAD2DEG = 180 / Math.PI;
        let textureFadeFrame = null;
        let currentVisualState = 'light';
        let transitionStart = performance.now();

        function cancelTextureFade() {
            if (textureFadeFrame) {
                cancelAnimationFrame(textureFadeFrame);
                textureFadeFrame = null;
            }
        }

        function clearGlobeTexture() {
            if (!globe) return;
            cancelTextureFade();
            globe.globeImageUrl(null);
            const material = globe.globeMaterial();
            material.transparent = true;
            material.opacity = 0;
            material.needsUpdate = true;
        }

        function setGlobeTexture(textureUrl, targetOpacity = 1, duration = 1200) {
            if (!globe) return;

            if (!textureUrl) {
                clearGlobeTexture();
                return;
            }

            cancelTextureFade();
            globe.globeImageUrl(textureUrl);
            const material = globe.globeMaterial();
            material.transparent = true;
            material.opacity = 0;
            material.needsUpdate = true;

            const startTime = performance.now();

            function animateOpacity(timestamp) {
                const elapsed = timestamp - startTime;
                const progress = Math.min(1, elapsed / duration);
                material.opacity = progress * targetOpacity;
                material.needsUpdate = true;

                if (progress < 1) {
                    textureFadeFrame = requestAnimationFrame(animateOpacity);
                } else {
                    textureFadeFrame = null;
                }
            }

            textureFadeFrame = requestAnimationFrame(animateOpacity);
        }

        function applyPointOfView(view, duration = 1200) {
            if (!globe) return;
            globe.pointOfView(view, duration);
        }

        function resetOrbitingParticles() {
            orbitingParticles = orbitingParticles.map(p => {
                const baseColor = p.baseColor ?? p.color ?? '#FFFFFF';
                const targetOpacity = p.targetOpacity ?? p.opacity ?? 0.85;
                return {
                    ...p,
                    baseColor,
                    currentOpacity: 0,
                    targetOpacity,
                    currentAltitude: p.baseAltitude ?? p.altitude,
                    targetAltitude: p.targetAltitude ?? p.baseAltitude ?? p.altitude,
                    color: colorWithOpacity(baseColor, 0),
                };
            });
        }

        function resetCommunityParticles() {
            communityParticles = communityParticles.map(p => {
                const baseColor = p.baseColor ?? p.color ?? '#FFFFFF';
                const targetOpacity = p.targetOpacity ?? p.opacity ?? 0.9;
                return {
                    ...p,
                    baseColor,
                    currentOpacity: 0,
                    targetOpacity,
                    color: colorWithOpacity(baseColor, 0),
                };
            });
        }

        function easeTowards(current, target, step) {
            const factor = Math.min(1, Math.max(0, step));
            if (Math.abs(target - current) < 0.001) return target;
            return current + (target - current) * factor;
        }

        const HOLOGRAPHIC_COLORS = ['#90F5FF', '#9D7BFF', '#FF8FFB', '#7CFFB2', '#FFE27A'];
        
        function pickHolographicColor(offset = 0) {
            const index = (Math.floor(Math.random() * HOLOGRAPHIC_COLORS.length) + offset) % HOLOGRAPHIC_COLORS.length;
            return HOLOGRAPHIC_COLORS[index];
        }
        
        function hexToRgba(hex, alpha) {
            const sanitized = hex.replace('#', '');
            const bigint = parseInt(sanitized, 16);
            const r = (bigint >> 16) & 255;
            const g = (bigint >> 8) & 255;
            const b = bigint & 255;
            const clamped = Math.max(0, Math.min(1, alpha ?? 1));
            return `rgba(\${r}, \${g}, \${b}, \${clamped})`;
        }

        function colorWithOpacity(baseColor, alpha) {
            const clamped = Math.max(0, Math.min(1, alpha ?? 1));
            if (!baseColor) {
                return `rgba(255, 255, 255, \${clamped})`;
            }

            if (baseColor.startsWith('#')) {
                return hexToRgba(baseColor, clamped);
            }

            const rgbMatch = baseColor.match(/rgba?\(([^)]+)\)/i);
            if (rgbMatch) {
                const [r, g, b] = rgbMatch[1]
                    .split(',')
                    .slice(0, 3)
                    .map(component => component.trim());
                return `rgba(\${r}, \${g}, \${b}, \${clamped})`;
            }

            return baseColor;
        }
        
        function applyHolographicAtmosphere() {
            globe.showAtmosphere(true);
            globe.atmosphereColor('#90F5FF');
            globe.atmosphereAltitude(0.22);
            const material = globe.globeMaterial();
            material.color = new THREE.Color('#0d0f29');
            material.emissive = new THREE.Color('#3947ff');
            material.emissiveIntensity = 0.35;
            material.shininess = 60;
            material.needsUpdate = true;
            globe.backgroundColor('#05010d');
        }
        
        function latLngToXY(lat, lng, width, height) {
            const x = (lng + 180) / 360 * width;
            const y = (90 - lat) / 180 * height;
            return { x, y };
        }
        
        function drawHolographicContinents(ctx, width, height) {
            const continents = [
                {
                    name: 'northAmerica',
                    coords: [
                        { lat: 72, lng: -168 }, { lat: 72, lng: -120 }, { lat: 70, lng: -90 },
                        { lat: 61, lng: -70 }, { lat: 50, lng: -55 }, { lat: 40, lng: -70 },
                        { lat: 30, lng: -85 }, { lat: 15, lng: -95 }, { lat: 5, lng: -105 },
                        { lat: 10, lng: -125 }, { lat: 30, lng: -140 }, { lat: 50, lng: -150 }
                    ]
                },
                {
                    name: 'southAmerica',
                    coords: [
                        { lat: 12, lng: -81 }, { lat: 5, lng: -75 }, { lat: -10, lng: -77 },
                        { lat: -30, lng: -70 }, { lat: -50, lng: -64 }, { lat: -55, lng: -50 },
                        { lat: -35, lng: -45 }, { lat: -5, lng: -50 }, { lat: 8, lng: -60 }
                    ]
                },
                {
                    name: 'europe',
                    coords: [
                        { lat: 71, lng: -10 }, { lat: 70, lng: 15 }, { lat: 64, lng: 30 },
                        { lat: 54, lng: 40 }, { lat: 45, lng: 20 }, { lat: 36, lng: 0 },
                        { lat: 50, lng: -5 }
                    ]
                },
                {
                    name: 'africa',
                    coords: [
                        { lat: 35, lng: -17 }, { lat: 33, lng: 15 }, { lat: 23, lng: 30 },
                        { lat: 5, lng: 38 }, { lat: -15, lng: 35 }, { lat: -30, lng: 20 },
                        { lat: -34, lng: 10 }, { lat: -30, lng: -10 }, { lat: -5, lng: -17 }
                    ]
                },
                {
                    name: 'asia',
                    coords: [
                        { lat: 78, lng: 45 }, { lat: 70, lng: 90 }, { lat: 60, lng: 135 },
                        { lat: 45, lng: 150 }, { lat: 25, lng: 140 }, { lat: 10, lng: 115 },
                        { lat: 20, lng: 95 }, { lat: 30, lng: 70 }, { lat: 40, lng: 55 },
                        { lat: 55, lng: 60 }
                    ]
                },
                {
                    name: 'australia',
                    coords: [
                        { lat: -10, lng: 110 }, { lat: -12, lng: 145 }, { lat: -32, lng: 150 },
                        { lat: -44, lng: 130 }, { lat: -28, lng: 112 }
                    ]
                }
            ];
            
            continents.forEach((continent, index) => {
                const projected = continent.coords.map(coord => latLngToXY(coord.lat, coord.lng, width, height));
                if (projected.length < 3) return;
                
                const xs = projected.map(p => p.x);
                const ys = projected.map(p => p.y);
                const minX = Math.min(...xs);
                const minY = Math.min(...ys);
                const maxX = Math.max(...xs);
                const maxY = Math.max(...ys);
                
                const gradient = ctx.createLinearGradient(minX, minY, maxX, maxY);
                gradient.addColorStop(0, hexToRgba(HOLOGRAPHIC_COLORS[index % HOLOGRAPHIC_COLORS.length], 0.85));
                gradient.addColorStop(0.5, hexToRgba(HOLOGRAPHIC_COLORS[(index + 2) % HOLOGRAPHIC_COLORS.length], 0.7));
                gradient.addColorStop(1, hexToRgba(HOLOGRAPHIC_COLORS[(index + 3) % HOLOGRAPHIC_COLORS.length], 0.82));
                
                ctx.save();
                ctx.beginPath();
                projected.forEach((point, pointIndex) => {
                    if (pointIndex === 0) {
                        ctx.moveTo(point.x, point.y);
                    } else {
                        ctx.lineTo(point.x, point.y);
                    }
                });
                ctx.closePath();
                
                ctx.shadowBlur = 45;
                ctx.shadowColor = hexToRgba(HOLOGRAPHIC_COLORS[(index + 1) % HOLOGRAPHIC_COLORS.length], 0.45);
                ctx.globalAlpha = 0.9;
                ctx.fillStyle = gradient;
                ctx.fill();
                ctx.restore();
            });
        }

        function createSpaceTexture() {
            const width = 2048;
            const height = 1024;
            const canvas = document.createElement('canvas');
            canvas.width = width;
            canvas.height = height;
            const ctx = canvas.getContext('2d');

            const twilight = ctx.createLinearGradient(0, 0, width, height);
            twilight.addColorStop(0, '#01030c');
            twilight.addColorStop(0.35, '#050b1d');
            twilight.addColorStop(0.7, '#071330');
            twilight.addColorStop(1, '#02030b');
            ctx.fillStyle = twilight;
            ctx.fillRect(0, 0, width, height);

            const aurora = ctx.createRadialGradient(width / 2, height / 2, width * 0.12, width / 2, height / 2, width * 0.48);
            aurora.addColorStop(0, 'rgba(157, 123, 255, 0.15)');
            aurora.addColorStop(1, 'rgba(157, 123, 255, 0)');
            ctx.fillStyle = aurora;
            ctx.fillRect(0, 0, width, height);

            return canvas.toDataURL('image/png');
        }

        // Initialize globe
        function initGlobe() {
            console.log('AWA Globe: Initializing globe with state:', currentGlobeState);
            
            const container = document.getElementById('globe-container');
            if (!container) {
                console.error('AWA Globe: Container not found');
                return;
            }
            
            // Initialize Globe.gl
            globe = Globe()
                .width(container.clientWidth)
                .height(container.clientHeight)
                (container);

            globe.pointColor('color');
            globe.pointAltitude(d => d.altitude || 0.02);
            globe.pointRadius(d => d.size || 2);
            
            // Configure globe based on initial state and transition
            setupGlobeForState(currentGlobeState, currentTransitionState);
            
            // Start animation loop
            startAnimationLoop();
            
            console.log('AWA Globe: Globe initialized successfully');

            if (window.parent) {
                window.parent.postMessage({ type: 'AWA_READY' }, '*');
            }
        }
        
        function setupGlobeForState(state, transitionState = null) {
            console.log('AWA Globe: Setting up for state:', state, 'transition:', transitionState);
            
            applyHolographicAtmosphere();
            
            if (transitionState) {
                handleTransition(transitionState);
            } else {
                switch (state) {
                    case 'light':
                        setupLightState();
                        break;
                    case 'awaSoul':
                        setupAwaSoulState();
                        break;
                    case 'globe':
                        setupGlobeState();
                        break;
                    default:
                        console.warn('AWA Globe: Unknown state:', state);
                        setupLightState();
                }
            }
        }

        function handleTransition(transitionState) {
            console.log('AWA Globe: Handling transition:', transitionState);
            isTransitioning = true;
            transitionStart = performance.now();
            
            switch (transitionState) {
                case 'lightToAwaSoul':
                    transitionLightToAwaSoul();
                    break;
                case 'awaSoulToGlobe':
                    transitionAwaSoulToGlobe();
                    break;
                case 'globeToAwaSoul':
                    transitionGlobeToAwaSoul();
                    break;
                case 'awaSoulToLight':
                    transitionAwaSoulToLight();
                    break;
                default:
                    console.warn('AWA Globe: Unknown transition:', transitionState);
            }
        }

        function transitionLightToAwaSoul() {
            console.log('AWA Globe: Transitioning Light → Awa Soul');
            
            // Start with light state
            setupLightState();
            
            // Begin zoom out and particle introduction
            const startTime = performance.now();
            const duration = transitionDuration;
            
            function animateTransition(timestamp) {
                const elapsed = timestamp - startTime;
                const progress = Math.min(1, elapsed / duration);
                
                // Easing function for smooth transition
                const easeProgress = 1 - Math.pow(1 - progress, 3);
                
                // Zoom out camera
                const startAlt = 1.6;
                const endAlt = 3.6;
                const currentAlt = startAlt + (endAlt - startAlt) * easeProgress;
                globe.pointOfView({ lat: 18, lng: -42, altitude: currentAlt }, 0);
                
                // Fade in orbiting particles
                if (orbitingParticles.length === 0) {
                    generateAwaSoulParticles();
                }
                
                orbitingParticles.forEach(particle => {
                    const targetOpacity = particle.targetOpacity * easeProgress;
                    particle.currentOpacity = targetOpacity;
                    particle.color = colorWithOpacity(particle.baseColor, targetOpacity);
                });
                
                globe.pointsData([...orbitingParticles]);
                
                if (progress < 1) {
                    requestAnimationFrame(animateTransition);
                } else {
                    // Transition complete, switch to awaSoul state
                    currentGlobeState = 'awaSoul';
                    currentTransitionState = null;
                    isTransitioning = false;
                    console.log('AWA Globe: Light → Awa Soul transition complete');
                    setupAwaSoulState();
                }
            }
            
            requestAnimationFrame(animateTransition);
        }

        function transitionAwaSoulToGlobe() {
            console.log('AWA Globe: Transitioning Awa Soul → Globe');
            
            // Start with awaSoul state
            setupAwaSoulState();
            
            const startTime = performance.now();
            const duration = transitionDuration;
            
            function animateTransition(timestamp) {
                const elapsed = timestamp - startTime;
                const progress = Math.min(1, elapsed / duration);
                const easeProgress = 1 - Math.pow(1 - progress, 3);
                
                // Fade in earth texture
                const material = globe.globeMaterial();
                material.opacity = easeProgress;
                material.needsUpdate = true;
                
                // Generate and fade in community particles
                if (communityParticles.length === 0) {
                    generateCommunityParticles();
                }
                
                communityParticles.forEach(particle => {
                    const targetOpacity = particle.targetOpacity * easeProgress;
                    particle.currentOpacity = targetOpacity;
                    particle.color = colorWithOpacity(particle.baseColor, targetOpacity);
                });
                
                // Fade out orbiting particles
                orbitingParticles.forEach(particle => {
                    const targetOpacity = particle.targetOpacity * (1 - easeProgress) * 0.45;
                    particle.currentOpacity = targetOpacity;
                    particle.color = colorWithOpacity(particle.baseColor, targetOpacity);
                });
                
                let allParticles = [...communityParticles, ...orbitingParticles];
                
                // Add user light if needed
                if (showUserLight && userLatitude !== null && userLongitude !== null) {
                    const baseColor = '#FFFFFF';
                    const userLightData = {
                        lat: userLatitude,
                        lng: userLongitude,
                        size: 4,
                        baseColor,
                        color: colorWithOpacity(baseColor, easeProgress),
                        type: 'user',
                        altitude: 0.02,
                        currentOpacity: easeProgress,
                        targetOpacity: 1,
                    };
                    allParticles.push(userLightData);
                }
                
                globe.pointsData(allParticles);
                
                // Adjust camera position
                const startAlt = 3.6;
                const endAlt = 2.2;
                const currentAlt = startAlt + (endAlt - startAlt) * easeProgress;
                globe.pointOfView({ lat: 20, lng: 0, altitude: currentAlt }, 0);
                
                if (progress < 1) {
                    requestAnimationFrame(animateTransition);
                } else {
                    // Transition complete, switch to globe state
                    currentGlobeState = 'globe';
                    currentTransitionState = null;
                    isTransitioning = false;
                    console.log('AWA Globe: Awa Soul → Globe transition complete');
                    setupGlobeState();
                }
            }
            
            requestAnimationFrame(animateTransition);
        }

        function transitionGlobeToAwaSoul() {
            console.log('AWA Globe: Transitioning Globe → Awa Soul');
            
            // Start with globe state
            setupGlobeState();
            
            const startTime = performance.now();
            const duration = transitionDuration;
            
            function animateTransition(timestamp) {
                const elapsed = timestamp - startTime;
                const progress = Math.min(1, elapsed / duration);
                const easeProgress = 1 - Math.pow(1 - progress, 3);
                
                // Fade out earth texture
                const material = globe.globeMaterial();
                material.opacity = 1 - easeProgress;
                material.needsUpdate = true;
                
                // Fade out community particles
                communityParticles.forEach(particle => {
                    const targetOpacity = particle.targetOpacity * (1 - easeProgress);
                    particle.currentOpacity = targetOpacity;
                    particle.color = colorWithOpacity(particle.baseColor, targetOpacity);
                });
                
                // Fade in orbiting particles
                orbitingParticles.forEach(particle => {
                    const targetOpacity = particle.targetOpacity * easeProgress;
                    particle.currentOpacity = targetOpacity;
                    particle.color = colorWithOpacity(particle.baseColor, targetOpacity);
                });
                
                globe.pointsData([...orbitingParticles]);
                
                // Adjust camera position
                const startAlt = 2.2;
                const endAlt = 3.6;
                const currentAlt = startAlt + (endAlt - startAlt) * easeProgress;
                globe.pointOfView({ lat: 18, lng: -42, altitude: currentAlt }, 0);
                
                if (progress < 1) {
                    requestAnimationFrame(animateTransition);
                } else {
                    // Transition complete, switch to awaSoul state
                    currentGlobeState = 'awaSoul';
                    currentTransitionState = null;
                    isTransitioning = false;
                    console.log('AWA Globe: Globe → Awa Soul transition complete');
                    setupAwaSoulState();
                }
            }
            
            requestAnimationFrame(animateTransition);
        }

        function transitionAwaSoulToLight() {
            console.log('AWA Globe: Transitioning Awa Soul → Light');
            
            // Start with awaSoul state
            setupAwaSoulState();
            
            const startTime = performance.now();
            const duration = transitionDuration;
            
            function animateTransition(timestamp) {
                const elapsed = timestamp - startTime;
                const progress = Math.min(1, elapsed / duration);
                const easeProgress = 1 - Math.pow(1 - progress, 3);
                
                // Fade out orbiting particles
                orbitingParticles.forEach(particle => {
                    const targetOpacity = particle.targetOpacity * (1 - easeProgress);
                    particle.currentOpacity = targetOpacity;
                    particle.color = colorWithOpacity(particle.baseColor, targetOpacity);
                });
                
                // Zoom in camera
                const startAlt = 3.6;
                const endAlt = 1.6;
                const currentAlt = startAlt + (endAlt - startAlt) * easeProgress;
                globe.pointOfView({ lat: 0, lng: 0, altitude: currentAlt }, 0);
                
                if (progress < 1) {
                    requestAnimationFrame(animateTransition);
                } else {
                    // Transition complete, switch to light state
                    currentGlobeState = 'light';
                    currentTransitionState = null;
                    isTransitioning = false;
                    console.log('AWA Globe: Awa Soul → Light transition complete');
                    setupLightState();
                }
            }
            
            requestAnimationFrame(animateTransition);
        }
        
        function setupLightState() {
            console.log('AWA Globe: Setting up Light state - single user light');
            
            clearGlobeTexture();
            globe.backgroundImageUrl(null);
            globe.showAtmosphere(false);
            globe.backgroundColor('#02020b');
            currentVisualState = 'light';
            transitionStart = performance.now();
            orbitingParticles = [];
            communityParticles = [];
            userLightData = null;

            const baseMaterial = globe.globeMaterial();
            baseMaterial.transparent = true;
            baseMaterial.opacity = 0;
            baseMaterial.color = new THREE.Color('#000000');
            baseMaterial.emissive = new THREE.Color('#000000');
            baseMaterial.emissiveIntensity = 0;
            baseMaterial.needsUpdate = true;

            const ignitionCoreColor = '#FFFFFF';
            const ignitionCore = {
                lat: 0,
                lng: 0,
                size: 11,
                baseColor: ignitionCoreColor,
                color: colorWithOpacity(ignitionCoreColor, 1),
                altitude: 0.05,
                type: 'core',
                currentOpacity: 1,
                targetOpacity: 1,
            };

            const ignitionHalo = Array.from({ length: 12 }, (_, index) => {
                const angle = (Math.PI * 2 * index) / 12;
                const radius = 6 + Math.random() * 1.5;
                const baseColor = pickHolographicColor(index);
                const haloOpacity = 0.45 + Math.random() * 0.25;
                return {
                    lat: Math.sin(angle) * radius,
                    lng: Math.cos(angle) * radius,
                    size: 2.2 + Math.random() * 1.4,
                    baseColor,
                    color: colorWithOpacity(baseColor, haloOpacity),
                    altitude: 0.035 + Math.random() * 0.015,
                    type: 'halo',
                    currentOpacity: haloOpacity,
                    targetOpacity: haloOpacity,
                };
            });

            const ignitionSparks = Array.from({ length: 6 }, () => {
                const baseColor = '#FFFFFF';
                const sparkOpacity = 0.65 + Math.random() * 0.2;
                return {
                    lat: (Math.random() - 0.5) * 4,
                    lng: (Math.random() - 0.5) * 4,
                    size: 3.2 + Math.random() * 1.2,
                    baseColor,
                    color: colorWithOpacity(baseColor, sparkOpacity),
                    altitude: 0.04 + Math.random() * 0.025,
                    type: 'spark',
                    currentOpacity: sparkOpacity,
                    targetOpacity: sparkOpacity,
                };
            });

            const lightParticles = [ignitionCore, ...ignitionHalo, ...ignitionSparks];

            globe.pointsData(lightParticles);
            globe.pointAltitude(d => d.altitude || 0.03);
            globe.pointRadius(d => d.size || 2.4);
            globe.pointColor('color');

            applyPointOfView({ lat: 0, lng: 0, altitude: 1.6 }, 1600);

            console.log('AWA Globe: Light state setup complete');
        }

        function setupAwaSoulState() {
            console.log('AWA Globe: Setting up Awa Soul state - particle cloud');
            
            const spaceTexture = createSpaceTexture();
            setGlobeTexture(spaceTexture, 0.55, 1600);
            globe.backgroundImageUrl(null);
            globe.backgroundColor('#020611');
            currentVisualState = 'awaSoul';
            transitionStart = performance.now();
            orbitingParticles = [];
            generateAwaSoulParticles();
            resetOrbitingParticles();
            globe.pointsData([...orbitingParticles]);

            // Position camera to show particle cloud
            applyPointOfView({ lat: 18, lng: -42, altitude: 3.6 }, 2000);
            
            applyHolographicAtmosphere();
            
            console.log('AWA Globe: Awa Soul state setup complete');
        }
        
        function setupGlobeState() {
            console.log('AWA Globe: Setting up Globe state - earth with particles');
            
            // Show earth with custom texture
            setGlobeTexture(EARTH_TEXTURE_URL, 1.0, 1800);
            globe.backgroundImageUrl(null);
            globe.backgroundColor('#040718');
            currentVisualState = 'globe';
            transitionStart = performance.now();
            // Generate community particles on continents
            generateCommunityParticles();
            resetCommunityParticles();
            orbitingParticles = [];

            let allParticles = [...communityParticles];

            // Add user light if practiced
            if (showUserLight && userLatitude !== null && userLongitude !== null) {
                const baseColor = '#FFFFFF';
                userLightData = {
                    lat: userLatitude,
                    lng: userLongitude,
                    size: 4,
                    baseColor,
                    color: colorWithOpacity(baseColor, 1),
                    type: 'user',
                    altitude: 0.02,
                    currentOpacity: 1,
                    targetOpacity: 1,
                };
                allParticles.push(userLightData);
            } else {
                userLightData = null;
            }
            
            globe.pointsData(allParticles);
            globe.pointAltitude(d => d.currentAltitude !== undefined ? d.currentAltitude : d.altitude || 0.02);
            globe.pointRadius(d => d.size || 2);
            globe.pointColor('color');
            
            // Position camera to show full globe
            applyPointOfView({ lat: 20, lng: 0, altitude: 2.2 }, 1800);

            // Enhanced lighting for "fancy" look
            setupLighting();
            
            applyHolographicAtmosphere();
            
            console.log('AWA Globe: Globe state setup complete');
        }
        
        function generateCommunityParticles() {
            communityParticles = [];
            
            // Major cities/continents for community distribution
            const locations = [
                // North America
                { lat: 40.7128, lng: -74.0060 }, // New York
                { lat: 34.0522, lng: -118.2437 }, // Los Angeles
                { lat: 41.8781, lng: -87.6298 }, // Chicago
                
                // Europe
                { lat: 51.5074, lng: -0.1278 }, // London
                { lat: 48.8566, lng: 2.3522 }, // Paris
                { lat: 52.5200, lng: 13.4050 }, // Berlin
                
                // Asia
                { lat: 35.6762, lng: 139.6503 }, // Tokyo
                { lat: 39.9042, lng: 116.4074 }, // Beijing
                { lat: 19.0760, lng: 72.8777 }, // Mumbai
                
                // Other continents
                { lat: -33.8688, lng: 151.2093 }, // Sydney
                { lat: -23.5505, lng: -46.6333 }, // São Paulo
                { lat: -1.2921, lng: 36.8219 }, // Nairobi
            ];
            
            locations.forEach(location => {
                // Add 3-5 particles per location
                const count = 3 + Math.floor(Math.random() * 3);
                for (let i = 0; i < count; i++) {
                    const baseColor = pickHolographicColor(i);
                    const targetOpacity = 0.92;
                    communityParticles.push({
                        lat: location.lat + (Math.random() - 0.5) * 10,
                        lng: location.lng + (Math.random() - 0.5) * 10,
                        size: 1.5 + Math.random() * 1,
                        baseColor,
                        color: colorWithOpacity(baseColor, 0),
                        type: 'community',
                        altitude: 0.015,
                        opacity: targetOpacity,
                        targetOpacity,
                        currentOpacity: 0,
                    });
                }
            });
            
            console.log('AWA Globe: Generated', communityParticles.length, 'community particles');
        }
        
        function generateAwaSoulParticles() {
            orbitingParticles = [];
            
            const count = 160;
            for (let i = 0; i < count; i++) {
                const altitude = 0.25 + Math.random() * 0.55;
                const baseColor = pickHolographicColor(i + 3);
                const inclination = Math.random() * Math.PI; // 0 - 180 degrees in radians
                const longitudeOffset = Math.random() * Math.PI * 2;
                const phase = Math.random() * Math.PI * 2;
                const speed = 0.01 + Math.random() * 0.02;

                const size = 0.9 + Math.random() * 1.6;
                const opacity = 0.6 + Math.random() * 0.25;

                orbitingParticles.push({
                    lat: 0,
                    lng: 0,
                    altitude,
                    size,
                    baseColor,
                    color: colorWithOpacity(baseColor, 0),
                    type: 'orbiting',
                    baseAltitude: altitude,
                    currentAltitude: altitude,
                    targetAltitude: altitude,
                    opacity,
                    targetOpacity: opacity,
                    currentOpacity: 0,
                    inclination,
                    longitudeOffset,
                    phase,
                    speed
                });
            }
            
            console.log('AWA Globe: Generated', orbitingParticles.length, 'orbiting particles');
        }
        
        function createEarthTexture() {
            const width = 2048;
            const height = 1024;
            const canvas = document.createElement('canvas');
            canvas.width = width;
            canvas.height = height;
            const ctx = canvas.getContext('2d');
            
            const baseGradient = ctx.createLinearGradient(0, 0, width, height);
            baseGradient.addColorStop(0, '#0d102f');
            baseGradient.addColorStop(0.5, '#152861');
            baseGradient.addColorStop(1, '#0b1033');
            ctx.fillStyle = baseGradient;
            ctx.fillRect(0, 0, width, height);
            
            const aura = ctx.createRadialGradient(width / 2, height / 2, width * 0.15, width / 2, height / 2, width * 0.5);
            aura.addColorStop(0, 'rgba(157, 123, 255, 0.25)');
            aura.addColorStop(1, 'rgba(157, 123, 255, 0)');
            ctx.fillStyle = aura;
            ctx.fillRect(0, 0, width, height);
            
            drawHolographicContinents(ctx, width, height);
            
            return canvas.toDataURL('image/png');
        }
        
        function setupLighting() {
            const scene = globe.scene();
            
            if (!scene.getObjectByName('awa-holo-ambient')) {
                const ambient = new THREE.AmbientLight(0x90f5ff, 0.9);
                ambient.name = 'awa-holo-ambient';
                scene.add(ambient);
            }
            
            if (!scene.getObjectByName('awa-holo-directional')) {
                const directionalLight = new THREE.DirectionalLight(0xffffff, 1.1);
                directionalLight.position.set(2, 1.5, 2);
                directionalLight.name = 'awa-holo-directional';
                scene.add(directionalLight);
            }
            
            if (!scene.getObjectByName('awa-holo-point-1')) {
                const pointLight1 = new THREE.PointLight(0x9d7bff, 0.9, 120);
                pointLight1.position.set(12, 8, 12);
                pointLight1.name = 'awa-holo-point-1';
                scene.add(pointLight1);
            }
            
            if (!scene.getObjectByName('awa-holo-point-2')) {
                const pointLight2 = new THREE.PointLight(0x7cffb2, 0.7, 120);
                pointLight2.position.set(-14, -6, 10);
                pointLight2.name = 'awa-holo-point-2';
                scene.add(pointLight2);
            }
        }
        
        function startAnimationLoop() {
            function animate() {
                const now = performance.now();
                const delta = Math.min(0.25, (now - lastFrameTime) / 1000);
                lastFrameTime = now;
                const elapsed = (Date.now() - startTime) / 1000;

                // Animate orbiting particles
                if (orbitingParticles.length > 0) {
                    orbitingParticles.forEach(particle => {
                        particle.phase += particle.speed * delta * 60;
                        const x = Math.cos(particle.phase);
                        const y = Math.sin(particle.phase) * Math.sin(particle.inclination);
                        const z = Math.sin(particle.phase) * Math.cos(particle.inclination);

                        const latRad = Math.asin(Math.max(-1, Math.min(1, z)));
                        const lngRad = Math.atan2(y, x) + particle.longitudeOffset;

                        particle.lat = latRad * RAD2DEG;
                        particle.lng = ((lngRad * RAD2DEG + 540) % 360) - 180;

                        let targetOpacity = 0;
                        let targetAltitude = particle.baseAltitude;
                        if (currentVisualState === 'awaSoul') {
                            targetOpacity = particle.targetOpacity;
                            targetAltitude = particle.baseAltitude;
                        } else if (currentVisualState === 'globe') {
                            targetOpacity = Math.min(0.45, particle.targetOpacity);
                            targetAltitude = Math.max(0.12, particle.baseAltitude * 0.65);
                        }

                        particle.currentOpacity = easeTowards(
                            particle.currentOpacity ?? 0,
                            targetOpacity,
                            1 - Math.pow(0.25, delta * 2.5)
                        );

                        particle.currentAltitude = easeTowards(
                            particle.currentAltitude ?? particle.baseAltitude,
                            targetAltitude,
                            1 - Math.pow(0.25, delta * 2.5)
                        );

                        const baseColor = particle.baseColor ?? particle.color ?? '#FFFFFF';
                        particle.color = colorWithOpacity(baseColor, particle.currentOpacity ?? 0);
                    });
                    
                    // Update globe data if in appropriate state
                    if (currentGlobeState === 'awaSoul') {
                        globe.pointsData([...orbitingParticles]);
                    } else if (currentGlobeState === 'globe') {
                        const allParticles = [...communityParticles, ...orbitingParticles];
                        if (userLightData) {
                            allParticles.push(userLightData);
                        }
                        globe.pointsData(allParticles);
                    }
                }

                if (communityParticles.length > 0) {
                    communityParticles.forEach(particle => {
                        const targetOpacity = currentVisualState === 'globe' ? (particle.targetOpacity ?? 0.9) : 0;
                        particle.currentOpacity = easeTowards(
                            particle.currentOpacity ?? 0,
                            targetOpacity,
                            1 - Math.pow(0.25, delta * 2.5)
                        );
                        const baseColor = particle.baseColor ?? particle.color ?? '#FFFFFF';
                        particle.color = colorWithOpacity(baseColor, particle.currentOpacity ?? 0);
                    });
                }

                animationFrameId = requestAnimationFrame(animate);
            }
            
            animate();
        }
        
        function stopAnimationLoop() {
            if (animationFrameId) {
                cancelAnimationFrame(animationFrameId);
                animationFrameId = null;
            }
        }
        
        // Transition functions for welcome screen
        function transitionToAwaSoul() {
            console.log('AWA Globe: Transitioning to Awa Soul');
            currentGlobeState = 'awaSoul';
            setupGlobeForState('awaSoul');
        }
        
        function transitionToGlobe() {
            console.log('AWA Globe: Transitioning to Globe');
            currentGlobeState = 'globe';
            setupGlobeForState('globe');
        }
        
        function updateState(newState, newTransitionState, newShowUserLight, newUserLat, newUserLng, newIsTransitioning, newTransitionDuration) {
            console.log('AWA Globe: Updating state:', newState, 'transition:', newTransitionState, 'showUserLight:', newShowUserLight);
            
            currentGlobeState = newState;
            currentTransitionState = newTransitionState;
            showUserLight = newShowUserLight;
            userLatitude = newUserLat || 0;
            userLongitude = newUserLng || 0;
            isTransitioning = newIsTransitioning || false;
            transitionDuration = newTransitionDuration || 2000;
            
            setupGlobeForState(currentGlobeState, currentTransitionState);
        }
        
        // Listen for messages from Flutter
        window.addEventListener('message', function(event) {
            console.log('AWA Globe: Received message:', event.data);
            
            if (event.data && event.data.type) {
                const commandType = event.data.type;
                switch (commandType) {
                    case 'goToAwaSoul':
                        transitionToAwaSoul();
                        break;
                    case 'goToGlobe':
                        transitionToGlobe();
                        break;
                    case 'updateState':
                        updateState(
                            event.data.state,
                            event.data.transitionState,
                            event.data.showUserLight,
                            event.data.userLatitude,
                            event.data.userLongitude,
                            event.data.isTransitioning,
                            event.data.transitionDuration
                        );
                        break;
                }

                if (window.parent) {
                    window.parent.postMessage({ type: 'AWA_ACK', command: commandType }, '*');
                }

            }
        });
        
        // Initialize when DOM is ready
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', initGlobe);
        } else {
            initGlobe();
        }
        
        // Cleanup on page unload
        window.addEventListener('beforeunload', function() {
            stopAnimationLoop();
        });
        
        console.log('AWA Globe: Script setup complete');
    </script>
</body>
</html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
