import 'package:base32/base32.dart';
import 'package:cipher/src/feature/account/models/auth_models.dart';
import 'package:cipher/src/feature/account/providers/auth_providers.dart';
import 'package:cipher/src/feature/account/utils/constants.dart';
import 'package:cipher/src/providers/colors.dart';
import 'package:cipher/src/providers/styles.dart';
import 'package:cipher/src/ui/widgets/app_bar.dart';
import 'package:cipher/src/ui/widgets/buttons.dart';
import 'package:cipher/src/ui/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AddEntityScreen extends StatefulHookConsumerWidget {
  const AddEntityScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddEntityScreenState();
}

class _AddEntityScreenState extends ConsumerState<AddEntityScreen> {
  MobileScannerController? _controller;

  @override
  void initState() {
    _controller = MobileScannerController(
      torchEnabled: false,
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.noDuplicates,
      detectionTimeoutMs: 500,
      formats: [BarcodeFormat.qrCode],
      returnImage: false,
      cameraResolution: Size.square(350),
    );
    super.initState();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await _controller?.dispose();
    _controller = null;
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = ref.watch(textStyleProvider);
    final palette = ref.watch(colorPaletteProvider);

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final ObjectRef<Map<String, String>> accountDetails = useRef({});

    return Scaffold(
      appBar: BaseAppBar(
        title: Text("Add Account"),
        elevation: 0,
        titleSpacing: 4,
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(color: palette.accent),
                  width: 350,
                  height: 350,
                  child: MobileScanner(
                    scanWindow: Rect.fromLTRB(50, 50, 50, 50),
                    controller: _controller!,
                    overlayBuilder: (context, constraints) {
                      return SizedBox(
                        width: 250,
                        height: 250,
                        child: Stack(
                          children: [
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: BoxBorder.fromLTRB(
                                    left: BorderSide(
                                      color: palette.fromHex("#FFFFFF"),
                                      width: 4,
                                    ),
                                    top: BorderSide(
                                      color: palette.fromHex("#FFFFFF"),
                                      width: 4,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                  ),
                                ),
                                width: 50,
                                height: 50,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: BoxBorder.fromLTRB(
                                    right: BorderSide(
                                      color: palette.fromHex("#FFFFFF"),
                                      width: 4,
                                    ),
                                    top: BorderSide(
                                      color: palette.fromHex("#FFFFFF"),
                                      width: 4,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                                width: 50,
                                height: 50,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: BoxBorder.fromLTRB(
                                    left: BorderSide(
                                      color: palette.fromHex("#FFFFFF"),
                                      width: 4,
                                    ),
                                    bottom: BorderSide(
                                      color: palette.fromHex("#FFFFFF"),
                                      width: 4,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                  ),
                                ),
                                width: 50,
                                height: 50,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: BoxBorder.fromLTRB(
                                    right: BorderSide(
                                      color: palette.fromHex("#FFFFFF"),
                                      width: 4,
                                    ),
                                    bottom: BorderSide(
                                      color: palette.fromHex("#FFFFFF"),
                                      width: 4,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                                width: 50,
                                height: 50,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    errorBuilder: (context, exception) {
                      return Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Icon(
                              Symbols.error,
                              size: 36,
                              color: palette.primary,
                            ),
                            const Gap(10),
                            Text(
                              "Error",
                              style: textStyles.heading3.copyWith(
                                color: palette.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Gap(10),
                            Text(
                              exception.errorDetails?.message ??
                                  'Unknown error',
                              style: textStyles.body.copyWith(
                                color: palette.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Gap(5),
                            Text(
                              "Error Code: ${exception.errorCode.hashCode}",
                              style: textStyles.body.copyWith(
                                color: palette.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                    fit: BoxFit.cover,
                    onDetect: (result) {
                      final keyUri = result.barcodes.first.rawValue;
                      if (keyUri != null &&
                          keyUri.startsWith(AuthConstants.uriScheme)) {
                        ref
                            .read(authControllerProvider.notifier)
                            .addAccountFromUri(keyUri);

                        if (context.canPop()) context.pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Scanned code is not valid. Please try again.",
                              style: textStyles.body.copyWith(
                                color: palette.primary,
                              ),
                            ),
                            backgroundColor: palette.error,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              const Gap(25),
              Text(
                "Can't scan code? Try entering the details manually below.",
                style: textStyles.heading3,
              ),
              const Gap(20),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    CustomTextFormField(
                      hintText: "Issuer (e.g. Google, Facebook)",
                      prefixIcon: Icon(Symbols.business, color: palette.accent),
                      onSaved: (value) {
                        accountDetails.value['issuer'] = value ?? '';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter an issuer name";
                        }
                        return null;
                      },
                    ),
                    const Gap(15),
                    CustomTextFormField(
                      hintText: "Username or Email",
                      prefixIcon: Icon(Symbols.person, color: palette.accent),
                      onSaved: (value) {
                        accountDetails.value['name'] = value ?? '';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username or email';
                        }

                        return null;
                      },
                    ),
                    const Gap(15),
                    CustomTextFormField(
                      hintText: "Secret Key",
                      prefixIcon: Icon(Symbols.key, color: palette.accent),
                      onSaved: (value) {
                        accountDetails.value['secret'] = value ?? '';
                      },
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a secret key';
                        } else if (base32.isValid(value) == false) {
                          return 'Please enter a valid secret key';
                        }

                        return null;
                      },
                    ),
                    const Gap(15),
                    SemanticElevatedButton(
                      label: "Add Account",
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          formKey.currentState?.save();

                          final secret = accountDetails.value['secret'] ?? '';
                          String label = accountDetails.value['name'] ?? '';
                          String issuer = accountDetails.value['issuer'] ?? '';

                          if (label.contains(":") && issuer.isEmpty) {
                            issuer = label.split(":").first;
                            label = label.split(":").last;
                          }

                          final account = Account(
                            label: label,
                            issuer: issuer,
                            algorithm: AuthConstants.algorithmSHA1,
                            digits: 6,
                            period: 30,
                            type: AuthConstants.totp,
                          );

                          ref
                              .read(authControllerProvider.notifier)
                              .addAccount(account, secret);

                          context.pop();
                        }
                      },
                      semanticLabel: "Add new account",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
