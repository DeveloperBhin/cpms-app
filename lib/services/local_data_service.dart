import 'dart:convert';

import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'api_services/block_api_services.dart';
import 'api_services/farm_api_services.dart';
import 'api_services/tree_api_services.dart';

class LocalDataService {
  LocalDataService._();

  static final LocalDataService instance = LocalDataService._();
  Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;

    final databasesPath = await getDatabasesPath();
    _database = await openDatabase(
      join(databasesPath, 'cpms_local.db'),
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE farms (
            id TEXT PRIMARY KEY,
            payload TEXT NOT NULL,
            pending INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await database.execute('''
          CREATE TABLE blocks (
            id TEXT PRIMARY KEY,
            farm_id TEXT NOT NULL,
            payload TEXT NOT NULL,
            pending INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await database.execute('''
          CREATE TABLE trees (
            id TEXT PRIMARY KEY,
            farm_id TEXT NOT NULL,
            block_id TEXT NOT NULL,
            payload TEXT NOT NULL,
            pending INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
    return _database!;
  }

  String _localId(String type) => 'local_${type}_${DateTime.now().microsecondsSinceEpoch}';

  Map<String, dynamic> _decode(Map<String, Object?> row) {
    final value = Map<String, dynamic>.from(jsonDecode(row['payload']! as String));
    value['_pendingSync'] = row['pending'] == 1;
    return value;
  }

  Future<List<Map<String, dynamic>>> _read(String table, {String? where, List<Object?>? args}) async {
    final rows = await (await _db).query(table, where: where, whereArgs: args);
    return rows.map(_decode).toList();
  }

  Future<void> _save(
    String table,
    Map<String, dynamic> value, {
    required String id,
    String? farmId,
    String? blockId,
    required bool pending,
  }) async {
    final payload = Map<String, dynamic>.from(value)..remove('_pendingSync');
    await (await _db).insert(
      table,
      {
        'id': id,
        if (farmId != null) 'farm_id': farmId,
        if (blockId != null) 'block_id': blockId,
        'payload': jsonEncode(payload),
        'pending': pending ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getFarms() async {
    await syncPending();
    try {
      final farms = await FarmApiServices.getMyFarms();
      for (final farm in farms) {
        final id = farm['id']?.toString();
        if (id != null) await _save('farms', farm, id: id, pending: false);
      }
    } catch (_) {}
    return _read('farms');
  }

  Future<Map<String, dynamic>> createFarm({required Map<String, dynamic> values}) async {
    try {
      final result = await FarmApiServices.createFarm(
        name: values['name'] as String,
        farmerId: values['farmerId'] as int,
        acreage: (values['acreage'] as num).toDouble(),
        plantingDate: values['plantingDate'] as String,
        farmType: values['farmType'] as String,
        farmLocation: values['farmLocation'] as String,
        region: values['region'] as String,
        district: values['district'] as String,
        ward: values['ward'] as String,
        village: values['village'] as String,
        latitude: (values['latitude'] as num).toDouble(),
        longitude: (values['longitude'] as num).toDouble(),
      );
      final id = result['id']?.toString();
      if (id != null) await _save('farms', result, id: id, pending: false);
      return result;
    } catch (_) {
      final local = Map<String, dynamic>.from(values)
        ..['id'] = _localId('farm')
        ..['_pendingSync'] = true;
      await _save('farms', local, id: local['id'] as String, pending: true);
      return local;
    }
  }

  Future<List<Map<String, dynamic>>> getBlocks(String farmId) async {
    await syncPending();
    try {
      final blocks = await BlockApiServices.getBlocksByFarm(farmId);
      for (final block in blocks) {
        final id = block['id']?.toString();
        if (id != null) await _save('blocks', block, id: id, farmId: farmId, pending: false);
      }
    } catch (_) {}
    return _read('blocks', where: 'farm_id = ?', args: [farmId]);
  }

  Future<Map<String, dynamic>> createBlock({
    required String farmId,
    required String name,
    required double size,
    String? variety,
    int? treeCount,
    String? description,
  }) async {
    final values = <String, dynamic>{
      'name': name,
      'size': size,
      'variety': variety,
      'treeCount': treeCount,
      'description': description,
      'farmId': farmId,
    };
    try {
      final result = await BlockApiServices.createBlock(
        farmId: farmId,
        name: name,
        size: size,
        variety: variety,
        treeCount: treeCount,
        description: description,
      );
      final id = result['id']?.toString();
      if (id != null) await _save('blocks', result, id: id, farmId: farmId, pending: false);
      return result;
    } catch (_) {
      final local = Map<String, dynamic>.from(values)
        ..['id'] = _localId('block')
        ..['_pendingSync'] = true;
      await _save('blocks', local, id: local['id'] as String, farmId: farmId, pending: true);
      return local;
    }
  }

  Future<List<Map<String, dynamic>>> getTrees(String farmId, String blockId) async {
    await syncPending();
    try {
      final trees = await TreeApiServices.getTreesByBlock(farmId: farmId, blockId: blockId);
      for (final tree in trees) {
        final id = tree['id']?.toString();
        if (id != null) await _save('trees', tree, id: id, farmId: farmId, blockId: blockId, pending: false);
      }
    } catch (_) {}
    return _read('trees', where: 'farm_id = ? AND block_id = ?', args: [farmId, blockId]);
  }

  Future<Map<String, dynamic>> createTree({
    required String farmId,
    required String blockId,
    required String variety,
    required int plantingYear,
    required String status,
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    final values = <String, dynamic>{
      'farmId': farmId,
      'blockId': blockId,
      'variety': variety,
      'plantingYear': plantingYear,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
    };
    try {
      final result = await TreeApiServices.createTree(
        farmId: farmId,
        blockId: blockId,
        variety: variety,
        plantingYear: plantingYear,
        status: status,
        latitude: latitude,
        longitude: longitude,
        notes: notes,
      );
      final id = result['id']?.toString();
      if (id != null) await _save('trees', result, id: id, farmId: farmId, blockId: blockId, pending: false);
      return result;
    } catch (_) {
      final local = Map<String, dynamic>.from(values)
        ..['id'] = _localId('tree')
        ..['_pendingSync'] = true;
      await _save('trees', local, id: local['id'] as String, farmId: farmId, blockId: blockId, pending: true);
      return local;
    }
  }

  Future<int> pendingCount() async {
    final database = await _db;
    var total = 0;
    for (final table in ['farms', 'blocks', 'trees']) {
      final result = await database.rawQuery('SELECT COUNT(*) AS count FROM $table WHERE pending = 1');
      total += (result.first['count'] as int?) ?? 0;
    }
    return total;
  }

  Future<void> cacheProfile(Map<String, dynamic> profile) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('cached_profile', jsonEncode(profile));
  }

  Future<Map<String, dynamic>?> getCachedProfile() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString('cached_profile');
    if (value == null) return null;
    return Map<String, dynamic>.from(jsonDecode(value) as Map);
  }

  Future<void> syncPending() async {
    final database = await _db;
    final farms = await database.query('farms', where: 'pending = 1');
    for (final row in farms) {
      final payload = Map<String, dynamic>.from(jsonDecode(row['payload']! as String));
      try {
        final result = await FarmApiServices.createFarm(
          name: payload['name'] as String,
          farmerId: payload['farmerId'] as int,
          acreage: (payload['acreage'] as num).toDouble(),
          plantingDate: payload['plantingDate'] as String,
          farmType: payload['farmType'] as String,
          farmLocation: payload['farmLocation'] as String,
          region: payload['region'] as String,
          district: payload['district'] as String,
          ward: payload['ward'] as String,
          village: payload['village'] as String,
          latitude: (payload['latitude'] as num).toDouble(),
          longitude: (payload['longitude'] as num).toDouble(),
        );
        final newId = result['id']?.toString();
        if (newId == null) continue;
        final oldId = row['id']! as String;
        await database.transaction((transaction) async {
          await transaction.delete('farms', where: 'id = ?', whereArgs: [oldId]);
          await transaction.insert('farms', {'id': newId, 'payload': jsonEncode(result), 'pending': 0});
          await _replaceParentId(transaction, 'blocks', 'farm_id', oldId, newId, 'farmId');
          await _replaceParentId(transaction, 'trees', 'farm_id', oldId, newId, 'farmId');
        });
      } catch (_) {
        break;
      }
    }

    final blocks = await database.query('blocks', where: 'pending = 1');
    for (final row in blocks) {
      final payload = Map<String, dynamic>.from(jsonDecode(row['payload']! as String));
      try {
        final result = await BlockApiServices.createBlock(
          farmId: row['farm_id']! as String,
          name: payload['name'] as String,
          size: (payload['size'] as num).toDouble(),
          variety: payload['variety'] as String?,
          treeCount: payload['treeCount'] as int?,
          description: payload['description'] as String?,
        );
        final newId = result['id']?.toString();
        if (newId == null) continue;
        final oldId = row['id']! as String;
        await database.transaction((transaction) async {
          await transaction.delete('blocks', where: 'id = ?', whereArgs: [oldId]);
          await transaction.insert('blocks', {'id': newId, 'farm_id': row['farm_id'], 'payload': jsonEncode(result), 'pending': 0});
          await _replaceParentId(transaction, 'trees', 'block_id', oldId, newId, 'blockId');
        });
      } catch (_) {
        break;
      }
    }

    final trees = await database.query('trees', where: 'pending = 1');
    for (final row in trees) {
      final payload = Map<String, dynamic>.from(jsonDecode(row['payload']! as String));
      try {
        final result = await TreeApiServices.createTree(
          farmId: row['farm_id']! as String,
          blockId: row['block_id']! as String,
          variety: payload['variety'] as String,
          plantingYear: payload['plantingYear'] as int,
          status: payload['status'] as String,
          latitude: (payload['latitude'] as num?)?.toDouble(),
          longitude: (payload['longitude'] as num?)?.toDouble(),
          notes: payload['notes'] as String?,
        );
        final newId = result['id']?.toString();
        if (newId == null) continue;
        await database.delete('trees', where: 'id = ?', whereArgs: [row['id']]);
        await database.insert('trees', {'id': newId, 'farm_id': row['farm_id'], 'block_id': row['block_id'], 'payload': jsonEncode(result), 'pending': 0});
      } catch (_) {
        break;
      }
    }
  }

  Future<void> _replaceParentId(
    Transaction transaction,
    String table,
    String column,
    String oldId,
    String newId,
    String payloadKey,
  ) async {
    final rows = await transaction.query(table, where: '$column = ?', whereArgs: [oldId]);
    for (final row in rows) {
      final payload = Map<String, dynamic>.from(jsonDecode(row['payload']! as String))..[payloadKey] = newId;
      await transaction.update(table, {column: newId, 'payload': jsonEncode(payload)}, where: 'id = ?', whereArgs: [row['id']]);
    }
  }
}