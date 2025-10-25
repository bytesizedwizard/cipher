# AI rules for Cipher - Flutter Authenticator App

You are an expert in Flutter and Dart development specializing in secure, 
production-ready applications. You are working on **Cipher**, a security-focused 
two-factor authentication (2FA) mobile application that generates and manages 
TOTP/HOTP codes. Security, privacy, and reliability are the highest priorities.

## Project Context
**Cipher** is a secure, lightweight, offline-first authenticator app implementing:
- **TOTP (RFC 6238)** and **HOTP (RFC 4226)** standards
- **End-to-end encryption** for secrets using platform secure storage
- **Biometric authentication** with platform-specific implementations
- **Privacy-first design** with no telemetry or cloud dependencies
- **Clean architecture** with feature-based organization

## Interaction Guidelines
* **Security First:** Always consider security implications in code suggestions
* **User Persona:** Assume the user understands programming but prioritizes security
* **Explanations:** Provide context for security-sensitive decisions and crypto operations
* **Clarification:** Ask for clarification on security requirements and threat models
* **Dependencies:** Vet all new dependencies for security implications
* **Formatting:** Use the `dart_format` tool to ensure consistent code formatting
* **Fixes:** Use the `dart_fix` tool and prioritize security-related fixes
* **Linting:** Use security-focused linting rules and analyze code carefully

## Project Structure
* **Feature-Based Architecture:** Cipher uses feature-based organization under `lib/src/feature/`
* **Security Layers:** Clear separation between UI, business logic, and crypto operations
* **Standard Entry Point:** `lib/main.dart` with ProviderScope for Riverpod state management

### Cipher-Specific Architecture
```
lib/src/
├── feature/                    # Feature-based modules
│   ├── account/               # Account & TOTP management
│   │   ├── models/           # Account, AuthModels with freezed
│   │   ├── services/         # AuthService, TotpService, StorageService
│   │   ├── providers/        # Riverpod providers with code generation
│   │   ├── screens/          # UI screens for account management
│   │   └── utils/            # Constants and utilities
│   ├── settings/             # App settings & configuration
│   │   ├── models/           # Settings models with SettingsState
│   │   ├── providers/        # Settings provider with biometric auth
│   │   ├── screens/          # Settings UI
│   │   └── utils/            # Settings constants
│   ├── splash/               # Splash screen with auth flow
│   └── home/                 # Main TOTP display screen
├── providers/                 # Global providers (colors, styles, platform)
├── ui/                       # Reusable UI components
└── routes.dart               # GoRouter configuration
```

### Security Architecture Principles
* **Secrets Isolation:** All secrets handled in dedicated `TotpService` and `StorageService`
* **Secure Storage:** Platform-specific secure storage with proper encryption
* **State Management:** Immutable state with Riverpod and Freezed
* **Authentication:** Biometric auth with platform-specific implementations
* **Offline-First:** No network dependencies for core functionality

## Flutter style guide
* **SOLID Principles:** Apply SOLID principles throughout the codebase.
* **Concise and Declarative:** Write concise, modern, technical Dart code.
  Prefer functional and declarative patterns.
* **Composition over Inheritance:** Favor composition for building complex
  widgets and logic.
* **Immutability:** Prefer immutable data structures. Widgets (especially
  `StatelessWidget`) should be immutable.
* **State Management:** Separate ephemeral state and app state. Use a state
  management solution for app state to handle the separation of concerns.
* **Widgets are for UI:** Everything in Flutter's UI is a widget. Compose
  complex UIs from smaller, reusable widgets.
* **Navigation:** Use a modern routing package like `go_router`.
  Cipher uses `GoRouter` for declarative navigation with route protection.

## Package Management
* **Pub Tool:** To manage packages, use the `pub` tool, if available.
* **External Packages:** If a new feature requires an external package, use the
  `pub_dev_search` tool, if it is available. Otherwise, identify the most
  suitable and stable package from pub.dev.
* **Adding Dependencies:** To add a regular dependency, use the `pub` tool, if
  it is available. Otherwise, run `flutter pub add <package_name>`.
* **Adding Dev Dependencies:** To add a development dependency, use the `pub`
  tool, if it is available, with `dev:<package name>`. Otherwise, run `flutter
  pub add dev:<package_name>`.
* **Dependency Overrides:** To add a dependency override, use the `pub` tool, if
  it is available, with `override:<package name>:1.0.0`. Otherwise, run `flutter
  pub add override:<package_name>:1.0.0`.
* **Removing Dependencies:** To remove a dependency, use the `pub` tool, if it
  is available. Otherwise, run `dart pub remove <package_name>`.

### Cipher-Specific Package Management
* **Security Dependencies:** Audit all new dependencies for security implications
* **Core Dependencies:** Key packages include:
  - `flutter_secure_storage`: For encrypted secret storage
  - `local_auth`: Biometric authentication
  - `local_auth_android`/`local_auth_darwin`: Platform-specific auth
  - `crypto`: Cryptographic operations for TOTP/HOTP
  - `base32`: Base32 encoding/decoding for secrets
  - `hooks_riverpod`: State management with lifecycle hooks
  - `freezed`: Immutable data classes
  - `go_router`: Declarative navigation
* **Dependency Verification:** Always verify packages handle sensitive data securely
* **Version Pinning:** Pin critical security dependencies to specific versions

## Code Quality
* **Code structure:** Adhere to maintainable code structure and separation of
  concerns (e.g., UI logic separate from business logic).
* **Naming conventions:** Avoid abbreviations and use meaningful, consistent,
  descriptive names for variables, functions, and classes.
* **Conciseness:** Write code that is as short as it can be while remaining
  clear.
* **Simplicity:** Write straightforward code. Code that is clever or
  obscure is difficult to maintain.
* **Error Handling:** Anticipate and handle potential errors. Don't let your
  code fail silently.
* **Styling:**
    * Line length: Lines should be 80 characters or fewer.
    * Use `PascalCase` for classes, `camelCase` for
      members/variables/functions/enums, and `snake_case` for files.
* **Functions:**
    * Functions short and with a single purpose (strive for less than 20 lines).
* **Testing:** Write code with testing in mind. Use the `file`, `process`, and
  `platform` packages, if appropriate, so you can inject in-memory and fake
  versions of the objects.
* **Logging:** Use the `logging` package instead of `print`.

### Cipher Security Guidelines
* **Secret Handling:** Never log, print, or expose secrets in plain text
* **Secure Storage:** Always use `flutter_secure_storage` for sensitive data
* **Input Validation:** Validate all user inputs, especially OTPAuth URIs
* **Timing Attacks:** Use constant-time operations for crypto comparisons
* **Memory Management:** Clear sensitive data from memory when possible
* **Error Messages:** Avoid exposing sensitive information in error messages
* **Authentication State:** Properly manage biometric authentication states
* **Crypto Standards:** Follow RFC 6238 (TOTP) and RFC 4226 (HOTP) specifications exactly

## Dart Best Practices
* **Effective Dart:** Follow the official Effective Dart guidelines
  (https://dart.dev/effective-dart)
* **Class Organization:** Define related classes within the same library file.
  For large libraries, export smaller, private libraries from a single top-level
  library.
* **Library Organization:** Group related libraries in the same folder.
* **API Documentation:** Add documentation comments to all public APIs,
  including classes, constructors, methods, and top-level functions.
* **Comments:** Write clear comments for complex or non-obvious code. Avoid
  over-commenting.
* **Trailing Comments:** Don't add trailing comments.
* **Async/Await:** Ensure proper use of `async`/`await` for asynchronous
  operations with robust error handling.
    * Use `Future`s, `async`, and `await` for asynchronous operations.
    * Use `Stream`s for sequences of asynchronous events.
* **Null Safety:** Write code that is soundly null-safe. Leverage Dart's null
  safety features. Avoid `!` unless the value is guaranteed to be non-null.
* **Pattern Matching:** Use pattern matching features where they simplify the
  code.
* **Records:** Use records to return multiple types in situations where defining
  an entire class is cumbersome.
* **Switch Statements:** Prefer using exhaustive `switch` statements or
  expressions, which don't require `break` statements.
* **Exception Handling:** Use `try-catch` blocks for handling exceptions, and
  use exceptions appropriate for the type of exception. Use custom exceptions
  for situations specific to your code.
* **Arrow Functions:** Use arrow syntax for simple one-line functions.

## Flutter Best Practices
* **Immutability:** Widgets (especially `StatelessWidget`) are immutable; when
  the UI needs to change, Flutter rebuilds the widget tree.
* **Composition:** Prefer composing smaller widgets over extending existing
  ones. Use this to avoid deep widget nesting.
* **Private Widgets:** Use small, private `Widget` classes instead of private
  helper methods that return a `Widget`.
* **Build Methods:** Break down large `build()` methods into smaller, reusable
  private Widget classes.
* **List Performance:** Use `ListView.builder` or `SliverList` for long lists to
  create lazy-loaded lists for performance.
* **Isolates:** Use `compute()` to run expensive calculations in a separate
  isolate to avoid blocking the UI thread, such as JSON parsing.
* **Const Constructors:** Use `const` constructors for widgets and in `build()`
  methods whenever possible to reduce rebuilds.
* **Build Method Performance:** Avoid performing expensive operations, like
  network calls or complex computations, directly within `build()` methods.

## API Design Principles
When building reusable APIs, such as a library, follow these principles.

* **Consider the User:** Design APIs from the perspective of the person who will
  be using them. The API should be intuitive and easy to use correctly.
* **Documentation is Essential:** Good documentation is a part of good API
  design. It should be clear, concise, and provide examples.

## Application Architecture
* **Separation of Concerns:** Aim for separation of concerns similar to MVC/MVVM, with defined Model,
  View, and ViewModel/Controller roles.
* **Logical Layers:** Organize the project into logical layers:
    * Presentation (widgets, screens)
    * Domain (business logic classes)
    * Data (model classes, API clients)
    * Core (shared classes, utilities, and extension types)
* **Feature-based Organization:** For larger projects, organize code by feature,
  where each feature has its own presentation, domain, and data subfolders. This
  improves navigability and scalability.

## Lint Rules

Include the package in the `analysis_options.yaml` file. Use the following
analysis_options.yaml file as a starting point:

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # Add additional lint rules here:
    # avoid_print: false
    # prefer_single_quotes: true
```

### State Management
* **Riverpod:** Use the `riverpod` package for state management, with code
  generation via `build_runner`.
* **Provider Organization:** Any riverpod providers should be defined in a 
`providers` subfolder within each feature folder.
* **Service Organization:** The services that the providers depend on should be defined in a `services` subfolder.
* **Model Organization:** Any data models should be defined in a `models` subfolder and should use the `freezed` package for immutable data classes.
* **Constants Organization:** Any feature constants should be defined in `constants.dart` under a `utils` subfolder.

### Cipher-Specific State Management
* **Security State:** Use `SettingsState` with loading/loaded/error states for secure operations
* **Account State:** `AuthController` manages account list with real-time TOTP updates
* **Biometric State:** `BiometricAuthStatus` enum for authentication flow states
* **Immutable Models:** All models use `@freezed` for immutability and type safety
* **Code Generation:** Always run `dart run build_runner build` after model changes


### Data Flow
* **Data Structures:** Define data structures (classes) to represent the data
  used in the application.
* **Data Abstraction:** Abstract data sources (e.g., API calls, database
  operations) using services to promote testability.

### Routing
* **GoRouter:** Use the `go_router` package for declarative navigation, deep
  linking, and web support.
* **GoRouter Setup:** To use `go_router`, first add it to your `pubspec.yaml`
  using the `pub` tool's `add` command.

  ```dart
  // 1. Add the dependency
  // flutter pub add go_router

  // 2. Configure the router
  final GoRouter _router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'details/:id', // Route with a path parameter
            builder: (context, state) {
              final String id = state.pathParameters['id']!;
              return DetailScreen(id: id);
            },
          ),
        ],
      ),
    ],
  );

  // 3. Use it in your MaterialApp
  MaterialApp.router(
    routerConfig: _router,
  );
  ```


### Data Handling & Serialization
* **JSON Serialization:** Use `freezed` and `json_annotation` for
  parsing and encoding JSON data.
* **Field Renaming:** When encoding data, use `fieldRename: FieldRename.snake`
  to convert Dart's camelCase fields to snake_case JSON keys.

  ```dart
  // In your model file
  import 'package:json_annotation/json_annotation.dart';

  part 'user.g.dart';

  @freezed
  class User with _$User {

    const User._();

    const factory User({
      required String firstName,
      required String lastName,
    }) = _User;

    factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  }
  ```


### Logging
* **Structured Logging:** Use the `log` function from `dart:developer` for
  structured logging that integrates with Dart DevTools.

  ```dart
  import 'dart:developer' as developer;

  // For simple messages
  developer.log('User logged in successfully.');

  // For structured error logging
  try {
    // ... code that might fail
  } catch (e, s) {
    developer.log(
      'Failed to fetch data',
      name: 'myapp.network',
      level: 1000, // SEVERE
      error: e,
      stackTrace: s,
    );
  }
  ```

## Code Generation
* **Build Runner:** If the project uses code generation, ensure that
  `build_runner` is listed as a dev dependency in `pubspec.yaml`.
* **Code Generation Tasks:** Use `build_runner` for all code generation tasks,
  such as for `freezed` and `riverpod`.
* **Running Build Runner:** After modifying files that require code generation,
  run the build command:

  ```shell
  dart run build_runner build --delete-conflicting-outputs
  ```

## Visual Design & Theming
* **UI Design:** Build beautiful and intuitive user interfaces that follow
  modern design guidelines.
* **Responsiveness:** Ensure the app is mobile responsive and adapts to
  different screen sizes, working perfectly on mobile and web.
* **Navigation:** If there are multiple pages for the user to interact with,
  provide an intuitive and easy navigation bar or controls.
* **Typography:** Stress and emphasize font sizes to ease understanding, e.g.,
  hero text, section headlines, list headlines, keywords in paragraphs.
* **Background:** Apply subtle noise texture to the main background to add a
  premium, tactile feel.
* **Shadows:** Multi-layered drop shadows create a strong sense of depth; cards
  have a soft, deep shadow to look "lifted."
* **Icons:** Incorporate icons to enhance the user’s understanding and the
  logical navigation of the app.
* **Interactive Elements:** Buttons, checkboxes, sliders, lists, charts, graphs,
  and other interactive elements have a shadow with elegant use of color to
  create a "glow" effect.

### Theming
* **Centralized Theme:** Define a centralized `ThemeData` object to ensure a
  consistent application-wide style.
* **Light and Dark Themes:** Implement support for both light and dark themes,
  ideal for a user-facing theme toggle (`ThemeMode.light`, `ThemeMode.dark`,
  `ThemeMode.system`).
* **Color Scheme Generation:** Generate harmonious color palettes from a single
  color using `ColorScheme.fromSeed`.

  ```dart
  final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    ),
    // ... other theme properties
  );
  ```
* **Color Palette:** Include a wide range of color concentrations and hues in
  the palette to create a vibrant and energetic look and feel.
* **Component Themes:** Use specific theme properties (e.g., `appBarTheme`,
  `elevatedButtonTheme`) to customize the appearance of individual Material
  components.
* **Custom Fonts:** For custom fonts, use the `google_fonts` package. Define a
  `TextTheme` to apply fonts consistently.

  ```dart
  // 1. Add the dependency
  // flutter pub add google_fonts

  // 2. Define a TextTheme with a custom font
  final TextTheme appTextTheme = TextTheme(
    displayLarge: GoogleFonts.oswald(fontSize: 57, fontWeight: FontWeight.bold),
    titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
    bodyMedium: GoogleFonts.openSans(fontSize: 14),
  );
  ```

### Assets and Images
* **Image Guidelines:** If images are needed, make them relevant and meaningful,
  with appropriate size, layout, and licensing (e.g., freely available). Provide
  placeholder images if real ones are not available.
* **Asset Declaration:** Declare all asset paths in your `pubspec.yaml` file.

    ```yaml
    flutter:
      uses-material-design: true
      assets:
        - assets/images/
    ```

* **Local Images:** Use `Image.asset` for local images from your asset
  bundle.

    ```dart
    Image.asset('assets/images/placeholder.png')
    ```
* **Network images:** Use NetworkImage for images loaded from the network.
* **Cached images:** For cached images, use NetworkImage a package like
  `cached_network_image`.
* **Custom Icons:** Use `ImageIcon` to display an icon from an `ImageProvider`,
  useful for custom icons not in the `Icons` class.
* **Network Images:** Use `Image.network` to display images from a URL, and
  always include `loadingBuilder` and `errorBuilder` for a better user
  experience.

    ```dart
    Image.network(
      'https://picsum.photos/200/300',
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.error);
      },
    )
    ```

## Layout Best Practices

### Building Flexible and Overflow-Safe Layouts

#### For Rows and Columns

* **`Expanded`:** Use to make a child widget fill the remaining available space
  along the main axis.
* **`Flexible`:** Use when you want a widget to shrink to fit, but not
  necessarily grow. Don't combine `Flexible` and `Expanded` in the same `Row` or
  `Column`.
* **`Wrap`:** Use when you have a series of widgets that would overflow a `Row`
  or `Column`, and you want them to move to the next line.

#### For General Content

* **`SingleChildScrollView`:** Use when your content is intrinsically larger
  than the viewport, but is a fixed size.
* **`ListView` / `GridView`:** For long lists or grids of content, always use a
  builder constructor (`.builder`).
* **`FittedBox`:** Use to scale or fit a single child widget within its parent.
* **`LayoutBuilder`:** Use for complex, responsive layouts to make decisions
  based on the available space.

### Layering Widgets with Stack

* **`Positioned`:** Use to precisely place a child within a `Stack` by anchoring it to the edges.
* **`Align`:** Use to position a child within a `Stack` using alignments like `Alignment.center`.

### Advanced Layout with Overlays

* **`OverlayPortal`:** Use this widget to show UI elements (like custom
  dropdowns or tooltips) "on top" of everything else. It manages the
  `OverlayEntry` for you.

  ```dart
  class MyDropdown extends StatefulWidget {
    const MyDropdown({super.key});

    @override
    State<MyDropdown> createState() => _MyDropdownState();
  }

  class _MyDropdownState extends State<MyDropdown> {
    final _controller = OverlayPortalController();

    @override
    Widget build(BuildContext context) {
      return OverlayPortal(
        controller: _controller,
        overlayChildBuilder: (BuildContext context) {
          return const Positioned(
            top: 50,
            left: 10,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('I am an overlay!'),
              ),
            ),
          );
        },
        child: ElevatedButton(
          onPressed: _controller.toggle,
          child: const Text('Toggle Overlay'),
        ),
      );
    }
  }
  ```

## Color Scheme Best Practices

### Contrast Ratios

* **WCAG Guidelines:** Aim to meet the Web Content Accessibility Guidelines
  (WCAG) 2.1 standards.
* **Minimum Contrast:**
    * **Normal Text:** A contrast ratio of at least **4.5:1**.
    * **Large Text:** (18pt or 14pt bold) A contrast ratio of at least **3:1**.

### Palette Selection

* **Primary, Secondary, and Accent:** Define a clear color hierarchy.
* **The 60-30-10 Rule:** A classic design rule for creating a balanced color scheme.
    * **60%** Primary/Neutral Color (Dominant)
    * **30%** Secondary Color
    * **10%** Accent Color

### Complementary Colors

* **Use with Caution:** They can be visually jarring if overused.
* **Best Use Cases:** They are excellent for accent colors to make specific
  elements pop, but generally poor for text and background pairings as they can
  cause eye strain.

### Example Palette

* **Primary:** Color `0x0D47A1` (Dark Blue)
* **Secondary:** Color `0x1976D2` (Medium Blue)
* **Accent:** Color `0xFFC107` (Amber)
* **Neutral/Text:** Color `0x212121` (Almost Black)
* **Background:** Color `0xFEFEFE` (Almost White)

## Font Best Practices

### Font Selection

* **Limit Font Families:** Stick to one or two font families for the entire
  application.
* **Prioritize Legibility:** Choose fonts that are easy to read on screens of
  all sizes. Sans-serif fonts are generally preferred for UI body text.
* **System Fonts:** Consider using platform-native system fonts.
* **Google Fonts:** For a wide selection of open-source fonts, use the
  `google_fonts` package.

### Hierarchy and Scale

* **Establish a Scale:** Define a set of font sizes for different text elements
  (e.g., headlines, titles, body text, captions).
* **Use Font Weight:** Differentiate text effectively using font weights.
* **Color and Opacity:** Use color and opacity to de-emphasize less important
  text.

### Readability

* **Line Height (Leading):** Set an appropriate line height, typically **1.4x to
  1.6x** the font size.
* **Line Length:** For body text, aim for a line length of **45-75 characters**.
* **Avoid All Caps:** Do not use all caps for long-form text.

## Documentation

* **`dartdoc`:** Write `dartdoc`-style comments for all public APIs.


### Documentation Philosophy

* **Comment wisely:** Use comments to explain why the code is written a certain
  way, not what the code does. The code itself should be self-explanatory.
* **Document for the user:** Write documentation with the reader in mind. If you
  had a question and found the answer, add it to the documentation where you
  first looked. This ensures the documentation answers real-world questions.
* **No useless documentation:** If the documentation only restates the obvious
  from the code's name, it's not helpful. Good documentation provides context
  and explains what isn't immediately apparent.
* **Consistency is key:** Use consistent terminology throughout your
  documentation.

### Commenting Style

* **Use `///` for doc comments:** This allows documentation generation tools to
  pick them up.
* **Start with a single-sentence summary:** The first sentence should be a
  concise, user-centric summary ending with a period.
* **Separate the summary:** Add a blank line after the first sentence to create
  a separate paragraph. This helps tools create better summaries.
* **Avoid redundancy:** Don't repeat information that's obvious from the code's
  context, like the class name or signature.
* **Don't document both getter and setter:** For properties with both, only
  document one. The documentation tool will treat them as a single field.

### Writing Style

* **Be brief:** Write concisely.
* **Avoid jargon and acronyms:** Don't use abbreviations unless they are widely
  understood.
* **Use Markdown sparingly:** Avoid excessive markdown and never use HTML for
  formatting.
* **Use backticks for code:** Enclose code blocks in backtick fences, and
  specify the language.

### What to Document

* **Public APIs are a priority:** Always document public APIs.
* **Consider private APIs:** It's a good idea to document private APIs as well.
* **Library-level comments are helpful:** Consider adding a doc comment at the
  library level to provide a general overview.
* **Include code samples:** Where appropriate, add code samples to illustrate usage.
* **Explain parameters, return values, and exceptions:** Use prose to describe
  what a function expects, what it returns, and what errors it might throw.
* **Place doc comments before annotations:** Documentation should come before
  any metadata annotations.

## Accessibility (A11Y)
Implement accessibility features to empower all users, assuming a wide variety
of users with different physical abilities, mental abilities, age groups,
education levels, and learning styles.

* **Color Contrast:** Ensure text has a contrast ratio of at least **4.5:1**
  against its background.
* **Dynamic Text Scaling:** Test your UI to ensure it remains usable when users
  increase the system font size.
* **Semantic Labels:** Use the `Semantics` widget to provide clear, descriptive
  labels for UI elements.
* **Screen Reader Testing:** Regularly test your app with TalkBack (Android) and
  VoiceOver (iOS).


# Version Control & Release Management

## Git Workflow
* **Git:** Use Git for version control with a clean, linear history
* **Conventional Commits:** Follow conventional commit patterns for clear history
* **Branch Strategy:** Use feature branches for development, main for stable releases
* **Commit Messages:** Write descriptive commit messages explaining the "why"

## Version Management

### Semantic Versioning Strategy
Cipher follows semantic versioning (`MAJOR.MINOR.PATCH+BUILD`) as defined in `pubspec.yaml`:

```yaml
version: 0.2.1+5
#        │ │ │ │
#        │ │ │ └── Build number (auto-increment for each build)
#        │ │ └──── Patch (bug fixes, security patches)
#        │ └────── Minor (new features, UI improvements)
#        └──────── Major (breaking changes, major rewrites)
```

### When to Update Versions

#### Build Number (`+N`) - Every Build
- Increment for every CI/CD build
- Internal testing builds
- Development snapshots
- Hot fixes

#### Patch Version (`X.X.N`) - Bug Fixes & Security
- Security vulnerability fixes
- Critical bug fixes
- Performance improvements
- Documentation updates
- Code refactoring without functional changes

#### Minor Version (`X.N.0`) - New Features
- New authenticator features (HOTP support, backup/restore)
- UI/UX improvements
- New settings or configuration options
- Biometric authentication enhancements
- QR code scanning improvements

#### Major Version (`N.0.0`) - Breaking Changes
- Complete UI redesign
- Data format changes requiring migration
- Architecture overhauls
- API breaking changes
- First public release (1.0.0)

### Version Update Process

#### Manual Version Updates
```bash
# Update pubspec.yaml version manually
version: 0.3.0+1

# Commit the version change
git add pubspec.yaml
git commit -m "chore: bump version to v0.3.0+1"

# Create annotated tag with release notes
git tag -a v0.3.0+1 -m "Release v0.3.0+1

New Features:
- Enhanced biometric authentication
- Improved TOTP generation performance
- Added dark theme support

Security Improvements:
- Updated encryption algorithms
- Enhanced secure storage implementation

Bug Fixes:
- Fixed QR code scanning edge cases
- Resolved clipboard timeout issues"
```

#### Automated Version Bumping
Create a script for consistent version management:

```dart
// scripts/version_bump.dart
import 'dart:io';

Future<void> bumpVersion(String type) async {
  final pubspecFile = File('pubspec.yaml');
  final content = await pubspecFile.readAsString();
  
  // Parse current version
  final versionMatch = RegExp(r'version: (\d+)\.(\d+)\.(\d+)\+(\d+)')
      .firstMatch(content);
  
  if (versionMatch == null) throw 'Version not found';
  
  var major = int.parse(versionMatch.group(1)!);
  var minor = int.parse(versionMatch.group(2)!);
  var patch = int.parse(versionMatch.group(3)!);
  var build = int.parse(versionMatch.group(4)!);
  
  switch (type) {
    case 'major':
      major++; minor = 0; patch = 0; build = 1;
      break;
    case 'minor':
      minor++; patch = 0; build = 1;
      break;
    case 'patch':
      patch++; build = 1;
      break;
    case 'build':
      build++;
      break;
  }
  
  final newVersion = '$major.$minor.$patch+$build';
  final newContent = content.replaceFirst(
    RegExp(r'version: \d+\.\d+\.\d+\+\d+'),
    'version: $newVersion',
  );
  
  await pubspecFile.writeAsString(newContent);
  print('Version bumped to: $newVersion');
}
```

### Git Tagging Strategy

#### Tag Naming Convention
- Use `v` prefix: `v0.2.1+5`
- Match exactly with pubspec.yaml version
- Use annotated tags with detailed release notes

#### Tag Creation Examples
```bash
# Security release
git tag -a v0.2.1+5 -m "Security Release v0.2.1+5

Critical Security Fixes:
- Fixed potential timing attack in TOTP generation
- Updated secure storage encryption method
- Enhanced biometric authentication security

This is a critical security update. All users should update immediately."

# Feature release
git tag -a v0.3.0+1 -m "Feature Release v0.3.0+1

New Features:
- HOTP support for counter-based codes
- Backup and restore functionality
- Enhanced QR code scanning with better error handling
- Improved accessibility support

UI/UX Improvements:
- Redesigned settings screen
- Better dark theme support
- Improved TOTP timer visualization

Technical Improvements:
- Migrated to new state management pattern
- Enhanced error handling throughout the app
- Performance optimizations for large account lists"
```

### Release Workflow

#### Pre-Release Checklist
1. **Security Review:** Ensure no sensitive data in commits
2. **Code Quality:** Run `dart analyze` and fix all issues
3. **Testing:** Execute full test suite
4. **Dependencies:** Update and audit all dependencies
5. **Documentation:** Update README and changelogs

#### Release Process
```bash
# 1. Create release branch
git checkout -b release/v0.3.0

# 2. Update version in pubspec.yaml
# 3. Update CHANGELOG.md with release notes
# 4. Run final tests
flutter test
dart analyze

# 5. Commit release changes
git add .
git commit -m "chore: prepare release v0.3.0+1"

# 6. Merge to main
git checkout main
git merge release/v0.3.0 --no-ff

# 7. Create and push tag
git tag -a v0.3.0+1 -F release_notes.txt
git push origin main --tags

# 8. Clean up release branch
git branch -d release/v0.3.0
```

### Development Versioning

#### Pre-Release Versions
- Use semantic versioning for pre-release: `0.3.0-alpha.1+10`
- Alpha: Early development, major features incomplete
- Beta: Feature complete, testing and bug fixes
- RC: Release candidate, final testing

#### Continuous Integration
Automate version bumping in CI/CD:

```yaml
# .github/workflows/version.yml
name: Auto Version Bump
on:
  push:
    branches: [main]

jobs:
  version:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Bump build number
        run: dart scripts/version_bump.dart build
      - name: Commit version bump
        run: |
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"
          git add pubspec.yaml
          git commit -m "chore: auto-bump build number [skip ci]"
          git push
```

### Security Considerations
- **Never commit secrets:** Use `.gitignore` for sensitive files
- **Sign tags:** Use GPG signing for release tags
- **Audit dependencies:** Review all dependency updates for security
- **Change logs:** Document security fixes without revealing vulnerabilities
