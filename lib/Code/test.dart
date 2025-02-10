import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ListWithCupertinoMenu(),
    );
  }
}

class ListWithCupertinoMenu extends StatefulWidget {
  const ListWithCupertinoMenu({super.key});

  @override
  State<ListWithCupertinoMenu> createState() => _ListWithCupertinoMenuState();
}

class _ListWithCupertinoMenuState extends State<ListWithCupertinoMenu> {
  List<String> items = List.generate(10, (index) => 'Item $index');

  void _deleteItem(int index) {
    setState(() {
      items.removeAt(index);
    });
    debugPrint('Deleted Item $index');
  }

  void _updateItem(int index) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController(text: items[index]);
        return CupertinoAlertDialog(
          title: const Text("Update Item"),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: CupertinoTextField(controller: controller),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            CupertinoDialogAction(
              onPressed: () {
                setState(() {
                  items[index] = controller.text;
                });
                Navigator.pop(context);
                debugPrint('Updated Item $index to ${controller.text}');
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // navigationBar: const CupertinoNavigationBar(middle: Text("List with Options")),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              ListTile(
                title: Text(items[index], style: const TextStyle(fontSize: 18)),
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.ellipsis_vertical),
                  onPressed: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (context) => CupertinoActionSheet(
                        actions: [
                          CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.pop(context);
                              _updateItem(index);
                            },
                            child: const Text("Update"),
                          ),
                          CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteItem(index);
                            },
                            isDestructiveAction: true,
                            child: const Text("Delete"),
                          ),
                        ],
                        cancelButton: CupertinoActionSheetAction(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
            ],
          );
        },
      ),
    );
  }
}
