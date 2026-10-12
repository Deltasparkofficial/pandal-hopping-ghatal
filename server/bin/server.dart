import 'dart:convert';
import 'dart:io';

const int serverPort = 5000;
const String mapsApiKey = 'AIzaSyCWIA9gZKanR12wo5HvtAHisy0TTK3yOmg';

late File pandalsFile;
late File alertsFile;
List<Map<String, dynamic>> pandalsData = [];
List<Map<String, dynamic>> alertsData = [];

void main() async {
  final currentDir = Directory.current.path;
  pandalsFile = File('$currentDir/server/data/pandals.json');
  alertsFile = File('$currentDir/server/data/alerts.json');

  _loadData();

  final server = await HttpServer.bind(InternetAddress.anyIPv4, serverPort);
  print('======================================================');
  print('  Pandal Hopping Ghatal - REST Backend Server Active  ');
  print('  Listening on: http://localhost:$serverPort/            ');
  print('  Web Admin Panel: http://localhost:$serverPort/admin    ');
  print('  Google Maps Key: Configured ($mapsApiKey)');
  print('======================================================');

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

void _handleRequest(HttpRequest request) async {
  final res = request.response;

  // Add CORS headers
  res.headers.set('Access-Control-Allow-Origin', '*');
  res.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.headers.set('Access-Control-Allow-Headers', 'Origin, Content-Type, Accept, Authorization');

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

    // 3. Stats Summary
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
        'timestamp': DateTime.now().toIso8601String(),
      });
      return;
    }

    // 4. Pandals Endpoints
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

    // 5. Alerts Endpoints
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

    // 6. Static Logo
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
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
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
      padding: 16px 28px;
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
      font-size: 19px;
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
      gap: 12px;
      align-items: center;
    }
    .btn {
      padding: 9px 16px;
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
    .live-dot {
      width: 8px;
      height: 8px;
      background: var(--danger);
      border-radius: 50%;
      animation: pulse 1.4s infinite;
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
      grid-template-columns: repeat(4, 1fr);
      gap: 16px;
      margin-bottom: 24px;
    }
    .stat-card {
      background: var(--card-bg);
      border: 1px solid var(--card-border);
      padding: 18px;
      border-radius: 16px;
      display: flex;
      flex-direction: column;
      gap: 6px;
    }
    .stat-label {
      font-size: 11px;
      color: var(--text-muted);
      text-transform: uppercase;
      letter-spacing: 0.8px;
      font-weight: 600;
    }
    .stat-val {
      font-size: 26px;
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
      margin-bottom: 12px;
      color: #FFF;
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
    }
    .form-control {
      width: 100%;
      padding: 10px 14px;
      background: #120A0A;
      border: 1px solid var(--card-border);
      border-radius: 10px;
      color: #FFF;
      font-family: inherit;
      font-size: 12px;
    }
    .form-control:focus {
      outline: none;
      border-color: var(--gold);
    }
    textarea.form-control {
      resize: vertical;
      min-height: 70px;
    }
    .alert-item {
      padding: 12px;
      background: #140B0B;
      border-radius: 12px;
      border-left: 3px solid var(--gold);
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
    }
    .alert-text {
      font-size: 11px;
      color: var(--text-muted);
      margin-top: 3px;
    }
    .alert-delete {
      background: none;
      border: none;
      color: #E53935;
      cursor: pointer;
      font-size: 13px;
      padding: 2px 4px;
    }
  </style>
</head>
<body>

  <header>
    <div class="brand">
      <div class="brand-icon">🛕</div>
      <div class="brand-title">
        <h1>Ghatal Sharodutsav Admin Command</h1>
        <p>Google Maps & Real-time Line Queue Controller</p>
      </div>
    </div>
    <div class="header-actions">
      <div class="badge-live">
        <div class="live-dot"></div>
        LIVE REST BACKEND (:5000)
      </div>
      <a href="http://localhost:8080/" target="_blank" class="btn btn-outline">Open Devotee App ↗</a>
      <button onclick="fetchData()" class="btn btn-primary">↻ Sync Now</button>
    </div>
  </header>

  <main>
    <div class="main-content">
      <!-- 4 Stats Cards -->
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
          <div class="stat-val" id="stat-shortest" style="font-size: 18px; color: var(--gold);">Loading...</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Google Maps Status</div>
          <div class="stat-val" style="font-size: 18px; color: #81C784;">Connected 🌐</div>
        </div>
      </div>

      <!-- Google Maps Container -->
      <div class="map-container">
        <div class="map-overlay-title">📍 Ghatal Municipality — Live Pandal Geospatial Radar</div>
        <div id="google-map"></div>
      </div>

      <!-- Pandals Live Queue Controller Table -->
      <div class="pandals-table-card">
        <div class="table-header">
          <div class="table-title">Live Pandal Gate Queue Controller</div>
          <div style="display: flex; gap: 8px;">
            <a href="https://docs.google.com/forms/d/e/1FAIpQLSf4_9QifSJAfrzi7SHCyS9t2K5pA935f287ockm9bTYMmJyXg/viewform?usp=publish-editor" target="_blank" class="btn btn-outline" style="text-decoration: none; display: inline-flex; align-items: center; gap: 6px;">📋 Committee Google Form ↗</a>
            <button onclick="openNewPandalPrompt()" class="btn btn-gold">+ Register New Pandal</button>
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

    <!-- Sidebar: Broadcast Alerts & Quick Config -->
    <div class="sidebar-panel">
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

    // Initialize Google Map centered on Ghatal
    function initMap() {
      const ghatalCoords = { lat: 22.6685, lng: 87.7247 };
      map = new google.maps.Map(document.getElementById("google-map"), {
        zoom: 14,
        center: ghatalCoords,
        styles: [
          { elementType: "geometry", stylers: [{ color: "#212121" }] },
          { elementType: "labels.icon", stylers: [{ visibility: "off" }] },
          { elementType: "labels.text.fill", stylers: [{ color: "#757575" }] },
          { elementType: "labels.text.stroke", stylers: [{ color: "#212121" }] },
          { featureType: "water", elementType: "geometry", stylers: [{ color: "#000000" }] }
        ]
      });
      fetchData();
    }

    window.addEventListener('load', () => {
      if (typeof google !== 'undefined' && google.maps) {
        initMap();
      } else {
        fetchData();
      }
    });

    async function fetchData() {
      try {
        const [pRes, sRes, aRes] = await Promise.all([
          fetch('/api/pandals'),
          fetch('/api/stats'),
          fetch('/api/alerts')
        ]);
        pandals = await pRes.json();
        const stats = await sRes.json();
        const alerts = await aRes.json();

        renderStats(stats);
        renderTable(pandals);
        renderMarkers(pandals);
        renderAlerts(alerts);
      } catch (e) {
        console.error('Sync failed:', e);
      }
    }

    function renderStats(stats) {
      document.getElementById('stat-total-queue').innerText = stats.totalPeopleInLine || 0;
      document.getElementById('stat-pandal-count').innerText = stats.totalPandals || 0;
      document.getElementById('stat-shortest').innerText = stats.shortestQueuePandal + ' (' + stats.shortestQueueCount + ')';
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

    // Auto-poll every 5 seconds
    setInterval(fetchData, 5000);
  </script>
</body>
</html>
''';
}
