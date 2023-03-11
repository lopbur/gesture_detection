import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gesture_detection_rebuild/provider/event.provider.dart';

class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(eventProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: config.length,
              itemBuilder: (BuildContext context, int index) =>
                  EventSettingMenu(index: index),
            ),
          ),
          ElevatedButton(
            onPressed: () => ref.read(eventProvider.notifier).addEmpty(),
            child: const Text('Add Config'),
          ),
        ],
      ),
    );
  }
}

class EventSettingMenu extends ConsumerStatefulWidget {
  const EventSettingMenu({required this.index, super.key});

  final int index;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EventSettingMenuState();
}

class _EventSettingMenuState extends ConsumerState<EventSettingMenu> {
  bool isExpanded = false;

  Widget keyDropdown() {
    return Text(EventType.alt.toString());
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(eventProvider)[widget.index];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(config.alias),
                ),
                Text('...${config.keyMap.length} event assigned'),
                IconButton(
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  icon: const Icon(Icons.arrow_downward),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 150),
              curve: Curves.fastOutSlowIn,
              child: Container(
                child: isExpanded
                    ? Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                  onPressed: () => {
                                        ref
                                            .read(eventProvider.notifier)
                                            .addKeyMapEmpty(config.alias)
                                      },
                                  icon: const Icon(Icons.add))
                            ],
                          ),
                          Column(
                            children: [
                              ...List<Widget>.generate(
                                config.keyMap.length,
                                (index) => Text('$index'),
                              ),
                            ],
                          )
                        ],
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
