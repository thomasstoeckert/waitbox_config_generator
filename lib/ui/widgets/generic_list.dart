import 'package:flutter/material.dart';

class GenericList extends StatelessWidget {
  final double minWidth;
  final String title;
  final ScrollController? controller;
  final int itemCount;
  final Widget? placeholder;
  final Widget Function(BuildContext context, int index)? itemBuilder;

  const GenericList(
      {Key? key,
      this.minWidth = 500,
      this.title = "Generic List",
      this.controller,
      this.itemCount = 10,
      this.itemBuilder,
      this.placeholder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500.0, minWidth: 250.0),
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: Theme.of(context).textTheme.headline4,
                textAlign: TextAlign.start,
                maxLines: 1,
              ),
            ),
            const Divider(height: 2.0, thickness: 2.0),
            Expanded(
              child: placeholder ??
                  ListView.builder(
                      controller: controller,
                      shrinkWrap: true,
                      itemBuilder: itemBuilder ??
                          ((c, i) => ListTile(
                                title: Text("Generic Item $i"),
                              )),
                      itemCount: itemCount),
            )
          ],
        ),
      ),
    );
  }
}
