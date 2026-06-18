import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pdac_immune_defense/services/persistence_service.dart';
import 'package:pdac_immune_defense/services/save_data.dart';

void main() {
  test(
    'init falls back to backup save data when the primary blob is corrupt',
    () async {
      final backup = SaveData(goldCoins: 77, highestRoundReached: 5).toJson();
      SharedPreferences.setMockInitialValues({
        'save_data_v1': '{not valid json',
        'save_data_v1_backup': jsonEncode(backup),
      });

      final service = await PersistenceService.init();

      expect(service.saveData.goldCoins, 77);
      expect(service.saveData.highestRoundReached, 5);
    },
  );

  test(
    'save writes are serialized so clearCheckpoint wins after slow saves',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final writeCompleters = <Completer<void>>[];
      final persistedRaw = <String>[];

      final service = PersistenceService.forTesting(
        prefs: prefs,
        writeSaveDataJson: (rawJson) async {
          final completer = Completer<void>();
          writeCompleters.add(completer);
          await completer.future;
          persistedRaw.add(rawJson);
        },
      );

      final checkpointWrite = service.saveCheckpoint(
        CheckpointData(
          roundNumber: 4,
          playerHp: 70,
          goldThisRun: 12,
          equippedWeapons: const ['pistol', 'shotgun', 'rifle'],
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(writeCompleters, hasLength(1));

      final clearWrite = service.clearCheckpoint();
      await Future<void>.delayed(Duration.zero);
      expect(
        writeCompleters,
        hasLength(1),
        reason: 'The clear should wait behind the in-flight checkpoint write.',
      );

      writeCompleters.first.complete();
      await Future<void>.delayed(Duration.zero);
      expect(writeCompleters, hasLength(2));

      writeCompleters.last.complete();
      await Future.wait([checkpointWrite, clearWrite]);

      final saved = SaveData.fromJson(
        jsonDecode(persistedRaw.last) as Map<String, dynamic>,
      );
      expect(saved.checkpoint, isNull);
      expect(service.checkpoint, isNull);
    },
  );

  test(
    'writeHealthy flips false on a failed write and recovers on success',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      var shouldFail = true;
      final service = PersistenceService.forTesting(
        prefs: prefs,
        writeSaveDataJson: (_) async {
          if (shouldFail) throw Exception('storage full');
        },
      );

      expect(service.writeHealthy.value, isTrue);

      await service.saveSaveData(SaveData(goldCoins: 10));
      expect(service.writeHealthy.value, isFalse);

      shouldFail = false;
      await service.saveSaveData(SaveData(goldCoins: 20));
      expect(service.writeHealthy.value, isTrue);
    },
  );

  test(
    'addLocalGold replaces the save object instead of mutating the shared one',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = PersistenceService.forTesting(
        prefs: prefs,
        initialData: SaveData(goldCoins: 100),
      );

      // What an in-flight write captured as the "prior-state" backup snapshot.
      final priorSnapshot = service.saveData;

      service.addLocalGold(50);

      // The previously-captured object must be untouched, so the backup it
      // serializes is a true last-known-good state...
      expect(priorSnapshot.goldCoins, 100);
      // ...while the live save reflects the increment via a fresh object.
      expect(service.saveData.goldCoins, 150);
      expect(identical(service.saveData, priorSnapshot), isFalse);
    },
  );
}
