// lib/screens/scan/scan_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

enum ScanStep { selectArea, capture, processing, done }

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  ScanStep _step = ScanStep.selectArea;
  String _selectedArea = '';
  bool _uvMode = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  double _analysisProgress = 0;

  final List<Map<String, dynamic>> _bodyAreas = [
    {'label': 'Face', 'icon': Icons.face_outlined},
    {'label': 'Neck', 'icon': Icons.accessibility_new_outlined},
    {'label': 'Chest', 'icon': Icons.accessibility_outlined},
    {'label': 'Back', 'icon': Icons.back_hand_outlined},
    {'label': 'Arm', 'icon': Icons.pan_tool_alt_outlined},
    {'label': 'Leg', 'icon': Icons.directions_walk_outlined},
    {'label': 'Hand', 'icon': Icons.pan_tool_outlined},
    {'label': 'Foot', 'icon': Icons.directions_run_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startCapture() async {
    setState(() => _step = ScanStep.capture);
  }

  Future<void> _startProcessing() async {
    setState(() {
      _step = ScanStep.processing;
      _analysisProgress = 0;
    });

    // Simulate AI processing
    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (mounted) setState(() => _analysisProgress = i / 100.0);
    }

    if (mounted) context.go('/scan/result/scan_001');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Scan'),
        leading: IconButton(
          onPressed: () {
            if (_step == ScanStep.selectArea) {
              context.go('/home');
            } else {
              setState(() {
                _step = ScanStep.values[_step.index - 1];
              });
            }
          },
          icon: const Icon(Icons.arrow_back_ios_rounded),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: switch (_step) {
          ScanStep.selectArea => _SelectAreaView(
              key: const ValueKey('select'),
              areas: _bodyAreas,
              selectedArea: _selectedArea,
              onSelect: (area) => setState(() => _selectedArea = area),
              onNext: _selectedArea.isNotEmpty ? _startCapture : null,
            ),
          ScanStep.capture => _CaptureView(
              key: const ValueKey('capture'),
              selectedArea: _selectedArea,
              uvMode: _uvMode,
              pulseAnim: _pulseAnim,
              onToggleUV: () => setState(() => _uvMode = !_uvMode),
              onCapture: _startProcessing,
            ),
          ScanStep.processing => _ProcessingView(
              key: const ValueKey('processing'),
              progress: _analysisProgress,
            ),
          ScanStep.done => const SizedBox.shrink(),
        },
      ),
    );
  }
}

// ─── Step 1: Select Body Area ────────────────────────────────────────────────

class _SelectAreaView extends StatelessWidget {
  final List<Map<String, dynamic>> areas;
  final String selectedArea;
  final void Function(String) onSelect;
  final VoidCallback? onNext;

  const _SelectAreaView({
    super.key,
    required this.areas,
    required this.selectedArea,
    required this.onSelect,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress step indicator
          const _StepIndicator(currentStep: 1),
          const SizedBox(height: 24),

          const Text(
            'Select Scan Area',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose the body area you want to scan for accurate analysis.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),

          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: areas.length,
              itemBuilder: (context, i) {
                final area = areas[i];
                final isSelected = selectedArea == area['label'];
                return GestureDetector(
                  onTap: () => onSelect(area['label']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha:0.1)
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          area['icon'],
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          area['label'],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              child: const Text('Continue to Capture'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 2: Camera Capture ──────────────────────────────────────────────────

class _CaptureView extends StatelessWidget {
  final String selectedArea;
  final bool uvMode;
  final Animation<double> pulseAnim;
  final VoidCallback onToggleUV;
  final VoidCallback onCapture;

  const _CaptureView({
    super.key,
    required this.selectedArea,
    required this.uvMode,
    required this.pulseAnim,
    required this.onToggleUV,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview placeholder
        Container(
          color: uvMode ? const Color(0xFF0A0020) : Colors.black,
          child: Center(
            child: AnimatedBuilder(
              animation: pulseAnim,
              builder: (_, child) => Transform.scale(
                scale: pulseAnim.value,
                child: child,
              ),
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: uvMode ? AppColors.uvCyan : Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    // Corner guides
                    ...const [
                      Alignment.topLeft,
                      Alignment.topRight,
                      Alignment.bottomLeft,
                      Alignment.bottomRight,
                    ].map((align) => Align(
                          alignment: align,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              border: Border(
                                top: align.y < 0
                                    ? BorderSide(
                                        color: uvMode
                                            ? AppColors.uvCyan
                                            : Colors.white,
                                        width: 4)
                                    : BorderSide.none,
                                bottom: align.y > 0
                                    ? BorderSide(
                                        color: uvMode
                                            ? AppColors.uvCyan
                                            : Colors.white,
                                        width: 4)
                                    : BorderSide.none,
                                left: align.x < 0
                                    ? BorderSide(
                                        color: uvMode
                                            ? AppColors.uvCyan
                                            : Colors.white,
                                        width: 4)
                                    : BorderSide.none,
                                right: align.x > 0
                                    ? BorderSide(
                                        color: uvMode
                                            ? AppColors.uvCyan
                                            : Colors.white,
                                        width: 4)
                                    : BorderSide.none,
                              ),
                            ),
                          ),
                        )),
                    if (uvMode)
                      Center(
                        child: Text(
                          'UV MODE\nACTIVE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.uvCyan.withValues(alpha:0.5),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Top overlay
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withValues(alpha:0.6), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  const _StepIndicator(currentStep: 2, dark: true),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha:0.3), width: 1),
                    ),
                    child: Text(
                      selectedArea,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Bottom controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black.withValues(alpha:0.7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Text(
                  uvMode
                      ? 'UV fluorescence mode active'
                      : 'Position skin within the frame',
                  style: TextStyle(
                    color: uvMode ? AppColors.uvCyan : Colors.white,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // UV toggle
                    GestureDetector(
                      onTap: onToggleUV,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: uvMode
                              ? AppColors.uvCyan.withValues(alpha:0.2)
                              : Colors.white.withValues(alpha:0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                uvMode ? AppColors.uvCyan : Colors.white,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(Icons.light_mode_rounded,
                            color: uvMode ? AppColors.uvCyan : Colors.white,
                            size: 24),
                      ),
                    ),

                    // Capture button
                    GestureDetector(
                      onTap: onCapture,
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.uvBlue],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              color: Colors.white, size: 28),
                        ),
                      ),
                    ),

                    // Flip camera
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha:0.3), width: 1.5),
                      ),
                      child: const Icon(Icons.flip_camera_ios_rounded,
                          color: Colors.white, size: 24),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Step 3: AI Processing ───────────────────────────────────────────────────

class _ProcessingView extends StatelessWidget {
  final double progress;

  const _ProcessingView({super.key, required this.progress});

  static const _stages = [
    'Preprocessing UV image...',
    'Detecting skin anomalies...',
    'Running BCC classification...',
    'Calculating risk score...',
    'Generating report...',
  ];

  String get _currentStage {
    final i = (progress * (_stages.length - 1)).floor().clamp(0, _stages.length - 1);
    return _stages[i];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkBackground, Color(0xFF1A0F3A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Scanning animation
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.uvCyan.withValues(alpha:0.3), width: 2),
                ),
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.uvCyan.withValues(alpha:0.3),
                        AppColors.primary.withValues(alpha:0.1),
                      ],
                    ),
                  ),
                  child: const Icon(Icons.biotech_outlined,
                      color: AppColors.uvCyan, size: 40),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Analyzing Scan',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                _currentStage,
                style: TextStyle(
                    fontSize: 14, color: Colors.white.withValues(alpha:0.6)),
              ),
              const SizedBox(height: 32),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withValues(alpha:0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.uvCyan),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                    color: AppColors.uvCyan,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared step indicator ───────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final bool dark;
  const _StepIndicator({required this.currentStep, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        final step = i + 1;
        final isActive = step == currentStep;
        final isDone = step < currentStep;
        return Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.riskLow
                    : isActive
                        ? AppColors.primary
                        : (dark ? Colors.white12 : AppColors.border),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : Text(
                        '$step',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isActive || isDone
                              ? Colors.white
                              : AppColors.textMuted,
                        ),
                      ),
              ),
            ),
            if (i < 2)
              Container(
                width: 20,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: isDone
                    ? AppColors.riskLow
                    : (dark ? Colors.white12 : AppColors.border),
              ),
          ],
        );
      }),
    );
  }
}
