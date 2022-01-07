import 'package:flutter/material.dart';

class AttractionListEntry extends StatelessWidget {
  final String attractionName;
  final String attractionType;
  final bool isTracked;
  final VoidCallback? onTap;

  const AttractionListEntry(
      {Key? key,
      this.attractionName = "UNDEFINED",
      this.attractionType = "UNDEFINED",
      this.isTracked = false,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(attractionName),
      subtitle: Text(attractionType),
      onTap: onTap,
      trailing: isTracked
          ? IconButton(
              icon: const Icon(Icons.check),
              onPressed: onTap,
            )
          : null,
    );
  }
}
