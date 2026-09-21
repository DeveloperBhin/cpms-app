import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'api_services/block_api_services.dart';
import 'api_services/farm_api_services.dart';
import 'api_services/tree_api_services.dart';

class LocalDataService {
  LocalDataService._();

  static final LocalDataService instance =
      LocalDataService._();

  Database? _database;
  StreamSubscription<List<ConnectivityResult>>?
      _connectivitySubscription;
  bool _syncInProgress = false;

  Future<void> startConnectivityListener() async {
    if (_connectivitySubscription != null) {
      return;
    }

    final currentConnection =
        await Connectivity().checkConnectivity();

    if (_hasConnection(currentConnection)) {
      await syncPending();
    }

    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(
      (connection) {
        if (_hasConnection(connection)) {
          unawaited(syncPending());
        }
      },
    );
  }

  Future<bool> hasNetworkConnection() async {
    final connection =
        await Connectivity().checkConnectivity();

    return _hasConnection(connection);
  }

  bool _hasConnection(
    List<ConnectivityResult> connection,
  ) {
    return connection.any(
      (result) => result != ConnectivityResult.none,
    );
  }

  // ============================================================
  // DATABASE
  // ============================================================

  Future<Database> get _db async {
    if (_database != null) {
      return _database!;
    }

    final databasesPath =
        await getDatabasesPath();

    _database = await openDatabase(
      join(
        databasesPath,
        'cpms_local.db',
      ),
      version: 1,
      onCreate: (
        database,
        version,
      ) async {
        // ======================================================
        // FARMS
        // ======================================================

        await database.execute(
          '''
          CREATE TABLE farms (
            id TEXT PRIMARY KEY,
            payload TEXT NOT NULL,
            pending INTEGER NOT NULL DEFAULT 0
          )
          ''',
        );

        // ======================================================
        // BLOCKS
        // ======================================================

        await database.execute(
          '''
          CREATE TABLE blocks (
            id TEXT PRIMARY KEY,
            farm_id TEXT NOT NULL,
            payload TEXT NOT NULL,
            pending INTEGER NOT NULL DEFAULT 0
          )
          ''',
        );

        // ======================================================
        // TREES
        // ======================================================

        await database.execute(
          '''
          CREATE TABLE trees (
            id TEXT PRIMARY KEY,
            farm_id TEXT NOT NULL,
            block_id TEXT NOT NULL,
            payload TEXT NOT NULL,
            pending INTEGER NOT NULL DEFAULT 0
          )
          ''',
        );
      },
    );

    return _database!;
  }

  // ============================================================
  // LOCAL ID
  // ============================================================

  String _localId(
    String type,
  ) {
    return 'local_${type}_${DateTime.now().microsecondsSinceEpoch}';
  }

  // ============================================================
  // DECODE LOCAL DATA
  // ============================================================

  Map<String, dynamic> _decode(
    Map<String, Object?> row,
  ) {
    final value =
        Map<String, dynamic>.from(
      jsonDecode(
        row['payload']! as String,
      ) as Map,
    );

    value['_pendingSync'] =
        row['pending'] == 1;

    return value;
  }

  // ============================================================
  // READ LOCAL DATA
  // ============================================================

  Future<List<Map<String, dynamic>>> _read(
    String table, {
    String? where,
    List<Object?>? args,
  }) async {
    final database = await _db;

    final rows =
        await database.query(
      table,
      where: where,
      whereArgs: args,
    );

    return rows
        .map(_decode)
        .toList();
  }

  // ============================================================
  // SAVE LOCAL DATA
  // ============================================================

  Future<void> _save(
    String table,
    Map<String, dynamic> value, {
    required String id,
    String? farmId,
    String? blockId,
    required bool pending,
  }) async {
    final payload =
        Map<String, dynamic>.from(
      value,
    )..remove(
            '_pendingSync',
          );

    final data =
        <String, Object?>{
      'id': id,
      'payload':
          jsonEncode(payload),
      'pending':
          pending ? 1 : 0,
    };

    if (farmId != null) {
      data['farm_id'] =
          farmId;
    }

    if (blockId != null) {
      data['block_id'] =
          blockId;
    }

    final database =
        await _db;

    await database.insert(
      table,
      data,
      conflictAlgorithm:
          ConflictAlgorithm.replace,
    );
  }

  // ============================================================
  // FARMS
  // ============================================================

  Future<List<Map<String, dynamic>>>
      getFarms() async {
    // Try to synchronize pending records first.
    //
    // syncPending() handles failures internally, so cached
    // records remain available when the server cannot be reached.

    await syncPending();

    try {
      final farms =
          await FarmApiServices
              .getMyFarms();

      for (final farm
          in farms) {
        final id =
            farm['id']?.toString();

        if (id != null &&
            id.isNotEmpty) {
          await _save(
            'farms',
            farm,
            id: id,
            pending: false,
          );
        }
      }
    } catch (e) {
      print(
        'GET FARMS ONLINE ERROR: $e',
      );

      // Use locally cached farms.
    }

    return _read(
      'farms',
    );
  }

  // ============================================================
  // CREATE FARM
  // ============================================================

  Future<Map<String, dynamic>>
      createFarm({
    required Map<String, dynamic>
        values,
  }) async {
    // ==========================================================
    // EXTRACT VALUES
    // ==========================================================

    final name =
        values['name']
                ?.toString()
                .trim() ??
            '';

    final acreageValue =
        values['acreage'];

    final acreage =
        acreageValue is num
            ? acreageValue
                .toDouble()
            : double.tryParse(
                  acreageValue
                          ?.toString() ??
                      '',
                ) ??
                0.0;

    final plantingDate =
        values['plantingDate']
                ?.toString()
                .trim() ??
            '';

    final farmType =
        values['farmType']
                ?.toString()
                .trim()
                .toUpperCase() ??
            '';

    final geometry =
        values['geometry']
                ?.toString()
                .trim() ??
            '';

    final region =
        values['region']
                ?.toString()
                .trim() ??
            '';

    final district =
        values['district']
                ?.toString()
                .trim() ??
            '';

    final ward =
        values['ward']
                ?.toString()
                .trim() ??
            '';

    final village =
        values['village']
                ?.toString()
                .trim() ??
            '';

    // ==========================================================
    // VALIDATION
    // ==========================================================

    if (name.isEmpty) {
      throw Exception(
        'Farm name is required.',
      );
    }

    if (acreage <= 0) {
      throw Exception(
        'Farm acreage must be greater than zero.',
      );
    }

    if (plantingDate.isEmpty) {
      throw Exception(
        'Planting date is required.',
      );
    }

    if (farmType.isEmpty) {
      throw Exception(
        'Farm type is required.',
      );
    }

    // Farm geometry is required because the backend stores
    // the farm boundary as a PostGIS Polygon.

    if (geometry.isEmpty) {
      throw Exception(
        'Farm boundary is required. '
        'Please map the farm before saving.',
      );
    }

    if (!geometry
        .toUpperCase()
        .startsWith(
          'POLYGON',
        )) {
      throw Exception(
        'Invalid farm boundary geometry.',
      );
    }

    if (region.isEmpty) {
      throw Exception(
        'Region is required.',
      );
    }

    if (district.isEmpty) {
      throw Exception(
        'District is required.',
      );
    }

    if (ward.isEmpty) {
      throw Exception(
        'Ward is required.',
      );
    }

    if (village.isEmpty) {
      throw Exception(
        'Village is required.',
      );
    }

    // ==========================================================
    // NORMALIZED VALUES
    // ==========================================================

    final normalizedValues =
        <String, dynamic>{
      ...values,
      'name': name,
      'acreage': acreage,
      'plantingDate':
          plantingDate,

      // Keep backend enum untranslated.
      'farmType':
          farmType,

      // WKT PostGIS polygon.
      'geometry':
          geometry,

      'region':
          region,
      'district':
          district,
      'ward':
          ward,
      'village':
          village,
    };

    print(
      '========================================',
    );

    print(
      'ATTEMPTING ONLINE FARM CREATION',
    );

    print(
      'NAME: $name',
    );

    print(
      'ACREAGE: $acreage',
    );

    print(
      'PLANTING DATE: $plantingDate',
    );

    print(
      'FARM TYPE: $farmType',
    );

    print(
      'REGION: $region',
    );

    print(
      'DISTRICT: $district',
    );

    print(
      'WARD: $ward',
    );

    print(
      'VILLAGE: $village',
    );

    print(
      'GEOMETRY: $geometry',
    );

    print(
      '========================================',
    );

    if (!await hasNetworkConnection()) {
      return _saveFarmOffline(
        normalizedValues,
      );
    }

    try {
      // ========================================================
      // ONLINE FIRST
      // ========================================================

      final result =
          await FarmApiServices
              .createFarm(
        name: name,
        acreage: acreage,
        plantingDate:
            plantingDate,
        farmType:
            farmType,
        geometry:
            geometry,
        region:
            region,
        district:
            district,
        ward:
            ward,
        village:
            village,
      );

      print(
        '========================================',
      );

      print(
        'FARM CREATED ONLINE SUCCESSFULLY',
      );

      print(
        'SERVER FARM: $result',
      );

      print(
        '========================================',
      );

      final id =
          result['id']
              ?.toString();

      if (id == null ||
          id.isEmpty) {
        throw Exception(
          'Farm was created but the server did not return a farm ID.',
        );
      }

      // ========================================================
      // SAVE ONLINE FARM AS LOCAL CACHE
      // ========================================================

      final onlineFarm =
          <String, dynamic>{
        ...normalizedValues,
        ...result,

        // Preserve geometry in case an older backend response
        // does not include it.
        'geometry':
            result['geometry'] ??
                geometry,

        '_pendingSync':
            false,
      };

      await _save(
        'farms',
        onlineFarm,
        id: id,
        pending: false,
      );

      return onlineFarm;
    }

    // ==========================================================
    // SERVER RESPONDED
    //
    // A 400 / 401 / 403 / 404 / 500 is NOT an offline error.
    //
    // Do not save another local farm in this situation.
    // ==========================================================

    on FarmApiException catch (e) {
      print(
        '========================================',
      );

      print(
        'FARM SERVER ERROR',
      );

      print(
        'STATUS: ${e.statusCode}',
      );

      print(
        'MESSAGE: ${e.message}',
      );

      print(
        '========================================',
      );

      rethrow;
    }

    // ==========================================================
    // TIMEOUT
    // ==========================================================

    on TimeoutException catch (e) {
      print(
        '========================================',
      );

      print(
        'FARM REQUEST TIMED OUT',
      );

      print(
        'ERROR: $e',
      );

      print(
        'SAVING FARM OFFLINE',
      );

      print(
        '========================================',
      );

      return _saveFarmOffline(
        normalizedValues,
      );
    }

    // ==========================================================
    // NETWORK FAILURE
    // ==========================================================

    on SocketException catch (e) {
      print(
        '========================================',
      );

      print(
        'FARM NETWORK ERROR',
      );

      print(
        'ERROR: $e',
      );

      print(
        'SAVING FARM OFFLINE',
      );

      print(
        '========================================',
      );

      return _saveFarmOffline(
        normalizedValues,
      );
    }

    // ==========================================================
    // OTHER ERROR
    // ==========================================================

    catch (e, stackTrace) {
      print(
        '========================================',
      );

      print(
        'UNEXPECTED FARM CREATION ERROR',
      );

      print(
        'ERROR: $e',
      );

      print(
        'STACK: $stackTrace',
      );

      print(
        '========================================',
      );

      // package:http may wrap the original SocketException.
      //
      // Only errors that clearly look like connection failures
      // are allowed to fall back to offline mode.

      if (_isNetworkError(
        e,
      )) {
        print(
          'Network-related error detected.',
        );

        print(
          'Saving farm offline.',
        );

        return _saveFarmOffline(
          normalizedValues,
        );
      }

      // Programming errors, malformed values and unexpected
      // backend responses must be visible to the UI.

      rethrow;
    }
  }

  // ============================================================
  // SAVE FARM OFFLINE
  // ============================================================

  Future<Map<String, dynamic>>
      _saveFarmOffline(
    Map<String, dynamic>
        values,
  ) async {
    final localId =
        _localId(
      'farm',
    );

    final local =
        Map<String, dynamic>.from(
      values,
    )
          ..['id'] =
              localId
          ..['_pendingSync'] =
              true;

    await _save(
      'farms',
      local,
      id: localId,
      pending: true,
    );

    print(
      '========================================',
    );

    print(
      'FARM SAVED OFFLINE',
    );

    print(
      'LOCAL ID: $localId',
    );

    print(
      'GEOMETRY: ${local['geometry']}',
    );

    print(
      '========================================',
    );

    return local;
  }

  // ============================================================
  // CHECK NETWORK ERROR
  // ============================================================

  bool _isNetworkError(
    Object error,
  ) {
    final message =
        error
            .toString()
            .toLowerCase();

    return message.contains(
          'socketexception',
        ) ||
        message.contains(
          'clientexception',
        ) ||
        message.contains(
          'timeoutexception',
        ) ||
        message.contains(
          'failed host lookup',
        ) ||
        message.contains(
          'connection refused',
        ) ||
        message.contains(
          'connection reset',
        ) ||
        message.contains(
          'connection timed out',
        ) ||
        message.contains(
          'timed out',
        ) ||
        message.contains(
          'network is unreachable',
        ) ||
        message.contains(
          'no route to host',
        ) ||
        message.contains(
          'connection closed',
        );
  }

  // ============================================================
  // BLOCKS
  // ============================================================

  Future<List<Map<String, dynamic>>>
      getBlocks(
    String farmId,
  ) async {
    await syncPending();

    try {
      final blocks =
          await BlockApiServices
              .getBlocksByFarm(
        farmId,
      );

      for (final block
          in blocks) {
        final id =
            block['id']
                ?.toString();

        if (id != null &&
            id.isNotEmpty) {
          await _save(
            'blocks',
            block,
            id: id,
            farmId:
                farmId,
            pending:
                false,
          );
        }
      }
    } catch (e) {
      print(
        'GET BLOCKS ONLINE ERROR: $e',
      );

      // Return locally cached blocks.
    }

    return _read(
      'blocks',
      where:
          'farm_id = ?',
      args: [
        farmId,
      ],
    );
  }

  // ============================================================
  // CREATE BLOCK
  // ============================================================

  Future<Map<String, dynamic>>
      createBlock({
    required String farmId,
    required String name,
    required double size,
    String? variety,
    int? treeCount,
    String? description,
  }) async {
    final values =
        <String, dynamic>{
      'name':
          name,
      'size':
          size,
      'variety':
          variety,
      'treeCount':
          treeCount,
      'description':
          description,
      'farmId':
          farmId,
    };

    if (!await hasNetworkConnection()) {
      return _saveBlockOffline(
        values,
      );
    }

    try {
      final result =
          await BlockApiServices
              .createBlock(
        farmId:
            farmId,
        name:
            name,
        size:
            size,
        variety:
            variety,
        treeCount:
            treeCount,
        description:
            description,
      );

      final id =
          result['id']
              ?.toString();

      if (id != null &&
          id.isNotEmpty) {
        await _save(
          'blocks',
          result,
          id:
              id,
          farmId:
              farmId,
          pending:
              false,
        );
      }

      return result;
    } catch (e) {
      if (!_isNetworkError(e)) {
        rethrow;
      }

      return _saveBlockOffline(
        values,
      );
    }
  }

  Future<Map<String, dynamic>> _saveBlockOffline(
    Map<String, dynamic> values,
  ) async {
    final local =
        Map<String, dynamic>.from(
      values,
    )
          ..['id'] = _localId('block')
          ..['_pendingSync'] = true;

    await _save(
      'blocks',
      local,
      id: local['id'] as String,
      farmId: values['farmId'] as String,
      pending: true,
    );

    return local;
  }

  // ============================================================
  // TREES
  // ============================================================

  Future<List<Map<String, dynamic>>>
      getTrees(
    String farmId,
    String blockId,
  ) async {
    await syncPending();

    try {
      final trees =
          await TreeApiServices
              .getTreesByBlock(
        farmId:
            farmId,
        blockId:
            blockId,
      );

      for (final tree
          in trees) {
        final id =
            tree['id']
                ?.toString();

        if (id != null &&
            id.isNotEmpty) {
          await _save(
            'trees',
            tree,
            id:
                id,
            farmId:
                farmId,
            blockId:
                blockId,
            pending:
                false,
          );
        }
      }
    } catch (e) {
      print(
        'GET TREES ONLINE ERROR: $e',
      );

      // Return cached trees.
    }

    return _read(
      'trees',
      where:
          'farm_id = ? AND block_id = ?',
      args: [
        farmId,
        blockId,
      ],
    );
  }

  // ============================================================
  // CREATE TREE
  // ============================================================

  Future<Map<String, dynamic>>
      createTree({
    required String farmId,
    required String blockId,
    required String variety,
    required int plantingYear,
    required String status,
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    final values =
        <String, dynamic>{
      'farmId':
          farmId,
      'blockId':
          blockId,
      'variety':
          variety,
      'plantingYear':
          plantingYear,
      'status':
          status,
      'latitude':
          latitude,
      'longitude':
          longitude,
      'notes':
          notes,
    };

    if (!await hasNetworkConnection()) {
      return _saveTreeOffline(
        values,
      );
    }

    try {
      final result =
          await TreeApiServices
              .createTree(
        farmId:
            farmId,
        blockId:
            blockId,
        variety:
            variety,
        plantingYear:
            plantingYear,
        status:
            status,
        latitude:
            latitude,
        longitude:
            longitude,
        notes:
            notes,
      );

      final id =
          result['id']
              ?.toString();

      if (id != null &&
          id.isNotEmpty) {
        await _save(
          'trees',
          result,
          id:
              id,
          farmId:
              farmId,
          blockId:
              blockId,
          pending:
              false,
        );
      }

      return result;
    } catch (e) {
      if (!_isNetworkError(e)) {
        rethrow;
      }

      return _saveTreeOffline(
        values,
      );
    }
  }

  Future<Map<String, dynamic>> _saveTreeOffline(
    Map<String, dynamic> values,
  ) async {
    final local =
        Map<String, dynamic>.from(
      values,
    )
          ..['id'] = _localId('tree')
          ..['_pendingSync'] = true;

    await _save(
      'trees',
      local,
      id: local['id'] as String,
      farmId: values['farmId'] as String,
      blockId: values['blockId'] as String,
      pending: true,
    );

    return local;
  }

  // ============================================================
  // PENDING COUNT
  // ============================================================

  Future<int> pendingCount() async {
    final database =
        await _db;

    var total = 0;

    for (final table in [
      'farms',
      'blocks',
      'trees',
    ]) {
      final result =
          await database.rawQuery(
        'SELECT COUNT(*) AS count '
        'FROM $table '
        'WHERE pending = 1',
      );

      total +=
          (result.first['count']
                  as int?) ??
              0;
    }

    return total;
  }

  // ============================================================
  // CACHE PROFILE
  // ============================================================

  Future<void> cacheProfile(
    Map<String, dynamic> profile,
  ) async {
    final preferences =
        await SharedPreferences
            .getInstance();

    await preferences.setString(
      'cached_profile',
      jsonEncode(
        profile,
      ),
    );
  }

  // ============================================================
  // GET CACHED PROFILE
  // ============================================================

  Future<Map<String, dynamic>?>
      getCachedProfile() async {
    final preferences =
        await SharedPreferences
            .getInstance();

    final value =
        preferences.getString(
      'cached_profile',
    );

    if (value == null) {
      return null;
    }

    return Map<String, dynamic>.from(
      jsonDecode(
        value,
      ) as Map,
    );
  }

  // ============================================================
  // SYNC PENDING DATA
  // ============================================================

  Future<void> syncPending() async {
    if (_syncInProgress) {
      return;
    }

    _syncInProgress = true;

    try {
      await _syncPendingData();
    } finally {
      _syncInProgress = false;
    }
  }

  Future<void> _syncPendingData() async {
    final database =
        await _db;

    await _syncPendingFarms(
      database,
    );

    await _syncPendingBlocks(
      database,
    );

    await _syncPendingTrees(
      database,
    );
  }

  // ============================================================
  // SYNC FARMS
  // ============================================================

  Future<void> _syncPendingFarms(
    Database database,
  ) async {
    final farms =
        await database.query(
      'farms',
      where:
          'pending = 1',
    );

    if (farms.isEmpty) {
      return;
    }

    print(
      '========================================',
    );

    print(
      'PENDING FARMS: ${farms.length}',
    );

    print(
      '========================================',
    );

    for (final row
        in farms) {
      final payload =
          Map<String, dynamic>.from(
        jsonDecode(
          row['payload']!
              as String,
        ) as Map,
      );

      final oldId =
          row['id']!
              as String;

      final geometry =
          payload['geometry']
                  ?.toString()
                  .trim() ??
              '';

      // ========================================================
      // OLD INVALID OFFLINE RECORD
      // ========================================================

      if (geometry.isEmpty) {
        print(
          '========================================',
        );

        print(
          'FARM SYNC SKIPPED',
        );

        print(
          'LOCAL ID: $oldId',
        );

        print(
          'REASON: Geometry is missing.',
        );

        print(
          '========================================',
        );

        continue;
      }

      if (!geometry
          .toUpperCase()
          .startsWith(
            'POLYGON',
          )) {
        print(
          '========================================',
        );

        print(
          'FARM SYNC SKIPPED',
        );

        print(
          'LOCAL ID: $oldId',
        );

        print(
          'REASON: Invalid geometry.',
        );

        print(
          'GEOMETRY: $geometry',
        );

        print(
          '========================================',
        );

        continue;
      }

      try {
        print(
          '========================================',
        );

        print(
          'SYNCING FARM',
        );

        print(
          'LOCAL ID: $oldId',
        );

        print(
          'NAME: ${payload['name']}',
        );

        print(
          'GEOMETRY: $geometry',
        );

        print(
          '========================================',
        );

        final result =
            await FarmApiServices
                .createFarm(
          name:
              payload['name']
                  .toString(),

          acreage:
              (payload['acreage']
                      as num)
                  .toDouble(),

          plantingDate:
              payload[
                      'plantingDate']
                  .toString(),

          farmType:
              payload['farmType']
                  .toString()
                  .toUpperCase(),

          geometry:
              geometry,

          region:
              payload['region']
                  .toString(),

          district:
              payload['district']
                  .toString(),

          ward:
              payload['ward']
                  .toString(),

          village:
              payload['village']
                  .toString(),
        );

        final newId =
            result['id']
                ?.toString();

        if (newId == null ||
            newId.isEmpty) {
          print(
            'Farm sync returned no server ID.',
          );

          print(
            'Keeping $oldId pending.',
          );

          continue;
        }

        // ======================================================
        // REPLACE LOCAL FARM + UPDATE CHILD IDs
        // ======================================================

        await database.transaction(
          (
            transaction,
          ) async {
            // Delete temporary local farm.

            await transaction.delete(
              'farms',
              where:
                  'id = ?',
              whereArgs: [
                oldId,
              ],
            );

            // Preserve original payload values such as geometry
            // if the backend response omits them.

            final serverFarm =
                <String, dynamic>{
              ...payload,
              ...result,
              'id':
                  newId,
              'geometry':
                  result['geometry'] ??
                      geometry,
            };

            await transaction.insert(
              'farms',
              {
                'id':
                    newId,
                'payload':
                    jsonEncode(
                  serverFarm,
                ),
                'pending':
                    0,
              },
              conflictAlgorithm:
                  ConflictAlgorithm
                      .replace,
            );

            // local farm ID -> server farm ID in blocks.

            await _replaceParentId(
              transaction,
              'blocks',
              'farm_id',
              oldId,
              newId,
              'farmId',
            );

            // local farm ID -> server farm ID in trees.

            await _replaceParentId(
              transaction,
              'trees',
              'farm_id',
              oldId,
              newId,
              'farmId',
            );
          },
        );

        print(
          '========================================',
        );

        print(
          'FARM SYNC SUCCESS',
        );

        print(
          'OLD ID: $oldId',
        );

        print(
          'NEW ID: $newId',
        );

        print(
          '========================================',
        );
      }

      // ========================================================
      // SERVER REJECTION
      // ========================================================

      on FarmApiException catch (e) {
        print(
          '========================================',
        );

        print(
          'PENDING FARM REJECTED BY SERVER',
        );

        print(
          'LOCAL ID: $oldId',
        );

        print(
          'STATUS: ${e.statusCode}',
        );

        print(
          'MESSAGE: ${e.message}',
        );

        print(
          '========================================',
        );

        // Do not delete local data.
        // Try another pending farm.

        continue;
      }

      // ========================================================
      // SERVER UNREACHABLE
      // ========================================================

      on TimeoutException catch (e) {
        print(
          'FARM SYNC TIMEOUT: $e',
        );

        // No reason to continue hitting the server.

        break;
      }

      on SocketException catch (e) {
        print(
          'FARM SYNC NETWORK ERROR: $e',
        );

        break;
      }

      catch (e) {
        print(
          'FARM SYNC ERROR [$oldId]: $e',
        );

        if (_isNetworkError(
          e,
        )) {
          break;
        }

        // Unexpected problem with this record:
        // leave it pending and continue.

        continue;
      }
    }
  }

  // ============================================================
  // SYNC BLOCKS
  // ============================================================

  Future<void> _syncPendingBlocks(
    Database database,
  ) async {
    final blocks =
        await database.query(
      'blocks',
      where:
          'pending = 1',
    );

    for (final row
        in blocks) {
      final payload =
          Map<String, dynamic>.from(
        jsonDecode(
          row['payload']!
              as String,
        ) as Map,
      );

      try {
        final result =
            await BlockApiServices
                .createBlock(
          farmId:
              row['farm_id']!
                  as String,

          name:
              payload['name']
                  as String,

          size:
              (payload['size']
                      as num)
                  .toDouble(),

          variety:
              payload['variety']
                  as String?,

          treeCount:
              payload['treeCount']
                  as int?,

          description:
              payload[
                      'description']
                  as String?,
        );

        final newId =
            result['id']
                ?.toString();

        if (newId == null ||
            newId.isEmpty) {
          continue;
        }

        final oldId =
            row['id']!
                as String;

        await database.transaction(
          (
            transaction,
          ) async {
            await transaction.delete(
              'blocks',
              where:
                  'id = ?',
              whereArgs: [
                oldId,
              ],
            );

            await transaction.insert(
              'blocks',
              {
                'id':
                    newId,
                'farm_id':
                    row['farm_id'],
                'payload':
                    jsonEncode(
                  result,
                ),
                'pending':
                    0,
              },
              conflictAlgorithm:
                  ConflictAlgorithm
                      .replace,
            );

            // Replace temporary block ID in child trees.

            await _replaceParentId(
              transaction,
              'trees',
              'block_id',
              oldId,
              newId,
              'blockId',
            );
          },
        );
      } catch (e) {
        print(
          'BLOCK SYNC ERROR: $e',
        );

        // Same behavior as your original implementation:
        // stop and retry on next sync.

        break;
      }
    }
  }

  // ============================================================
  // SYNC TREES
  // ============================================================

  Future<void> _syncPendingTrees(
    Database database,
  ) async {
    final trees =
        await database.query(
      'trees',
      where:
          'pending = 1',
    );

    for (final row
        in trees) {
      final payload =
          Map<String, dynamic>.from(
        jsonDecode(
          row['payload']!
              as String,
        ) as Map,
      );

      try {
        final result =
            await TreeApiServices
                .createTree(
          farmId:
              row['farm_id']!
                  as String,

          blockId:
              row['block_id']!
                  as String,

          variety:
              payload['variety']
                  as String,

          plantingYear:
              payload[
                      'plantingYear']
                  as int,

          status:
              payload['status']
                  as String,

          latitude:
              (payload['latitude']
                      as num?)
                  ?.toDouble(),

          longitude:
              (payload['longitude']
                      as num?)
                  ?.toDouble(),

          notes:
              payload['notes']
                  as String?,
        );

        final newId =
            result['id']
                ?.toString();

        if (newId == null ||
            newId.isEmpty) {
          continue;
        }

        await database.delete(
          'trees',
          where:
              'id = ?',
          whereArgs: [
            row['id'],
          ],
        );

        await database.insert(
          'trees',
          {
            'id':
                newId,
            'farm_id':
                row['farm_id'],
            'block_id':
                row['block_id'],
            'payload':
                jsonEncode(
              result,
            ),
            'pending':
                0,
          },
          conflictAlgorithm:
              ConflictAlgorithm
                  .replace,
        );
      } catch (e) {
        print(
          'TREE SYNC ERROR: $e',
        );

        // Retry later.

        break;
      }
    }
  }

  // ============================================================
  // REPLACE LOCAL PARENT ID WITH SERVER ID
  // ============================================================

  Future<void> _replaceParentId(
    Transaction transaction,
    String table,
    String column,
    String oldId,
    String newId,
    String payloadKey,
  ) async {
    final rows =
        await transaction.query(
      table,
      where:
          '$column = ?',
      whereArgs: [
        oldId,
      ],
    );

    for (final row
        in rows) {
      final payload =
          Map<String, dynamic>.from(
        jsonDecode(
          row['payload']!
              as String,
        ) as Map,
      );

      // Update ID inside JSON payload.

      payload[payloadKey] =
          newId;

      // Update both relational column and JSON payload.

      await transaction.update(
        table,
        {
          column:
              newId,
          'payload':
              jsonEncode(
            payload,
          ),
        },
        where:
            'id = ?',
        whereArgs: [
          row['id'],
        ],
      );
    }
  }
}