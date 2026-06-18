import 'package:flame/components.dart';

import '../../data/categories.dart';
import '../../data/enemies/enemy_catalog.dart';
import '../../data/enemies/enemy_def.dart';
import '../../data/weapons/weapon_catalog.dart';
import '../pdac_game.dart';

/// The ordered beats of the interactive tutorial.
enum TutorialBeat { intro, move, innate, antibody, cytotoxic, done }

/// Pure beat-transition table (extracted so the ordering is unit-testable
/// without a Flame harness). [done] is terminal.
TutorialBeat tutorialBeatAfter(TutorialBeat beat) {
  switch (beat) {
    case TutorialBeat.intro:
      return TutorialBeat.move;
    case TutorialBeat.move:
      return TutorialBeat.innate;
    case TutorialBeat.innate:
      return TutorialBeat.antibody;
    case TutorialBeat.antibody:
      return TutorialBeat.cytotoxic;
    case TutorialBeat.cytotoxic:
      return TutorialBeat.done;
    case TutorialBeat.done:
      return TutorialBeat.done;
  }
}

/// Drives the interactive training arena: scripts one threat of each immune
/// category, gates progress on the player actually moving and clearing each
/// threat, and coaches via the transient context-tip banner. The reticle does
/// the rest - matched fire shows a bright ring, mismatched a grey one - so the
/// player learns the swap-to-match loop by doing, not by reading.
///
/// Added only when [PdacGame.tutorial] is true; the player is invulnerable for
/// the duration (see [PlayerComponent.takeDamage]).
class TutorialDirector extends Component with HasGameReference<PdacGame> {
  TutorialBeat _beat = TutorialBeat.intro;

  /// Seconds spent in the current beat (reset on each transition).
  double _beatTime = 0;
  Vector2? _startPos;
  bool _spawned = false;
  bool _finished = false;

  /// The coaching text currently shown, so we only push a new banner value when
  /// it actually changes (avoids re-triggering the banner's enter animation).
  String? _tipText;

  /// Seconds the player has held a WRONG-category weapon against the current
  /// threat; once it passes [_swapNudgeAfter] we escalate to an explicit
  /// "how to swap" prompt.
  double _wrongWeaponTime = 0;

  static const double _moveDistance = 70;
  static const double _swapNudgeAfter = 3.5;

  /// Minimum seconds a text-only beat stays up before it may advance, so even a
  /// fast player gets time to read it (the kill beats are reader-paced already -
  /// they wait for the kill).
  static const double _readDwell = 5.0;

  /// This frame's delta, captured so [_runKillBeat] can advance its own timer.
  double _frameDt = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _beatTime += dt;
    _frameDt = dt;

    // Keep the "germs active" HUD readout honest while the round loop is off.
    game.hud.enemiesRemaining.value = game.activeMobs.length;

    switch (_beat) {
      case TutorialBeat.intro:
        // Reader-paced: the welcome stays up until the player actually starts
        // moving, so there's no timer rushing them off it. (_startPos is set
        // once, not every frame, or the distance check would never trigger.)
        _startPos ??= game.player.position.clone();
        _setTip(_touch
            ? 'Welcome, defender! Your weapon fires on its own - you just move '
                  'and pick the right tool. Drag the joystick to move around '
                  'when you are ready.'
            : 'Welcome, defender! Your weapon fires on its own - you just move '
                  'and pick the right tool. Use WASD or the arrow keys to move '
                  'around when you are ready.');
        final moved = _startPos != null &&
            game.player.position.distanceTo(_startPos!) > _moveDistance;
        if (moved && _beatTime > 1.0) _advance();
      case TutorialBeat.move:
        // The colour-matching lesson. Text-only, so hold it for a comfortable
        // reading dwell before moving on to the hands-on practice.
        _setTip('Great - you can move! Now the key skill: every germ has a '
            'COLOUR. Match your weapon to it to deal real damage. The wrong '
            'colour barely does anything.');
        if (_beatTime > _readDwell) _advance();
      case TutorialBeat.innate:
        _runKillBeat(def: EnemyCatalog.virus, colorWord: 'BLUE');
      case TutorialBeat.antibody:
        _runKillBeat(
          def: EnemyCatalog.bacteria,
          colorWord: 'PURPLE',
          shielded: true,
        );
      case TutorialBeat.cytotoxic:
        _runKillBeat(def: EnemyCatalog.fungalSpore, colorWord: 'RED');
      case TutorialBeat.done:
        // Hold the closing message on screen for a reading dwell before handing
        // back to the menu (it used to pop instantly, so it was never read).
        _setTip("That's the whole game: read the germ's colour, swap to match. "
            "You've got it - good luck out there!");
        if (!_finished && _beatTime > _readDwell) {
          _finished = true;
          game.completeTutorial();
        }
    }
  }

  bool get _touch => game.touchControlsEnabled;

  /// How the player swaps on this platform (used inside coaching prompts).
  String get _swapAction =>
      _touch ? 'tap the SWAP button' : 'press Q or Tab';

  /// Spawns one [def] (once) on a deliberately WRONG-category weapon, then
  /// coaches the player to swap to [colorWord]. Wrong-color fire deals no damage
  /// in the tutorial (see CollisionResolver), so the threat can ONLY be cleared
  /// by swapping - and if the player keeps firing the wrong colour we escalate
  /// to an explicit how-to-swap nudge. Advances once the arena is clear.
  void _runKillBeat({
    required EnemyDef def,
    required String colorWord,
    bool shielded = false,
  }) {
    if (!_spawned) {
      _equipMismatched(def.category);
      game.spawnTutorialMob(def, _spawnPoint());
      _spawned = true;
      _wrongWeaponTime = 0;
    }

    if (game.activeMobs.isEmpty) {
      _advance();
      return;
    }

    final equippedCategory =
        WeaponCatalog.all[game.gameState.equippedWeaponId]?.category;
    final matched = equippedCategory == def.category;

    final name = def.displayName;
    if (matched) {
      _wrongWeaponTime = 0;
      _setTip('Matched! See the bright ring? Your $colorWord weapon shreds the '
          '$name now - finish it off!');
      return;
    }

    _wrongWeaponTime += _frameDt;
    if (_wrongWeaponTime > _swapNudgeAfter) {
      // Escalated nudge: the player has been firing the wrong colour - tell
      // them plainly what's wrong and exactly how to fix it.
      _setTip('Your shots are bouncing off - wrong colour! Keep $_swapAction '
          'until the ring around the $name turns $colorWord.');
    } else {
      final shield = shielded ? ', and it has a shield' : '';
      _setTip('A $name - the $colorWord threat$shield. Match its colour: '
          '$_swapAction to bring out your $colorWord weapon.');
    }
  }

  /// Equips a wrong-category weapon for [target] so the beat starts mismatched.
  /// No-op if the loadout somehow lacks a mismatching weapon.
  void _equipMismatched(ImmuneCategory target) {
    final equipped = game.gameState.equippedWeapons;
    for (var i = 0; i < equipped.length; i++) {
      if (WeaponCatalog.all[equipped[i]]?.category != target) {
        game.selectWeapon(i);
        return;
      }
    }
  }

  Vector2 _spawnPoint() {
    final size = game.arenaSize;
    // Top-centre, clear of the HUD block and the player's start.
    return Vector2(size.x * 0.5, size.y * 0.24);
  }

  void _advance() {
    _beat = tutorialBeatAfter(_beat);
    _beatTime = 0;
    _spawned = false;
    _wrongWeaponTime = 0;
  }

  /// Sets the coaching banner only when the text actually changes. The banner
  /// is persistent during the tutorial (see ContextTipOverlay), so there's no
  /// need to re-assert it - this just avoids re-triggering the enter animation
  /// every frame.
  void _setTip(String text) {
    if (text == _tipText) return;
    game.hud.contextTip.value = text;
    _tipText = text;
  }
}
