# Cipher - The open source authenticator

A secure, lightweight, production-ready two-factor authentication (2FA) mobile application that generates and manages one-time passwords (TOTP/HOTP) and other multi-factor authentication mechanisms to help users protect their online accounts.

## About this application

This application is an offline-first mobile authenticator built with security, simplicity, and maintainability as first principles. It implements industry standards (TOTP — RFC 6238 and HOTP — RFC 4226) for one-time password generation and focuses on secure handling of authentication secrets, a minimal and accessible user interface, and a robust developer experience for future extensions (sync, server-side backup, enterprise features).

Primary design goals:

* **Security-first**: Secrets are encrypted on-device using platform-recommended secure storage primitives. No plaintext secrets are persisted.
* **Privacy-friendly**: No telemetry or user-identifying data is sent off-device by default.
* **Reliability and performance**: App works offline and is snappy on a wide range of devices.
* **Maintainability**: Well-documented, modular code and test coverage.
* **Extensibility**: Architecture supports adding optional cloud sync, enterprise provisioning, and advanced MFA later.

## Key priorities

* Robust security for secret storage and TOTP/HOTP generation.
* Clear, testable implementation of auth algorithms (RFC 6238 / RFC 4226).
* Simple, accessible UX with quick setup (QR code scanning) and easy account management.
* Production-ready code comments and documentation for every public module.
* Maintainable architecture and secure defaults.

## Features

* TOTP (time-based) and HOTP (counter-based) code generation
* Add accounts via QR code (otpauth URI) or manual entry
* Support for multiple accounts with labels and issuers
* Secure, encrypted on-device storage for secrets
* Copy / reveal current code, and view code lifetime (countdown)
* Account re-ordering, edit, and delete
* Backup & restore (optional, encrypted)
* Persistent configuration and theming
* Accessibility support (screen-reader friendly, scalable text)

## Supported standards

* TOTP (RFC 6238)
* HOTP (RFC 4226)
* otpauth URI format (compatible with major authenticators)
* QR codes for otpauth URIs

## Tech stack

* Frontend: Flutter (single codebase for iOS & Android)
* State management: Riverpod + Freezed (codegen)
* Routing: go\_router
* Cryptography & storage: Platform secure storage (Keychain on iOS, Android Keystore) with additional app-level authenticated encryption for persisted blobs
* Optional backend services (future): Golang microservices for encrypted backup, sync and user account recovery

## Project structure

```
/docs              → Project documentation, security notes, RFC references
/lib               → Flutter app source code
/lib/src           → Main app packages and modules
/lib/src/ui        → Widgets and screens
/lib/src/features  → Feature modules (otp, accounts, backup, settings)
/test              → Unit and widget tests
/android           → Android platform integration
/ios               → iOS platform integration
/tools             → Developer scripts and utilities (build, release helpers)
/assets            → Icons, images, fonts
/README.md         → This file
/LICENSE           → License file
```

## Quick start (development)

1. Clone the repo:

   ```bash
   git clone https://github.com/your-username/authenticator-app.git
   cd authenticator-app
   ```

2. Install Flutter dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app on an emulator or device:

   ```bash
   flutter run
   ```

4. Run tests:

   ```bash
   flutter test
   ```

## Security considerations (high level)

* Secrets must be encrypted at rest. Use platform secure storage (Keychain / Keystore) and an authenticated encryption layer (e.g., AES-GCM) for any persisted blobs.
