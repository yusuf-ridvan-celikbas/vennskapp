import 'package:flutter/material.dart';

/// Book cover image with a warm placeholder showing the title when there is
/// no cover (or it fails to load).
class BookCover extends StatelessWidget {
  const BookCover({super.key, required this.title, this.url, this.width = 80});

  final String title;
  final String? url;
  final double width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = Container(
      color: scheme.secondaryContainer,
      padding: const EdgeInsets.all(6),
      alignment: Alignment.center,
      child: Text(
        title,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: scheme.onSecondaryContainer),
      ),
    );
    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: url == null
              ? placeholder
              : Image.network(
                  url!,
                  fit: BoxFit.cover,
                  semanticLabel: title,
                  // Cover hosts don't all send CORS headers; fall back to <img>.
                  webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                  errorBuilder: (_, _, _) => placeholder,
                ),
        ),
      ),
    );
  }
}
