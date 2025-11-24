# dst_mk2

A Flutter-based mobile application designed for real-time device tracking, sensor monitoring, and secure data processing using MQTT and modern cryptography.

## Overview

**dst_mk2** is the second iteration of a tracking application built to support location monitoring, motion detection, and device management features.  
This project integrates IoT data streams, secure encrypted payloads, and dynamic UI updates to deliver a reliable tracking experience.

Key capabilities include:
- Real-time GPS visualization
- Accelerometer and environmental sensor readings
- Secure MQTT communication with decryption support
- Multi-device support via QR-based pairing
- Firebase authentication and cloud data storage
- Modern and responsive Flutter UI

---

## Code Structure

The project is organized into clean and modular directories:

lib/
- main.dart # Application entry point
- pages/ # UI screens (Home, TrackPage, GpsPage, Settings, etc.)
- services/ # MQTT client, Firebase services, QR Scanner


---

## Features

- **Real-time MQTT Data Streaming**  
  Displays live GPS coordinates, speed, temperature, humidity, and motion data.

- **Secure Communication**  
  Supports encrypted payloads (AES-GCM algorithms).

- **QR Tracker Registration**  
  Easily add new devices by scanning QR codes containing encryption keys and topics.

- **Firebase Integration**  
  Includes authentication, profile management, and cloud storage for user data.

- **Modern Interface**  
  Clean UI with animated elements, cards, and responsive layouts.

---

## Getting Started

To run this project locally:

```bash
flutter pub get
flutter run
