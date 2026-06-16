function showFatalError(msg) {
  var d = document.createElement('div');
  d.style.cssText = 'position:fixed;top:0;left:0;width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:#111;color:#fff;font-family:sans-serif;font-size:18px;text-align:center;padding:20px;z-index:9999';
  d.textContent = msg;
  document.body.appendChild(d);
  try { GameChannel.postMessage(JSON.stringify({ action: 'error', message: msg })); } catch(e) {}
}

var testCanvas = document.createElement('canvas');
var gl = testCanvas.getContext('webgl') || testCanvas.getContext('experimental-webgl');
if (!gl) {
  showFatalError('WebGL no soportado en este dispositivo');
  throw new Error('WebGL no soportado');
}

if (typeof BABYLON === 'undefined') {
  showFatalError('Error cargando el motor 3D.\nVerifica tu conexión a internet.');
  throw new Error('Babylon.js no disponible');
}

var canvas = document.getElementById('gameCanvas');
var engine = new BABYLON.Engine(canvas, true, { preserveDrawingBuffer: true, stencil: true });

const scene = new BABYLON.Scene(engine);
scene.clearColor = new BABYLON.Color4(0.4, 0.7, 0.95, 1.0);
scene.fogMode = BABYLON.Scene.FOGMODE_EXP;
scene.fogDensity = 0.012;
scene.fogColor = new BABYLON.Color3(0.5, 0.8, 1.0);

const camera = new BABYLON.ArcRotateCamera('camera', -Math.PI/4, Math.PI/3, 12, BABYLON.Vector3.Zero(), scene);
camera.lowerRadiusLimit = 6;
camera.upperRadiusLimit = 20;
camera.attachControl(canvas, false);

const hemiLight = new BABYLON.HemisphericLight('hemi', new BABYLON.Vector3(0, 1, 0), scene);
hemiLight.intensity = 0.6;
hemiLight.groundColor = new BABYLON.Color3(0.4, 0.6, 0.3);
const dirLight = new BABYLON.DirectionalLight('dir', new BABYLON.Vector3(-0.5, -1, -0.5), scene);
dirLight.position = new BABYLON.Vector3(5, 10, 5);
dirLight.intensity = 0.5;
const fillLight = new BABYLON.DirectionalLight('fill', new BABYLON.Vector3(0.5, -0.3, 0.5), scene);
fillLight.position = new BABYLON.Vector3(-3, 5, -3);
fillLight.intensity = 0.2;

const shadowGen = new BABYLON.ShadowGenerator(512, dirLight);
shadowGen.useBlurExponentialShadowMap = true;
shadowGen.blurKernel = 8;
shadowGen.setDarkness(0.3);

const groundDT = new BABYLON.DynamicTexture('gDT', { width: 128, height: 128 }, scene, false);
const gctx = groundDT.getContext();
gctx.fillStyle = '#4a8c3f';
gctx.fillRect(0, 0, 128, 128);
for (let i = 0; i < 300; i++) {
  const gx = Math.random() * 128, gy = Math.random() * 128;
  const gs = 1 + Math.random() * 2;
  gctx.fillStyle = Math.random() > 0.5 ? '#5a9c4f' : '#3a7c2f';
  gctx.fillRect(gx, gy, gs, gs);
}
groundDT.update();

const ground = BABYLON.MeshBuilder.CreateGround('ground', { width: 24, height: 24 }, scene);
const groundTex = new BABYLON.StandardMaterial('groundTex', scene);
groundTex.diffuseTexture = groundDT;
groundTex.specularColor = BABYLON.Color3.Black();
groundTex.diffuseTexture.uScale = 8;
groundTex.diffuseTexture.vScale = 8;
ground.material = groundTex;
shadowGen.addShadowCaster(ground);

const pathMat = new BABYLON.StandardMaterial('pathMat', scene);
pathMat.diffuseColor = new BABYLON.Color3(0.65, 0.58, 0.45);
pathMat.specularColor = BABYLON.Color3.Black();

const pathH = BABYLON.MeshBuilder.CreatePlane('pathH', { width: 10, height: 1.6 }, scene);
pathH.rotation.x = Math.PI / 2;
pathH.position = new BABYLON.Vector3(0, -0.005, 0);
pathH.material = pathMat;

const pathV = BABYLON.MeshBuilder.CreatePlane('pathV', { width: 1.6, height: 10 }, scene);
pathV.rotation.x = Math.PI / 2;
pathV.position = new BABYLON.Vector3(0, -0.005, 0);
pathV.material = pathMat;

const pathEdgeMat = new BABYLON.StandardMaterial('pathEdgeMat', scene);
pathEdgeMat.diffuseColor = new BABYLON.Color3(0.5, 0.45, 0.35);
pathEdgeMat.specularColor = BABYLON.Color3.Black();
const peH = BABYLON.MeshBuilder.CreatePlane('peH', { width: 10.4, height: 0.08 }, scene);
peH.rotation.x = Math.PI / 2; peH.position = new BABYLON.Vector3(0, -0.003, -0.85); peH.material = pathEdgeMat;
const peH2 = BABYLON.MeshBuilder.CreatePlane('peH2', { width: 10.4, height: 0.08 }, scene);
peH2.rotation.x = Math.PI / 2; peH2.position = new BABYLON.Vector3(0, -0.003, 0.85); peH2.material = pathEdgeMat;
const peV = BABYLON.MeshBuilder.CreatePlane('peV', { width: 0.08, height: 10.4 }, scene);
peV.rotation.x = Math.PI / 2; peV.position = new BABYLON.Vector3(-0.85, -0.003, 0); peV.material = pathEdgeMat;
const peV2 = BABYLON.MeshBuilder.CreatePlane('peV2', { width: 0.08, height: 10.4 }, scene);
peV2.rotation.x = Math.PI / 2; peV2.position = new BABYLON.Vector3(0.85, -0.003, 0); peV2.material = pathEdgeMat;
const fenceMat = new BABYLON.StandardMaterial('fenceMat', scene);
fenceMat.diffuseColor = new BABYLON.Color3(0.6, 0.4, 0.2);
fenceMat.specularColor = new BABYLON.Color3(0.1, 0.1, 0.1);
const fencePostMat = new BABYLON.StandardMaterial('fencePostMat', scene);
fencePostMat.diffuseColor = new BABYLON.Color3(0.5, 0.35, 0.15);
fencePostMat.specularColor = BABYLON.Color3(0.05, 0.05, 0.05);

function createFence(x, z, rotY) {
  const rail = BABYLON.MeshBuilder.CreateBox('fence', { width: 0.12, height: 0.12, depth: 2 }, scene);
  rail.position = new BABYLON.Vector3(x, 0.55, z);
  rail.rotation.y = rotY;
  rail.material = fenceMat;
  const rail2 = BABYLON.MeshBuilder.CreateBox('fence2', { width: 0.1, height: 0.1, depth: 1.8 }, scene);
  rail2.position = new BABYLON.Vector3(x, 0.25, z);
  rail2.rotation.y = rotY;
  rail2.material = fenceMat;
  const post = BABYLON.MeshBuilder.CreateBox('post', { width: 0.14, height: 0.7, depth: 0.14 }, scene);
  post.position = new BABYLON.Vector3(x, 0.35, z);
  post.rotation.y = rotY;
  post.material = fencePostMat;
  const postTop = BABYLON.MeshBuilder.CreateBox('postTop', { width: 0.18, height: 0.06, depth: 0.18 }, scene);
  postTop.position = new BABYLON.Vector3(x, 0.7, z);
  postTop.rotation.y = rotY;
  postTop.material = fencePostMat;
  shadowGen.addShadowCaster(rail);
  shadowGen.addShadowCaster(rail2);
  shadowGen.addShadowCaster(post);
}
for (let i = -11; i <= 11; i += 2) {
  createFence(i, -11.5, 0);
  createFence(i, 11.5, 0);
  createFence(-11.5, i, Math.PI / 2);
  createFence(11.5, i, Math.PI / 2);
}

function createTree(x, z) {
  const trunk = BABYLON.MeshBuilder.CreateCylinder('trunk', { height: 1.0, diameterTop: 0.08, diameterBottom: 0.18 }, scene);
  trunk.position = new BABYLON.Vector3(x, 0.5, z);
  const trunkMat = new BABYLON.StandardMaterial('trunkMat', scene);
  trunkMat.diffuseColor = new BABYLON.Color3(0.5, 0.28, 0.12);
  trunkMat.specularColor = BABYLON.Color3(0.05, 0.05, 0.05);
  trunk.material = trunkMat;

  for (let b = 0; b < 3; b++) {
    const angle = (b / 3) * Math.PI * 2;
    const br = BABYLON.MeshBuilder.CreateCylinder('br', { height: 0.3, diameter: 0.03 }, scene);
    br.position = new BABYLON.Vector3(x + Math.cos(angle) * 0.12, 0.4 + b * 0.25, z + Math.sin(angle) * 0.12);
    br.rotation.x = Math.PI / 5;
    br.rotation.y = angle;
    br.material = trunkMat;
  }

  const c1 = BABYLON.MeshBuilder.CreateCylinder('c1', { height: 0.4, diameterTop: 0, diameterBottom: 0.7 }, scene);
  c1.position = new BABYLON.Vector3(x, 1.0, z);
  const cm1 = new BABYLON.StandardMaterial('cm1', scene);
  cm1.diffuseColor = new BABYLON.Color3(0.15, 0.55, 0.05);
  cm1.specularColor = BABYLON.Color3.Black();
  c1.material = cm1;

  const c2 = BABYLON.MeshBuilder.CreateCylinder('c2', { height: 0.35, diameterTop: 0, diameterBottom: 0.55 }, scene);
  c2.position = new BABYLON.Vector3(x, 1.3, z);
  const cm2 = new BABYLON.StandardMaterial('cm2', scene);
  cm2.diffuseColor = new BABYLON.Color3(0.1, 0.5, 0.0);
  cm2.specularColor = BABYLON.Color3.Black();
  c2.material = cm2;

  shadowGen.addShadowCaster(trunk);
  shadowGen.addShadowCaster(c1);
  shadowGen.addShadowCaster(c2);
}
createTree(-9, -9);
createTree(9, -9);
createTree(-9, 9);
createTree(9, 9);
createTree(-9, 5);
createTree(9, 5);

const gameState = {
  score: 0, correct: 0, wrong: 0,
  plastic: 0, glass: 0, paper: 0, organic: 0,
  timeLeft: 90, isPlaying: false, isGameOver: false,
  moveX: 0, moveY: 0, hasItem: false, heldItemType: '',
  items: [], bins: [],
};

const playerMat = new BABYLON.StandardMaterial('playerMat', scene);
playerMat.diffuseColor = new BABYLON.Color3(0.1, 0.4, 0.8);
playerMat.specularColor = new BABYLON.Color3(0.2, 0.2, 0.2);

const playerBody = BABYLON.MeshBuilder.CreateCylinder('pBody', { height: 0.7, diameter: 0.35 }, scene);
playerBody.position = new BABYLON.Vector3(0, 0.6, 0);
playerBody.material = playerMat;

const playerHead = BABYLON.MeshBuilder.CreateSphere('pHead', { diameter: 0.2 }, scene);
playerHead.position = new BABYLON.Vector3(0, 1.0, 0);
const headMat = new BABYLON.StandardMaterial('headMat', scene);
headMat.diffuseColor = new BABYLON.Color3(1.0, 0.85, 0.65);
playerHead.material = headMat;

const armMat = new BABYLON.StandardMaterial('armMat', scene);
armMat.diffuseColor = new BABYLON.Color3(0.15, 0.5, 0.9);
armMat.specularColor = BABYLON.Color3(0.1, 0.1, 0.1);

const leftArm = BABYLON.MeshBuilder.CreateCylinder('lArm', { height: 0.4, diameter: 0.05 }, scene);
leftArm.position = new BABYLON.Vector3(-0.25, 0.75, 0);
leftArm.rotation.z = 0.2;
leftArm.material = armMat;

const rightArm = BABYLON.MeshBuilder.CreateCylinder('rArm', { height: 0.4, diameter: 0.05 }, scene);
rightArm.position = new BABYLON.Vector3(0.25, 0.75, 0);
rightArm.rotation.z = -0.2;
rightArm.material = armMat;

const legMat = new BABYLON.StandardMaterial('legMat', scene);
legMat.diffuseColor = new BABYLON.Color3(0.2, 0.2, 0.25);
legMat.specularColor = BABYLON.Color3(0.05, 0.05, 0.05);

const leftLeg = BABYLON.MeshBuilder.CreateCylinder('lLeg', { height: 0.3, diameter: 0.055 }, scene);
leftLeg.position = new BABYLON.Vector3(-0.1, 0.15, 0);
leftLeg.material = legMat;

const rightLeg = BABYLON.MeshBuilder.CreateCylinder('rLeg', { height: 0.3, diameter: 0.055 }, scene);
rightLeg.position = new BABYLON.Vector3(0.1, 0.15, 0);
rightLeg.material = legMat;

const player = BABYLON.MeshBuilder.CreateBox('player', { width: 0.01, height: 0.01, depth: 0.01 }, scene);
playerBody.parent = player;
playerHead.parent = player;
leftArm.parent = player;
rightArm.parent = player;
leftLeg.parent = player;
rightLeg.parent = player;
player.position = new BABYLON.Vector3(0, 0, 0);

shadowGen.addShadowCaster(playerBody);
shadowGen.addShadowCaster(playerHead);

const playerSpeed = 2.5;

const itemTypes = [
  { name: 'plastic', color: new BABYLON.Color3(1.0, 0.75, 0.0) },
  { name: 'glass', color: new BABYLON.Color3(0.3, 0.7, 0.3) },
  { name: 'paper', color: new BABYLON.Color3(0.2, 0.5, 1.0) },
  { name: 'organic', color: new BABYLON.Color3(0.5, 0.35, 0.2) },
];

const itemShapes = ['sphere', 'box', 'cylinder'];

function createItemMesh(typeName, color) {
  const d = 0.2 + Math.random() * 0.1;
  const mat = new BABYLON.StandardMaterial('itemMat', scene);
  mat.diffuseColor = color;
  mat.specularColor = BABYLON.Color3.Black();
  let mesh;
  switch (typeName) {
    case 'plastic':
      mesh = BABYLON.MeshBuilder.CreateCylinder('item', { height: d * 1.6, diameter: d * 0.6 }, scene);
      break;
    case 'glass':
      mesh = BABYLON.MeshBuilder.CreateSphere('item', { diameter: d }, scene);
      break;
    case 'paper':
      mesh = BABYLON.MeshBuilder.CreateBox('item', { width: d * 0.8, height: d * 0.7, depth: d * 0.6 }, scene);
      break;
    case 'organic':
      mesh = BABYLON.MeshBuilder.CreateCylinder('item', { height: d * 0.8, diameterTop: 0, diameterBottom: d * 0.6 }, scene);
      break;
    default:
      mesh = BABYLON.MeshBuilder.CreateSphere('item', { diameter: d }, scene);
  }
  mesh.material = mat;
  return mesh;
}

function spawnItem() {
  const typeIdx = Math.floor(Math.random() * itemTypes.length);
  const type = itemTypes[typeIdx];
  const x = (Math.random() - 0.5) * 18;
  const z = (Math.random() - 0.5) * 18;
  if (Math.abs(x) < 2 && Math.abs(z) < 2) return;

  const mesh = createItemMesh(type.name, type.color);
  mesh.position = new BABYLON.Vector3(x, 0.1, z);

  gameState.items.push({
    mesh: mesh,
    type: type.name,
    collected: false,
  });
}

for (let i = 0; i < 12; i++) spawnItem();

const binMatPlastic = new BABYLON.StandardMaterial('binMatP', scene);
binMatPlastic.diffuseColor = new BABYLON.Color3(1.0, 0.75, 0.0);
const binMatGlass = new BABYLON.StandardMaterial('binMatG', scene);
binMatGlass.diffuseColor = new BABYLON.Color3(0.3, 0.7, 0.3);
const binMatPaper = new BABYLON.StandardMaterial('binMatPa', scene);
binMatPaper.diffuseColor = new BABYLON.Color3(0.2, 0.5, 1.0);
const binMatOrganic = new BABYLON.StandardMaterial('binMatO', scene);
binMatOrganic.diffuseColor = new BABYLON.Color3(0.5, 0.35, 0.2);

const binLabels = { plastic: 'PLASTICO', glass: 'VIDRIO', paper: 'PAPEL', organic: 'ORGANICO' };

function createBin(x, z, type, mat) {
  const rimMat = mat.clone('rimMat');
  rimMat.diffuseColor = rimMat.diffuseColor.scale(0.6);

  const body = BABYLON.MeshBuilder.CreateBox('bin', { width: 0.7, height: 0.55, depth: 0.5 }, scene);
  body.position = new BABYLON.Vector3(x, 0.275, z);
  body.material = mat;
  const rim = BABYLON.MeshBuilder.CreateBox('rim', { width: 0.74, height: 0.06, depth: 0.54 }, scene);
  rim.position = new BABYLON.Vector3(x, 0.56, z);
  rim.material = rimMat;

  const lid = BABYLON.MeshBuilder.CreateBox('lid', { width: 0.78, height: 0.06, depth: 0.58 }, scene);
  lid.position = new BABYLON.Vector3(x, 0.68, z);
  const lidMat = mat.clone('lidMat');
  lidMat.diffuseColor = lidMat.diffuseColor.scale(0.7);
  lid.material = lidMat;

  const handle = BABYLON.MeshBuilder.CreateBox('handle', { width: 0.35, height: 0.04, depth: 0.04 }, scene);
  handle.position = new BABYLON.Vector3(x, 0.75, -0.3);
  handle.material = lidMat;

  const labelMat = new BABYLON.StandardMaterial('labelMat', scene);
  labelMat.specularColor = BABYLON.Color3.Black();
  labelMat.useAlphaFromDiffuseTexture = true;
  labelMat.backFaceCulling = false;
  const dt = new BABYLON.DynamicTexture('dt', 256, scene, true);
  const iconColor = type === 'plastic' ? '#FFC107' : type === 'glass' ? '#4CAF50' : type === 'paper' ? '#2196F3' : '#8D6E63';
  dt.drawText(binLabels[type], null, null, '28px Arial bold', iconColor, 'transparent', true);
  labelMat.diffuseTexture = dt;
  const labelBg = BABYLON.MeshBuilder.CreatePlane('labelBg', { width: 0.55, height: 0.24 }, scene);
  labelBg.position = new BABYLON.Vector3(x, 0.32, 0.252);
  labelBg.material = labelMat;

  const stripeMat = new BABYLON.StandardMaterial('stripeMat', scene);
  stripeMat.diffuseColor = BABYLON.Color3.FromHexString(iconColor);
  stripeMat.specularColor = BABYLON.Color3.Black();
  const stripe = BABYLON.MeshBuilder.CreateBox('stripe', { width: 0.72, height: 0.04, depth: 0.52 }, scene);
  stripe.position = new BABYLON.Vector3(x, 0.12, z);
  stripe.material = stripeMat;

  shadowGen.addShadowCaster(body);
  shadowGen.addShadowCaster(lid);

  gameState.bins.push({ type, body, lid, center: new BABYLON.Vector3(x, 0.3, z) });
}

createBin(-5.5, 0, 'plastic', binMatPlastic);
createBin(5.5, 0, 'glass', binMatGlass);
createBin(0, -5.5, 'paper', binMatPaper);
createBin(0, 5.5, 'organic', binMatOrganic);

const flowerMat = new BABYLON.StandardMaterial('flowerMat', scene);
flowerMat.diffuseColor = new BABYLON.Color3(1, 0.2, 0.3);
flowerMat.specularColor = BABYLON.Color3.Black();
const flowerMat2 = new BABYLON.StandardMaterial('flowerMat2', scene);
flowerMat2.diffuseColor = new BABYLON.Color3(1, 0.8, 0.1);
flowerMat2.specularColor = BABYLON.Color3.Black();
const flowerMat3 = new BABYLON.StandardMaterial('flowerMat3', scene);
flowerMat3.diffuseColor = new BABYLON.Color3(1, 0.4, 0.8);
flowerMat3.specularColor = BABYLON.Color3.Black();
const stemMat = new BABYLON.StandardMaterial('stemMat', scene);
stemMat.diffuseColor = new BABYLON.Color3(0.2, 0.5, 0.1);

function createFlower(x, z, fm) {
  const stem = BABYLON.MeshBuilder.CreateCylinder('stem', { height: 0.25, diameter: 0.015 }, scene);
  stem.position = new BABYLON.Vector3(x, 0.125, z);
  stem.material = stemMat;
  const head = BABYLON.MeshBuilder.CreateSphere('fh', { diameter: 0.08 }, scene);
  head.position = new BABYLON.Vector3(x, 0.28, z);
  head.material = fm;
}
const fMat = [flowerMat, flowerMat2, flowerMat3];
for (let f = 0; f < 12; f++) {
  const fx = -10.5 + Math.random() * 20;
  const fz = -10.5 + Math.random() * 20;
  if (Math.abs(fx) < 3 && Math.abs(fz) < 3) continue;
  if (Math.abs(fx) < 6.5 && Math.abs(fz) < 1.5) continue;
  if (Math.abs(fx) < 1.5 && Math.abs(fz) < 6.5) continue;
  createFlower(fx, fz, fMat[f % 3]);
}

const bushMat = new BABYLON.StandardMaterial('bushMat', scene);
bushMat.diffuseColor = new BABYLON.Color3(0.15, 0.5, 0.08);
bushMat.specularColor = BABYLON.Color3.Black();
function createBush(x, z) {
  const b1 = BABYLON.MeshBuilder.CreateSphere('bush1', { diameter: 0.5 }, scene);
  b1.position = new BABYLON.Vector3(x, 0.25, z);
  b1.material = bushMat;
  const b2 = BABYLON.MeshBuilder.CreateSphere('bush2', { diameter: 0.35 }, scene);
  b2.position = new BABYLON.Vector3(x + 0.2, 0.15, z + 0.15);
  b2.material = bushMat;
  const b3 = BABYLON.MeshBuilder.CreateSphere('bush3', { diameter: 0.35 }, scene);
  b3.position = new BABYLON.Vector3(x - 0.15, 0.15, z - 0.2);
  b3.material = bushMat;
  shadowGen.addShadowCaster(b1);
}
createBush(-10, -5);
createBush(10, -5);
createBush(-10, 5);
createBush(10, 5);

const lampPostMat = new BABYLON.StandardMaterial('lampPostMat', scene);
lampPostMat.diffuseColor = new BABYLON.Color3(0.3, 0.3, 0.3);
lampPostMat.specularColor = new BABYLON.Color3(0.2, 0.2, 0.2);
function createLampPost(x, z) {
  const pole = BABYLON.MeshBuilder.CreateCylinder('pole', { height: 0.8, diameter: 0.04 }, scene);
  pole.position = new BABYLON.Vector3(x, 0.4, z);
  pole.material = lampPostMat;
  const arm = BABYLON.MeshBuilder.CreateBox('lampArm', { width: 0.15, height: 0.025, depth: 0.025 }, scene);
  arm.position = new BABYLON.Vector3(x, 0.8, z - 0.1);
  arm.material = lampPostMat;
  const globe = BABYLON.MeshBuilder.CreateSphere('globe', { diameter: 0.06 }, scene);
  globe.position = new BABYLON.Vector3(x, 0.83, z - 0.18);
  const globeMat = new BABYLON.StandardMaterial('globeMat', scene);
  globeMat.diffuseColor = new BABYLON.Color3(1, 0.95, 0.6);
  globeMat.specularColor = BABYLON.Color3.Black();
  globe.material = globeMat;
  shadowGen.addShadowCaster(pole);
}
createLampPost(-10.5, -10.5);
createLampPost(10.5, -10.5);
createLampPost(-10.5, 10.5);
createLampPost(10.5, 10.5);

scene.onBeforeRenderObservable.add(() => {
  if (!gameState.isPlaying) return;
  const dt = engine.getDeltaTime() / 1000;
  const mx = gameState.moveX || 0;
  const my = gameState.moveY || 0;
  if (mx !== 0 || my !== 0) {
    const len = Math.sqrt(mx*mx + my*my);
    const nx = mx / len;
    const ny = my / len;
    const angle = Math.atan2(nx, ny);
    player.rotation.y = angle;
    const speed = Math.min(len, 1) * playerSpeed * dt;
    const newX = player.position.x + nx * speed;
    const newZ = player.position.z + ny * speed;
    if (Math.abs(newX) < 11) player.position.x = newX;
    if (Math.abs(newZ) < 11) player.position.z = newZ;
  }

  if (heldItemMesh) {
    heldItemMesh.rotation.y += dt * 2;
    heldItemMesh.position.y = 1.15 + Math.sin(Date.now() / 300) * 0.03;
  }
});

const camRoot = new BABYLON.TransformNode('camRoot');
camRoot.position = player.position.clone();
const camDist = 6;
const camHeight = 4;
let highlightRing = null;
let lastHighlightedBin = null;

scene.onBeforeRenderObservable.add(() => {
  const p = player.position;
  camRoot.position = BABYLON.Vector3.Lerp(camRoot.position, p, 0.05);
  camera.setTarget(camRoot.position);
  camera.radius = camDist;
  camera.alpha = -Math.PI/4;
  camera.beta = Math.PI/3;

  if (gameState.hasItem) {
    let closestBin = null;
    let closestDist = 4;
    for (const bin of gameState.bins) {
      const dist = BABYLON.Vector3.Distance(p, bin.center);
      if (dist < closestDist) { closestDist = dist; closestBin = bin; }
    }
    if (closestBin !== lastHighlightedBin) {
      if (highlightRing) { highlightRing.dispose(); highlightRing = null; }
      if (closestBin) {
        highlightRing = BABYLON.MeshBuilder.CreateTorus('ring', { diameter: 0.9, thickness: 0.03 }, scene);
        highlightRing.position = closestBin.center.clone();
        highlightRing.position.y += 0.02;
        const ringMat = new BABYLON.StandardMaterial('ringMat', scene);
        ringMat.diffuseColor = BABYLON.Color3.FromHexString('#FFD700');
        ringMat.alpha = 0.6;
        ringMat.specularColor = BABYLON.Color3.Black();
        highlightRing.material = ringMat;
      }
      lastHighlightedBin = closestBin;
    }
  } else {
    if (highlightRing) { highlightRing.dispose(); highlightRing = null; lastHighlightedBin = null; }
  }
});

let timerInterval = null;
const feedbackEl = document.getElementById('feedback-overlay');
const timerEl = document.getElementById('timer-display');
const scoreEl = document.getElementById('score-display');
const heldIndicator = document.getElementById('held-indicator');

function updateUI() {
  const mins = Math.floor(gameState.timeLeft / 60);
  const secs = Math.floor(gameState.timeLeft % 60);
  timerEl.textContent = mins.toString().padStart(2,'0') + ':' + secs.toString().padStart(2,'0');
  scoreEl.textContent = 'Puntos: ' + gameState.score;
}

function showFeedback(correct) {
  feedbackEl.textContent = correct ? 'Correcto!' : 'Incorrecto';
  feedbackEl.style.color = correct ? '#4CAF50' : '#F44336';
  feedbackEl.style.opacity = '1';
  setTimeout(() => { feedbackEl.style.opacity = '0'; }, 600);
}

function notifyFlutter(action, data) {
  try {
    GameChannel.postMessage(JSON.stringify(Object.assign({ action: action }, data)));
  } catch(e) {}
}

function startTimer() {
  if (timerInterval) return;
  timerInterval = setInterval(() => {
    if (!gameState.isPlaying) return;
    gameState.timeLeft--;
    updateUI();
    if (gameState.timeLeft <= 0) {
      gameOver();
    }
  }, 1000);
}

function gameOver() {
  gameState.isPlaying = false;
  gameState.isGameOver = true;
  clearInterval(timerInterval);
  timerInterval = null;
  notifyFlutter('gameOver', {
    score: gameState.score,
    correct: gameState.correct,
    wrong: gameState.wrong,
    plastic: gameState.plastic,
    glass: gameState.glass,
    paper: gameState.paper,
    organic: gameState.organic,
  });
}

function startGame() {
  gameState.isPlaying = true;
  startTimer();
}

function onFlutterCommand(data) {
  if (data.command === 'restart') {
    gameState.score = 0;
    gameState.correct = 0;
    gameState.wrong = 0;
    gameState.plastic = 0;
    gameState.glass = 0;
    gameState.paper = 0;
    gameState.organic = 0;
    gameState.timeLeft = 90;
    gameState.isPlaying = false;
    gameState.isGameOver = false;
    clearInterval(timerInterval);
    timerInterval = null;
    updateUI();
    scene.dispose();
    location.reload();
  }
}
window.onFlutterCommand = onFlutterCommand;

engine.runRenderLoop(() => scene.render());
window.addEventListener('resize', () => engine.resize());
setTimeout(() => engine.resize(), 100);

canvas.addEventListener('contextmenu', (e) => e.preventDefault());

const joystickArea = document.getElementById('joystick-area');
const joystickKnob = document.getElementById('joystick-knob');
const actionBtn = document.getElementById('action-btn');
let joystickActive = false;
let joystickTouchId = null;

function handleJoystickStart(touch) {
  joystickActive = true;
  joystickTouchId = touch.identifier;
}
function handleJoystickMove(touch) {
  if (touch.identifier !== joystickTouchId) return;
  const rect = joystickArea.getBoundingClientRect();
  const cx = rect.left + rect.width/2;
  const cy = rect.top + rect.height/2;
  let dx = touch.clientX - cx;
  let dy = touch.clientY - cy;
  const maxDist = rect.width/2 - 25;
  const dist = Math.sqrt(dx*dx + dy*dy);
  if (dist > maxDist) { dx = dx/dist*maxDist; dy = dy/dist*maxDist; }
  joystickKnob.style.transform = 'translate('+dx+'px, '+dy+'px)';
  gameState.moveX = dx/maxDist;
  gameState.moveY = -dy/maxDist;
}
function handleJoystickEnd() {
  joystickActive = false;
  joystickTouchId = null;
  joystickKnob.style.transform = 'translate(0px, 0px)';
  gameState.moveX = 0;
  gameState.moveY = 0;
}

joystickArea.addEventListener('touchstart', (e) => {
  e.preventDefault();
  handleJoystickStart(e.changedTouches[0]);
});
joystickArea.addEventListener('touchmove', (e) => {
  e.preventDefault();
  handleJoystickMove(e.changedTouches[0]);
});
joystickArea.addEventListener('touchend', (e) => {
  e.preventDefault();
  handleJoystickEnd();
});
joystickArea.addEventListener('touchcancel', (e) => {
  e.preventDefault();
  handleJoystickEnd();
});

let heldItemMesh = null;

function respawnItem(itemData) {
  const x = (Math.random() - 0.5) * 18;
  const z = (Math.random() - 0.5) * 18;
  if (Math.abs(x) < 2 && Math.abs(z) < 2) { respawnItem(itemData); return; }
  itemData.collected = false;
  itemData.mesh.position = new BABYLON.Vector3(x, 0.1, z);
  itemData.mesh.setEnabled(true);
}

function pickUpItem(itemData) {
  itemData.collected = true;
  itemData.mesh.setEnabled(false);
  gameState.hasItem = true;
  gameState.heldItemType = itemData.type;

  const mat = itemData.mesh.material.clone('heldMat');
  heldItemMesh = createItemMesh(itemData.type, mat.diffuseColor);
  heldItemMesh.scaling = new BABYLON.Vector3(0.6, 0.6, 0.6);
  heldItemMesh.parent = player;
  heldItemMesh.position = new BABYLON.Vector3(0, 1.15, 0.3);
  heldItemMesh.material = mat;

  playerMat.emissiveColor = new BABYLON.Color3(0.2, 0.4, 0.8);

  setTimeout(() => {
    playerMat.emissiveColor = BABYLON.Color3.Black();
    respawnItem(itemData);
  }, 3000);

  heldIndicator.textContent = 'Sosteniendo: ' + itemData.type.toUpperCase();
  showFeedback(true);
}

function dropItemOnBin() {
  if (!gameState.hasItem || !heldItemMesh) return;

  let closestBin = null;
  let closestDist = 2.0;
  for (const bin of gameState.bins) {
    const dist = BABYLON.Vector3.Distance(player.position, bin.center);
    if (dist < closestDist) {
      closestDist = dist;
      closestBin = bin;
    }
  }

  if (closestBin) {
    const correct = gameState.heldItemType === closestBin.type;
    if (correct) {
      gameState.score += 10;
      gameState.correct++;
    } else {
      gameState.score = Math.max(0, gameState.score - 5);
      gameState.wrong++;
    }

    if (gameState.heldItemType === 'plastic') gameState.plastic++;
    else if (gameState.heldItemType === 'glass') gameState.glass++;
    else if (gameState.heldItemType === 'paper') gameState.paper++;
    else if (gameState.heldItemType === 'organic') gameState.organic++;

    showFloatText(closestBin.body.position, correct ? '+10' : '-5', correct);
    spawnParticles(closestBin.body.position, correct);
    animateBinLid(closestBin);

    heldItemMesh.dispose();
    heldItemMesh = null;
    gameState.hasItem = false;
    gameState.heldItemType = '';
    heldIndicator.textContent = '';
    playerMat.emissiveColor = BABYLON.Color3.Black();

    updateUI();
    notifyFlutter('updateScore', {
      score: gameState.score,
      correct: gameState.correct,
      wrong: gameState.wrong,
    });
    showFeedback(correct);
  } else {
    heldItemMesh.dispose();
    heldItemMesh = null;
    gameState.hasItem = false;
    gameState.heldItemType = '';
    playerMat.emissiveColor = BABYLON.Color3.Black();
    showFeedback(false);
  }
}

function performAction() {
  if (!gameState.isPlaying || gameState.isGameOver) return;

  if (gameState.hasItem) {
    dropItemOnBin();
    return;
  }

  let closest = null;
  let closestDist = 2.5;
  for (const item of gameState.items) {
    if (item.collected) continue;
    const dist = BABYLON.Vector3.Distance(player.position, item.mesh.position);
    if (dist < closestDist) {
      closestDist = dist;
      closest = item;
    }
  }
  if (closest) {
    pickUpItem(closest);
  }
}

function showFloatText(position, text, isGood) {
  const dt = new BABYLON.DynamicTexture('floatDt', 128, scene, true);
  dt.drawText(text, null, null, '48px Arial', isGood ? '#4CAF50' : '#F44336', 'transparent', true);
  const plane = BABYLON.MeshBuilder.CreatePlane('floatText', { width: 1, height: 0.5 }, scene);
  plane.position = position.clone();
  plane.position.y += 1;
  const mat = new BABYLON.StandardMaterial('floatMat', scene);
  mat.diffuseTexture = dt;
  mat.specularColor = BABYLON.Color3.Black();
  mat.useAlphaFromDiffuseTexture = true;
  mat.backFaceCulling = false;
  plane.material = mat;
  const startY = plane.position.y;
  let elapsed = 0;
  const obs = scene.onBeforeRenderObservable.add((_, state) => {
    elapsed += state.deltaTime / 1000;
    plane.position.y = startY + elapsed * 1.5;
    plane.rotation.x = Math.sin(elapsed * 3) * 0.05;
    mat.alpha = Math.max(0, 1 - elapsed / 1.2);
    if (elapsed > 1.2) {
      plane.dispose();
      dt.dispose();
      scene.onBeforeRenderObservable.remove(obs);
    }
  });
}

function spawnParticles(position, isGood) {
  const count = 12;
  const color = isGood ? new BABYLON.Color4(0.3, 0.8, 0.3, 1) : new BABYLON.Color4(0.8, 0.3, 0.3, 1);
  for (let i = 0; i < count; i++) {
    const box = BABYLON.MeshBuilder.CreateBox('particle', { width: 0.05, height: 0.05, depth: 0.05 }, scene);
    box.position = position.clone();
    box.position.y += 0.5;
    const pMat = new BABYLON.StandardMaterial('pMat', scene);
    pMat.diffuseColor = new BABYLON.Color3(color.r, color.g, color.b);
    pMat.specularColor = BABYLON.Color3.Black();
    box.material = pMat;
    const vx = (Math.random() - 0.5) * 3;
    const vy = 2 + Math.random() * 2;
    const vz = (Math.random() - 0.5) * 3;
    let life = 0;
    const obs = scene.onBeforeRenderObservable.add((_, state) => {
      life += state.deltaTime / 1000;
      box.position.x += vx * state.deltaTime / 1000;
      box.position.y += vy * state.deltaTime / 1000 - 9.8 * life * state.deltaTime / 1000;
      box.position.z += vz * state.deltaTime / 1000;
      box.rotation.x += state.deltaTime / 1000 * 5;
      box.rotation.z += state.deltaTime / 1000 * 5;
      pMat.alpha = Math.max(0, 1 - life / 1.0);
      if (life > 1.0) {
        box.dispose();
        scene.onBeforeRenderObservable.remove(obs);
      }
    });
  }
}

function animateBinLid(bin) {
  bin.lid.position.y = bin.body.position.y + 0.45;
  setTimeout(() => {
    bin.lid.position.y = bin.body.position.y + 0.65;
  }, 400);
}

actionBtn.addEventListener('click', performAction);
actionBtn.addEventListener('touchstart', (e) => {
  e.preventDefault();
  performAction();
});

scene.executeWhenReady(() => {
  startGame();
});
