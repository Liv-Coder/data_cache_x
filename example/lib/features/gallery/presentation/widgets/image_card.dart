import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:intl/intl.dart';

import '../../data/models/gallery_image.dart';

class ImageCard extends StatelessWidget {
  final GalleryImage image;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onDelete;
  final Function(String)? onTagTap;
  final Function(String)? onAddTag;
  final Function(String)? onRemoveTag;

  const ImageCard({
    super.key,
    required this.image,
    required this.onFavoriteToggle,
    required this.onDelete,
    this.onTagTap,
    this.onAddTag,
    this.onRemoveTag,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 260),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.2,
                  child: Image.network(
                    image.url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(153),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      icon: Icon(
                        image.isFavorite
                            ? Ionicons.star
                            : Ionicons.star_outline,
                        color: image.isFavorite ? Colors.amber : Colors.white,
                        size: 20,
                      ),
                      onPressed: onFavoriteToggle,
                      tooltip: 'Toggle Favorite',
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: const EdgeInsets.all(4),
                      iconSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    Text(
                      image.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatDate(image.uploadDate),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withAlpha(153),
                                    ),
                          ),
                        ),
                        Text(
                          _formatBytes(image.size),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withAlpha(153),
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${image.width}x${image.height}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Ionicons.pricetag_outline,
                                size: 16,
                              ),
                              onPressed: () => _showTagDialog(context),
                              tooltip: 'Manage Tags',
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: const EdgeInsets.all(4),
                              iconSize: 16,
                            ),
                            IconButton(
                              icon: const Icon(
                                Ionicons.trash_outline,
                                size: 16,
                              ),
                              onPressed: onDelete,
                              tooltip: 'Delete',
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: const EdgeInsets.all(4),
                              iconSize: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (image.tags.isNotEmpty) const SizedBox(height: 4),
                    if (image.tags.isNotEmpty)
                      SizedBox(
                        height: 24,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: image.tags.map((tag) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: InkWell(
                                onTap: onTagTap != null
                                    ? () => onTagTap!(tag)
                                    : null,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withAlpha(30),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '#$tag',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      if (onRemoveTag != null)
                                        InkWell(
                                          onTap: () => onRemoveTag!(tag),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 2),
                                            child: Icon(
                                              Ionicons.close_outline,
                                              size: 12,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  void _showTagDialog(BuildContext context) {
    final TextEditingController tagController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Tags'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image.tags.isNotEmpty) ...[
              const Text('Current Tags:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: image.tags.map((tag) {
                  return Chip(
                    label: Text('#$tag'),
                    deleteIcon: const Icon(Ionicons.close_outline, size: 16),
                    onDeleted: onRemoveTag != null
                        ? () {
                            onRemoveTag!(tag);
                            Navigator.of(context).pop();
                          }
                        : null,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            const Text('Add New Tag:'),
            const SizedBox(height: 8),
            TextField(
              controller: tagController,
              decoration: const InputDecoration(
                hintText: 'Enter tag name',
                prefixIcon: Icon(Ionicons.pricetag_outline),
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (value) {
                if (value.isNotEmpty && onAddTag != null) {
                  onAddTag!(value.trim().toLowerCase());
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final tag = tagController.text.trim().toLowerCase();
              if (tag.isNotEmpty && onAddTag != null) {
                onAddTag!(tag);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add Tag'),
          ),
        ],
      ),
    );
  }
}
