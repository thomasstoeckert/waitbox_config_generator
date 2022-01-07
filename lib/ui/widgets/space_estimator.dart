import 'package:flutter/material.dart';

class SpaceEstimator extends StatelessWidget {
  final int numLines;
  final int maxLines;
  const SpaceEstimator({Key? key, this.numLines = 0, this.maxLines = 37})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        width: 90,
        height: 90,
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              child: CircularProgressIndicator(
                  strokeWidth: 8.0, value: numLines / maxLines),
              width: 64.0,
              height: 64.0,
            ),
            Align(
              child: Text(
                "$numLines/$maxLines\nlines",
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              alignment: Alignment.center,
            )
          ],
        ),
      ),
    );
  }
}
