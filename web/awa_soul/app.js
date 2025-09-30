import * as THREE from 'three';
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js';
import { SimplexNoise } from 'three/examples/jsm/math/SimplexNoise.js';

const CANVAS = document.getElementById('awa-soul-canvas');
const CONTAINER = document.getElementById('scene-container');

const renderer = new THREE.WebGLRenderer({ canvas: CANVAS, antialias: true, alpha: true });
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
renderer.setSize(CONTAINER.clientWidth, CONTAINER.clientHeight, false);
renderer.setClearColor(0x000000, 0);

const scene = new THREE.Scene();
scene.fog = new THREE.FogExp2(0x030109, 0.25);

const camera = new THREE.PerspectiveCamera(55, CONTAINER.clientWidth / CONTAINER.clientHeight, 0.1, 100);
camera.position.set(0, 0, 5.5);

const clock = new THREE.Clock();
const simplex = new SimplexNoise();
const simplexAlt = new SimplexNoise();

const POINT_COUNT = 15000;
const positions = new Float32Array(POINT_COUNT * 3);
const velocities = new Float32Array(POINT_COUNT * 3);
const targetPositions = new Float32Array(POINT_COUNT * 3);
const lightTargets = new Float32Array(POINT_COUNT * 3);

const colors = new Float32Array(POINT_COUNT * 3);
const colorA = new THREE.Color('#ff355a');
const colorB = new THREE.Color('#ffa642');

for (let i = 0; i < POINT_COUNT; i++) {
  const idx = i * 3;
  const mix = Math.pow(i / POINT_COUNT, 0.32);
  const tint = colorA.clone().lerp(colorB, mix);
  colors[idx] = tint.r;
  colors[idx + 1] = tint.g;
  colors[idx + 2] = tint.b;

  const u = Math.random() * 2 - 1;
  const theta = Math.random() * Math.PI * 2;
  const r = 2.2 + Math.pow(Math.random(), 0.65) * 0.8;
  const s = Math.sqrt(1 - u * u);

  positions[idx] = r * s * Math.cos(theta);
  positions[idx + 1] = r * u;
  positions[idx + 2] = r * s * Math.sin(theta);

  const lr = 0.25 + Math.random() * 0.7;
  lightTargets[idx] = lr * s * Math.cos(theta);
  lightTargets[idx + 1] = lr * u;
  lightTargets[idx + 2] = lr * s * Math.sin(theta);
}

velocities.fill(0);

targetPositions.set(lightTargets);

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
  gradient.addColorStop(0.0, 'rgba(255,255,255,0.95)');
  gradient.addColorStop(0.2, 'rgba(255,200,180,0.85)');
  gradient.addColorStop(1.0, 'rgba(0,0,0,0)');
  ctx.fillStyle = gradient;
  ctx.fillRect(0, 0, size, size);
  return new THREE.CanvasTexture(canvas);
})();

const material = new THREE.PointsMaterial({
  size: 0.065,
  map: spriteTexture,
  transparent: true,
  depthWrite: false,
  blending: THREE.AdditiveBlending,
  vertexColors: true,
  opacity: 0.92,
});

const particles = new THREE.Points(geometry, material);
particles.frustumCulled = false;
scene.add(particles);

function hash(index, offset = 0.0) {
  const seed = Math.sin((index + offset) * 12.9898) * 43758.5453123;
  return seed - Math.floor(seed);
}

const tmpFlow = { x: 0, y: 0, z: 0 };
const tmpWiggle = { x: 0, y: 0, z: 0 };
const tmpRot = { x: 0, y: 0, z: 0 };

function rotateY(out, x, y, z, angle) {
  const c = Math.cos(angle);
  const s = Math.sin(angle);
  out.x = x * c - z * s;
  out.y = y;
  out.z = x * s + z * c;
  return out;
}

function curlNoise(out, x, y, z, w) {
  const eps = 0.0015;
  const n1 = simplex.noise3d(y + eps, z, w);
  const n2 = simplex.noise3d(y - eps, z, w);
  const a = (n1 - n2) / (2 * eps);

  const n3 = simplex.noise3d(z + eps, w, x);
  const n4 = simplex.noise3d(z - eps, w, x);
  const b = (n3 - n4) / (2 * eps);

  const n5 = simplexAlt.noise3d(w + eps, x, y);
  const n6 = simplexAlt.noise3d(w - eps, x, y);
  const c = (n5 - n6) / (2 * eps);

  let len = Math.sqrt(a * a + b * b + c * c);
  if (len < 1e-6) len = 1e-6;
  out.x = a / len;
  out.y = b / len;
  out.z = c / len;
  return out;
}

function clamp01(value) {
  return Math.min(1, Math.max(0, value));
}

function createGlobeTarget() {
  const out = new Float32Array(POINT_COUNT * 3);
  const offset = 2 / POINT_COUNT;
  const increment = Math.PI * (3 - Math.sqrt(5));
  const radius = 2.24;

  for (let i = 0; i < POINT_COUNT; i++) {
    const y = (i * offset) - 1 + offset / 2;
    const r = Math.sqrt(Math.max(0, 1 - y * y));
    const phi = i * increment;

    const x = Math.cos(phi) * r;
    const z = Math.sin(phi) * r;

    const idx = i * 3;
    out[idx] = x * radius;
    out[idx + 1] = y * radius;
    out[idx + 2] = z * radius;
  }

  return out;
}

const stateSettings = {
  light: {
    settleDuration: 4.0,
    wiggleSpeed: 0.85,
    wigglePowerStart: 0.52,
    wigglePowerEnd: 0.18,
    particleSizeStart: 0.072,
    particleSizeEnd: 0.06,
    scaleStart: 0.82,
    scaleEnd: 0.72,
  },
  human: {
    settleDuration: 5.0,
    wiggleSpeed: 1.88,
    wigglePowerStart: 0.66,
    wigglePowerEnd: 0.24,
    particleSizeStart: 0.07,
    particleSizeEnd: 0.065,
    scaleStart: 1.16,
    scaleEnd: 1.06,
  },
  mask: {
    settleDuration: 5.4,
    wiggleSpeed: 1.95,
    wigglePowerStart: 0.7,
    wigglePowerEnd: 0.28,
    particleSizeStart: 0.071,
    particleSizeEnd: 0.067,
    scaleStart: 1.18,
    scaleEnd: 1.08,
  },
  globe: {
    settleDuration: 6.2,
    wiggleSpeed: 1.4,
    wigglePowerStart: 0.45,
    wigglePowerEnd: 0.2,
    particleSizeStart: 0.068,
    particleSizeEnd: 0.062,
    scaleStart: 0.88,
    scaleEnd: 0.84,
  },
};

const pointer = new THREE.Vector2(0, 0);
const pointerTarget = new THREE.Vector2(0, 0);
let pointerActive = false;

CANVAS.addEventListener('pointermove', (event) => {
  const rect = CANVAS.getBoundingClientRect();
  pointerTarget.x = ((event.clientX - rect.left) / rect.width - 0.5) * 2;
  pointerTarget.y = ((event.clientY - rect.top) / rect.height - 0.5) * -2;
  pointerActive = true;
  document.body.classList.add('hide-hint');
});

CANVAS.addEventListener('pointerleave', () => {
  pointerActive = false;
});

window.addEventListener('resize', () => {
  const { clientWidth, clientHeight } = CONTAINER;
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  renderer.setSize(clientWidth, clientHeight, false);
  camera.aspect = clientWidth / clientHeight;
  camera.updateProjectionMatrix();
});

const loader = new GLTFLoader();
const targets = new Map([
  ['light', lightTargets],
]);

let ready = false;
let pendingRequest = null;
let currentState = 'light';
let elapsedTime = 0;
let stateChangedAt = 0;
let autoCycleEnabled = false;
let autoCycleTimer = 0;
const AUTO_CYCLE_INTERVAL = 10.5;

async function loadTargets() {
  const gltfs = await Promise.all([
    loader.loadAsync('gltf/face2.glb'),
    loader.loadAsync('gltf/suzanne.glb'),
  ]);

  const getMesh = (scene, index) => {
    if (index === 0) {
      return scene.children[1].children[0].children[0].children[0];
    }
    return scene.children[0];
  };

  gltfs.forEach((gltf, index) => {
    const mesh = getMesh(gltf.scene, index);
    mesh.geometry.toNonIndexed();
    mesh.geometry.center();

    if (index === 0) {
      mesh.geometry.rotateX(-Math.PI / 2);
      mesh.geometry.scale(0.13, 0.13, 0.13);
    } else {
      mesh.geometry.scale(1.7, 1.7, 1.7);
    }

    const original = mesh.geometry.attributes.position.array;
    const count = mesh.geometry.attributes.position.count;
    const out = new Float32Array(POINT_COUNT * 3);

    for (let i = 0; i < POINT_COUNT; i++) {
      const sourceIndex = i < count ? i : Math.floor(hash(i, index * 911) * count);
      const src = sourceIndex * 3;
      const dst = i * 3;
      out[dst] = original[src];
      out[dst + 1] = original[src + 1];
      out[dst + 2] = original[src + 2];
    }

    const bounds = new THREE.Box3();
    const temp = new THREE.Vector3();
    for (let i = 0; i < out.length; i += 3) {
      temp.set(out[i], out[i + 1], out[i + 2]);
      bounds.expandByPoint(temp);
    }
    const size = new THREE.Vector3();
    bounds.getSize(size);
    const maxAxis = Math.max(size.x, size.y, size.z) || 1;
    const normalize = 2.9 / maxAxis;
    for (let i = 0; i < out.length; i += 3) {
      out[i] *= normalize;
      out[i + 1] *= normalize;
      out[i + 2] *= normalize;
    }

    if (index === 0) {
      targets.set('human', out);
    } else {
      targets.set('mask', out);
    }
  });

  targets.set('globe', createGlobeTarget());

  ready = true;
  postToParent({ type: 'AWA_SOUL_READY' });

  if (pendingRequest) {
    const { state, options } = pendingRequest;
    pendingRequest = null;
    setSoulState(state, options);
  }
}

loadTargets().catch((error) => {
  console.error('[AWA_SOUL] failed to load targets', error);
  postToParent({ type: 'AWA_SOUL_ERROR', message: String(error) });
});

function setSoulState(state, options = {}) {
  if (!ready) {
    pendingRequest = { state, options };
    return;
  }

  const data = targets.get(state);
  if (!data) {
    console.warn('[AWA_SOUL] unknown state', state);
    return;
  }

  currentState = state;
  if (data.length === targetPositions.length) {
    targetPositions.set(data);
  } else {
    for (let i = 0; i < targetPositions.length; i += 3) {
      const sourceIndex = i % data.length;
      targetPositions[i] = data[sourceIndex];
      targetPositions[i + 1] = data[(sourceIndex + 1) % data.length];
      targetPositions[i + 2] = data[(sourceIndex + 2) % data.length];
    }
  }
  stateChangedAt = elapsedTime;
  autoCycleTimer = 0;

  if (options.immediate) {
    if (data.length === positions.length) {
      positions.set(data);
    } else {
      for (let i = 0; i < positions.length; i += 3) {
        const sourceIndex = i % data.length;
        positions[i] = data[sourceIndex];
        positions[i + 1] = data[(sourceIndex + 1) % data.length];
        positions[i + 2] = data[(sourceIndex + 2) % data.length];
      }
    }
    velocities.fill(0);
    geometry.attributes.position.needsUpdate = true;
  }

  if (state !== 'light') {
    document.body.classList.add('hide-hint');
  }

  postToParent({ type: 'AWA_SOUL_STATE', state });
}

function cycleState() {
  if (!ready) {
    return;
  }

  if (currentState === 'human') {
    setSoulState('mask');
  } else {
    setSoulState('human');
  }
}

function postToParent(message) {
  try {
    window.parent?.postMessage(message, '*');
  } catch (error) {
    console.error('[AWA_SOUL] postMessage failed', error);
  }
}

function update(delta) {
  const settings = stateSettings[currentState] ?? stateSettings.human;
  const morphAge = Math.max(0, elapsedTime - stateChangedAt);
  const settleMix = clamp01(morphAge / settings.settleDuration);

  const wigglePower = THREE.MathUtils.lerp(settings.wigglePowerStart, settings.wigglePowerEnd, settleMix);
  const wiggleSpeed = settings.wiggleSpeed;
  const particleSize = THREE.MathUtils.lerp(settings.particleSizeStart, settings.particleSizeEnd, settleMix);
  const scaleTarget = THREE.MathUtils.lerp(settings.scaleStart, settings.scaleEnd, settleMix);

  if (Math.abs(material.size - particleSize) > 0.0001) {
    material.size = particleSize;
    material.needsUpdate = true;
  }

  const step = delta * 60;

  for (let i = 0; i < POINT_COUNT; i++) {
    const idx = i * 3;

    const px = positions[idx];
    const py = positions[idx + 1];
    const pz = positions[idx + 2];

    const tx = targetPositions[idx];
    const ty = targetPositions[idx + 1];
    const tz = targetPositions[idx + 2];

    const vxPrev = velocities[idx];
    const vyPrev = velocities[idx + 1];
    const vzPrev = velocities[idx + 2];

    const h = hash(i);
    curlNoise(tmpFlow, px * 0.6, py * 0.6, pz * 0.6, elapsedTime * 0.2);
    const flowScale = (h * 0.05 + 0.6) * 1.2;
    const overshootX = vxPrev * flowScale * tmpFlow.x;
    const overshootY = vyPrev * flowScale * tmpFlow.y;
    const overshootZ = vzPrev * flowScale * tmpFlow.z;

    const dx = tx - px;
    const dy = ty - py;
    const dz = tz - pz;
    const dist = Math.sqrt(dx * dx + dy * dy + dz * dz);
    let dirX = 0;
    let dirY = 0;
    let dirZ = 0;
    if (dist > 1e-5) {
      const inv = 1 / dist;
      dirX = dx * inv;
      dirY = dy * inv;
      dirZ = dz * inv;
    }

    const scale = clamp01(dist) * 0.04;
    const speedScale = h * 0.35 + 0.6;
    const speedX = dirX * scale * speedScale;
    const speedY = dirY * scale * speedScale;
    const speedZ = dirZ * scale * speedScale;

    const combinedX = overshootX + speedX;
    const combinedY = overshootY + speedY;
    const combinedZ = overshootZ + speedZ;
    const combinedLen = Math.sqrt(combinedX * combinedX + combinedY * combinedY + combinedZ * combinedZ) || 1e-6;

    rotateY(tmpRot, px * 0.85, py * 0.85, pz * 0.85, elapsedTime * 0.3);
    curlNoise(tmpWiggle, tmpRot.x, tmpRot.y, tmpRot.z, elapsedTime * wiggleSpeed);
    const wiggleX = tmpWiggle.x * wigglePower;
    const wiggleY = tmpWiggle.y * wigglePower;
    const wiggleZ = tmpWiggle.z * wigglePower;

    let newX = combinedX / combinedLen + wiggleX;
    let newY = combinedY / combinedLen + wiggleY;
    let newZ = combinedZ / combinedLen + wiggleZ;

    const newLen = Math.sqrt(newX * newX + newY * newY + newZ * newZ) || 1e-6;
    const velocityScale = combinedLen / newLen;
    newX *= velocityScale;
    newY *= velocityScale;
    newZ *= velocityScale;

    positions[idx] = px + newX * step;
    positions[idx + 1] = py + newY * step;
    positions[idx + 2] = pz + newZ * step;

    velocities[idx] = newX;
    velocities[idx + 1] = newY;
    velocities[idx + 2] = newZ;
  }

  geometry.attributes.position.needsUpdate = true;

  const pointerLerp = pointerActive ? 0.12 : 0.035;
  pointer.x += (pointerTarget.x - pointer.x) * pointerLerp;
  pointer.y += (pointerTarget.y - pointer.y) * pointerLerp;

  particles.rotation.y += (pointer.x * 0.22 - particles.rotation.y) * pointerLerp;
  particles.rotation.x += (pointer.y * 0.16 - particles.rotation.x) * pointerLerp;
  particles.rotation.z += (pointer.x * -0.08 - particles.rotation.z) * pointerLerp;

  const currentScale = particles.scale.x;
  const scaleLerp = currentScale + (scaleTarget - currentScale) * (1 - Math.pow(0.0006, step));
  particles.scale.setScalar(scaleLerp);
}

function animate() {
  const delta = Math.min(clock.getDelta(), 1 / 30);
  elapsedTime += delta;

  if (autoCycleEnabled) {
    autoCycleTimer += delta;
    if (autoCycleTimer > AUTO_CYCLE_INTERVAL) {
      autoCycleTimer = 0;
      cycleState();
    }
  }

  update(delta);
  renderer.render(scene, camera);
  requestAnimationFrame(animate);
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
        setSoulState(data.state, { immediate: data.immediate === true });
      }
      break;
    case 'AWA_SOUL_TRIGGER':
      cycleState();
      break;
    case 'AWA_SOUL_SET_AUTOCYCLE':
      if (typeof data.enabled === 'boolean') {
        autoCycleEnabled = data.enabled;
        autoCycleTimer = 0;
      }
      break;
    default:
      break;
  }
});

postToParent({ type: 'AWA_SOUL_INIT' });
