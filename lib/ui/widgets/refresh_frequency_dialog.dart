import 'package:flutter/material.dart';

class RefreshFrequencyDialog extends StatefulWidget {
  final int refreshFrequency;
  const RefreshFrequencyDialog({Key? key, this.refreshFrequency = 5})
      : super(key: key);

  @override
  _RefreshFrequencyDialogState createState() => _RefreshFrequencyDialogState();
}

class _RefreshFrequencyDialogState extends State<RefreshFrequencyDialog> {
  double _currentRefreshFrequency = 0;

  @override
  void initState() {
    _currentRefreshFrequency = widget.refreshFrequency.toDouble();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Configure Refresh Frequency"),
      content: SizedBox(
        height: 40.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_currentRefreshFrequency.round().toString() + " mins"),
            Expanded(
              child: Slider(
                value: _currentRefreshFrequency,
                min: 5,
                max: 60,
                divisions: 11,
                onChanged: (double value) {
                  setState(() {
                    _currentRefreshFrequency = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        MaterialButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        MaterialButton(
          onPressed: () =>
              Navigator.of(context).pop(_currentRefreshFrequency.toInt()),
          child: const Text("Save"),
        )
      ],
    );
  }
}
