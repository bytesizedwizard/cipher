import 'package:cipher/src/providers/colors.dart';
import 'package:cipher/src/providers/styles.dart';
import 'package:cipher/src/ui/widgets/app_bar.dart';
import 'package:cipher/src/ui/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
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

    return Scaffold(
      appBar: BaseAppBar(
        title: Text("Add Source"),
        elevation: 0,
        titleSpacing: 4,
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Scan Code", style: textStyles.heading2),
              const Gap(5),
              Text(
                "Use your device camera to scan a code, or enter the details manually below.",
                style: textStyles.body,
              ),
              const Gap(20),
              Container(
                decoration: BoxDecoration(
                  color: palette.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                width: 350,
                height: 350,
                child: MobileScanner(
                  controller: _controller!,
                  errorBuilder: (context, exception) {
                    return Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(Symbols.error, size: 36, color: palette.primary),
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
                            exception.errorDetails?.message ?? 'Unknown error',
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
                  fit: BoxFit.contain,
                  onDetect: (result) {
                    debugPrint(result.barcodes.first.rawValue);
                  },
                ),
              ),
              const Gap(25),
              Text(
                "Can't scan code? Try entering it manually below.",
                style: textStyles.heading3,
              ),
              const Gap(10),
              Form(
                child: Column(
                  children: [
                    CustomTextFormField(
                      hintText: "Account Name",
                      prefixIcon: Icon(Symbols.person, color: palette.accent),
                    ),
                    const Gap(15),
                    CustomTextFormField(
                      hintText: "Secret Key",
                      prefixIcon: Icon(Symbols.key, color: palette.accent),
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
