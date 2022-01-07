import 'package:flutter/material.dart';

class ParkListEntry extends StatelessWidget {
  final String parkName;
  final int numAttractionsTracked;
  final VoidCallback? onTap;
  final VoidCallback? onDeleteTapped;

  const ParkListEntry(
      {Key? key,
      this.parkName = "UNDEFINED PARK",
      this.numAttractionsTracked = 0,
      this.onTap,
      this.onDeleteTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(parkName),
      subtitle: (numAttractionsTracked > 0)
          ? Text(
              "$numAttractionsTracked Attraction${numAttractionsTracked == 1 ? '' : 's'} Tracked")
          : null,
      onTap: onTap,
      trailing: (numAttractionsTracked > 0)
          ? IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDeleteTapped,
            )
          : null,
    );
  }
}
