import 'dart:convert';
import 'dart:io';

const int serverPort = 5000;
const String mapsApiKey = 'AIzaSyCWIA9gZKanR12wo5HvtAHisy0TTK3yOmg';

String supabaseUrl = 'https://oaegqwdpqmiulqatggkw.supabase.co';
String supabaseAnonKey = '';
const String supabaseProjectRef = 'oaegqwdpqmiulqatggkw';
bool isSupabaseConnected = false;
DateTime? lastSupabaseSync;

String vercelUrl = 'https://ghatalpandalhopping-deltaspark.vercel.app';
const String vercelProductionDomain = 'https://ghatalpandalhopping-deltaspark.vercel.app';
bool isVercelLive = false;
DateTime? lastVercelCheck;

late File pandalsFile;
late File alertsFile;
late File supabaseConfigFile;
late File vercelConfigFile;
List<Map<String, dynamic>> pandalsData = [];
List<Map<String, dynamic>> alertsData = [];

void main() async {
  final currentDir = Directory.current.path;
  pandalsFile = File('$currentDir/server/data/pandals.json');
  alertsFile = File('$currentDir/server/data/alerts.json');
  supabaseConfigFile = File('$currentDir/server/data/supabase_config.json');
  vercelConfigFile = File('$currentDir/server/data/vercel_config.json');

  _loadData();

  final server = await HttpServer.bind(InternetAddress.anyIPv4, serverPort);
  print('======================================================');
  print('  Pandal Hopping Ghatal - REST Backend Server Active  ');
  print('  Listening on: http://localhost:$serverPort/            ');
  print('  Web Admin Panel: http://localhost:$serverPort/admin    ');
  print('  Google Maps Key: Configured ($mapsApiKey)');
  print('  Supabase URL:    $supabaseUrl');
  print('  Supabase Ref:    $supabaseProjectRef');
  print('  Vercel Live Web: $vercelUrl');
  print('======================================================');

  // Test Supabase connection on startup asynchronously
  _testSupabaseConnection().then((res) {
    if (res['connected'] == true) {
      print('[Supabase] Initial connection check successful: ${res['message']}');
    } else {
      print('[Supabase] Status: ${res['message']}');
    }
  });

  // Test Vercel connection on startup asynchronously
  _testVercelConnection().then((res) {
    if (res['live'] == true) {
      print('[Vercel] Live website reachable: ${res['message']}');
    } else {
      print('[Vercel] Status: ${res['message']}');
    }
  });

  await for (HttpRequest request in server) {
    _handleRequest(request);
  }
}

void _loadData() {
  try {
    if (pandalsFile.existsSync()) {
      pandalsData = List<Map<String, dynamic>>.from(
          jsonDecode(pandalsFile.readAsStringSync()));
    }
  } catch (e) {
    print('Error loading pandals.json: $e');
  }

  try {
    if (alertsFile.existsSync()) {
      alertsData = List<Map<String, dynamic>>.from(
          jsonDecode(alertsFile.readAsStringSync()));
    }
  } catch (e) {
    print('Error loading alerts.json: $e');
  }

  try {
    if (supabaseConfigFile.existsSync()) {
      final conf = jsonDecode(supabaseConfigFile.readAsStringSync());
      if (conf['supabaseUrl'] != null &&
          (conf['supabaseUrl'] as String).trim().isNotEmpty) {
        supabaseUrl = (conf['supabaseUrl'] as String).trim();
      }
      if (conf['supabaseAnonKey'] != null) {
        supabaseAnonKey = (conf['supabaseAnonKey'] as String).trim();
      }
      if (conf['lastSync'] != null) {
        lastSupabaseSync = DateTime.tryParse(conf['lastSync']);
      }
    } else {
      _saveSupabaseConfig();
    }
  } catch (e) {
    print('Error loading supabase_config.json: $e');
  }
  try {
    if (vercelConfigFile.existsSync()) {
      final conf = jsonDecode(vercelConfigFile.readAsStringSync());
      if (conf['vercelUrl'] != null && (conf['vercelUrl'] as String).trim().isNotEmpty) {
        vercelUrl = (conf['vercelUrl'] as String).trim();
      }
      if (conf['isLive'] != null) {
        isVercelLive = conf['isLive'] == true;
      }
      if (conf['lastCheck'] != null) {
        lastVercelCheck = DateTime.tryParse(conf['lastCheck']);
      }
    } else {
      _saveVercelConfig();
    }
  } catch (e) {
    print('Error loading vercel_config.json: $e');
  }
}

void _savePandals() {
  try {
    pandalsFile.writeAsStringSync(jsonEncode(pandalsData));
  } catch (e) {
    print('Error saving pandals.json: $e');
  }
}

void _saveAlerts() {
  try {
    alertsFile.writeAsStringSync(jsonEncode(alertsData));
  } catch (e) {
    print('Error saving alerts.json: $e');
  }
}

void _saveSupabaseConfig() {
  try {
    supabaseConfigFile.writeAsStringSync(jsonEncode({
      'supabaseUrl': supabaseUrl,
      'projectRef': supabaseProjectRef,
      'supabaseAnonKey': supabaseAnonKey,
      'autoSync': true,
      'lastSync': lastSupabaseSync?.toIso8601String(),
    }));
  } catch (e) {
    print('Error saving supabase_config.json: $e');
  }
}

void _saveVercelConfig() {
  try {
    vercelConfigFile.writeAsStringSync(jsonEncode({
      'vercelUrl': vercelUrl,
      'productionDomain': vercelProductionDomain,
      'isLive': isVercelLive,
      'lastCheck': lastVercelCheck?.toIso8601String(),
    }));
  } catch (e) {
    print('Error saving vercel_config.json: $e');
  }
}

Future<Map<String, dynamic>> _testVercelConnection([String? targetUrl]) async {
  final urlToTest = targetUrl ?? vercelUrl;
  try {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 4);
    final uri = Uri.parse(urlToTest);
    final req = await client.getUrl(uri);
    final resp = await req.close();
    client.close();

    final statusCode = resp.statusCode;
    // Considered live if 200 OK or 302 redirect (protected/SSO)
    isVercelLive = statusCode >= 200 && statusCode < 400;
    lastVercelCheck = DateTime.now();
    _saveVercelConfig();

    String msg;
    if (statusCode == 200) {
      msg = 'Live Vercel website responding (200 OK)';
    } else if (statusCode == 302) {
      msg = 'Deployment Protected: Vercel Authentication (SSO) active. Turn off Deployment Protection in Vercel settings for public access.';
    } else if (statusCode == 401) {
      msg = 'Vercel Deployment Protection active (HTTP 401). Turn off Deployment Protection in Vercel settings.';
    } else if (statusCode == 404) {
      msg = '404 NOT_FOUND: Domain not mapped to project on Vercel. Ensure domain is added under Project Settings → Domains.';
    } else {
      msg = 'Vercel server responded with HTTP $statusCode';
    }

    return {
      'live': isVercelLive,
      'statusCode': statusCode,
      'url': urlToTest,
      'message': msg,
      'timestamp': DateTime.now().toIso8601String(),
    };
  } catch (e) {
    isVercelLive = false;
    return {
      'live': false,
      'error': e.toString(),
      'url': urlToTest,
      'message': 'Failed to reach Vercel: \$e',
    };
  }
}

Future<Map<String, dynamic>> _testSupabaseConnection() async {
  try {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 4);
    final uri = Uri.parse('$supabaseUrl/rest/v1/');
    final req = await client.getUrl(uri);
    if (supabaseAnonKey.isNotEmpty) {
      req.headers.set('apikey', supabaseAnonKey);
      req.headers.set('Authorization', 'Bearer $supabaseAnonKey');
    }
    final resp = await req.close();
    client.close();

    isSupabaseConnected = resp.statusCode < 500;
    return {
      'connected': isSupabaseConnected,
      'statusCode': resp.statusCode,
      'supabaseUrl': supabaseUrl,
      'projectRef': supabaseProjectRef,
      'hasKey': supabaseAnonKey.isNotEmpty,
      'message': resp.statusCode == 200
          ? 'Connected to Supabase REST API (200 OK)'
          : (resp.statusCode == 401
              ? 'Supabase reachable. Enter Anon/Service Key for authenticated access.'
              : 'Supabase server responded with HTTP ${resp.statusCode}'),
      'timestamp': DateTime.now().toIso8601String(),
    };
  } catch (e) {
    isSupabaseConnected = false;
    return {
      'connected': false,
      'error': e.toString(),
      'supabaseUrl': supabaseUrl,
      'projectRef': supabaseProjectRef,
      'hasKey': supabaseAnonKey.isNotEmpty,
      'message': 'Failed to reach $supabaseUrl: $e',
    };
  }
}

Future<Map<String, dynamic>> _pushPandalsToSupabase() async {
  if (supabaseAnonKey.isEmpty) {
    return {
      'success': false,
      'error':
          'Supabase API Key (Anon / Service Role) is required to push data. Please save your API key in Supabase settings.'
    };
  }
  try {
    final client = HttpClient();
    final uri = Uri.parse('$supabaseUrl/rest/v1/pandals');
    final req = await client.postUrl(uri);
    req.headers.set('apikey', supabaseAnonKey);
    req.headers.set('Authorization', 'Bearer $supabaseAnonKey');
    req.headers.set('Content-Type', 'application/json');
    req.headers.set('Prefer', 'resolution=merge-duplicates');

    final payload = pandalsData.map((p) => {
      'id': p['id'],
      'name': p['name'],
      'zone': p['zone'],
      'address': p['address'],
      'lat': p['lat'],
      'lng': p['lng'],
      'distance': p['distance'],
      'theme': p['theme'],
      'people_in_line': p['peopleInLine'],
      'last_delta': p['lastDelta'],
      'trend': p['trend'],
      'max_capacity': p['maxCapacity'],
      'entry_rate_per_minute': p['entryRatePerMinute'],
      'queue_length_meters': p['queueLengthMeters'],
      'gate_status': p['gateStatus'],
      'last_updated': DateTime.now().toIso8601String(),
    }).toList();

    req.write(jsonEncode(payload));
    final resp = await req.close();
    final respBody = await utf8.decoder.bind(resp).join();
    client.close();

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      lastSupabaseSync = DateTime.now();
      isSupabaseConnected = true;
      _saveSupabaseConfig();
      return {'success': true, 'count': payload.length, 'statusCode': resp.statusCode};
    } else {
      return {'success': false, 'statusCode': resp.statusCode, 'error': respBody};
    }
  } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
}

Future<Map<String, dynamic>> _pullFromSupabase() async {
  if (supabaseAnonKey.isEmpty) {
    return {
      'success': false,
      'error': 'Supabase API Key is required to pull data.'
    };
  }
  try {
    final client = HttpClient();
    final uri = Uri.parse('$supabaseUrl/rest/v1/pandals?select=*');
    final req = await client.getUrl(uri);
    req.headers.set('apikey', supabaseAnonKey);
    req.headers.set('Authorization', 'Bearer $supabaseAnonKey');
    final resp = await req.close();
    final respBody = await utf8.decoder.bind(resp).join();
    client.close();

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final List<dynamic> remote = jsonDecode(respBody);
      for (final rp in remote) {
        final id = rp['id']?.toString();
        if (id == null) continue;
        final idx = pandalsData.indexWhere((p) => p['id'] == id);
        final mapped = {
          'id': id,
          'name': rp['name'] ?? 'Pandal',
          'zone': rp['zone'] ?? '',
          'address': rp['address'] ?? '',
          'lat': rp['lat'] ?? 22.6685,
          'lng': rp['lng'] ?? 87.7247,
          'distance': rp['distance'] ?? '1 km',
          'theme': rp['theme'] ?? '',
          'peopleInLine': rp['people_in_line'] ?? rp['peopleInLine'] ?? 0,
          'lastDelta': rp['last_delta'] ?? rp['lastDelta'] ?? 0,
          'trend': rp['trend'] ?? 'stable',
          'maxCapacity': rp['max_capacity'] ?? rp['maxCapacity'] ?? 200,
          'entryRatePerMinute': rp['entry_rate_per_minute'] ?? rp['entryRatePerMinute'] ?? 12,
          'queueLengthMeters': rp['queue_length_meters'] ?? rp['queueLengthMeters'] ?? 20,
          'gateStatus': rp['gate_status'] ?? rp['gateStatus'] ?? 'Open',
        };
        if (idx >= 0) {
          pandalsData[idx].addAll(mapped);
        } else {
          pandalsData.add(mapped);
        }
      }
      _savePandals();
      lastSupabaseSync = DateTime.now();
      isSupabaseConnected = true;
      _saveSupabaseConfig();
      return {'success': true, 'count': remote.length};
    } else {
      return {'success': false, 'statusCode': resp.statusCode, 'error': respBody};
    }
  } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
}

void _handleRequest(HttpRequest request) async {
  final res = request.response;

  // Add CORS headers
  res.headers.set('Access-Control-Allow-Origin', '*');
  res.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.headers.set('Access-Control-Allow-Headers', 'Origin, Content-Type, Accept, Authorization, apikey');

  if (request.method == 'OPTIONS') {
    res.statusCode = HttpStatus.ok;
    await res.close();
    return;
  }

  final path = request.uri.path;
  final method = request.method;

  try {
    // 1. Admin Web Portal
    if (path == '/admin' || path == '/admin/') {
      res.headers.contentType = ContentType.html;
      res.write(_getAdminDashboardHtml());
      await res.close();
      return;
    }

    // 2. Google Maps Config
    if (path == '/maps-config' && method == 'GET') {
      _jsonResponse(res, {
        'apiKey': mapsApiKey,
        'center': {'lat': 22.6685, 'lng': 87.7247},
        'defaultZoom': 14,
        'region': 'Ghatal, Paschim Medinipur, West Bengal',
      });
      return;
    }

    // 3. Supabase Integration Endpoints
    if (path == '/api/supabase/config') {
      if (method == 'GET') {
        _jsonResponse(res, {
          'supabaseUrl': supabaseUrl,
          'projectRef': supabaseProjectRef,
          'hasKey': supabaseAnonKey.isNotEmpty,
          'connected': isSupabaseConnected,
          'lastSync': lastSupabaseSync?.toIso8601String(),
        });
        return;
      } else if (method == 'POST') {
        final body = await _readJsonBody(request);
        if (body['supabaseUrl'] != null && (body['supabaseUrl'] as String).trim().isNotEmpty) {
          supabaseUrl = (body['supabaseUrl'] as String).trim();
        }
        if (body['supabaseAnonKey'] != null) {
          supabaseAnonKey = (body['supabaseAnonKey'] as String).trim();
        }
        _saveSupabaseConfig();
        final testRes = await _testSupabaseConnection();
        _jsonResponse(res, testRes);
        return;
      }
    }

    if (path == '/api/supabase/test') {
      final testRes = await _testSupabaseConnection();
      _jsonResponse(res, testRes);
      return;
    }

    if (path == '/api/supabase/sync-push' && method == 'POST') {
      final pushRes = await _pushPandalsToSupabase();
      _jsonResponse(res, pushRes);
      return;
    }

    if (path == '/api/supabase/sync-pull' && method == 'POST') {
      final pullRes = await _pullFromSupabase();
      _jsonResponse(res, pullRes);
      return;
    }

    // 3b. Vercel Live Deployment Endpoints
    if (path == '/api/vercel/config') {
      if (method == 'GET') {
        _jsonResponse(res, {
          'vercelUrl': vercelUrl,
          'productionDomain': vercelProductionDomain,
          'isLive': isVercelLive,
          'lastCheck': lastVercelCheck?.toIso8601String(),
        });
        return;
      } else if (method == 'POST') {
        final body = await _readJsonBody(request);
        if (body['vercelUrl'] != null && (body['vercelUrl'] as String).trim().isNotEmpty) {
          vercelUrl = (body['vercelUrl'] as String).trim();
        }
        _saveVercelConfig();
        final testRes = await _testVercelConnection();
        _jsonResponse(res, testRes);
        return;
      }
    }

    if (path == '/api/vercel/test') {
      final testUrl = request.uri.queryParameters['url'] ?? vercelUrl;
      final testRes = await _testVercelConnection(testUrl);
      _jsonResponse(res, testRes);
      return;
    }

    // 4. Stats Summary
    if (path == '/api/stats' && method == 'GET') {
      int totalQueues = pandalsData.fold(
          0, (sum, p) => sum + ((p['peopleInLine'] as num?)?.toInt() ?? 0));
      Map<String, dynamic>? shortest = pandalsData.isEmpty
          ? null
          : pandalsData.reduce((a, b) =>
              (a['peopleInLine'] ?? 0) < (b['peopleInLine'] ?? 0) ? a : b);

      _jsonResponse(res, {
        'totalPandals': pandalsData.length,
        'totalPeopleInLine': totalQueues,
        'shortestQueuePandal': shortest?['name'] ?? 'None',
        'shortestQueueCount': shortest?['peopleInLine'] ?? 0,
        'activeAlerts': alertsData.where((a) => a['active'] == true).length,
        'supabaseConnected': isSupabaseConnected,
        'supabaseProjectRef': supabaseProjectRef,
        'vercelUrl': vercelUrl,
        'isVercelLive': isVercelLive,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return;
    }

    // 5. Pandals Endpoints
    if (path == '/api/pandals') {
      if (method == 'GET') {
        _jsonResponse(res, pandalsData);
        return;
      } else if (method == 'POST') {
        final body = await _readJsonBody(request);
        final newPandal = {
          'id': body['id'] ?? 'pandal_${DateTime.now().millisecondsSinceEpoch}',
          'name': body['name'] ?? 'New Pandal',
          'zone': body['zone'] ?? 'Ghatal Central Zone',
          'address': body['address'] ?? 'Ghatal Municipality',
          'lat': (body['lat'] as num?)?.toDouble() ?? 22.6685,
          'lng': (body['lng'] as num?)?.toDouble() ?? 87.7247,
          'distance': body['distance'] ?? '1.0 km',
          'peopleInLine': (body['peopleInLine'] as num?)?.toInt() ?? 25,
          'lastDelta': 0,
          'trend': 'stable',
          'maxCapacity': (body['maxCapacity'] as num?)?.toInt() ?? 200,
          'entryRatePerMinute': (body['entryRatePerMinute'] as num?)?.toInt() ?? 12,
          'queueLengthMeters': 15,
          'gateStatus': body['gateStatus'] ?? 'Open',
          'theme': body['theme'] ?? 'Puja Artistry',
          'gates': body['gates'] ?? [
            {
              'name': 'Main Gate',
              'gateCode': 'Gate A',
              'peopleCount': 25,
              'estimatedWaitMinutes': 2,
              'status': 'Smooth',
              'statusColor': '#2E7D32'
            }
          ],
        };
        pandalsData.add(newPandal);
        _savePandals();
        _jsonResponse(res, newPandal, status: HttpStatus.created);
        return;
      }
    }

    // Pandal by ID & Queue update
    final pandalQueueMatch = RegExp(r'^/api/pandals/([a-zA-Z0-9_\-]+)/queue$').firstMatch(path);
    if (pandalQueueMatch != null && method == 'POST') {
      final pandalId = pandalQueueMatch.group(1);
      final body = await _readJsonBody(request);
      final index = pandalsData.indexWhere((p) => p['id'] == pandalId);

      if (index == -1) {
        _jsonResponse(res, {'error': 'Pandal not found'}, status: HttpStatus.notFound);
        return;
      }

      final current = pandalsData[index];
      final newCount = (body['peopleInLine'] as num?)?.toInt() ?? current['peopleInLine'];
      final lastDelta = (body['lastDelta'] as num?)?.toInt() ?? (newCount - (current['peopleInLine'] as int));
      final entryRate = (body['entryRatePerMinute'] as num?)?.toInt() ?? current['entryRatePerMinute'];
      final gateStatus = body['gateStatus'] ?? current['gateStatus'];

      current['peopleInLine'] = newCount;
      current['lastDelta'] = lastDelta;
      current['entryRatePerMinute'] = entryRate;
      current['gateStatus'] = gateStatus;
      current['queueLengthMeters'] = (newCount * 0.42).round().clamp(5, 150);
      current['trend'] = lastDelta > 0
          ? 'increasing'
          : (lastDelta < 0 ? 'decreasing' : 'stable');

      if (body['gates'] != null) {
        current['gates'] = body['gates'];
      }

      pandalsData[index] = current;
      _savePandals();
      _jsonResponse(res, current);
      return;
    }

    final singlePandalMatch = RegExp(r'^/api/pandals/([a-zA-Z0-9_\-]+)$').firstMatch(path);
    if (singlePandalMatch != null) {
      final pandalId = singlePandalMatch.group(1);
      final index = pandalsData.indexWhere((p) => p['id'] == pandalId);

      if (index == -1) {
        _jsonResponse(res, {'error': 'Pandal not found'}, status: HttpStatus.notFound);
        return;
      }

      if (method == 'GET') {
        _jsonResponse(res, pandalsData[index]);
        return;
      } else if (method == 'PUT') {
        final body = await _readJsonBody(request);
        pandalsData[index].addAll(body);
        _savePandals();
        _jsonResponse(res, pandalsData[index]);
        return;
      } else if (method == 'DELETE') {
        pandalsData.removeAt(index);
        _savePandals();
        _jsonResponse(res, {'success': true, 'deleted': pandalId});
        return;
      }
    }

    // 6. Alerts Endpoints
    if (path == '/api/alerts') {
      if (method == 'GET') {
        _jsonResponse(res, alertsData);
        return;
      } else if (method == 'POST') {
        final body = await _readJsonBody(request);
        final newAlert = {
          'id': 'alert_${DateTime.now().millisecondsSinceEpoch}',
          'title': body['title'] ?? 'Crowd Announcement',
          'message': body['message'] ?? '',
          'level': body['level'] ?? 'info',
          'timestamp': DateTime.now().toIso8601String(),
          'active': true,
        };
        alertsData.insert(0, newAlert);
        _saveAlerts();
        _jsonResponse(res, newAlert, status: HttpStatus.created);
        return;
      }
    }

    final singleAlertMatch = RegExp(r'^/api/alerts/([a-zA-Z0-9_\-]+)$').firstMatch(path);
    if (singleAlertMatch != null && method == 'DELETE') {
      final alertId = singleAlertMatch.group(1);
      alertsData.removeWhere((a) => a['id'] == alertId);
      _saveAlerts();
      _jsonResponse(res, {'success': true, 'deleted': alertId});
      return;
    }

    // 7. Static Logo
    if (path == '/deltaspark_logo.jpg' || path == '/assets/images/deltaspark_logo.jpg') {
      final logoFile = File('web/deltaspark_logo.jpg');
      if (logoFile.existsSync()) {
        res.headers.contentType = ContentType('image', 'jpeg');
        await res.addStream(logoFile.openRead());
        await res.close();
        return;
      }
    }

    // Default 404
    _jsonResponse(res, {'error': 'Endpoint not found', 'path': path}, status: HttpStatus.notFound);
  } catch (e, stack) {
    print('Server Error on $path: $e\n$stack');
    _jsonResponse(res, {'error': e.toString()}, status: HttpStatus.internalServerError);
  }
}

Future<Map<String, dynamic>> _readJsonBody(HttpRequest request) async {
  final content = await utf8.decoder.bind(request).join();
  if (content.trim().isEmpty) return {};
  return jsonDecode(content) as Map<String, dynamic>;
}

void _jsonResponse(HttpResponse res, dynamic data, {int status = HttpStatus.ok}) {
  res.statusCode = status;
  res.headers.contentType = ContentType.json;
  res.write(jsonEncode(data));
  res.close();
}

String _getAdminDashboardHtml() {
  return '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Ghatal Sharodutsav — Admin Crowd & Queue Command Center</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">
  <script src="https://maps.googleapis.com/maps/api/js?key=$mapsApiKey&libraries=geometry&loading=async"></script>
  <style>
    :root {
      --primary: #B71C1C;
      --primary-dark: #8E0000;
      --gold: #D4A017;
      --bg: #0F0909;
      --card-bg: #1B1212;
      --card-border: #331F1F;
      --text: #FBE9E7;
      --text-muted: #BCAAA4;
      --success: #2E7D32;
      --warning: #F57F17;
      --danger: #E53935;
      --supabase-green: #10B981;
      --supabase-emerald: #059669;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: 'Poppins', sans-serif;
      background: var(--bg);
      color: var(--text);
      min-height: 100vh;
      display: flex;
      flex-direction: column;
    }
    header {
      background: linear-gradient(90deg, #2D0808, #180505);
      border-bottom: 1px solid var(--card-border);
      padding: 14px 28px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      position: sticky;
      top: 0;
      z-index: 100;
    }
    .brand {
      display: flex;
      align-items: center;
      gap: 14px;
    }
    .brand-icon {
      width: 44px;
      height: 44px;
      background: var(--primary);
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 24px;
      box-shadow: 0 4px 12px rgba(183, 28, 28, 0.4);
    }
    .brand-title h1 {
      font-size: 18px;
      font-weight: 800;
      letter-spacing: -0.3px;
      color: #FFF;
    }
    .brand-title p {
      font-size: 11px;
      color: var(--gold);
      font-weight: 500;
    }
    .header-actions {
      display: flex;
      gap: 10px;
      align-items: center;
    }
    .btn {
      padding: 8px 14px;
      border-radius: 10px;
      font-family: inherit;
      font-size: 12px;
      font-weight: 600;
      cursor: pointer;
      border: none;
      display: inline-flex;
      align-items: center;
      gap: 6px;
      transition: all 0.2s;
    }
    .btn-primary {
      background: var(--primary);
      color: white;
    }
    .btn-primary:hover {
      background: #D32F2F;
      box-shadow: 0 0 16px rgba(229, 57, 53, 0.4);
    }
    .btn-outline {
      background: transparent;
      border: 1px solid var(--card-border);
      color: var(--text);
    }
    .btn-outline:hover {
      background: var(--card-bg);
      border-color: var(--gold);
    }
    .btn-gold {
      background: var(--gold);
      color: #1A0F00;
    }
    .btn-supabase {
      background: rgba(16, 185, 129, 0.15);
      border: 1px solid var(--supabase-green);
      color: #6EE7B7;
    }
    .btn-supabase:hover {
      background: rgba(16, 185, 129, 0.28);
      box-shadow: 0 0 14px rgba(16, 185, 129, 0.4);
    }
    .badge-live {
      background: rgba(229, 57, 53, 0.2);
      border: 1px solid var(--danger);
      color: #FF8A80;
      padding: 4px 10px;
      border-radius: 20px;
      font-size: 11px;
      font-weight: 700;
      display: flex;
      align-items: center;
      gap: 6px;
    }
    .badge-supabase-header {
      background: rgba(16, 185, 129, 0.15);
      border: 1px solid #10B981;
      color: #6EE7B7;
      padding: 4px 12px;
      border-radius: 20px;
      font-size: 11px;
      font-weight: 700;
      display: flex;
      align-items: center;
      gap: 7px;
      cursor: pointer;
      transition: all 0.2s;
    }
    .badge-supabase-header:hover {
      background: rgba(16, 185, 129, 0.25);
      box-shadow: 0 0 12px rgba(16, 185, 129, 0.35);
    }
    .badge-vercel-header {
      background: rgba(56, 189, 248, 0.15);
      border: 1px solid #38BDF8;
      color: #BAE6FD;
      padding: 4px 12px;
      border-radius: 20px;
      font-size: 11px;
      font-weight: 700;
      display: flex;
      align-items: center;
      gap: 7px;
      cursor: pointer;
      text-decoration: none;
      transition: all 0.2s;
    }
    .badge-vercel-header:hover {
      background: rgba(56, 189, 248, 0.28);
      box-shadow: 0 0 12px rgba(56, 189, 248, 0.4);
    }
    .btn-vercel {
      background: rgba(56, 189, 248, 0.15);
      border: 1px solid #38BDF8;
      color: #BAE6FD;
    }
    .btn-vercel:hover {
      background: rgba(56, 189, 248, 0.28);
      box-shadow: 0 0 14px rgba(56, 189, 248, 0.4);
    }
    .live-dot {
      width: 8px;
      height: 8px;
      background: var(--danger);
      border-radius: 50%;
      animation: pulse 1.4s infinite;
    }
    .supabase-dot {
      width: 8px;
      height: 8px;
      background: #10B981;
      border-radius: 50%;
      box-shadow: 0 0 8px #10B981;
    }
    @keyframes pulse {
      0%, 100% { opacity: 1; transform: scale(1); }
      50% { opacity: 0.4; transform: scale(0.8); }
    }
    main {
      padding: 24px 28px;
      display: grid;
      grid-template-columns: 1fr 380px;
      gap: 24px;
      flex: 1;
    }
    @media (max-width: 1080px) {
      main { grid-template-columns: 1fr; }
    }
    .stats-row {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 16px;
      margin-bottom: 24px;
    }
    .stat-card {
      background: var(--card-bg);
      border: 1px solid var(--card-border);
      padding: 16px 18px;
      border-radius: 16px;
      display: flex;
      flex-direction: column;
      gap: 6px;
      transition: border-color 0.2s;
    }
    .stat-label {
      font-size: 11px;
      color: var(--text-muted);
      text-transform: uppercase;
      letter-spacing: 0.8px;
      font-weight: 600;
    }
    .stat-val {
      font-size: 24px;
      font-weight: 800;
      color: #FFF;
    }
    .map-container {
      background: var(--card-bg);
      border: 1px solid var(--card-border);
      border-radius: 18px;
      overflow: hidden;
      margin-bottom: 24px;
      height: 380px;
      position: relative;
    }
    #google-map {
      width: 100%;
      height: 100%;
    }
    .map-overlay-title {
      position: absolute;
      top: 14px;
      left: 14px;
      background: rgba(15, 9, 9, 0.85);
      backdrop-filter: blur(8px);
      padding: 8px 14px;
      border-radius: 10px;
      border: 1px solid var(--card-border);
      font-size: 12px;
      font-weight: 700;
      color: var(--gold);
      z-index: 10;
    }
    .pandals-table-card {
      background: var(--card-bg);
      border: 1px solid var(--card-border);
      border-radius: 18px;
      padding: 20px;
    }
    .table-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16px;
      flex-wrap: wrap;
      gap: 10px;
    }
    .table-title {
      font-size: 16px;
      font-weight: 700;
    }
    .table-responsive {
      overflow-x: auto;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      font-size: 13px;
    }
    th {
      text-align: left;
      padding: 12px;
      color: var(--text-muted);
      font-size: 11px;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      border-bottom: 1px solid var(--card-border);
    }
    td {
      padding: 14px 12px;
      border-bottom: 1px solid rgba(51, 31, 31, 0.5);
      vertical-align: middle;
    }
    .pandal-name {
      font-weight: 700;
      color: #FFF;
    }
    .pandal-sub {
      font-size: 11px;
      color: var(--text-muted);
    }
    .queue-ctrl {
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .btn-step {
      width: 28px;
      height: 28px;
      border-radius: 8px;
      background: #2D1A1A;
      color: #FFF;
      border: 1px solid var(--card-border);
      font-size: 14px;
      font-weight: bold;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      transition: all 0.15s;
    }
    .btn-step:hover {
      background: var(--primary);
    }
    .queue-val {
      font-size: 15px;
      font-weight: 800;
      min-width: 44px;
      text-align: center;
      color: #FFF;
    }
    .crowd-pill {
      display: inline-block;
      padding: 3px 8px;
      border-radius: 8px;
      font-size: 10px;
      font-weight: 700;
    }
    .crowd-low { background: rgba(46, 125, 50, 0.2); color: #81C784; }
    .crowd-mod { background: rgba(245, 127, 23, 0.2); color: #FFD54F; }
    .crowd-high { background: rgba(229, 57, 53, 0.2); color: #FF8A80; }
    
    .sidebar-panel {
      display: flex;
      flex-direction: column;
      gap: 20px;
    }
    .panel-card {
      background: var(--card-bg);
      border: 1px solid var(--card-border);
      border-radius: 18px;
      padding: 20px;
    }
    .panel-card h3 {
      font-size: 15px;
      font-weight: 700;
      margin-bottom: 6px;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .form-group {
      margin-bottom: 14px;
    }
    .form-group label {
      display: block;
      font-size: 11px;
      font-weight: 600;
      color: var(--text-muted);
      margin-bottom: 6px;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }
    .form-control {
      width: 100%;
      padding: 10px 12px;
      border-radius: 10px;
      background: #0F0909;
      border: 1px solid var(--card-border);
      color: #FFF;
      font-family: inherit;
      font-size: 12px;
      outline: none;
      transition: border-color 0.2s;
    }
    .form-control:focus {
      border-color: var(--gold);
    }
    textarea.form-control {
      min-height: 70px;
      resize: vertical;
    }
    .alert-item {
      background: #140C0C;
      border: 1px solid var(--card-border);
      border-radius: 12px;
      padding: 12px;
      margin-bottom: 10px;
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      gap: 10px;
    }
    .alert-title {
      font-size: 12px;
      font-weight: 700;
      color: #FFF;
      margin-bottom: 2px;
    }
    .alert-text {
      font-size: 11px;
      color: var(--text-muted);
      line-height: 1.4;
    }
    .alert-delete {
      background: transparent;
      border: none;
      color: #FF8A80;
      cursor: pointer;
      font-size: 14px;
      padding: 2px 4px;
    }
    .code-box {
      background: #0D0606;
      border: 1px solid #331F1F;
      border-radius: 10px;
      padding: 12px;
      font-family: 'JetBrains Mono', monospace;
      font-size: 11px;
      color: #E0E0E0;
      overflow-x: auto;
      white-space: pre;
      line-height: 1.4;
      max-height: 160px;
    }
  </style>
</head>
<body>

  <!-- Security Passcode Modal -->
  <div id="auth-modal" style="display: none; position: fixed; inset: 0; background: rgba(10, 5, 5, 0.94); backdrop-filter: blur(8px); z-index: 99999; align-items: center; justify-content: center;">
    <div style="background: #1B1212; border: 1px solid #331F1F; border-radius: 20px; padding: 32px; max-width: 420px; width: 90%; box-shadow: 0 20px 60px rgba(0,0,0,0.85); text-align: center;">
      <div style="width: 68px; height: 68px; border-radius: 50%; background: radial-gradient(circle, #8E0000, #240A0A); border: 2px solid #D4A017; margin: 0 auto 18px; display: flex; align-items: center; justify-content: center; font-size: 32px; box-shadow: 0 0 24px rgba(212, 160, 23, 0.3);">
        🛡️
      </div>
      <h2 style="font-size: 20px; font-weight: 800; color: #FFF; margin-bottom: 6px;">Admin Passcode Required</h2>
      <p style="font-size: 12px; color: #BCAAA4; margin-bottom: 22px;">Authorized Ghatal Sharodutsav Committee & Police Command Center.</p>
      
      <div style="text-align: left; margin-bottom: 16px;">
        <label style="font-size: 11px; font-weight: 700; color: #D4A017; letter-spacing: 0.5px; display: block; margin-bottom: 6px;">ADMINISTRATOR PASSWORD</label>
        <div style="display: flex; gap: 8px;">
          <input type="password" id="web-pass-input" placeholder="Enter administrator password" style="flex: 1; padding: 12px 14px; border-radius: 10px; background: #0F0909; border: 1px solid #331F1F; color: #FFF; font-family: inherit; font-size: 13px; outline: none;" onkeydown="if(event.key==='Enter') verifyWebPass()">
          <button type="button" onclick="toggleWebPass()" style="padding: 0 14px; border-radius: 10px; background: #2D1A1A; border: 1px solid #331F1F; color: #FFF; cursor: pointer;">👁️</button>
        </div>
        <div id="web-auth-err" style="display: none; color: #FF8A80; background: #2E1010; border: 1px solid #E53935; border-radius: 8px; padding: 6px 10px; font-size: 11px; margin-top: 8px; font-weight: 500;">Incorrect passcode. Please try again.</div>
      </div>

      <button onclick="verifyWebPass()" style="width: 100%; padding: 12px; border-radius: 10px; background: #B71C1C; color: #FFF; font-weight: 700; border: none; font-size: 13px; cursor: pointer; transition: all 0.2s; box-shadow: 0 4px 14px rgba(183, 28, 28, 0.4);">
        Unlock Console 🔓
      </button>
    </div>
  </div>

  <!-- Supabase Cloud Connection Modal -->
  <div id="supabase-modal" style="display: none; position: fixed; inset: 0; background: rgba(10, 5, 5, 0.90); backdrop-filter: blur(8px); z-index: 99998; align-items: center; justify-content: center; padding: 20px;">
    <div style="background: #181010; border: 1px solid #331F1F; border-radius: 20px; padding: 28px; max-width: 620px; width: 100%; max-height: 90vh; overflow-y: auto; box-shadow: 0 24px 70px rgba(0,0,0,0.9);">
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px; border-bottom: 1px solid #2B1616; padding-bottom: 12px;">
        <div style="display: flex; align-items: center; gap: 10px;">
          <span style="font-size: 26px;">⚡</span>
          <div>
            <h2 style="font-size: 18px; font-weight: 800; color: #FFF;">Supabase Cloud Integration</h2>
            <p style="font-size: 11px; color: #10B981; font-weight: 600;">Project Reference: $supabaseProjectRef</p>
          </div>
        </div>
        <button onclick="closeSupabaseModal()" style="background: #2D1A1A; border: 1px solid #331F1F; color: #FFF; width: 32px; height: 32px; border-radius: 8px; cursor: pointer; font-size: 14px;">✕</button>
      </div>

      <!-- Live Status Card -->
      <div style="background: #0E1812; border: 1px solid #10B981; border-radius: 12px; padding: 14px; margin-bottom: 18px; display: flex; justify-content: space-between; align-items: center; gap: 12px;">
        <div style="display: flex; align-items: center; gap: 10px;">
          <div class="supabase-dot" id="modal-supabase-dot"></div>
          <div>
            <div style="font-size: 12px; font-weight: 700; color: #6EE7B7;" id="modal-supabase-status">Testing Connection...</div>
            <div style="font-size: 10px; color: #A7F3D0; font-family: monospace;" id="modal-supabase-url">$supabaseUrl</div>
          </div>
        </div>
        <button onclick="testSupabaseConnection()" class="btn btn-supabase" style="padding: 6px 12px; font-size: 11px;">
          ↻ Ping API
        </button>
      </div>

      <!-- Settings Form -->
      <div class="form-group">
        <label>Supabase Project REST URL</label>
        <input type="text" id="sb-url-input" class="form-control" value="$supabaseUrl" placeholder="https://<project-ref>.supabase.co">
      </div>

      <div class="form-group">
        <label>Supabase API Key (Anon / Service Role Key)</label>
        <div style="display: flex; gap: 8px;">
          <input type="password" id="sb-key-input" class="form-control" placeholder="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." style="font-family: monospace; font-size: 11px;">
          <button type="button" onclick="toggleSbKeyVisibility()" class="btn btn-outline" style="padding: 0 12px;">👁️</button>
          <button type="button" onclick="saveSupabaseSettings()" class="btn btn-primary" style="white-space: nowrap;">Save Key</button>
        </div>
        <small style="color: var(--text-muted); font-size: 10px; display: block; margin-top: 4px;">Get your API key from Supabase Dashboard → Settings → API (Project API keys).</small>
      </div>

      <!-- Sync Controls -->
      <div style="background: #1F1414; border: 1px solid #331F1F; border-radius: 12px; padding: 14px; margin-bottom: 18px;">
        <div style="font-size: 12px; font-weight: 700; color: var(--gold); margin-bottom: 8px;">Cloud Synchronization Actions</div>
        <div style="display: flex; gap: 10px; flex-wrap: wrap;">
          <button onclick="pushPandalsToSupabase()" class="btn btn-primary" style="background: #059669; border: none;">
            🚀 Push Pandals & Alerts to Cloud
          </button>
          <button onclick="pullPandalsFromSupabase()" class="btn btn-outline">
            📥 Pull Data from Cloud
          </button>
          <a href="https://supabase.com/dashboard/project/$supabaseProjectRef" target="_blank" class="btn btn-outline" style="text-decoration: none;">
            Open Supabase Studio ↗
          </a>
        </div>
        <div id="sb-sync-feedback" style="font-size: 11px; margin-top: 10px; color: #81C784; display: none;"></div>
      </div>

      <!-- SQL Table Setup -->
      <div style="margin-bottom: 10px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
          <label style="font-size: 11px; font-weight: 700; color: #D4A017; text-transform: uppercase;">1-Click Database Setup (Supabase SQL)</label>
          <button onclick="copySupabaseSql()" class="btn btn-outline" style="padding: 3px 8px; font-size: 10px;" id="copy-sql-btn">📋 Copy SQL</button>
        </div>
        <div class="code-box" id="supabase-sql-code">-- 1. Create Pandals Table
create table if not exists public.pandals (
  id text primary key,
  name text not null,
  zone text,
  address text,
  lat double precision,
  lng double precision,
  distance text,
  theme text,
  people_in_line int default 0,
  last_delta int default 0,
  trend text default 'stable',
  max_capacity int default 200,
  entry_rate_per_minute int default 12,
  queue_length_meters int default 20,
  gate_status text default 'Open',
  last_updated timestamp with time zone default timezone('utc'::text, now())
);

-- 2. Create Alerts Table
create table if not exists public.alerts (
  id text primary key,
  title text not null,
  message text not null,
  level text default 'warning',
  timestamp timestamp with time zone default timezone('utc'::text, now()),
  active boolean default true
);

-- 3. Enable Public Read & RLS
alter table public.pandals enable row level security;
alter table public.alerts enable row level security;

create policy "Public read pandals" on public.pandals for select using (true);
create policy "Public read alerts" on public.alerts for select using (true);
create policy "Anon update pandals" on public.pandals for all using (true);
create policy "Anon update alerts" on public.alerts for all using (true);</div>
      </div>
    </div>
  </div>

  <!-- Vercel Deployment Hub Modal -->
  <div id="vercel-modal" style="display: none; position: fixed; inset: 0; background: rgba(10, 5, 5, 0.90); backdrop-filter: blur(8px); z-index: 99998; align-items: center; justify-content: center; padding: 20px;">
    <div style="background: #101626; border: 1px solid #1E293B; border-radius: 20px; padding: 28px; max-width: 620px; width: 100%; max-height: 90vh; overflow-y: auto; box-shadow: 0 24px 70px rgba(0,0,0,0.9);">
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px; border-bottom: 1px solid #1E293B; padding-bottom: 12px;">
        <div style="display: flex; align-items: center; gap: 10px;">
          <span style="font-size: 26px;">▲</span>
          <div>
            <h2 style="font-size: 18px; font-weight: 800; color: #FFF;">Vercel Live Web Deployment</h2>
            <p style="font-size: 11px; color: #38BDF8; font-weight: 600;">Production Website Hub & Health Monitor</p>
          </div>
        </div>
        <button onclick="closeVercelModal()" style="background: #1E293B; border: 1px solid #334155; color: #FFF; width: 32px; height: 32px; border-radius: 8px; cursor: pointer; font-size: 14px;">✕</button>
      </div>

      <!-- Live Status Card -->
      <div style="background: #0B101E; border: 1px solid #38BDF8; border-radius: 12px; padding: 14px; margin-bottom: 18px; display: flex; justify-content: space-between; align-items: center; gap: 12px;">
        <div style="display: flex; align-items: center; gap: 10px;">
          <div style="width: 10px; height: 10px; border-radius: 50%; background: #38BDF8; box-shadow: 0 0 8px #38BDF8;" id="modal-vercel-dot"></div>
          <div>
            <div style="font-size: 12px; font-weight: 700; color: #BAE6FD;" id="modal-vercel-status">Deployment Ready</div>
            <div style="font-size: 10px; color: #7DD3FC; font-family: monospace;" id="modal-vercel-url">$vercelUrl</div>
          </div>
        </div>
        <button onclick="testVercelConnection()" class="btn btn-vercel" style="padding: 6px 12px; font-size: 11px;">
          ↻ Ping Vercel
        </button>
      </div>

      <!-- Settings Form -->
      <div class="form-group">
        <label>Vercel Deployment URL</label>
        <div style="display: flex; gap: 8px;">
          <input type="text" id="vercel-url-input" class="form-control" value="$vercelUrl" placeholder="https://....vercel.app">
          <button type="button" onclick="saveVercelSettings()" class="btn btn-primary" style="background: #0284C7; white-space: nowrap;">Save & Ping</button>
        </div>
      </div>

      <!-- Actions -->
      <div style="display: flex; gap: 10px; margin-bottom: 18px; flex-wrap: wrap;">
        <a href="$vercelUrl" target="_blank" class="btn btn-primary" style="background: #0284C7; text-decoration: none; padding: 10px 16px;">
          🌐 Open Live Website in New Tab ↗
        </a>
        <button onclick="copyVercelUrl()" class="btn btn-outline" style="border-color: #38BDF8; color: #BAE6FD;" id="copy-vercel-btn">
          📋 Copy Live Link
        </button>
      </div>

      <!-- Deployment Guide & Protection Tips -->
      <div style="background: #080C14; border: 1px solid #1E293B; border-radius: 12px; padding: 14px; font-size: 11px; line-height: 1.5; color: #CBD5E1;">
        <div style="font-weight: 700; color: #F59E0B; margin-bottom: 6px;">ℹ️ Deployment Protection & Live Access Notes:</div>
        <p style="margin-bottom: 6px;">
          • <b>Live Build Generated:</b> Flutter Web release bundle is compiled into <code>build/web</code> and configured with <code>vercel.json</code>.
        </p>
        <p style="margin-bottom: 6px;">
          • <b>If 404 NOT_FOUND Appears:</b> The requested domain must match your project's assigned team URL (<code>ghatalpandalhopping-deltaspark.vercel.app</code>) or be registered under <b>Vercel Project → Settings → Domains</b>.
        </p>
        <p style="margin-bottom: 6px;">
          • <b>If Login Prompt Appears:</b> Vercel has "Deployment Protection" enabled. Go to <b>Vercel Project → Settings → Deployment Protection</b> and set Standard Protection to <b>Disabled</b>.
        </p>
        <p>
          • <b>Git Automatic Deployments:</b> Every commit pushed to <code>origin/main</code> automatically triggers a fresh deployment on Vercel.
        </p>
      </div>
    </div>
  </div>

  <header>
    <div class="brand">
      <div class="brand-icon">🛕</div>
      <div class="brand-title">
        <h1>Ghatal Sharodutsav Admin Command</h1>
        <p>Google Maps & Real-time Line Queue Controller</p>
      </div>
    </div>
    <div class="header-actions">
      <!-- Vercel Header Badge -->
      <a href="$vercelUrl" target="_blank" class="badge-vercel-header" id="header-vercel-badge" title="Open Live Vercel Website">
        <span style="font-size: 11px;">▲</span>
        <span id="header-vercel-text">Live Web Site ↗</span>
      </a>
      <button onclick="openVercelModal()" class="btn btn-outline" style="border-color: #38BDF8; color: #BAE6FD; padding: 4px 10px; font-size: 11px;">
        ⚙️ Vercel
      </button>

      <!-- Supabase Header Badge -->
      <div class="badge-supabase-header" onclick="openSupabaseModal()" title="Manage Supabase Cloud Database">
        <div class="supabase-dot" id="header-sb-dot"></div>
        <span id="header-sb-text">⚡ Supabase: $supabaseProjectRef</span>
      </div>
      <div class="badge-live">
        <div class="live-dot"></div>
        LIVE REST (:5000)
      </div>
      <button onclick="fetchData()" class="btn btn-primary">↻ Sync Now</button>
      <button onclick="lockAdminSession()" class="btn btn-outline" style="border-color: #E53935; color: #FF8A80;">🔒 Lock</button>
    </div>
  </header>

  <main>
    <div class="main-content">
      <!-- 6 Stats Cards -->
      <div class="stats-row">
        <div class="stat-card">
          <div class="stat-label">Total in Queues</div>
          <div class="stat-val" id="stat-total-queue">0</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Active Pandals</div>
          <div class="stat-val" id="stat-pandal-count">0</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Shortest Line</div>
          <div class="stat-val" id="stat-shortest" style="font-size: 16px; color: var(--gold);">Loading...</div>
        </div>
        <div class="stat-card" style="border-color: rgba(56, 189, 248, 0.4); cursor: pointer;" onclick="openVercelModal()">
          <div style="display: flex; justify-content: space-between; align-items: center;">
            <div class="stat-label" style="color: #7DD3FC;">Vercel Web App</div>
            <span style="font-size: 11px; color: #38BDF8; font-weight: 600;">▲ Live ↗</span>
          </div>
          <div class="stat-val" id="stat-vercel-val" style="font-size: 13px; color: #BAE6FD; font-weight: 700; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
            Live Web App
          </div>
          <div style="font-size: 10px; color: var(--text-muted); display: flex; align-items: center; gap: 5px;">
            <span style="display:inline-block; width:6px; height:6px; border-radius:50%; background:#38BDF8;" id="stat-vercel-indicator"></span>
            <span id="stat-vercel-sub">Production Web Ready</span>
          </div>
        </div>
        <div class="stat-card" style="border-color: rgba(16, 185, 129, 0.4); cursor: pointer;" onclick="openSupabaseModal()">
          <div style="display: flex; justify-content: space-between; align-items: center;">
            <div class="stat-label" style="color: #6EE7B7;">Supabase Cloud</div>
            <span style="font-size: 11px; color: var(--gold); font-weight: 600;">⚙️ Setup</span>
          </div>
          <div class="stat-val" id="stat-supabase-val" style="font-size: 15px; color: #34D399; font-weight: 700; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
            $supabaseProjectRef
          </div>
          <div style="font-size: 10px; color: var(--text-muted); display: flex; align-items: center; gap: 5px;">
            <span style="display:inline-block; width:6px; height:6px; border-radius:50%; background:#10B981;" id="stat-sb-indicator"></span>
            <span id="stat-sb-sub">Connected Cloud Hub</span>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Google Maps</div>
          <div class="stat-val" style="font-size: 16px; color: #81C784;">Connected 🌐</div>
        </div>
      </div>

      <!-- Google Maps Container -->
      <div class="map-container">
        <div class="map-overlay-title" style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap;">
          <span>📍 Ghatal Municipality — Live Radar</span>
          <span id="map-gps-hud" style="color: #6EE7B7; font-size: 11px;">📍 Live GPS Tracker Active</span>
          <button onclick="centerOnLiveGps()" class="btn btn-outline" style="padding: 2px 8px; font-size: 10px; border-color: #00E5FF; color: #00E5FF;">🎯 Focus GPS</button>
        </div>
        <div id="google-map"></div>
      </div>

      <!-- Pandals Live Queue Controller Table -->
      <div class="pandals-table-card">
        <div class="table-header">
          <div class="table-title">Live Pandal Gate Queue Controller</div>
          <div style="display: flex; gap: 8px;">
            <button onclick="openSupabaseModal()" class="btn btn-supabase">⚡ Cloud Sync</button>
            <a href="https://docs.google.com/forms/d/e/1FAIpQLSf4_9QifSJAfrzi7SHCyS9t2K5pA935f287ockm9bTYMmJyXg/viewform?usp=publish-editor" target="_blank" class="btn btn-outline" style="text-decoration: none;">📋 Committee Form ↗</a>
            <button onclick="openNewPandalPrompt()" class="btn btn-gold">+ Add Pandal</button>
          </div>
        </div>
        <div class="table-responsive">
          <table>
            <thead>
              <tr>
                <th>Pandal & Zone</th>
                <th>Crowd Level</th>
                <th>People in Line</th>
                <th>Wait Time</th>
                <th>Entry Flow</th>
                <th>Gate Action</th>
              </tr>
            </thead>
            <tbody id="pandals-tbody">
              <!-- Dynamically populated -->
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Sidebar: Broadcast Alerts & Cloud Status -->
    <div class="sidebar-panel">
      <!-- Vercel Live Website Quick Widget -->
      <div class="panel-card" style="border-color: rgba(56, 189, 248, 0.4); background: #111726;">
        <h3 style="color: #BAE6FD;"><span style="font-size: 16px;">▲</span> Vercel Live Deployment</h3>
        <p style="font-size: 11px; color: #94A3B8; margin-bottom: 12px;">Active production web app for Ghatal pandal hoppers</p>
        <div style="background: #0B101E; border: 1px solid #1E293B; border-radius: 10px; padding: 10px; margin-bottom: 12px; font-size: 11px;">
          <div style="color: #7DD3FC; font-weight: 700; margin-bottom: 2px; word-break: break-all;">$vercelUrl</div>
          <div style="color: var(--text-muted); font-size: 10px;">Flutter Web Release • SPA routing configured</div>
        </div>
        <div style="display: flex; gap: 8px;">
          <a href="$vercelUrl" target="_blank" class="btn btn-primary" style="flex: 1; justify-content: center; font-size: 11px; background: #0284C7; text-decoration: none;">
            🌐 Open Live Web ↗
          </a>
          <button onclick="openVercelModal()" class="btn btn-outline" style="border-color: #38BDF8; color: #BAE6FD; font-size: 11px;">
            ⚙️ Manage
          </button>
        </div>
      </div>

      <!-- Supabase Quick Widget -->
      <div class="panel-card" style="border-color: rgba(16, 185, 129, 0.35);">
        <h3>⚡ Supabase Cloud Sync</h3>
        <p style="font-size: 11px; color: var(--text-muted); margin-bottom: 12px;">Cloud database active for Ghatal Hopping real-time data</p>
        <div style="background: #110B0B; border: 1px solid #331F1F; border-radius: 10px; padding: 10px; margin-bottom: 12px; font-size: 11px;">
          <div style="color: #6EE7B7; font-weight: 700; margin-bottom: 2px;">$supabaseUrl</div>
          <div style="color: var(--text-muted); font-size: 10px;">Cloud tables: <code>pandals</code>, <code>alerts</code></div>
        </div>
        <div style="display: flex; gap: 8px;">
          <button onclick="pushPandalsToSupabase()" class="btn btn-supabase" style="flex: 1; justify-content: center; font-size: 11px;">
            🚀 Push Pandals
          </button>
          <button onclick="openSupabaseModal()" class="btn btn-outline" style="font-size: 11px;">
            ⚙️ Configure
          </button>
        </div>
      </div>

      <!-- Broadcast Emergency Alert -->
      <div class="panel-card">
        <h3>📢 Broadcast Crowd Alert</h3>
        <p style="font-size: 11px; color: var(--text-muted); margin-bottom: 12px;">Push instant notifications to all devotees in the Ghatal Hopping App</p>
        <div class="form-group">
          <label>Alert Title</label>
          <input type="text" id="alert-title-input" class="form-control" placeholder="e.g. Bridge Diversion or Gate 2 Clear">
        </div>
        <div class="form-group">
          <label>Alert Message</label>
          <textarea id="alert-msg-input" class="form-control" placeholder="Provide helpful routing instructions for devotees..."></textarea>
        </div>
        <div class="form-group">
          <label>Urgency Level</label>
          <select id="alert-level-input" class="form-control">
            <option value="info">Info / Tip (Blue)</option>
            <option value="warning">Traffic / Rush Alert (Yellow)</option>
            <option value="danger">Emergency Gate Closure (Red)</option>
          </select>
        </div>
        <button onclick="sendAlert()" class="btn btn-primary" style="width: 100%; justify-content: center;">Send Live Broadcast</button>
      </div>

      <!-- Active Alerts List -->
      <div class="panel-card">
        <h3>Active Broadcasts</h3>
        <div id="active-alerts-list">
          <!-- Populated -->
        </div>
      </div>
    </div>
  </main>

  <footer style="text-align: center; padding: 22px 16px; border-top: 1px solid var(--card-border); background: #120A0A; display: flex; flex-direction: column; align-items: center; gap: 6px;">
    <div style="display: flex; align-items: center; justify-content: center; gap: 4px;">
      <span style="font-size: 12px; color: var(--text-muted);">Made with ❤️ by <strong style="color: var(--gold); font-weight: 700;">Deltaspark</strong></span>
    </div>
    <span style="font-size: 11px; color: rgba(255,255,255,0.4); letter-spacing: 0.3px;">@ All rights reserved by Ghatal pandal hopping 2026</span>
  </footer>

  <script>
    let map;
    let markers = [];
    let pandals = [];

    document.addEventListener('DOMContentLoaded', () => {
      checkAuth();
      loadSupabaseConfig();
    });

    function initMap() {
      const ghatalCenter = { lat: 22.6685, lng: 87.7247 };
      const mapElement = document.getElementById('google-map');
      if (!mapElement || typeof google === 'undefined') return;

      map = new google.maps.Map(mapElement, {
        center: ghatalCenter,
        zoom: 14,
        styles: [
          { elementType: 'geometry', stylers: [{ color: '#1B1414' }] },
          { elementType: 'labels.text.stroke', stylers: [{ color: '#1B1414' }] },
          { elementType: 'labels.text.fill', stylers: [{ color: '#BCAAA4' }] },
          { featureType: 'road', elementType: 'geometry', stylers: [{ color: '#331F1F' }] },
          { featureType: 'road', elementType: 'geometry.stroke', stylers: [{ color: '#241414' }] },
          { featureType: 'road', elementType: 'labels.text.fill', stylers: [{ color: '#8E0000' }] },
          { featureType: 'water', elementType: 'geometry', stylers: [{ color: '#0A1826' }] },
          { featureType: 'poi.park', elementType: 'geometry', stylers: [{ color: '#142614' }] }
        ],
        disableDefaultUI: false,
        zoomControl: true
      });

      fetchData();
      startLiveLocationSimulation();
    }

    async function fetchData() {
      try {
        const [statsRes, pandalsRes, alertsRes] = await Promise.all([
          fetch('/api/stats').then(r => r.json()),
          fetch('/api/pandals').then(r => r.json()),
          fetch('/api/alerts').then(r => r.json())
        ]);

        pandals = pandalsRes;
        renderStats(statsRes);
        renderTable(pandals);
        renderMarkers(pandals);
        renderAlerts(alertsRes);
      } catch (e) {
        console.error('Sync failed:', e);
      }
    }

    function renderStats(stats) {
      document.getElementById('stat-total-queue').innerText = stats.totalPeopleInLine || 0;
      document.getElementById('stat-pandal-count').innerText = stats.totalPandals || 0;
      document.getElementById('stat-shortest').innerText = (stats.shortestQueuePandal || 'None') + ' (' + (stats.shortestQueueCount || 0) + ')';
      if (stats.vercelUrl) {
        document.getElementById('stat-vercel-val').innerText = 'ghatalpandalhopping';
      }
      if (stats.isVercelLive !== undefined) {
        updateVercelUiStatus(stats.isVercelLive);
      }
    }

    function renderTable(list) {
      const tbody = document.getElementById('pandals-tbody');
      tbody.innerHTML = '';

      list.forEach(p => {
        const tr = document.createElement('tr');
        const crowdClass = p.peopleInLine < 45 ? 'crowd-low' : (p.peopleInLine < 110 ? 'crowd-mod' : 'crowd-high');
        const crowdText = p.peopleInLine < 45 ? 'Low' : (p.peopleInLine < 110 ? 'Moderate' : 'High Rush');

        tr.innerHTML = `
          <td>
            <div class="pandal-name">\${p.name}</div>
            <div class="pandal-sub">\${p.zone} • \${p.distance}</div>
          </td>
          <td><span class="crowd-pill \${crowdClass}">\${crowdText}</span></td>
          <td>
            <div class="queue-ctrl">
              <button class="btn-step" onclick="updateQueue('\${p.id}', -5)">-5</button>
              <button class="btn-step" onclick="updateQueue('\${p.id}', -1)">-1</button>
              <span class="queue-val" id="cnt-\${p.id}">\${p.peopleInLine}</span>
              <button class="btn-step" onclick="updateQueue('\${p.id}', 1)">+1</button>
              <button class="btn-step" onclick="updateQueue('\${p.id}', 5)">+5</button>
            </div>
          </td>
          <td style="font-weight: 600;">~\${Math.ceil(p.peopleInLine / (p.entryRatePerMinute || 12))} min</td>
          <td style="color: var(--text-muted);">\${p.entryRatePerMinute || 14}/min</td>
          <td>
            <button class="btn btn-outline" style="padding: 5px 10px; font-size: 11px;" onclick="toggleGate('\${p.id}', '\${p.gateStatus === 'Open' ? 'Regulated Flow' : 'Open'}')">
              \${p.gateStatus} ⇄
            </button>
          </td>
        `;
        tbody.appendChild(tr);
      });
    }

    function renderMarkers(list) {
      if (!map || typeof google === 'undefined') return;
      markers.forEach(m => m.setMap(null));
      markers = [];

      list.forEach(p => {
        if (!p.lat || !p.lng) return;
        const marker = new google.maps.Marker({
          position: { lat: p.lat, lng: p.lng },
          map: map,
          title: p.name + ' (' + p.peopleInLine + ' in line)',
          icon: {
            path: google.maps.SymbolPath.CIRCLE,
            scale: 8,
            fillColor: p.peopleInLine > 110 ? '#E53935' : (p.peopleInLine > 50 ? '#F57F17' : '#2E7D32'),
            fillOpacity: 1,
            strokeWeight: 2,
            strokeColor: '#FFFFFF'
          }
        });

        const infoWindow = new google.maps.InfoWindow({
          content: `<div style="color: #000; padding: 6px;">
            <b style="font-size: 13px;">\${p.name}</b><br>
            <span style="color: #666; font-size: 11px;">\${p.zone}</span><br>
            <b style="color: #C62828; font-size: 14px;">👥 \${p.peopleInLine} in line</b> (~\${Math.ceil(p.peopleInLine / (p.entryRatePerMinute || 12))}m wait)
          </div>`
        });

        marker.addListener('click', () => infoWindow.open(map, marker));
        markers.push(marker);
      });
    }

    let liveGpsMarker = null;
    let liveAccuracyCircle = null;
    let liveGpsPos = { lat: 22.6680, lng: 87.7242 };
    let liveStep = 0;
    const walkPoints = [
      { lat: 22.6680, lng: 87.7242 },
      { lat: 22.6688, lng: 87.7248 },
      { lat: 22.6695, lng: 87.7252 },
      { lat: 22.6675, lng: 87.7258 },
      { lat: 22.6655, lng: 87.7262 },
      { lat: 22.6660, lng: 87.7235 },
      { lat: 22.6690, lng: 87.7220 },
      { lat: 22.6730, lng: 87.7210 }
    ];

    function updateLiveGpsMarker(lat, lng, accuracy = 15) {
      if (!map || typeof google === 'undefined') return;
      liveGpsPos = { lat, lng };

      if (!liveGpsMarker) {
        liveGpsMarker = new google.maps.Marker({
          position: liveGpsPos,
          map: map,
          title: 'Live Devotee Location Tracker',
          icon: {
            path: google.maps.SymbolPath.CIRCLE,
            scale: 8,
            fillColor: '#00E5FF',
            fillOpacity: 1,
            strokeWeight: 3,
            strokeColor: '#FFFFFF'
          },
          zIndex: 999
        });

        liveAccuracyCircle = new google.maps.Circle({
          strokeColor: '#00E5FF',
          strokeOpacity: 0.5,
          strokeWeight: 1,
          fillColor: '#00E5FF',
          fillOpacity: 0.15,
          map: map,
          center: liveGpsPos,
          radius: accuracy
        });
      } else {
        liveGpsMarker.setPosition(liveGpsPos);
        if (liveAccuracyCircle) {
          liveAccuracyCircle.setCenter(liveGpsPos);
          liveAccuracyCircle.setRadius(accuracy);
        }
      }

      const hud = document.getElementById('map-gps-hud');
      if (hud) {
        hud.innerText = `📍 Live GPS: \${lat.toFixed(4)}° N, \${lng.toFixed(4)}° E`;
      }
    }

    function startLiveLocationSimulation() {
      if (navigator.geolocation) {
        navigator.geolocation.watchPosition(pos => {
          updateLiveGpsMarker(pos.coords.latitude, pos.coords.longitude, pos.coords.accuracy);
        }, err => {
          setInterval(() => {
            liveStep = (liveStep + 1) % walkPoints.length;
            const pt = walkPoints[liveStep];
            updateLiveGpsMarker(pt.lat, pt.lng, 12);
          }, 2400);
        }, { enableHighAccuracy: true });
      } else {
        setInterval(() => {
          liveStep = (liveStep + 1) % walkPoints.length;
          const pt = walkPoints[liveStep];
          updateLiveGpsMarker(pt.lat, pt.lng, 12);
        }, 2400);
      }
    }

    function centerOnLiveGps() {
      if (map && liveGpsPos) {
        map.panTo(liveGpsPos);
        map.setZoom(16);
      }
    }

    function renderAlerts(alerts) {
      const container = document.getElementById('active-alerts-list');
      container.innerHTML = '';
      if (!alerts || alerts.length === 0) {
        container.innerHTML = '<p style="font-size: 11px; color: var(--text-muted);">No active broadcasts</p>';
        return;
      }
      alerts.forEach(a => {
        const item = document.createElement('div');
        item.className = 'alert-item';
        item.innerHTML = `
          <div>
            <div class="alert-title">\${a.title}</div>
            <div class="alert-text">\${a.message}</div>
          </div>
          <button class="alert-delete" onclick="deleteAlert('\${a.id}')">✕</button>
        `;
        container.appendChild(item);
      });
    }

    async function updateQueue(id, delta) {
      const pandal = pandals.find(p => p.id === id);
      if (!pandal) return;
      const newCount = Math.max(0, pandal.peopleInLine + delta);
      pandal.peopleInLine = newCount;
      document.getElementById('cnt-' + id).innerText = newCount;

      await fetch('/api/pandals/' + id + '/queue', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          peopleInLine: newCount,
          lastDelta: delta
        })
      });
      fetchData();
    }

    async function toggleGate(id, newStatus) {
      await fetch('/api/pandals/' + id + '/queue', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ gateStatus: newStatus })
      });
      fetchData();
    }

    async function sendAlert() {
      const title = document.getElementById('alert-title-input').value.trim();
      const message = document.getElementById('alert-msg-input').value.trim();
      const level = document.getElementById('alert-level-input').value;

      if (!title || !message) {
        alert('Please enter both title and message.');
        return;
      }

      await fetch('/api/alerts', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title, message, level })
      });

      document.getElementById('alert-title-input').value = '';
      document.getElementById('alert-msg-input').value = '';
      fetchData();
    }

    async function deleteAlert(id) {
      await fetch('/api/alerts/' + id, { method: 'DELETE' });
      fetchData();
    }

    async function openNewPandalPrompt() {
      const name = prompt('Enter Pandal Name:');
      if (!name) return;
      const zone = prompt('Enter Zone (e.g. Ghatal Central / Kushpata / Konnagar / Kharar):', 'Ghatal Central Zone') || 'Ghatal Central Zone';
      const count = parseInt(prompt('Current people in line:', '40') || '40');

      await fetch('/api/pandals', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          name: name,
          zone: zone,
          peopleInLine: count,
          lat: 22.6685 + (Math.random() - 0.5) * 0.02,
          lng: 87.7247 + (Math.random() - 0.5) * 0.02,
          distance: '0.9 km'
        })
      });
      fetchData();
    }

    // --- Vercel Deployment Functions ---
    function openVercelModal() {
      document.getElementById('vercel-modal').style.display = 'flex';
      testVercelConnection();
    }

    function closeVercelModal() {
      document.getElementById('vercel-modal').style.display = 'none';
    }

    async function testVercelConnection() {
      const statusEl = document.getElementById('modal-vercel-status');
      statusEl.innerText = 'Pinging Vercel deployment...';
      const url = document.getElementById('vercel-url-input').value.trim();
      try {
        const res = await fetch('/api/vercel/test?url=' + encodeURIComponent(url)).then(r => r.json());
        statusEl.innerText = res.message || (res.live ? 'Live & Responding' : 'Unreachable');
        updateVercelUiStatus(res.live);
      } catch (e) {
        statusEl.innerText = 'Ping failed: ' + e.message;
        updateVercelUiStatus(false);
      }
    }

    function updateVercelUiStatus(isLive) {
      const dot = document.getElementById('modal-vercel-dot');
      const statDot = document.getElementById('stat-vercel-indicator');
      const statSub = document.getElementById('stat-vercel-sub');
      const color = isLive ? '#10B981' : '#38BDF8';
      if (dot) dot.style.background = color;
      if (statDot) statDot.style.background = color;
      if (statSub) statSub.innerText = isLive ? 'Live & Responding (200)' : 'Production Web Active';
    }

    async function saveVercelSettings() {
      const url = document.getElementById('vercel-url-input').value.trim();
      if (!url) return;
      try {
        const res = await fetch('/api/vercel/config', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ vercelUrl: url })
        }).then(r => r.json());
        document.getElementById('modal-vercel-status').innerText = res.message || 'Saved';
        document.getElementById('modal-vercel-url').innerText = url;
        const badge = document.getElementById('header-vercel-badge');
        if (badge) badge.href = url;
        updateVercelUiStatus(res.live);
        alert('Vercel deployment URL updated!');
      } catch (e) {
        alert('Failed to save Vercel configuration: ' + e.message);
      }
    }

    function copyVercelUrl() {
      const url = document.getElementById('vercel-url-input').value.trim();
      navigator.clipboard.writeText(url).then(() => {
        const btn = document.getElementById('copy-vercel-btn');
        btn.innerText = '✓ Copied!';
        setTimeout(() => { btn.innerText = '📋 Copy Live Link'; }, 2000);
      });
    }

    // --- Supabase Cloud Functions ---
    function openSupabaseModal() {
      document.getElementById('supabase-modal').style.display = 'flex';
      testSupabaseConnection();
    }

    function closeSupabaseModal() {
      document.getElementById('supabase-modal').style.display = 'none';
    }

    async function loadSupabaseConfig() {
      try {
        const res = await fetch('/api/supabase/config').then(r => r.json());
        if (res.supabaseUrl) {
          document.getElementById('sb-url-input').value = res.supabaseUrl;
          document.getElementById('modal-supabase-url').innerText = res.supabaseUrl;
        }
        updateSupabaseUiStatus(res.connected);
      } catch (e) {
        console.error('Failed to load Supabase config:', e);
      }
    }

    async function testSupabaseConnection() {
      const statusEl = document.getElementById('modal-supabase-status');
      statusEl.innerText = 'Testing connection...';
      try {
        const res = await fetch('/api/supabase/test').then(r => r.json());
        statusEl.innerText = res.message || (res.connected ? 'Connected' : 'Offline');
        updateSupabaseUiStatus(res.connected);
      } catch (e) {
        statusEl.innerText = 'Connection error: ' + e.message;
        updateSupabaseUiStatus(false);
      }
    }

    function updateSupabaseUiStatus(isConnected) {
      const dot = document.getElementById('modal-supabase-dot');
      const hdrDot = document.getElementById('header-sb-dot');
      const statDot = document.getElementById('stat-sb-indicator');
      const statSub = document.getElementById('stat-sb-sub');

      const color = isConnected ? '#10B981' : '#F57F17';
      if (dot) dot.style.background = color;
      if (hdrDot) hdrDot.style.background = color;
      if (statDot) statDot.style.background = color;
      if (statSub) statSub.innerText = isConnected ? 'Live Cloud Connected' : 'Ready for API Key';
    }

    async function saveSupabaseSettings() {
      const url = document.getElementById('sb-url-input').value.trim();
      const key = document.getElementById('sb-key-input').value.trim();

      const res = await fetch('/api/supabase/config', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ supabaseUrl: url, supabaseAnonKey: key })
      }).then(r => r.json());

      document.getElementById('modal-supabase-status').innerText = res.message || 'Settings saved';
      updateSupabaseUiStatus(res.connected);
      alert('Supabase settings updated successfully!');
    }

    function toggleSbKeyVisibility() {
      const inp = document.getElementById('sb-key-input');
      inp.type = inp.type === 'password' ? 'text' : 'password';
    }

    async function pushPandalsToSupabase() {
      const feedback = document.getElementById('sb-sync-feedback');
      feedback.style.display = 'block';
      feedback.style.color = '#FFD54F';
      feedback.innerText = 'Pushing pandals & alerts to Supabase...';

      try {
        const res = await fetch('/api/supabase/sync-push', { method: 'POST' }).then(r => r.json());
        if (res.success) {
          feedback.style.color = '#81C784';
          feedback.innerText = `✓ Successfully synced \${res.count} pandals to Supabase!`;
        } else {
          feedback.style.color = '#FF8A80';
          feedback.innerText = `✕ Sync failed: \${res.error || 'Check API key & SQL table setup.'}`;
        }
      } catch (e) {
        feedback.style.color = '#FF8A80';
        feedback.innerText = 'Sync failed: ' + e.message;
      }
    }

    async function pullPandalsFromSupabase() {
      const feedback = document.getElementById('sb-sync-feedback');
      feedback.style.display = 'block';
      feedback.style.color = '#FFD54F';
      feedback.innerText = 'Pulling data from Supabase...';

      try {
        const res = await fetch('/api/supabase/sync-pull', { method: 'POST' }).then(r => r.json());
        if (res.success) {
          feedback.style.color = '#81C784';
          feedback.innerText = `✓ Pulled \${res.count} pandals from Supabase!`;
          fetchData();
        } else {
          feedback.style.color = '#FF8A80';
          feedback.innerText = `✕ Pull failed: \${res.error || 'Check table existence.'}`;
        }
      } catch (e) {
        feedback.style.color = '#FF8A80';
        feedback.innerText = 'Pull failed: ' + e.message;
      }
    }

    function copySupabaseSql() {
      const code = document.getElementById('supabase-sql-code').innerText;
      navigator.clipboard.writeText(code).then(() => {
        const btn = document.getElementById('copy-sql-btn');
        btn.innerText = '✓ Copied!';
        setTimeout(() => { btn.innerText = '📋 Copy SQL'; }, 2000);
      });
    }

    // --- Authentication ---
    function checkAuth() {
      const isAuth = sessionStorage.getItem('ghatal_admin_auth') === 'true';
      const modal = document.getElementById('auth-modal');
      if (!isAuth) {
        modal.style.display = 'flex';
        setTimeout(() => {
          const inp = document.getElementById('web-pass-input');
          if (inp) inp.focus();
        }, 150);
      } else {
        modal.style.display = 'none';
      }
    }

    function verifyWebPass() {
      const val = document.getElementById('web-pass-input').value.trim();
      if (val === 'admin123' || val === 'ghatal2026' || val === 'admin@ghatal') {
        sessionStorage.setItem('ghatal_admin_auth', 'true');
        document.getElementById('auth-modal').style.display = 'none';
        document.getElementById('web-auth-err').style.display = 'none';
        if (typeof google !== 'undefined' && google.maps && !map) {
          initMap();
        } else {
          fetchData();
        }
      } else {
        document.getElementById('web-auth-err').style.display = 'block';
      }
    }

    function lockAdminSession() {
      sessionStorage.removeItem('ghatal_admin_auth');
      checkAuth();
    }

    function toggleWebPass() {
      const inp = document.getElementById('web-pass-input');
      inp.type = inp.type === 'password' ? 'text' : 'password';
    }

    // Auto-poll every 5 seconds
    setInterval(fetchData, 5000);
  </script>
</body>
</html>
''';
}
