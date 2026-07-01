# Changelog

All notable changes to Cipher will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.0+9] - 2026-07-01

### Added
- Account sorting by issuer, label, and date added (sort picker in home screen toolbar)
- IssuerLogo widget with brand SVGs for 43 services (Apple, Google, GitHub, Discord, etc.)
- Display IssuerLogo in account list tiles and view account screen
- CustomPaint arc timer replacing CircularProgressIndicator
- Base32 secret validation during QR code parsing to catch invalid secrets early
- Design document (DESIGN.md) with UI/UX guidelines

### Fixed
- QR scan flow edge-case crashes (double-scan guard, mounted checks, navigation fixes)
- Deprecated `withOpacity` replaced with `withValues(alpha:)` across codebase

### Changed
- OTP font size reduced from 32 to 24 for better list layout
- Account list title weight increased to w600
- Timer turns red when ≤5 seconds remaining
- SemanticRadioButtonGroup padding default changed to 0

## [0.3.2+8] - 2025-11-18

### Added
- Dedicated error dialog for QR code scan failures with detailed error information
- Enhanced error handling in QR scanner with try-catch blocks
- Button disabled state customization (`disabledColor` property)

### Fixed
- Async navigation bug in delete account dialog (added context.mounted check)
- URI parsing now handles flexible issuer/label combinations
- Delete button text color for better dark theme visibility
- Non-functional floating action button in settings screen
- Dark theme error color improved for better contrast

### Changed
- Renamed `add_entity_screen.dart` to `add_account_screen.dart` for clarity
- Updated iOS build configuration with automatic code signing
- Added bundle display name "Cipher" for iOS

### Security
- No security-sensitive changes
- Improved error handling maintains security boundaries

## [0.3.1+7] - 2025-11-02

### Added
- User-friendly error dialog for QR scanner issues
- App lifecycle state management in scanner
- Enhanced error handling with detailed messages

### Fixed
- QR code scanning reliability improved with better detection area
- Fixed URI parsing for accounts with different issuer values

### Security
- Maintained security while improving QR code compatibility
- No changes to cryptographic or secret storage functionality

### Version Note
- Version jump from 0.2.1 to 0.3.1 to correctly reflect feature additions:
  - 0.2.0 → 0.3.0: Addition of tutorial feature
  - 0.3.0 → 0.3.1: New scanner features and improvements

## [0.2.1+6] - 2025-11-02 (Renamed to 0.3.0+6)

### Fixed
- QR code scanning reliability improved with better detection area
- Enhanced error handling in QR scanner with user-friendly dialogs
- Fixed URI parsing for accounts with different issuer values
- Improved app lifecycle management in scanner

### Security
- Maintained security while improving QR code compatibility
- No changes to cryptographic or secret storage functionality

## [0.2.1+6] - 2025-11-02

### Added
- Interactive How-To guide with step-by-step tutorial
- In-app tutorial with visual guides and explanations
- Help button in home screen for quick tutorial access
- Seven comprehensive tutorial steps with screenshots
- Enhanced user onboarding experience

### Security
- No security-sensitive changes; tutorial feature is UI-only
- All tutorial assets are bundled with the app (no external resources)

## [0.2.0+5] - 2025-11-02

### Changed
- Reworked Settings screen layout: Backup & Recovery and Recovery Codes sections reorganized
- Added a Recovery Codes tile (marked "Coming Soon") and Import/Export placeholders for future backup features
- Disabled actions for "Coming Soon" items to avoid user confusion and accidental navigation
- Small UI spacing and accessibility improvements across Settings (gap adjustments, consistent dividers)

### Security
- No security-sensitive behavior changed. No secrets exposed by UI-only updates.

## [0.2.0+4] - 2025-10-31

### Added
- Tap-to-focus functionality in QR code scanner for improved scanning accuracy
- Enhanced camera interaction allowing manual focus control on difficult-to-scan codes

### Changed
- Updated mobile_scanner from 7.0.1 to 7.1.3 for performance and security improvements
- Updated go_router to 16.3.0 with navigation enhancements
- Updated material_symbols_icons to 4.2874.0 with latest icon set
- Updated multiple transitive dependencies for security and compatibility
- Enhanced Android and iOS platform configurations for URL launcher support
- Improved development environment with latest toolchain versions

### Security
- Security improvements through dependency updates across the stack
- Enhanced platform-specific configurations for secure external link handling
- Updated build system components for better security and compatibility

## [0.2.0+1] - 2025-10-29

### Added
- Beta disclaimer modal with user acknowledgment system
- Privacy policy and terms of service links in settings
- Enhanced QR code scanner with visual corner overlay indicators
- Comprehensive user consent flow for beta software usage
- URL launcher functionality for external links
- Comprehensive changelog management workflow
- Automatic changelog update guidelines in development process

### Fixed
- Clipboard timeout default value now properly uses settings constants (30 seconds) - Issue #2
- Biometric authentication default settings now use configuration constants
- Beta disclaimer display logic with proper state management
- Account validation improvements in QR scanner - Issue #1

### Changed
- Improved empty state messaging on home screen for better user guidance
- Enhanced divider styling with proper indentation in account list
- Better settings provider initialization with centralized constants
- Enhanced development guidelines with systematic changelog management

### Security
- Added user consent acknowledgment for beta software usage
- Enhanced clipboard security with proper timeout configuration
- Improved external link handling with secure URL launcher
- Centralized security settings management prevents configuration drift
- Privacy-first documentation and legal compliance features

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