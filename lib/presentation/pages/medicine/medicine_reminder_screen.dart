import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:alarm/alarm.dart';
import '../../../core/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../../data/repositories/activity_log_repository.dart';

class MedicineReminderScreen extends StatefulWidget {
  const MedicineReminderScreen({super.key});

  @override
  State<MedicineReminderScreen> createState() => _MedicineReminderScreenState();
}

class _MedicineReminderScreenState extends State<MedicineReminderScreen> {
  final ActivityLogRepository _activityLogRepository = ActivityLogRepository();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _scheduleAlarm(String name, TimeOfDay time, {int? id}) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final alarmSettings = AlarmSettings(
      id: id ?? DateTime.now().millisecondsSinceEpoch % 100000,
      dateTime: scheduledDate,
      assetAudioPath: null,
      loopAudio: true,
      vibrate: true,
      volumeSettings: VolumeSettings.fade(
        volume: 0.8,
        fadeDuration: Duration(seconds: 5),
      ),
      notificationSettings: NotificationSettings(
        title: 'Medicine Reminder',
        body: 'It\'s time to take your $name',
        stopButton: 'Stop',
        icon: 'notification_icon',
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }

  void _showAddEditMedicineModal([Map<String, dynamic>? existingData]) {
    final nameCtrl = TextEditingController(text: existingData?['name'] ?? '');
    String frequency = existingData?['frequency'] ?? 'Daily';
    List<TimeOfDay> selectedTimes = [];
    List<int> selectedDays = []; // 1=Mon, 7=Sun

    if (existingData != null) {
      if (existingData['times'] != null) {
        final List<dynamic> timesList = existingData['times'];
        selectedTimes = timesList.map((t) {
          final parts = t.toString().split(':');
          return TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }).toList();
      } else if (existingData['time'] != null) {
        final parts = existingData['time'].toString().split(':');
        selectedTimes.add(
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
        );
      }

      if (existingData['days'] != null) {
        selectedDays = List<int>.from(existingData['days']);
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existingData != null
                        ? 'Edit Medicine Reminder'
                        : 'Add Medicine Reminder',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Medicine Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Select Times (${selectedTimes.length} added)'),
                    trailing: const Icon(Icons.add_alarm),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setModalState(() {
                          if (!selectedTimes.contains(time)) {
                            selectedTimes.add(time);
                          }
                        });
                      }
                    },
                  ),
                  if (selectedTimes.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: selectedTimes
                          .map(
                            (t) => Chip(
                              label: Text(t.format(context)),
                              onDeleted: () =>
                                  setModalState(() => selectedTimes.remove(t)),
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: frequency,
                    decoration: const InputDecoration(labelText: 'Frequency'),
                    items: ['Daily', 'Weekly']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setModalState(() => frequency = v!),
                  ),
                  if (frequency == 'Weekly') ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Select Days:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [1, 2, 3, 4, 5, 6, 7].map((day) {
                        final dayName = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun',
                        ][day - 1];
                        final isSelected = selectedDays.contains(day);
                        return FilterChip(
                          label: Text(dayName),
                          selected: isSelected,
                          onSelected: (val) {
                            setModalState(() {
                              if (val)
                                selectedDays.add(day);
                              else
                                selectedDays.remove(day);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        if (nameCtrl.text.isEmpty || selectedTimes.isEmpty)
                          return;

                        if (frequency == 'Weekly' && selectedDays.isEmpty)
                          return;

                        final user = context.read<AuthProvider>().user;
                        if (user == null) return;

                        final box = Hive.box('medicines');
                        final newMap = {
                          'userId': user.id,
                          'name': nameCtrl.text.trim(),
                          'times': selectedTimes
                              .map(
                                (t) =>
                                    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
                              )
                              .toList(),
                          'frequency': frequency,
                          'days': frequency == 'Weekly' ? selectedDays : null,
                          'createdAt':
                              existingData?['createdAt'] ??
                              DateTime.now().toIso8601String(),
                          'lastTakenAt': existingData?['lastTakenAt'],
                          'lastTakenNote': existingData?['lastTakenNote'],
                        };

                        if (existingData != null) {
                          await box.put(existingData['key'], newMap);
                        } else {
                          await box.add(newMap);
                        }

                        for (var t in selectedTimes) {
                          await _scheduleAlarm(
                            nameCtrl.text.trim(),
                            t,
                            id:
                                (nameCtrl.text.trim() + t.toString()).hashCode %
                                100000,
                          );
                        }

                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text(
                        'Save Reminder',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showTakeMedicineOptions(Map<String, dynamic> data) {
    String reason = '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Take ${data['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Did you take this medicine or picked it up?\nAdd notes/status why:',
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (v) => reason = v,
              decoration: InputDecoration(
                hintText: 'e.g., Taken after meal, forgot morning dose',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final box = Hive.box('medicines');
              final map = Map<String, dynamic>.from(data);
              map.remove('key');
              map['lastTakenAt'] = DateTime.now().toIso8601String();
              map['lastTakenNote'] = reason;
              box.put(data['key'], map);

              // Log activity to Firestore for admin/caregiver
              final user = context.read<AuthProvider>().user;
              if (user != null) {
                await _activityLogRepository.logActivity(
                  userId: user.id,
                  userName: user.name,
                  role: 'senior',
                  action: 'MEDICINE_TAKEN',
                  details: 'Took medicine: ${data['name']}. Note: $reason',
                  targetName: data['name'],
                );
              }

              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text(
              'Save Status',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medicine Reminders',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ValueListenableBuilder(
              valueListenable: Hive.box('medicines').listenable(),
              builder: (context, box, _) {
                final userReminders = box.keys
                    .map((key) {
                      final val = box.get(key);
                      // Ensure it's a map we can work with
                      Map<String, dynamic> mapVal = {};
                      if (val is Map) {
                        mapVal = val.map((k, v) => MapEntry(k.toString(), v));
                      }
                      return {'key': key, ...mapVal};
                    })
                    .where((e) => e['userId'] == user.id)
                    .toList();

                if (userReminders.isEmpty) {
                  return const Center(
                    child: Text('No medicine reminders yet.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: userReminders.length,
                  itemBuilder: (context, index) {
                    final data = userReminders[index];
                    final timesList =
                        (data['times'] as List<dynamic>?)?.join(', ') ??
                        data['time'] ??
                        '';

                    String daysStr = '';
                    if (data['frequency'] == 'Weekly' && data['days'] != null) {
                      final d = List<int>.from(data['days']);
                      d.sort();
                      final mapD = d
                          .map(
                            (x) => [
                              'Mon',
                              'Tue',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat',
                              'Sun',
                            ][x - 1],
                          )
                          .join(', ');
                      daysStr = '\nDays: $mapD';
                    }

                    final takenNote = data['lastTakenNote'] != null
                        ? '\nStatus: ${data['lastTakenNote']}\nLast Update: ${data['lastTakenAt'].toString().split('T').first}'
                        : '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () => _showTakeMedicineOptions(data),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade50,
                              child: const Icon(
                                Icons.medical_services,
                                color: Colors.blue,
                              ),
                            ),
                            title: Text(
                              data['name'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Times: $timesList • ${data['frequency']}$daysStr$takenNote',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () =>
                                      _showAddEditMedicineModal(data),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final id =
                                        (data['name'].toString() +
                                                (data['time'] ?? ''))
                                            .hashCode %
                                        100000;
                                    await Alarm.stop(id);
                                    box.delete(data['key']);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditMedicineModal(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
