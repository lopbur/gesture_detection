import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gesture_detection_rebuild/provider/event.provider.dart';

class EventSettingPage extends ConsumerWidget {
  const EventSettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configLists = ref.watch(eventProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          children: [
            configLists.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      itemCount: configLists.length,
                      itemBuilder: (BuildContext context, int index) =>
                          EventSettingMenu(index: index),
                    ),
                  )
                : const Expanded(
                    child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'There are no settings.',
                      style: TextStyle(fontSize: 16.0, color: Colors.grey),
                    ),
                  )),
            ElevatedButton(
              onPressed: () => ref.read(eventProvider.notifier).addEmpty(),
              child: const Text('Add Config'),
            ),
          ],
        ),
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

  Widget getConfigList(int index, EventSetting e) {
    return Text('$index, $e');
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
                Column(
                  children: [
                    Text(config.gesture == 'none'
                        ? 'Gesture not assigned'
                        : 'Assigned to ${config.gesture}'),
                    Text('...${config.keyMap.length} event assigned'),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    ref.read(eventProvider.notifier).remove(config);
                  },
                  icon: const Icon(Icons.delete),
                ),
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
              child: isExpanded
                  ? SizedBox(
                      height: 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Scrollbar(
                              child: ListView.builder(
                                shrinkWrap: true,
                                // physics: const NeverScrollableScrollPhysics(),
                                itemCount: config.keyMap.length,
                                itemBuilder: (context, index) => Row(
                                  children: [
                                    Text('#${index + 1}  '),
                                    Expanded(
                                      child: DropdownButton<EventType>(
                                        isExpanded: true,
                                        value: config.keyMap[index],
                                        onChanged: (EventType? newValue) {
                                          ref
                                              .read(eventProvider.notifier)
                                              .updateKeyMapWhere(config.alias,
                                                  index, newValue!);
                                        },
                                        items: EventType.values.map(
                                          (EventType eventType) {
                                            return DropdownMenuItem<EventType>(
                                              value: eventType,
                                              child: Text(eventType.alias),
                                            );
                                          },
                                        ).toList(),
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () => {
                                              ref
                                                  .read(eventProvider.notifier)
                                                  .removeKeyMapWhere(
                                                      config.alias, index)
                                            },
                                        icon: const Icon(Icons.delete))
                                  ],
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => {
                              ref
                                  .read(eventProvider.notifier)
                                  .addKeyMapEmpty(config.alias)
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }
}
