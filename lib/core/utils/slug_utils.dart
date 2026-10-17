/// URL-safe slug validation for booth names.
abstract final class SlugUtils {
  static final RegExp _slugPattern = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');

  static String slugify(String input) {
    var slug = input.trim().toLowerCase();
    slug = slug
        .replaceAll(RegExp(r'[\s_]+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9\-]'), '')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return slug;
  }

  static bool isValid(String slug) => _slugPattern.hasMatch(slug);
}
