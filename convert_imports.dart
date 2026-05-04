import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  final libDir = Directory('lib');
  final files = libDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    var content = file.readAsStringSync();
    var changed = false;

    // Matches `import '...';` or `import "..."`
    final regex = RegExp(r'''import\s+['"]([^'"]+)['"](.*?;)''');
    
    content = content.replaceAllMapped(regex, (match) {
      final importPath = match.group(1)!;
      final rest = match.group(2)!;

      // Skip already package imports or dart: imports
      if (importPath.startsWith('package:') || importPath.startsWith('dart:')) {
        return match.group(0)!;
      }

      // It's a relative import
      // file.path is like "lib\presentation\pages\..."
      // We need to resolve importPath relative to file's directory
      final fileDir = p.dirname(file.path);
      final resolvedPath = p.normalize(p.join(fileDir, importPath));
      
      // resolvedPath is something like "lib\core\app_constants.dart"
      // We need to convert it to "package:senior_care/core/app_constants.dart"
      // First, ensure it uses forward slashes
      var normalized = resolvedPath.replaceAll(r'\', '/');
      
      if (normalized.startsWith('lib/')) {
        final packagePath = normalized.replaceFirst('lib/', 'package:senior_care/');
        changed = true;
        return "import '$packagePath'$rest";
      }
      
      return match.group(0)!;
    });

    if (changed) {
      file.writeAsStringSync(content);
      print('Updated ${file.path}');
    }
  }
}
