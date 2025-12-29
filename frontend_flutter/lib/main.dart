import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';

const String apiBase = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'http://localhost:5000',
);

void main() {
  runApp(const McvDashboard());
}

class McvDashboard extends StatelessWidget {
  const McvDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Microcontroller Vision Classifier',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String statusText = 'Backend status: unknown';
  Color statusColor = Colors.grey;
  String predictionLabel = '--';
  String predictionScore = 'Score: --';
  String sampleName = 'Sample: demo-frame';
  bool isBusy = false;
  List<InferenceEntry> history = [];

  Future<void> _checkBackend() async {
    setState(() {
      statusText = 'Checking backend...';
      statusColor = Colors.blueGrey;
      isBusy = true;
    });

    try {
      final response = await html.HttpRequest.request(
        '$apiBase/api/health',
        method: 'GET',
      );
      final data = json.decode(response.responseText ?? '{}') as Map<String, dynamic>;
      setState(() {
        statusText = 'Backend status: ${data['status']} @ ${data['timestamp']}';
        statusColor = Colors.green;
        isBusy = false;
      });
    } catch (_) {
      setState(() {
        statusText = 'Backend status: offline';
        statusColor = Colors.red;
        isBusy = false;
      });
    }
  }

  Future<void> _loadHistory() async {
    try {
      final response = await html.HttpRequest.request(
        '$apiBase/api/history',
        method: 'GET',
      );
      final data = json.decode(response.responseText ?? '{}') as Map<String, dynamic>;
      final entries = (data['history'] as List<dynamic>? ?? [])
          .map((entry) => InferenceEntry.fromJson(entry as Map<String, dynamic>))
          .toList();
      setState(() {
        history = entries;
      });
    } catch (_) {
      setState(() {
        history = [];
      });
    }
  }

  Future<void> _runInference() async {
    setState(() {
      statusText = 'Sending sample frame...';
      statusColor = Colors.blueGrey;
      isBusy = true;
    });

    try {
      final response = await html.HttpRequest.request(
        '$apiBase/api/infer',
        method: 'POST',
        sendData: json.encode({'sample': 'demo-frame'}),
        requestHeaders: {'Content-Type': 'application/json'},
      );
      final data = json.decode(response.responseText ?? '{}') as Map<String, dynamic>;
      final prediction = data['prediction'] as Map<String, dynamic>? ?? {};
      setState(() {
        predictionLabel = 'Label ${prediction['label'] ?? '--'}';
        predictionScore = 'Score: ${prediction['score'] ?? '--'}';
        sampleName = 'Sample: ${data['sample'] ?? 'demo-frame'}';
        statusText = 'Inference complete';
        statusColor = Colors.green;
        isBusy = false;
      });
      await _loadHistory();
    } catch (_) {
      setState(() {
        statusText = 'Inference failed - check backend';
        statusColor = Colors.red;
        isBusy = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkBackend();
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroSection(statusText: statusText),
                const SizedBox(height: 24),
                _ActionPanel(
                  statusText: statusText,
                  statusColor: statusColor,
                  isBusy: isBusy,
                  onCheckBackend: _checkBackend,
                  onRunInference: _runInference,
                ),
                const SizedBox(height: 24),
                _StatsGrid(
                  predictionLabel: predictionLabel,
                  predictionScore: predictionScore,
                  sampleName: sampleName,
                  history: history,
                ),
                const SizedBox(height: 24),
                _ApiHint(apiBase: apiBase),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.statusText});

  final String statusText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14101828),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Microcontroller Vision Classifier',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 2,
                  color: Colors.blueGrey,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Device-ready vision insights',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Monitor inference results in real time, visualize confidence trends, '
            'and keep your TinyML deployment healthy.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.blueGrey,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            statusText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blueGrey,
                ),
          ),
        ],
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({
    required this.statusText,
    required this.statusColor,
    required this.isBusy,
    required this.onCheckBackend,
    required this.onRunInference,
  });

  final String statusText;
  final Color statusColor;
  final bool isBusy;
  final VoidCallback onCheckBackend;
  final VoidCallback onRunInference;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECEF)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inference Console',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Use the demo controls to send a sample frame to the backend and '
                  'see the predicted label and confidence score.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.blueGrey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Wrap(
                spacing: 12,
                children: [
                  OutlinedButton(
                    onPressed: isBusy ? null : onCheckBackend,
                    child: const Text('Check backend'),
                  ),
                  FilledButton(
                    onPressed: isBusy ? null : onRunInference,
                    child: const Text('Run inference'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                statusText,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: statusColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.predictionLabel,
    required this.predictionScore,
    required this.sampleName,
    required this.history,
  });

  final String predictionLabel;
  final String predictionScore;
  final String sampleName;
  final List<InferenceEntry> history;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 800;
        return Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _InfoCard(
              title: 'Latest Prediction',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    predictionLabel,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    predictionScore,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.blueGrey),
                  ),
                ],
              ),
              width: isNarrow ? constraints.maxWidth : 300,
            ),
            _InfoCard(
              title: 'Sample Frame',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sampleName,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0x334F46E5),
                          Color(0x330EA5E9),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              width: isNarrow ? constraints.maxWidth : 300,
            ),
            _InfoCard(
              title: 'System Notes',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NoteItem(text: 'Connect your board to stream frames.'),
                  _NoteItem(text: 'Match preprocess dimensions to the model.'),
                  _NoteItem(text: 'Monitor memory headroom during inference.'),
                ],
              ),
              width: isNarrow ? constraints.maxWidth : 300,
            ),
            _InfoCard(
              title: 'Recent Inferences',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: history.isEmpty
                    ? [
                        Text(
                          'No history yet. Run inference to populate.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.blueGrey),
                        ),
                      ]
                    : history
                        .take(5)
                        .map((entry) => _HistoryItem(entry: entry))
                        .toList(),
              ),
              width: isNarrow ? constraints.maxWidth : 300,
            ),
          ],
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.child,
    required this.width,
  });

  final String title;
  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _NoteItem extends StatelessWidget {
  const _NoteItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApiHint extends StatelessWidget {
  const _ApiHint({required this.apiBase});

  final String apiBase;

  @override
  Widget build(BuildContext context) {
    return Text(
      'API base: $apiBase (override with --dart-define=API_BASE=...)',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.blueGrey,
          ),
    );
  }
}

class InferenceEntry {
  InferenceEntry({
    required this.id,
    required this.sample,
    required this.label,
    required this.score,
    required this.timestamp,
    required this.latencyMs,
  });

  final int id;
  final String sample;
  final int label;
  final num score;
  final String timestamp;
  final num latencyMs;

  factory InferenceEntry.fromJson(Map<String, dynamic> json) {
    final prediction = json['prediction'] as Map<String, dynamic>? ?? {};
    return InferenceEntry(
      id: json['id'] as int? ?? 0,
      sample: json['sample'] as String? ?? 'demo-frame',
      label: prediction['label'] as int? ?? 0,
      score: prediction['score'] as num? ?? 0,
      timestamp: json['timestamp'] as String? ?? '',
      latencyMs: json['latency_ms'] as num? ?? 0,
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({required this.entry});

  final InferenceEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sample ${entry.sample} → Label ${entry.label}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            'Score ${entry.score} • ${entry.latencyMs} ms',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }
}
