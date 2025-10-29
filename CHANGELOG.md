# Changelog

All notable changes to Cipher will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Beta disclaimer modal with user acknowledgment system
- Privacy policy and terms of service links in settings
- Enhanced QR code scanner with visual corner overlay indicators
- Comprehensive user consent flow for beta software usage
- URL launcher functionality for external links

### Fixed
- Clipboard timeout default value now properly uses settings constants (30 seconds)
- Biometric authentication default settings now use configuration constants
- Beta disclaimer display logic with proper state management

### Changed
- Improved empty state messaging on home screen for better user guidance
- Enhanced divider styling with proper indentation in account list
- Better settings provider initialization with centralized constants

### Security
- Added user consent acknowledgment for beta software usage
- Enhanced clipboard security with proper timeout configuration
- Improved external link handling with secure URL launcher

## [0.1.1+2] - 2025-10-29

### Added
- Android release build configuration with ProGuard optimization
- Comprehensive ProGuard rules for security and performance
- Release signing configuration with keystore support
- Camera permission for QR code scanning functionality
- iOS keychain access groups for secure storage isolation
- Proper MainActivity with correct package namespace
- Android Studio IDE configuration files

### Fixed
- App loading state with proper fallback UI and theme detection
- Storage service error handling for SharedPreferences operations
- Main app initialization with better error boundaries

### Changed
- Removed SensitiveContent wrapper for cleaner startup flow
- Enhanced scaffold background theming
- Improved Android build optimization settings

### Security
- Code minification and resource shrinking for production builds
- Crypto classes protection in ProGuard rules for TOTP security
- Biometric authentication classes preservation
- Debug logging removal in release builds
- Platform-specific secure storage configuration

## [0.1.0+1] - 2025-10-25

### Added
- Account deletion functionality with secure confirmation dialog
- Enhanced color utilities with `fromHex()` method for dynamic theming
- Comprehensive DeleteAccountDialog with multiple security confirmations
- Complete account removal from all storage sources (secure & shared storage)
- Enhanced copilot instructions with comprehensive security guidelines

### Security
- Multi-step confirmation process prevents accidental account deletion
- Secure cleanup of sensitive data from all storage layers
- Clear warnings about permanent data loss and irreversible actions
- Type-to-confirm pattern for critical destructive operations

### Changed
- Material Design 3 patterns for critical actions
- Enhanced user experience with clear visual warnings
- Feature-based organization with proper separation of concerns
- Clean architecture implementation across service, provider, and UI layers

### Developer Experience
- Detailed version management and git workflow documentation
- Professional development practices for security-focused applications
- Complete project documentation for Flutter authenticator development

## [0.0.2+1] - 2025-10-25

### Added
- Comprehensive copilot instructions tailored for Cipher authenticator app
- Security-focused development guidelines and best practices
- Detailed version management and release workflow documentation
- Enhanced state management patterns for security applications

### Fixed
- Settings provider initialization for first-run scenarios
- Added proper default settings fallback logic
- Improved robustness of settings state management

### Changed
- Updated architecture documentation with feature-based organization
- Added security guidelines for secret handling and biometric auth
- Enhanced dependency management practices for security-critical packages

## [0.0.1+1] - 2025-10-24

### Added
- Comprehensive biometric authentication system in splash screen
- Platform-specific local_auth dependencies (Android/iOS)
- Robust settings state management with proper async patterns
- Enhanced UI components with loading and error states
- Cross-platform authentication dialogs and error handling
- Clean architecture with proper separation of concerns

### Features
- Biometric authentication with fallback handling
- Settings persistence with state management
- Theme support (light/dark/system)
- Clipboard timeout management
- Enhanced splash screen with authentication flow

### Fixed
- Race conditions in authentication flow
- Proper hook usage preventing multiple executions
- Comprehensive error handling and user feedback

### Technical
- Generated code separation and iOS entitlements
- Updated Riverpod providers for authentication state
- Enhanced service layer for account management
- Secure storage implementation for sensitive data

## [0.0.1] - 2025-10-24

### Added
- Initial Flutter project structure and configuration
- Core authentication features with TOTP support
- Secure storage service for sensitive data
- Authentication models with JSON serialization
- TOTP service for generating one-time passwords
- Riverpod providers for state management
- UI widgets and authentication screens
- Home screen with entity list and TOTP display
- Settings screen with app configuration options
- Splash screen with transition animation
- Go router configuration for navigation
- Color and style providers for theming
- Search functionality for accounts
- Custom fonts and app icons

### Security
- End-to-end encryption for secrets using platform secure storage
- RFC 6238 (TOTP) standard implementation
- Secure clipboard handling with timeout
- Privacy-first design with no telemetry

### Developer Experience
- Comprehensive Flutter development guidelines
- Feature-based architecture organization
- Clean separation of concerns
- Comprehensive dependencies setup

---

## Security Notice

Cipher is a security-focused authenticator application. All releases undergo security review, and we prioritize:

- **End-to-end encryption** for all sensitive data
- **Offline-first design** with no cloud dependencies  
- **Platform secure storage** for authentication secrets
- **Biometric authentication** with platform-specific implementations
- **Privacy by design** with no telemetry or tracking

## Contributing

Please read our security guidelines before contributing. All code changes must:

1. Follow security-first development practices
2. Include proper error handling for sensitive operations
3. Implement appropriate logging without exposing secrets
4. Use constant-time operations for crypto comparisons
5. Clear sensitive data from memory when possible

For more information, see `.github/copilot-instructions.md`.