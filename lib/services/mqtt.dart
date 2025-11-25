import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTClientWrapper {
  static final MQTTClientWrapper _instance = MQTTClientWrapper._internal();

  factory MQTTClientWrapper({
    void Function(String topic, String message)? onMessageReceived,
  }) {
    if (onMessageReceived != null &&
        !_instance._listeners.contains(onMessageReceived)) {
      _instance._listeners.add(onMessageReceived);
    }

    if (!_instance._initialized) {
      _instance._prepareMqttClient();
    }

    return _instance;
  }

  MQTTClientWrapper._internal();

  late MqttServerClient client;

  final List<void Function(String topic, String message)> _listeners = [];
  final Set<String> _subscribedTopics = {};

  bool _initialized = false;
  bool get isConnected =>
      client.connectionStatus?.state == MqttConnectionState.connected;

  Future<void> _prepareMqttClient() async {
    debugPrint("[MQTT] Preparing client...");

    final clientId = "FlutterClient_${DateTime.now().millisecondsSinceEpoch}";

    client = MqttServerClient.withPort(
      'IP_ADDRES',
      clientId,
      PORT,
    );

    client.secure = false;
    client.keepAlivePeriod = 60;

    client.onConnected = () => debugPrint("[MQTT] Connected");
    client.onDisconnected = () => debugPrint("[MQTT] Disconnected");
    client.onSubscribed = (topic) => debugPrint("[MQTT] Subscribed to $topic");

    try {
      debugPrint("[MQTT] Connecting...");
      await client.connect('admin', 'hivemq');
    } catch (e) {
      debugPrint("[MQTT] Connection failed: $e");
      return;
    }

    if (isConnected) {
      debugPrint("[MQTT] Connected as $clientId");
    } else {
      debugPrint("[MQTT] Connection failed (unknown reason)");
      return;
    }

    client.updates?.listen(_onMessageReceived);

    _initialized = true;
  }

  void _onMessageReceived(List<MqttReceivedMessage<MqttMessage>> event) {
    final MqttPublishMessage recMess = event[0].payload as MqttPublishMessage;
    final topic = event[0].topic;
    final message =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    debugPrint("[MQTT] Message from $topic: $message");

    for (var listener in _listeners) {
      try {
        listener(topic, message);
      } catch (e) {
        debugPrint("[MQTT] Listener error: $e");
      }
    }
  }

  void subscribeToTopic(String topic) {
    if (!isConnected) {
      debugPrint("[MQTT] Can't subscribe, client NOT connected.");
      return;
    }

    if (_subscribedTopics.contains(topic)) {
      debugPrint("[MQTT] Already subscribed to $topic");
      return;
    }

    debugPrint("[MQTT] Subscribing to $topic");
    client.subscribe(topic, MqttQos.atMostOnce);
    _subscribedTopics.add(topic);
  }

  void unsubscribeFromTopic(String topic) {
    if (!isConnected) return;

    debugPrint("[MQTT] Unsubscribing from $topic");
    client.unsubscribe(topic);
    _subscribedTopics.remove(topic);
  }

  bool isSubscribed(String topic) => _subscribedTopics.contains(topic);

  Future<bool> checkTopicExists(String token) async {
    await ensureConnected();

    if (!isConnected) return false;

    final fullTopic = "hasil/$token";
    final Completer<bool> completer = Completer<bool>();
    bool responded = false;

    void tempListener(String topic, String message) {
      if (topic == fullTopic && !responded) {
        responded = true;
        completer.complete(true);
        removeListener(tempListener);
      }
    }

    addListener(tempListener);
    subscribeToTopic(fullTopic);

    Future.delayed(const Duration(seconds: 5)).then((_) {
      if (!responded && !completer.isCompleted) {
        debugPrint("[MQTT] checkTopicExists timeout: $fullTopic");
        removeListener(tempListener);
        completer.complete(false);
      }
    });

    return completer.future;
  }

  void addListener(void Function(String topic, String message) listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  void removeListener(void Function(String topic, String message) listener) {
    _listeners.remove(listener);
  }

  Future<void> ensureConnected() async {
    if (!isConnected) {
      debugPrint("[MQTT] ensureConnected(): reconnecting...");
      await _prepareMqttClient();
    }
  }
}
