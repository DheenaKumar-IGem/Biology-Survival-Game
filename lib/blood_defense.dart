import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum BloodDefenseTowerType {
  macrophageNest(
    title: 'Macrophage Nest',
    description: 'Reliable single-target defense that pops one cell at a time.',
    cost: 25,
    color: Color(0xFF95D5B2),
  ),
  plateletSnare(
    title: 'Platelet Snare',
    description: 'Sticky clot shots slow red blood cells while dealing light damage.',
    cost: 30,
    color: Color(0xFFFFD166),
  ),
  enzymeGland(
    title: 'Enzyme Gland',
    description: 'Burst damage that splashes nearby red blood cells.',
    cost: 42,
    color: Color(0xFF90E0EF),
  );

  const BloodDefenseTowerType({
    required this.title,
    required this.description,
    required this.cost,
    required this.color,
  });

  final String title;
  final String description;
  final int cost;
  final Color color;
}

class BloodDefensePrototypeScreen extends StatefulWidget {
  const BloodDefensePrototypeScreen({super.key});

  @override
  State<BloodDefensePrototypeScreen> createState() => _BloodDefensePrototypeScreenState();
}

class _BloodDefensePrototypeScreenState extends State<BloodDefensePrototypeScreen> with SingleTickerProviderStateMixin {
  static const int _columns = 10;
  static const int _rows = 6;
  static const List<Offset> _pathPoints = <Offset>[
    Offset(0.5, 2.5),
    Offset(1.5, 2.5),
    Offset(2.5, 2.5),
    Offset(3.5, 2.5),
    Offset(3.5, 1.5),
    Offset(4.5, 1.5),
    Offset(5.5, 1.5),
    Offset(6.5, 1.5),
    Offset(6.5, 3.5),
    Offset(7.5, 3.5),
    Offset(8.5, 3.5),
    Offset(9.5, 3.5),
  ];
  static final Set<_GridCell> _pathCells = <_GridCell>{
    _GridCell(0, 2),
    _GridCell(1, 2),
    _GridCell(2, 2),
    _GridCell(3, 2),
    _GridCell(3, 1),
    _GridCell(4, 1),
    _GridCell(5, 1),
    _GridCell(6, 1),
    _GridCell(6, 2),
    _GridCell(6, 3),
    _GridCell(7, 3),
    _GridCell(8, 3),
    _GridCell(9, 3),
  };
  static const List<_WaveConfig> _waves = <_WaveConfig>[
    _WaveConfig(count: 10, spawnInterval: 0.72, speed: 1.02, health: 2, reward: 6),
    _WaveConfig(count: 14, spawnInterval: 0.64, speed: 1.10, health: 3, reward: 7),
    _WaveConfig(count: 18, spawnInterval: 0.58, speed: 1.18, health: 4, reward: 8),
    _WaveConfig(count: 22, spawnInterval: 0.52, speed: 1.28, health: 5, reward: 9),
    _WaveConfig(count: 26, spawnInterval: 0.48, speed: 1.38, health: 6, reward: 10),
    _WaveConfig(count: 30, spawnInterval: 0.44, speed: 1.52, health: 7, reward: 12),
  ];

  late final Ticker _ticker;
  Duration? _lastTick;

  final List<_BloodEnemy> _enemies = <_BloodEnemy>[];
  final List<_BloodTower> _towers = <_BloodTower>[];
  final List<_ShotFlash> _flashes = <_ShotFlash>[];

  BloodDefenseTowerType _selectedTower = BloodDefenseTowerType.macrophageNest;
  int _bioEnergy = 85;
  int _vesselHealth = 15;
  int _waveIndex = 0;
  int _remainingToSpawn = 0;
  double _spawnTimer = 0;
  double _betweenWaveTimer = 0;
  String _statusText = 'Build a small defense line, then begin the prototype.';
  bool _started = false;
  bool _waveActive = false;
  bool _won = false;
  bool _lost = false;

  double get _pathLengthInCells {
    double total = 0;
    for (int i = 0; i < _pathPoints.length - 1; i++) {
      total += (_pathPoints[i + 1] - _pathPoints[i]).distance;
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    final previous = _lastTick;
    _lastTick = elapsed;
    if (previous == null || !_started || _won || _lost) {
      return;
    }
    var dt = (elapsed - previous).inMicroseconds / 1000000;
    dt = dt.clamp(0.0, 0.05);
    _updatePrototype(dt);
  }

  void _startPrototype() {
    setState(() {
      _started = true;
      _won = false;
      _lost = false;
      _waveIndex = 0;
      _bioEnergy = 85;
      _vesselHealth = 15;
      _remainingToSpawn = 0;
      _betweenWaveTimer = 0.8;
      _spawnTimer = 0;
      _statusText = 'Wave 1 is about to enter the vessel.';
      _enemies.clear();
      _towers.clear();
      _flashes.clear();
      _waveActive = false;
    });
  }

  void _updatePrototype(double dt) {
    for (final flash in _flashes.toList()) {
      flash.life -= dt;
      if (flash.life <= 0) {
        _flashes.remove(flash);
      }
    }

    if (_betweenWaveTimer > 0) {
      _betweenWaveTimer = math.max(0.0, _betweenWaveTimer - dt);
      if (_betweenWaveTimer <= 0) {
        _beginWave(_waveIndex);
      }
    }

    if (_waveActive && _waveIndex < _waves.length) {
      final config = _waves[_waveIndex];
      _spawnTimer += dt;
      while (_remainingToSpawn > 0 && _spawnTimer >= config.spawnInterval) {
        _spawnTimer -= config.spawnInterval;
        _remainingToSpawn -= 1;
        _enemies.add(
          _BloodEnemy(
            distance: 0,
            speedCellsPerSecond: config.speed,
            health: config.health,
            reward: config.reward,
          ),
        );
      }
    }

    for (final enemy in _enemies.toList()) {
      if (enemy.slowTimer > 0) {
        enemy.slowTimer = math.max(0.0, enemy.slowTimer - dt);
      }
      final speedMultiplier = enemy.slowTimer > 0 ? 0.55 : 1.0;
      enemy.distance += enemy.speedCellsPerSecond * speedMultiplier * dt;
      if (enemy.distance >= _pathLengthInCells) {
        _enemies.remove(enemy);
        _vesselHealth -= 1;
        _statusText = 'A red blood cell slipped through the vessel wall.';
        if (_vesselHealth <= 0) {
          _lost = true;
          _waveActive = false;
          _statusText = 'The vessel clogged. Restart the prototype and try a tighter defense.';
        }
      }
    }

    for (final tower in _towers) {
      tower.cooldown -= dt;
      if (tower.cooldown > 0) {
        continue;
      }
      final target = _pickTargetForTower(tower);
      if (target == null) {
        continue;
      }
      _fireTower(tower, target);
    }

    for (final enemy in _enemies.where((enemy) => enemy.health <= 0).toList()) {
      _enemies.remove(enemy);
      _bioEnergy += enemy.reward;
      _statusText = 'Bio energy recovered from the broken cell.';
    }

    if (_waveActive && _remainingToSpawn == 0 && _enemies.isEmpty && !_won && !_lost) {
      _waveActive = false;
      _waveIndex += 1;
      if (_waveIndex >= _waves.length) {
        _won = true;
        _statusText = 'Prototype complete. The vessel held against every wave.';
      } else {
        _betweenWaveTimer = 2.2;
        _statusText = 'Wave ${_waveIndex + 1} is gathering at the vessel entrance.';
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _beginWave(int waveIndex) {
    final config = _waves[waveIndex];
    _waveActive = true;
    _remainingToSpawn = config.count;
    _spawnTimer = 0;
    _statusText = 'Wave ${waveIndex + 1} has entered the vessel.';
  }

  _BloodEnemy? _pickTargetForTower(_BloodTower tower) {
    _BloodEnemy? best;
    double bestDistance = double.infinity;
    final towerCenter = _cellCenter(tower.cell);
    for (final enemy in _enemies) {
      final enemyPoint = _pointAlongPath(enemy.distance);
      final distance = (enemyPoint - towerCenter).distance;
      if (distance <= tower.rangeInCells) {
        if (best == null || enemy.distance > best.distance || (enemy.distance == best.distance && distance < bestDistance)) {
          best = enemy;
          bestDistance = distance;
        }
      }
    }
    return best;
  }

  void _fireTower(_BloodTower tower, _BloodEnemy target) {
    final from = _cellCenter(tower.cell);
    final to = _pointAlongPath(target.distance);
    switch (tower.type) {
      case BloodDefenseTowerType.macrophageNest:
        target.health -= 1;
        tower.cooldown = 0.62;
        _flashes.add(_ShotFlash(from: from, to: to, color: tower.type.color));
        break;
      case BloodDefenseTowerType.plateletSnare:
        target.health -= 1;
        target.slowTimer = math.max(target.slowTimer, 0.9);
        tower.cooldown = 1.0;
        _flashes.add(_ShotFlash(from: from, to: to, color: tower.type.color));
        break;
      case BloodDefenseTowerType.enzymeGland:
        tower.cooldown = 1.35;
        for (final enemy in _enemies) {
          final distance = (_pointAlongPath(enemy.distance) - to).distance;
          if (distance <= 0.95) {
            enemy.health -= enemy == target ? 2 : 1;
          }
        }
        _flashes.add(_ShotFlash(from: from, to: to, color: tower.type.color, width: 4));
        break;
    }
  }

  void _handleBoardTap(Offset localPosition, Size boardSize) {
    if (!_started || _won || _lost) {
      return;
    }
    final cell = _cellForOffset(localPosition, boardSize);
    if (cell == null) {
      return;
    }
    if (_pathCells.contains(cell)) {
      setState(() {
        _statusText = 'That tile is part of the blood vessel path.';
      });
      return;
    }
    if (_towers.any((tower) => tower.cell == cell)) {
      setState(() {
        _statusText = 'A biological defense already occupies that tissue tile.';
      });
      return;
    }
    if (_bioEnergy < _selectedTower.cost) {
      setState(() {
        _statusText = 'Not enough bio energy for ${_selectedTower.title}.';
      });
      return;
    }
    setState(() {
      _bioEnergy -= _selectedTower.cost;
      _towers.add(
        _BloodTower(
          cell: cell,
          type: _selectedTower,
          rangeInCells: switch (_selectedTower) {
            BloodDefenseTowerType.macrophageNest => 2.1,
            BloodDefenseTowerType.plateletSnare => 1.9,
            BloodDefenseTowerType.enzymeGland => 2.2,
          },
        ),
      );
      _statusText = '${_selectedTower.title} placed in the tissue wall.';
    });
  }

  _GridCell? _cellForOffset(Offset localPosition, Size boardSize) {
    final cellWidth = boardSize.width / _columns;
    final cellHeight = boardSize.height / _rows;
    final column = (localPosition.dx / cellWidth).floor();
    final row = (localPosition.dy / cellHeight).floor();
    if (column < 0 || row < 0 || column >= _columns || row >= _rows) {
      return null;
    }
    return _GridCell(column, row);
  }

  Offset _cellCenter(_GridCell cell) => Offset(cell.column + 0.5, cell.row + 0.5);

  Offset _pointAlongPath(double distance) {
    var remaining = distance;
    for (int i = 0; i < _pathPoints.length - 1; i++) {
      final start = _pathPoints[i];
      final end = _pathPoints[i + 1];
      final segmentLength = (end - start).distance;
      if (remaining <= segmentLength) {
        final t = segmentLength == 0 ? 0.0 : remaining / segmentLength;
        return Offset(
          start.dx + (end.dx - start.dx) * t,
          start.dy + (end.dy - start.dy) * t,
        );
      }
      remaining -= segmentLength;
    }
    return _pathPoints.last;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071713),
      appBar: AppBar(
        title: const Text('Blood Vessel Defense Prototype'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _BloodStatCard(label: 'Vessel Health', value: '$_vesselHealth'),
                  _BloodStatCard(label: 'Bio Energy', value: '$_bioEnergy'),
                  _BloodStatCard(label: 'Wave', value: _won ? 'Complete' : '${math.min(_waveIndex + (_waveActive ? 1 : 0), _waves.length)}/${_waves.length}'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _statusText,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Center(
                      child: AspectRatio(
                        aspectRatio: _columns / _rows,
                        child: GestureDetector(
                          onTapDown: (details) => _handleBoardTap(details.localPosition, Size(constraints.maxWidth, constraints.maxWidth * _rows / _columns)),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: _BloodDefensePainter(
                                    columns: _columns,
                                    rows: _rows,
                                    pathCells: _pathCells,
                                    pathPoints: _pathPoints,
                                    enemies: _enemies,
                                    towers: _towers,
                                    flashes: _flashes,
                                    selectedTower: _selectedTower,
                                    pointAlongPath: _pointAlongPath,
                                  ),
                                ),
                              ),
                              if (!_started || _won || _lost)
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.black45,
                                    alignment: Alignment.center,
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 420),
                                      child: Card(
                                        child: SingleChildScrollView(
                                          padding: const EdgeInsets.all(22),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                !_started
                                                    ? 'Prototype Brief'
                                                    : _won
                                                        ? 'Prototype Complete'
                                                        : 'Vessel Overrun',
                                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                !_started
                                                    ? 'Red blood cells are moving through the vessel. Place biological defenses on the open tissue tiles and stop them before they leak past the exit.'
                                                    : _won
                                                        ? 'The vessel stayed clear through all six waves.'
                                                        : 'Too many cells escaped. Try a tighter defense line.',
                                                style: const TextStyle(fontSize: 16),
                                              ),
                                              const SizedBox(height: 16),
                                              const Text('- Tap a defense card below to choose it.'),
                                              const Text('- Tap an open tissue tile to place it.'),
                                              const Text('- Hold the center turn and the bottom lane to survive later waves.'),
                                              const SizedBox(height: 18),
                                              FilledButton(
                                                onPressed: _startPrototype,
                                                child: Text(!_started ? 'Start Prototype' : 'Restart Prototype'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _started && !_won && !_lost
                              ? () {
                                  setState(() {
                                    _betweenWaveTimer = math.max(_betweenWaveTimer, 0.2);
                                    _statusText = 'The next wave is already on its way.';
                                  });
                                }
                              : null,
                          child: Text(_waveActive ? 'Wave Active' : 'Next Wave Incoming'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: _startPrototype,
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (final tower in BloodDefenseTowerType.values) ...[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: tower == BloodDefenseTowerType.values.last ? 0 : 10),
                            child: _TowerChoiceCard(
                              tower: tower,
                              selected: _selectedTower == tower,
                              onTap: () {
                                setState(() {
                                  _selectedTower = tower;
                                  _statusText = '${tower.title} selected.';
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BloodDefensePainter extends CustomPainter {
  const _BloodDefensePainter({
    required this.columns,
    required this.rows,
    required this.pathCells,
    required this.pathPoints,
    required this.enemies,
    required this.towers,
    required this.flashes,
    required this.selectedTower,
    required this.pointAlongPath,
  });

  final int columns;
  final int rows;
  final Set<_GridCell> pathCells;
  final List<Offset> pathPoints;
  final List<_BloodEnemy> enemies;
  final List<_BloodTower> towers;
  final List<_ShotFlash> flashes;
  final BloodDefenseTowerType selectedTower;
  final Offset Function(double distance) pointAlongPath;

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / columns;
    final cellHeight = size.height / rows;
    final tissuePaint = Paint()..color = const Color(0xFF102A24);
    final pathPaint = Paint()..color = const Color(0xFF3B0D16);
    final gridPaint = Paint()
      ..color = const Color(0xFF1F4A3D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(18)),
      Paint()..color = const Color(0xFF081C15),
    );

    for (int row = 0; row < rows; row++) {
      for (int column = 0; column < columns; column++) {
        final rect = Rect.fromLTWH(column * cellWidth, row * cellHeight, cellWidth, cellHeight);
        final cell = _GridCell(column, row);
        canvas.drawRect(rect, pathCells.contains(cell) ? pathPaint : tissuePaint);
        canvas.drawRect(rect, gridPaint);
      }
    }

    final vesselPaint = Paint()
      ..color = const Color(0xFF7F1D1D).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.min(cellWidth, cellHeight) * 0.38
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final vesselPath = Path();
    for (int i = 0; i < pathPoints.length; i++) {
      final point = Offset(pathPoints[i].dx * cellWidth, pathPoints[i].dy * cellHeight);
      if (i == 0) {
        vesselPath.moveTo(point.dx, point.dy);
      } else {
        vesselPath.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(vesselPath, vesselPaint);

    for (final tower in towers) {
      final center = Offset((tower.cell.column + 0.5) * cellWidth, (tower.cell.row + 0.5) * cellHeight);
      final towerRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: cellWidth * 0.62, height: cellHeight * 0.62),
        const Radius.circular(8),
      );
      canvas.drawRRect(towerRect, Paint()..color = tower.type.color);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: cellWidth * 0.24, height: cellHeight * 0.24),
          const Radius.circular(4),
        ),
        Paint()..color = const Color(0xFF081C15),
      );
    }

    for (final enemy in enemies) {
      final point = pointAlongPath(enemy.distance);
      final center = Offset(point.dx * cellWidth, point.dy * cellHeight);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(0.18);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: cellWidth * 0.54, height: cellHeight * 0.34),
        Paint()..color = const Color(0xFFE63946),
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: cellWidth * 0.28, height: cellHeight * 0.16),
        Paint()..color = const Color(0xFFFFB3C1).withValues(alpha: 0.8),
      );
      canvas.restore();
    }

    for (final flash in flashes) {
      final start = Offset(flash.from.dx * cellWidth, flash.from.dy * cellHeight);
      final end = Offset(flash.to.dx * cellWidth, flash.to.dy * cellHeight);
      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = flash.color.withValues(alpha: flash.life.clamp(0.0, 1.0))
          ..strokeWidth = flash.width
          ..strokeCap = StrokeCap.round,
      );
    }

    final selectionPaint = Paint()
      ..color = selectedTower.color.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, 10, cellWidth * 0.8, cellHeight * 0.45),
        const Radius.circular(8),
      ),
      selectionPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BloodDefensePainter oldDelegate) => true;
}

class _TowerChoiceCard extends StatelessWidget {
  const _TowerChoiceCard({
    required this.tower,
    required this.selected,
    required this.onTap,
  });

  final BloodDefenseTowerType tower;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? tower.color.withValues(alpha: 0.22) : const Color(0xFF102A24),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? tower.color : const Color(0xFF1F4A3D), width: selected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tower.title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Cost ${tower.cost}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
            const SizedBox(height: 6),
            Text(tower.description, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _BloodStatCard extends StatelessWidget {
  const _BloodStatCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF102A24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F4A3D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _GridCell {
  const _GridCell(this.column, this.row);

  final int column;
  final int row;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _GridCell && runtimeType == other.runtimeType && column == other.column && row == other.row;

  @override
  int get hashCode => Object.hash(column, row);
}

class _WaveConfig {
  const _WaveConfig({
    required this.count,
    required this.spawnInterval,
    required this.speed,
    required this.health,
    required this.reward,
  });

  final int count;
  final double spawnInterval;
  final double speed;
  final int health;
  final int reward;
}

class _BloodEnemy {
  _BloodEnemy({
    required this.distance,
    required this.speedCellsPerSecond,
    required this.health,
    required this.reward,
  });

  double distance;
  final double speedCellsPerSecond;
  int health;
  final int reward;
  double slowTimer = 0;
}

class _BloodTower {
  _BloodTower({
    required this.cell,
    required this.type,
    required this.rangeInCells,
  });

  final _GridCell cell;
  final BloodDefenseTowerType type;
  final double rangeInCells;
  double cooldown = 0;
}

class _ShotFlash {
  _ShotFlash({
    required this.from,
    required this.to,
    required this.color,
    this.width = 3,
  });

  final Offset from;
  final Offset to;
  final Color color;
  final double width;
  double life = 0.14;
}
