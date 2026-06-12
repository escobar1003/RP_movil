import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _gameOver = false;
  int _score = 0;
  int _correct = 0;
  int _wrong = 0;
  int _plasticCount = 0;
  int _glassCount = 0;
  int _paperCount = 0;
  int _organicCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('GameChannel', onMessageReceived: _onGameMessage)
      ..setNavigationDelegate(
        NavigationDelegate(onPageFinished: (_) {
          setState(() => _isLoading = false);
        }),
      )
      ..loadHtmlString(_buildGameHtml());
  }

  void _onGameMessage(JavaScriptMessage message) {
    try {
      final data = jsonDecode(message.message) as Map<String, dynamic>;
      switch (data['action'] as String) {
        case 'updateScore':
          setState(() {
            _score = data['score'] as int;
            _correct = data['correct'] as int;
            _wrong = data['wrong'] as int;
          });
          break;
        case 'gameOver':
          setState(() {
            _gameOver = true;
            _score = data['score'] as int;
            _correct = data['correct'] as int;
            _wrong = data['wrong'] as int;
            _plasticCount = data['plastic'] as int;
            _glassCount = data['glass'] as int;
            _paperCount = data['paper'] as int;
            _organicCount = data['organic'] as int;
          });
          break;
        case 'feedback':
          _showFeedback(data['correct'] as bool);
          break;
      }
    } catch (_) {}
  }

  void _showFeedback(bool correct) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(correct ? '+10 puntos!' : '-5 puntos'),
        backgroundColor: correct ? Colors.green : Colors.red,
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  void _sendGameCommand(String command, [Map<String, dynamic>? args]) {
    final json = jsonEncode({'command': command, 'args': args ?? {}});
    _controller.runJavaScript('onFlutterCommand($json)');
  }

  void _restartGame() {
    setState(() {
      _gameOver = false;
      _score = 0;
      _correct = 0;
      _wrong = 0;
      _plasticCount = 0;
      _glassCount = 0;
      _paperCount = 0;
      _organicCount = 0;
    });
    _sendGameCommand('restart');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: _gameOver
            ? null
            : AppBar(
                backgroundColor: Colors.black.withValues(alpha: 0.7),
                elevation: 0,
                title: Text('Puntos: $_score',
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _correct + _wrong > 0
                          ? const Color(0xFF4CAF50)
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_correct}/${_correct + _wrong}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                ],
              ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF4CAF50)),
                    SizedBox(height: 16),
                    Text('Cargando juego 3D...',
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            if (_gameOver) _buildGameOver(),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOver() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8))
            ],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.recycling, size: 56, color: Color(0xFF4CAF50)),
            const SizedBox(height: 8),
            const Text('Juego terminado',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF263238))),
            const SizedBox(height: 4),
            Text('Puntaje: $_score',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4CAF50))),
            const SizedBox(height: 12),
            _statRow(
                const Color(0xFFFBC02D), 'Plástico', _plasticCount),
            _statRow(const Color(0xFF4CAF50), 'Vidrio', _glassCount),
            _statRow(const Color(0xFF2196F3), 'Papel', _paperCount),
            _statRow(const Color(0xFF8D6E63), 'Orgánico', _organicCount),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _restartGame,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver',
                  style: TextStyle(color: Color(0xFF78909C))),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _statRow(Color color, String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text('$label: $count',
            style: const TextStyle(
                fontSize: 14, color: Color(0xFF455A64))),
      ]),
    );
  }

  String _buildGameHtml() {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <script src="https://cdnjs.cloudflare.com/ajax/libs/babylonjs/7.37.0/babylon.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/babylonjs/7.37.0/babylon.gui.min.js"></script>
  <style>
    * { margin:0; padding:0; box-sizing:border-box; }
    html, body { width:100%; height:100%; overflow:hidden; touch-action:none; background:#000; }
    canvas { display:block; width:100vw; height:100vh; touch-action:none; }
    #ui-overlay {
      position:fixed; top:0; left:0; width:100%; height:100%;
      pointer-events:none; z-index:10;
    }
    #joystick-area {
      position:absolute; bottom:30px; left:30px; width:130px; height:130px;
      pointer-events:auto; touch-action:none;
    }
    #joystick-base {
      width:130px; height:130px; border-radius:50%;
      background:rgba(255,255,255,0.15);
      border:2px solid rgba(255,255,255,0.3);
      position:relative;
    }
    #joystick-knob {
      width:50px; height:50px; border-radius:50%;
      background:rgba(255,255,255,0.5);
      position:absolute; top:40px; left:40px;
      transition:none;
    }
    #action-btn {
      position:absolute; bottom:40px; right:40px;
      width:70px; height:70px; border-radius:50%;
      background:rgba(76,175,80,0.7); border:3px solid rgba(76,175,80,0.9);
      color:white; font-size:12px; font-weight:bold;
      display:flex; align-items:center; justify-content:center;
      pointer-events:auto; touch-action:none;
      user-select:none; -webkit-user-select:none;
    }
    #action-btn:active { background:rgba(76,175,80,0.9); }
    #timer-display {
      position:absolute; top:12px; right:12px;
      background:rgba(0,0,0,0.5); color:white;
      padding:6px 14px; border-radius:20px;
      font-family:sans-serif; font-size:16px; font-weight:bold;
    }
    #score-display {
      position:absolute; top:12px; left:12px;
      background:rgba(0,0,0,0.5); color:white;
      padding:6px 14px; border-radius:20px;
      font-family:sans-serif; font-size:16px; font-weight:bold;
    }
    #held-indicator {
      position:absolute; bottom:130px; left:0; width:100%;
      text-align:center; color:white; font-family:sans-serif;
      font-size:14px; font-weight:bold; text-shadow:0 1px 4px rgba(0,0,0,0.5);
    }
    #feedback-overlay {
      position:absolute; top:0; left:0; width:100%; height:100%;
      display:flex; align-items:center; justify-content:center;
      pointer-events:none; opacity:0;
      transition:opacity 0.3s;
      font-family:sans-serif; font-size:32px; font-weight:bold;
      color:white; text-shadow:0 2px 8px rgba(0,0,0,0.5);
    }
  </style>
</head>
<body>
  <canvas id="gameCanvas"></canvas>
  <div id="ui-overlay">
    <div id="timer-display">01:30</div>
    <div id="score-display">Puntos: 0</div>
    <div id="held-indicator"></div>
    <div id="feedback-overlay"></div>
    <div id="joystick-area">
      <div id="joystick-base">
        <div id="joystick-knob"></div>
      </div>
    </div>
    <div id="action-btn">RECOGER</div>
  </div>
  <script>
    const canvas = document.getElementById('gameCanvas');
    const engine = new BABYLON.Engine(canvas, true, { preserveDrawingBuffer: true, stencil: true });

    const scene = new BABYLON.Scene(engine);
    scene.clearColor = new BABYLON.Color4(0.5, 0.8, 1.0, 1.0);

    const camera = new BABYLON.ArcRotateCamera('camera', -Math.PI/4, Math.PI/3, 12, BABYLON.Vector3.Zero(), scene);
    camera.lowerRadiusLimit = 6;
    camera.upperRadiusLimit = 20;
    camera.attachControl(canvas, false);

    const hemiLight = new BABYLON.HemisphericLight('hemi', new BABYLON.Vector3(0, 1, 0), scene);
    hemiLight.intensity = 0.7;
    const dirLight = new BABYLON.DirectionalLight('dir', new BABYLON.Vector3(-0.5, -1, -0.5), scene);
    dirLight.position = new BABYLON.Vector3(5, 10, 5);
    dirLight.intensity = 0.4;

    const groundMat = new BABYLON.StandardMaterial('groundMat', scene);

const ground = BABYLON.MeshBuilder.CreateGround('ground', { width: 24, height: 24 }, scene);

const groundTex = new BABYLON.GridMaterial('groundTex', scene);
groundTex.mainColor = new BABYLON.Color3(0.35, 0.65, 0.25);
groundTex.lineColor = new BABYLON.Color3(0.3, 0.55, 0.2);
groundTex.opacity = 0.3;
ground.material = groundTex;
const pathMat = new BABYLON.StandardMaterial('pathMat', scene);
pathMat.diffuseColor = new BABYLON.Color3(0.6, 0.55, 0.45);
pathMat.specularColor = BABYLON.Color3.Black();

const pathH = BABYLON.MeshBuilder.CreatePlane('pathH', { width: 10, height: 2 }, scene);
pathH.rotation.x = Math.PI / 2;
pathH.position = new BABYLON.Vector3(0, -0.01, 0);
pathH.material = pathMat;

const pathV = BABYLON.MeshBuilder.CreatePlane('pathV', { width: 2, height: 10 }, scene);
pathV.rotation.x = Math.PI / 2;
pathV.position = new BABYLON.Vector3(0, -0.01, 0);
pathV.material = pathMat;
const fenceMat = new BABYLON.StandardMaterial('fenceMat', scene);
fenceMat.diffuseColor = new BABYLON.Color3(0.5, 0.35, 0.2);
fenceMat.specularColor = BABYLON.Color3.Black();

function createFence(x, z, rotY) {
  const f = BABYLON.MeshBuilder.CreateBox('fence', { width: 0.2, height: 0.8, depth: 2 }, scene);
  f.position = new BABYLON.Vector3(x, 0.4, z);
  f.rotation.y = rotY;
  f.material = fenceMat;
  return f;
}
for (let i = -11; i <= 11; i += 2) {
  createFence(i, -11.5, 0);
  createFence(i, 11.5, 0);
  createFence(-11.5, i, Math.PI / 2);
  createFence(11.5, i, Math.PI / 2);
}

function createTree(x, z) {
  const trunk = BABYLON.MeshBuilder.CreateCylinder('trunk', { height: 0.8, diameter: 0.2 }, scene);
  trunk.position = new BABYLON.Vector3(x, 0.4, z);
  const trunkMat = new BABYLON.StandardMaterial('trunkMat', scene);
  trunkMat.diffuseColor = new BABYLON.Color3(0.45, 0.25, 0.1);
  trunk.material = trunkMat;

  const crown = BABYLON.MeshBuilder.CreateSphere('crown', { diameter: 0.8 }, scene);
  crown.position = new BABYLON.Vector3(x, 1.0, z);
  const crownMat = new BABYLON.StandardMaterial('crownMat', scene);
  crownMat.diffuseColor = new BABYLON.Color3(0.2, 0.6, 0.15);
  crown.material = crownMat;
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

const player = BABYLON.MeshBuilder.CreateBox('player', { width: 0.01, height: 0.01, depth: 0.01 }, scene);
playerBody.parent = player;
playerHead.parent = player;
player.position = new BABYLON.Vector3(0, 0, 0);

const playerSpeed = 2.5;

const itemTypes = [
  { name: 'plastic', color: new BABYLON.Color3(1.0, 0.75, 0.0) },
  { name: 'glass', color: new BABYLON.Color3(0.3, 0.7, 0.3) },
  { name: 'paper', color: new BABYLON.Color3(0.2, 0.5, 1.0) },
  { name: 'organic', color: new BABYLON.Color3(0.5, 0.35, 0.2) },
];

const itemShapes = ['sphere', 'box', 'cylinder'];

function spawnItem() {
  const typeIdx = Math.floor(Math.random() * itemTypes.length);
  const shapeIdx = Math.floor(Math.random() * itemShapes.length);
  const type = itemTypes[typeIdx];
  const x = (Math.random() - 0.5) * 18;
  const z = (Math.random() - 0.5) * 18;
  if (Math.abs(x) < 2 && Math.abs(z) < 2) return;

  let mesh;
  const d = 0.2 + Math.random() * 0.15;
  if (itemShapes[shapeIdx] === 'sphere') {
    mesh = BABYLON.MeshBuilder.CreateSphere('item', { diameter: d }, scene);
  } else if (itemShapes[shapeIdx] === 'box') {
    mesh = BABYLON.MeshBuilder.CreateBox('item', { width: d, height: d, depth: d }, scene);
  } else {
    mesh = BABYLON.MeshBuilder.CreateCylinder('item', { height: d * 1.2, diameter: d * 0.8 }, scene);
  }
  const mat = new BABYLON.StandardMaterial('itemMat', scene);
  mat.diffuseColor = type.color;
  mat.specularColor = BABYLON.Color3.Black();
  mesh.material = mat;
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
  const body = BABYLON.MeshBuilder.CreateBox('bin', { width: 0.7, height: 0.6, depth: 0.5 }, scene);
  body.position = new BABYLON.Vector3(x, 0.3, z);
  body.material = mat;
  const lid = BABYLON.MeshBuilder.CreateBox('lid', { width: 0.75, height: 0.05, depth: 0.55 }, scene);
  lid.position = new BABYLON.Vector3(x, 0.65, z);
  const lidMat = mat.clone('lidMat');
  lidMat.diffuseColor = lidMat.diffuseColor.scale(0.7);
  lid.material = lidMat;

  const labelPlane = BABYLON.MeshBuilder.CreatePlane('label', { width: 0.8, height: 0.25 }, scene);
  labelPlane.position = new BABYLON.Vector3(x, 0.9, z);
  const dt = new BABYLON.DynamicTexture('dt', 256, scene, true);
  dt.drawText(binLabels[type], null, null, '32px Arial', 'white', 'transparent', true);
  const labelMat = new BABYLON.StandardMaterial('labelMat', scene);
  labelMat.diffuseTexture = dt;
  labelMat.specularColor = BABYLON.Color3.Black();
  labelMat.useAlphaFromDiffuseTexture = true;
  labelMat.backFaceCulling = false;
  labelPlane.material = labelMat;

  gameState.bins.push({ type, body, lid, center: new BABYLON.Vector3(x, 0.3, z) });
}

createBin(-5.5, 0, 'plastic', binMatPlastic);
createBin(5.5, 0, 'glass', binMatGlass);
createBin(0, -5.5, 'paper', binMatPaper);
createBin(0, 5.5, 'organic', binMatOrganic);

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
});

const camRoot = new BABYLON.TransformNode('camRoot');
camRoot.position = player.position.clone();
const camDist = 6;
const camHeight = 4;
scene.onBeforeRenderObservable.add(() => {
  const p = player.position;
  camRoot.position = BABYLON.Vector3.Lerp(camRoot.position, p, 0.05);
  camera.setTarget(camRoot.position);
  camera.radius = camDist;
  camera.alpha = -Math.PI/4;
  camera.beta = Math.PI/3;
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
      heldItemMesh = BABYLON.MeshBuilder.CreateSphere('heldItem', { diameter: 0.2 }, scene);
      heldItemMesh.material = mat;
      heldItemMesh.parent = player;
      heldItemMesh.position = new BABYLON.Vector3(0, 1.2, 0.3);

      setTimeout(() => respawnItem(itemData), 3000);

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

        heldItemMesh.dispose();
        heldItemMesh = null;
        gameState.hasItem = false;
        gameState.heldItemType = '';
        heldIndicator.textContent = '';

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

    actionBtn.addEventListener('click', performAction);
    actionBtn.addEventListener('touchstart', (e) => {
      e.preventDefault();
      performAction();
    });

    scene.executeWhenReady(() => {
      startGame();
    });
  </script>
</body>
</html>
''';
  }
}
