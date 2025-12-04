import * as THREE from 'three';

const GOLDEN_ANGLE = Math.PI * (3 - Math.sqrt(5));
const POINT_COUNT = 2000;
const AUTO_CYCLE_INTERVAL = 18;

const container = document.getElementById('scene-container');
const canvas = document.getElementById('awa-soul-canvas');

const renderer = new THREE.WebGLRenderer({ canvas, antialias: true });
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
renderer.setClearColor(0xffffff, 1);

const scene = new THREE.Scene();
scene.background = new THREE.Color('#ffffff');

const camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0.1, 10);
camera.position.set(0, 0, 4);

const clock = new THREE.Clock();
let elapsed = 0;

const basePositions = new Float32Array(POINT_COUNT * 2);
const positions = new Float32Array(POINT_COUNT * 3);
const colors = new Float32Array(POINT_COUNT * 3);
const mixes = new Float32Array(POINT_COUNT);

const spread = 0.085;
for (let i = 0; i < POINT_COUNT; i++) {
  const radius = Math.sqrt(i + 0.5) * spread;
  const angle = i * GOLDEN_ANGLE;
  const idx2 = i * 2;
  basePositions[idx2] = Math.cos(angle) * radius;
  basePositions[idx2 + 1] = Math.sin(angle) * radius;
  mixes[i] = i / POINT_COUNT;
}

const geometry = new THREE.BufferGeometry();
geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));

const spriteTexture = (() => {
  const size = 128;
  const canvas = document.createElement('canvas');
  canvas.width = size;
  canvas.height = size;
  const ctx = canvas.getContext('2d');
  const gradient = ctx.createRadialGradient(size / 2, size / 2, 0, size / 2, size / 2, size / 2);
  gradient.addColorStop(0, 'rgba(255,255,255,1)');
  gradient.addColorStop(0.4, 'rgba(255,255,255,0.8)');
  gradient.addColorStop(1, 'rgba(255,255,255,0)');
  ctx.fillStyle = gradient;
  ctx.fillRect(0, 0, size, size);
  return new THREE.CanvasTexture(canvas);
})();

const material = new THREE.PointsMaterial({
  size: 3.4,
  sizeAttenuation: false,
  transparent: true,
  opacity: 1,
  depthWrite: false,
  vertexColors: true,
  map: spriteTexture,
  alphaTest: 0.02,
});

const points = new THREE.Points(geometry, material);
points.frustumCulled = false;
scene.add(points);

const THEMES = {
  light: {
    radius: 0.82,
    jitter: 0.03,
    size: 3.1,
    spin: 0.22,
    colorA: '#FDF1DF',
    colorB: '#FF9EB1',
  },
  human: {
    radius: 1.04,
    jitter: 0.05,
    size: 3.4,
    spin: 0.34,
    colorA: '#FFD3BA',
    colorB: '#FF6F91',
  },
  mask: {
    radius: 1.18,
    jitter: 0.065,
    size: 3.6,
    spin: 0.46,
    colorA: '#B5CFFF',
    colorB: '#FE7FBF',
  },
  globe: {
    radius: 1.02,
    jitter: 0.04,
    size: 3.2,
    spin: 0.3,
    colorA: '#9EDBFF',
    colorB: '#FFC3A0',
  },
};

const themeState = {
  radius: THEMES.human.radius,
  jitter: THEMES.human.jitter,
  spin: THEMES.human.spin,
};
const themeTarget = {
  radius: THEMES.human.radius,
  jitter: THEMES.human.jitter,
  spin: THEMES.human.spin,
  size: THEMES.human.size,
};

const colorA = new THREE.Color(THEMES.human.colorA);
const colorB = new THREE.Color(THEMES.human.colorB);
const colorTargetA = new THREE.Color(THEMES.human.colorA);
const colorTargetB = new THREE.Color(THEMES.human.colorB);

let currentState = 'human';
let ready = false;
let pendingRequest = null;
let autoCycleEnabled = false;
let autoCycleTimer = 0;

const pointer = { x: 0, y: 0, targetX: 0, targetY: 0, active: false };

function handleResize() {
  const width = container.clientWidth;
  const height = container.clientHeight;
  renderer.setSize(width, height, false);
  const aspect = width / Math.max(1, height);
  const viewHeight = 3.2;
  camera.left = -viewHeight * aspect;
  camera.right = viewHeight * aspect;
  camera.top = viewHeight;
  camera.bottom = -viewHeight;
  camera.updateProjectionMatrix();
}

window.addEventListener('resize', handleResize);
handleResize();

function updatePointer(event) {
  const rect = container.getBoundingClientRect();
  pointer.targetX = ((event.clientX - rect.left) / rect.width) * 2 - 1;
  pointer.targetY = ((event.clientY - rect.top) / rect.height) * -2 + 1;
  pointer.active = true;
}

container.addEventListener('pointermove', updatePointer);
container.addEventListener('pointerdown', updatePointer);
container.addEventListener('pointerleave', () => {
  pointer.active = false;
  pointer.targetX = 0;
  pointer.targetY = 0;
});

function updatePositions(time) {
  const pulse = 1 + Math.sin(time * 0.8) * 0.04;
  for (let i = 0; i < POINT_COUNT; i++) {
    const idx2 = i * 2;
    const idx3 = i * 3;
    const baseX = basePositions[idx2];
    const baseY = basePositions[idx2 + 1];
    const ripple = Math.sin(time * 1.1 + i * 0.015) * themeState.jitter;
    const scale = (themeState.radius + ripple) * pulse;
    positions[idx3] = baseX * scale;
    positions[idx3 + 1] = baseY * scale;
    positions[idx3 + 2] = Math.sin(i * 0.02 + time * 0.6) * 0.05;
  }
  geometry.attributes.position.needsUpdate = true;
}

function updateColors() {
  for (let i = 0; i < POINT_COUNT; i++) {
    const mix = mixes[i];
    const idx3 = i * 3;
    colors[idx3] = colorA.r + (colorB.r - colorA.r) * mix;
    colors[idx3 + 1] = colorA.g + (colorB.g - colorA.g) * mix;
    colors[idx3 + 2] = colorA.b + (colorB.b - colorA.b) * mix;
  }
  geometry.attributes.color.needsUpdate = true;
}

function applyTheme(theme, immediate = false) {
  themeTarget.radius = theme.radius;
  themeTarget.jitter = theme.jitter;
  themeTarget.spin = theme.spin;
  themeTarget.size = theme.size;
  colorTargetA.set(theme.colorA);
  colorTargetB.set(theme.colorB);

  if (immediate) {
    themeState.radius = theme.radius;
    themeState.jitter = theme.jitter;
    themeState.spin = theme.spin;
    material.size = theme.size;
    material.needsUpdate = true;
    colorA.copy(colorTargetA);
    colorB.copy(colorTargetB);
    updatePositions(elapsed);
    updateColors();
  }
}

function postToParent(message) {
  try {
    window.parent?.postMessage(message, '*');
  } catch (error) {
    console.error('[AWA_SOUL] postMessage failed', error);
  }
}

function setSoulState(state, options = {}) {
  const theme = THEMES[state] ?? THEMES.human;
  currentState = state;
  applyTheme(theme, options.immediate === true);
  autoCycleTimer = 0;
  if (state === 'light') {
    document.body.classList.remove('hide-hint');
  } else {
    document.body.classList.add('hide-hint');
  }
  postToParent({ type: 'AWA_SOUL_STATE', state });
}

function requestState(state, options = {}) {
  if (!ready) {
    pendingRequest = { state, options };
    return;
  }
  setSoulState(state, options);
}

function cycleState() {
  if (currentState === 'human') {
    requestState('mask');
  } else {
    requestState('human');
  }
}

function setAutoCycle(enabled) {
  autoCycleEnabled = enabled === true;
  autoCycleTimer = 0;
}

function animateFrame(delta) {
  const pointerMix = pointer.active ? 0.18 : 0.06;
  pointer.x += (pointer.targetX - pointer.x) * pointerMix;
  pointer.y += (pointer.targetY - pointer.y) * pointerMix;
  const pointerStrength = Math.min(1, Math.hypot(pointer.x, pointer.y));

  const easing = 1 - Math.pow(0.0007, delta * 60);
  themeState.radius += (themeTarget.radius - themeState.radius) * easing;
  themeState.jitter += (themeTarget.jitter - themeState.jitter) * easing;
  themeState.spin += (themeTarget.spin - themeState.spin) * easing;

  const nextSize = material.size + (themeTarget.size - material.size) * easing;
  if (Math.abs(nextSize - material.size) > 0.0001) {
    material.size = nextSize;
    material.needsUpdate = true;
  }

  colorA.lerp(colorTargetA, easing);
  colorB.lerp(colorTargetB, easing);

  updatePositions(elapsed);
  updateColors();

  points.rotation.z += delta * (themeState.spin + pointerStrength * 0.6);
  points.rotation.x = THREE.MathUtils.lerp(points.rotation.x, pointer.y * 0.25, 0.08);
  points.rotation.y = THREE.MathUtils.lerp(points.rotation.y, pointer.x * 0.25, 0.08);

  const scaleTarget = 1 + pointerStrength * 0.32;
  const nextScale = THREE.MathUtils.lerp(points.scale.x, scaleTarget, 0.06);
  points.scale.setScalar(nextScale);
  points.position.x = THREE.MathUtils.lerp(points.position.x, pointer.x * 0.8, 0.06);
  points.position.y = THREE.MathUtils.lerp(points.position.y, pointer.y * 0.8, 0.06);

  renderer.render(scene, camera);
}

function animate() {
  const delta = Math.min(clock.getDelta(), 1 / 30);
  elapsed += delta;

  if (autoCycleEnabled) {
    autoCycleTimer += delta;
    if (autoCycleTimer > AUTO_CYCLE_INTERVAL) {
      autoCycleTimer = 0;
      cycleState();
    }
  }

  animateFrame(delta);
  requestAnimationFrame(animate);
}

applyTheme(THEMES[currentState], true);
updatePositions(0);
updateColors();
ready = true;
document.body.classList.add('hide-hint');
postToParent({ type: 'AWA_SOUL_READY' });

if (pendingRequest) {
  const { state, options } = pendingRequest;
  pendingRequest = null;
  setSoulState(state, options);
} else {
  postToParent({ type: 'AWA_SOUL_STATE', state: currentState });
}

animate();

window.addEventListener('message', (event) => {
  const { data } = event;
  if (!data || typeof data !== 'object') {
    return;
  }

  switch (data.type) {
    case 'AWA_SOUL_SET_STATE':
      if (typeof data.state === 'string') {
        requestState(data.state, { immediate: data.immediate === true });
      }
      break;
    case 'AWA_SOUL_TRIGGER':
      cycleState();
      break;
    case 'AWA_SOUL_SET_AUTOCYCLE':
      if (typeof data.enabled === 'boolean') {
        setAutoCycle(data.enabled);
      }
      break;
    default:
      break;
  }
});

postToParent({ type: 'AWA_SOUL_INIT' });
