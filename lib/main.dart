import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MoodProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Diary',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class MoodEntry {
  final DateTime date;
  final String mood;
  final String note;

  MoodEntry({
    required this.date,
    required this.mood,
    required this.note,
  });
}

class MoodProvider extends ChangeNotifier {
  final List<MoodEntry> _entries = [];
  DateTime _selectedDate = DateTime.now();

  List<MoodEntry> get entries => _entries;
  DateTime get selectedDate => _selectedDate;

  void addEntry(MoodEntry entry) {
    _entries.add(entry);
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  MoodEntry? getEntryForDate(DateTime date) {
    try {
      return _entries.firstWhere(
        (entry) => isSameDay(entry.date, date),
      );
    } catch (e) {
      return null;
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Diary'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StatsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendarHeader(),
          _buildCalendarGrid(),
          const SizedBox(height: 20),
          _buildSelectedDayInfo(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddMoodBottomSheet(context),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Consumer<MoodProvider>(
        builder: (context, provider, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(provider.selectedDate),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => provider.setSelectedDate(
                      DateTime(provider.selectedDate.year,
                          provider.selectedDate.month - 1),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => provider.setSelectedDate(
                      DateTime(provider.selectedDate.year,
                          provider.selectedDate.month + 1),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return Consumer<MoodProvider>(
      builder: (context, provider, child) {
        final firstDay = DateTime(
            provider.selectedDate.year, provider.selectedDate.month, 1);
        final lastDay = DateTime(
            provider.selectedDate.year, provider.selectedDate.month + 1, 0);
        final daysInMonth = lastDay.day;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
          ),
          itemCount: daysInMonth,
          itemBuilder: (context, index) {
            final currentDate = DateTime(provider.selectedDate.year,
                provider.selectedDate.month, index + 1);
            final entry = provider.getEntryForDate(currentDate);

            return GestureDetector(
              onTap: () => provider.setSelectedDate(currentDate),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: entry != null
                      ? _getMoodColor(entry.mood).withOpacity(0.3)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        provider.isSameDay(currentDate, provider.selectedDate)
                            ? Colors.blue
                            : Colors.grey,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: entry != null
                              ? _getMoodColor(entry.mood)
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (entry != null) Text(entry.mood),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSelectedDayInfo() {
    return Consumer<MoodProvider>(
      builder: (context, provider, child) {
        final entry = provider.getEntryForDate(provider.selectedDate);

        return Column(
          children: [
            Text(
              DateFormat('EEEE, MMM d').format(provider.selectedDate),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (entry != null) ...[
              Text('Mood: ${entry.mood}', style: const TextStyle(fontSize: 16)),
              Text('Note: ${entry.note}', style: const TextStyle(fontSize: 16)),
            ],
          ],
        );
      },
    );
  }

  void _showAddMoodBottomSheet(BuildContext context) {
    String selectedMood = '😊';
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('How are you feeling today?',
                    style: TextStyle(fontSize: 20)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMoodButton(
                        '😊', selectedMood, () => selectedMood = '😊'),
                    _buildMoodButton(
                        '😢', selectedMood, () => selectedMood = '😢'),
                    _buildMoodButton(
                        '😠', selectedMood, () => selectedMood = '😠'),
                    _buildMoodButton(
                        '😴', selectedMood, () => selectedMood = '😴'),
                    _buildMoodButton(
                        '🎉', selectedMood, () => selectedMood = '🎉'),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    labelText: 'Add a note',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 100,
                ),
                ElevatedButton(
                  onPressed: () {
                    final entry = MoodEntry(
                      date: context.read<MoodProvider>().selectedDate,
                      mood: selectedMood,
                      note: textController.text,
                    );
                    context.read<MoodProvider>().addEntry(entry);
                    Navigator.pop(context);
                  },
                  child: const Text('Save Entry'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMoodButton(String mood, String selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: mood == selected ? _getMoodColor(mood).withOpacity(0.3) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(mood, style: const TextStyle(fontSize: 32)),
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case '😊':
        return Colors.yellow;
      case '😢':
        return Colors.blue;
      case '😠':
        return Colors.red;
      case '😴':
        return Colors.purple;
      case '🎉':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<MoodProvider>().entries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: entries.isEmpty
          ? const Center(child: Text('No entries yet!'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Mood Distribution',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                PieChartSample(entries: entries),
                const SizedBox(height: 20),
                ..._buildMoodStatistics(entries),
              ],
            ),
    );
  }

  List<Widget> _buildMoodStatistics(List<MoodEntry> entries) {
    final moodCounts = <String, int>{};

    for (var entry in entries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    return moodCounts.entries
        .map((entry) => ListTile(
              leading: Text(entry.key, style: const TextStyle(fontSize: 24)),
              title: Text('Count: ${entry.value}'),
              tileColor: _getMoodColor(entry.key).withOpacity(0.1),
            ))
        .toList();
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case '😊':
        return Colors.yellow;
      case '😢':
        return Colors.blue;
      case '😠':
        return Colors.red;
      case '😴':
        return Colors.purple;
      case '🎉':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class PieChartSample extends StatelessWidget {
  final List<MoodEntry> entries;

  const PieChartSample({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final moodCounts = <String, int>{};
    for (var entry in entries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      child: CustomPaint(
        painter: PieChartPainter(moodCounts: moodCounts),
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final Map<String, int> moodCounts;

  PieChartPainter({required this.moodCounts});

  @override
  void paint(Canvas canvas, Size size) {
    final total = moodCounts.values.fold(0, (a, b) => a + b);
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.shortestSide / 2,
    );

    double startAngle = -0.5 * 3.14159;
    int index = 0;

    moodCounts.forEach((mood, count) {
      final sweepAngle = 2 * 3.14159 * (count / total);
      final paint = Paint()
        ..color = _getMoodColor(mood)
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
      index++;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  Color _getMoodColor(String mood) {
    switch (mood) {
      case '😊':
        return Colors.yellow;
      case '😢':
        return Colors.blue;
      case '😠':
        return Colors.red;
      case '😴':
        return Colors.purple;
      case '🎉':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
