# Tag-Based Cache Management

Tag-based cache management is a powerful feature in DataCacheX that allows you to organize and manage your cached data more effectively. By tagging cache items, you can perform operations on groups of related items, such as retrieving all items with a specific tag or invalidating multiple items at once.

## Overview

Tags are string labels that you can attach to cache items. Each item can have multiple tags, and you can use these tags to:

- Organize related data
- Retrieve items by tag
- Delete items by tag
- Filter and search through cached data
- Implement category-based caching

## Basic Usage

### Storing Items with Tags

```dart
// Store an item with tags
await dataCache.put('user_profile', userProfile, 
    tags: {'user', 'profile', 'settings'});

// Store multiple items with the same tags
await dataCache.putAll({
  'product_1': product1,
  'product_2': product2,
  'product_3': product3,
}, tags: {'products', 'featured'});
```

### Retrieving Items by Tag

```dart
// Get all keys with a specific tag
final userKeys = await dataCache.getKeysByTag('user');

// Get all keys with multiple tags (AND logic)
final activeUserKeys = await dataCache.getKeysByTags(['user', 'active']);

// Get all items with a specific tag
final allUsers = await dataCache.getByTag<UserData>('user');

// Get all items with multiple tags (AND logic)
final activeUsers = await dataCache.getByTags<UserData>(['user', 'active']);
```

### Deleting Items by Tag

```dart
// Delete all items with a specific tag
await dataCache.deleteByTag('temporary');

// Delete all items with multiple tags (AND logic)
await dataCache.deleteByTags(['products', 'discontinued']);
```

## Advanced Usage

### Tag-Based Invalidation

Tags are particularly useful for invalidating related cache items when data changes:

```dart
// When user data changes, invalidate all user-related cache items
await dataCache.deleteByTag('user');

// When a specific category of products changes
await dataCache.deleteByTag('electronics');
```

### Combining Tags with Policies

You can combine tags with cache policies for even more control:

```dart
// Store items with tags and a specific policy
await dataCache.put('featured_products', products, 
    tags: {'products', 'featured'},
    policy: CachePolicy(
      expiry: Duration(hours: 1),
      priority: CachePriority.high,
    ));
```

### Pagination with Tags

You can implement pagination when retrieving items by tag:

```dart
// Get the first page of products (10 items)
final page1Keys = await dataCache.getKeysByTag('products', 
    limit: 10, offset: 0);

// Get the second page of products (next 10 items)
final page2Keys = await dataCache.getKeysByTag('products', 
    limit: 10, offset: 10);
```

## Example: Category-Based Caching

Here's an example of how to implement category-based caching using tags:

```dart
// Store news articles with category tags
await dataCache.put('article_1', article1, 
    tags: {'news', 'technology'});
await dataCache.put('article_2', article2, 
    tags: {'news', 'business'});
await dataCache.put('article_3', article3, 
    tags: {'news', 'technology', 'featured'});

// Get all technology articles
final techArticles = await dataCache.getByTag<Article>('technology');

// Get featured technology articles
final featuredTechArticles = await dataCache.getByTags<Article>(
    ['technology', 'featured']);

// When technology news is updated, invalidate only that category
await dataCache.deleteByTag('technology');
```

## Example: User Data Management

Here's an example of managing user-related data with tags:

```dart
// Store user data with appropriate tags
await dataCache.put('user_${user.id}', user, 
    tags: {'user', user.role, user.isActive ? 'active' : 'inactive'});

// Store user preferences
await dataCache.put('prefs_${user.id}', preferences, 
    tags: {'user', 'preferences', user.id.toString()});

// Store user activity
await dataCache.put('activity_${user.id}', activity, 
    tags: {'user', 'activity', user.id.toString()});

// When user logs out, clear all their data
await dataCache.deleteByTag(user.id.toString());

// Get all active users
final activeUsers = await dataCache.getByTag<User>('active');

// Get all admin users
final admins = await dataCache.getByTag<User>('admin');
```

## Implementation in the Example App

The CacheHub example app demonstrates tag-based cache management in several features:

### Image Gallery

The Image Gallery feature uses tags to categorize images and allow filtering:

- Images are tagged with categories like 'nature', 'landscape', 'portrait', etc.
- Size-based tags ('small', 'large') are automatically applied based on image size
- Users can filter the gallery by tag to find specific types of images
- Tags are visually displayed on image cards for easy identification

### News Feed

The News Feed feature uses tags for cross-category content discovery:

- News articles are tagged with categories like 'technology', 'business', 'politics', etc.
- Additional tags are applied based on content topics
- Users can filter articles by tag to find related content across different categories
- Tags are displayed on article cards and can be clicked to filter content

### Explorer

The Explorer feature allows browsing and filtering cached data by tags:

- All cached items display their associated tags
- Users can filter the explorer view by tag to find specific types of cached data
- Tag statistics show the most commonly used tags in the cache

## Best Practices

1. **Use Consistent Naming**: Establish a consistent naming convention for tags
2. **Limit Tag Count**: Don't overuse tags - typically 3-5 tags per item is sufficient
3. **Use Hierarchical Tags**: Consider using hierarchical tags for complex categorization (e.g., 'product:electronics', 'product:clothing')
4. **Combine with Policies**: Use tags in combination with cache policies for more granular control
5. **Document Tag Usage**: Keep track of which tags are used for what purpose in your application

## API Reference

| Method | Description |
|--------|-------------|
| `Future<List<String>> getKeysByTag(String tag, {int? limit, int? offset})` | Gets keys with a specific tag |
| `Future<List<String>> getKeysByTags(List<String> tags, {int? limit, int? offset})` | Gets keys with all specified tags |
| `Future<void> deleteByTag(String tag)` | Deletes all items with a specific tag |
| `Future<void> deleteByTags(List<String> tags)` | Deletes all items with all specified tags |
| `Future<Map<String, T>> getByTag<T>(String tag, {CachePolicy? policy})` | Gets all items with a specific tag |
| `Future<Map<String, T>> getByTags<T>(List<String> tags, {CachePolicy? policy})` | Gets all items with all specified tags |
