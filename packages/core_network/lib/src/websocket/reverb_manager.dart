import 'dart:async';
import 'package:core/core.dart';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';

/// Status koneksi WebSocket
enum ReverbConnectionStatus { disconnected, connecting, connected, error }

/// Event yang diterima dari WebSocket
class ReverbEvent {
  const ReverbEvent({
    required this.channel,
    required this.event,
    required this.data,
  });

  final String channel;
  final String event;
  final dynamic data;
}

/// Manager terpusat untuk koneksi WebSocket via Laravel Reverb.
/// Satu koneksi untuk semua channel — fitur subscribe ke channel
/// dan listen event masing-masing tanpa perlu tahu detail koneksi.
class ReverbManager {
  ReverbManager({
    required String host,
    required int port,
    required String appKey,
    required Future<String?> Function() getAccessToken,
    required String authEndpoint,
  }) : _host = host,
       _port = port,
       _appKey = appKey,
       _getAccessToken = getAccessToken,
       _authEndpoint = authEndpoint;

  final String _host;
  final int _port;
  final String _appKey;
  final Future<String?> Function() _getAccessToken;
  final String _authEndpoint;

  PusherChannelsClient? _client;

  /// Simpan channel instances agar bisa di-unsubscribe nanti
  final Map<String, Channel> _channels = {};

  final _statusController =
      StreamController<ReverbConnectionStatus>.broadcast();

  Stream<ReverbConnectionStatus> get connectionStatus =>
      _statusController.stream;

  ReverbConnectionStatus _currentStatus = ReverbConnectionStatus.disconnected;
  ReverbConnectionStatus get currentStatus => _currentStatus;

  void _updateStatus(ReverbConnectionStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  /// Buka koneksi ke Reverb
  Future<void> connect() async {
    try {
      _updateStatus(ReverbConnectionStatus.connecting);

      _client = PusherChannelsClient.websocket(
        options: PusherChannelsOptions.fromHost(
          scheme: 'ws',
          host: _host,
          key: _appKey,
          port: _port,
        ),
        connectionErrorHandler: (error, trace, refresh) {
          AppLogger.error('[Reverb] Connection error', error, trace);
          _updateStatus(ReverbConnectionStatus.error);
          refresh();
        },
      );

      _client!.onConnectionEstablished.listen((_) {
        AppLogger.info('[Reverb] Connected');
        _updateStatus(ReverbConnectionStatus.connected);

        // Resubscribe semua channel yang sudah ada saat reconnect
        for (final channel in _channels.values) {
          channel.subscribeIfNotUnsubscribed();
        }
      });

      await _client!.connect();
    } catch (e, st) {
      AppLogger.error('[Reverb] Failed to connect', e, st);
      _updateStatus(ReverbConnectionStatus.error);
    }
  }

  /// Tutup koneksi
  Future<void> disconnect() async {
    await _client?.disconnect();
    _channels.clear();
    _updateStatus(ReverbConnectionStatus.disconnected);
    AppLogger.info('[Reverb] Disconnected');
  }

  /// Subscribe ke public channel
  PublicChannel subscribePublic(String channelName) {
    _assertConnected();

    if (_channels.containsKey(channelName)) {
      return _channels[channelName] as PublicChannel;
    }

    final channel = _client!.publicChannel(channelName);
    channel.subscribeIfNotUnsubscribed();
    _channels[channelName] = channel;

    AppLogger.debug('[Reverb] Subscribed to public: $channelName');
    return channel;
  }

  /// Subscribe ke private channel — memerlukan auth dari backend
  Future<PrivateChannel> subscribePrivate(String channelName) async {
    _assertConnected();

    if (_channels.containsKey(channelName)) {
      return _channels[channelName] as PrivateChannel;
    }

    final token = await _getAccessToken();

    final channel = _client!.privateChannel(
      channelName,
      authorizationDelegate:
          EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
            authorizationEndpoint: Uri.parse(_authEndpoint),
            headers: {
              if (token != null) 'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
    );

    channel.subscribeIfNotUnsubscribed();
    _channels[channelName] = channel;

    AppLogger.debug('[Reverb] Subscribed to private: $channelName');
    return channel;
  }

  /// Unsubscribe dari channel dan hapus dari map
  void unsubscribe(String channelName) {
    final channel = _channels[channelName];
    if (channel == null) return;

    channel.unsubscribe();
    _channels.remove(channelName);
    AppLogger.debug('[Reverb] Unsubscribed from: $channelName');
  }

  /// Listen event dari channel yang sudah disubscribe
  Stream<ReverbEvent> on(String channelName, String eventName) {
    _assertConnected();

    final channel = _channels[channelName];
    if (channel == null) {
      AppLogger.warning(
        '[Reverb] Channel $channelName belum disubscribe. '
        'Panggil subscribePublic() atau subscribePrivate() terlebih dahulu.',
      );
      return const Stream.empty();
    }

    return channel
        .bind(eventName)
        .map(
          (event) => ReverbEvent(
            channel: channelName,
            event: eventName,
            data: event.data,
          ),
        );
  }

  void _assertConnected() {
    if (_client == null || _currentStatus != ReverbConnectionStatus.connected) {
      throw StateError(
        '[Reverb] Belum terkoneksi. Panggil connect() terlebih dahulu.',
      );
    }
  }

  void dispose() {
    disconnect();
    _statusController.close();
  }
}
