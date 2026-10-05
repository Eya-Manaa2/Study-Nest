import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../app_provider.dart';
import '../models.dart';
import '../widgets/sn_card.dart';
import '../services/storage_service.dart';
import '../services/firestore_service.dart';

class SubjectDetailScreen extends ConsumerStatefulWidget {
  final String subjectId;
  final VoidCallback onBack;

  const SubjectDetailScreen({
    super.key,
    required this.subjectId,
    required this.onBack,
  });

  @override
  ConsumerState<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends ConsumerState<SubjectDetailScreen> {
  DocType? _activeType; // null = Tous

  @override
  Widget build(BuildContext context) {
    final state    = ref.watch(appProvider);
    final t        = state.theme;
    final notifier = ref.read(appProvider.notifier);
    final subject  = state.subjects.firstWhere(
      (s) => s.id == widget.subjectId,
      orElse: () => state.subjects.first,
    );

    final visibleDocs = _activeType == null
        ? subject.docs
        : subject.docs.where((d) => d.type == _activeType).toList();

    final availableTypes = DocType.values
        .where((type) => subject.docs.any((d) => d.type == type))
        .toList();

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Hero header ───────────────────────────────────────────────────
            Container(
              color: t.surface,
              child: Stack(
                children: [
                  // Gradient tint
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [subject.color.withValues(alpha: 0.15), Colors.transparent],
                          begin:  Alignment.topLeft,
                          end:    Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back / options
                        Row(
                          children: [
                            GestureDetector(
                              onTap: widget.onBack,
                              child: Container(
                                width:  40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color:        t.surface2,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size:  18,
                                  color: t.textColor,
                                ),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => _showSubjectOptions(context, ref, subject),
                              child: Container(
                                width:  40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color:        t.surface2,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Icon(
                                  Icons.more_horiz_rounded,
                                  color: t.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Subject info
                        Row(
                          children: [
                            Container(
                              width:  52,
                              height: 52,
                              decoration: BoxDecoration(
                                color:        subject.color.withValues(alpha: 0.13),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                subject.emoji,
                                style: const TextStyle(fontSize: 26),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subject.name,
                                  style: TextStyle(
                                    fontSize:   22,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Fraunces',
                                    color:      t.textColor,
                                  ),
                                ),
                                Text(
                                  'Semestre 1',
                                  style: TextStyle(fontSize: 12, color: t.muted),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Stats row
                        Row(
                          children: [
                            _StatCol(
                              value: '${subject.docCount}',
                              label: 'Docs',
                            ),
                            const SizedBox(width: 28),
                            _StatCol(
                              value: '${subject.favCount}',
                              label: 'Favoris',
                            ),
                            const SizedBox(width: 28),
                            _StatCol(
                              value: '${subject.docs.map((d) => d.type).toSet().length}',
                              label: 'Types',
                            ),
                            const SizedBox(width: 28),
                            _StatCol(
                              value: subject.grades.isEmpty ? '-' : subject.average.toStringAsFixed(2),
                              label: 'Moyenne',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: t.line),

            // ── Doc type tabs ─────────────────────────────────────────────────
            Container(
              color: t.surface,
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:         const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SnChip(
                      label:   'Tous',
                      active:  _activeType == null,
                      onTap:   () => setState(() => _activeType = null),
                    ),
                  ),
                  ...availableTypes.map((type) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SnChip(
                      label:  type.label,
                      active: _activeType == type,
                      onTap:  () => setState(() => _activeType = type),
                    ),
                  )),
                ],
              ),
            ),

            Divider(height: 1, color: t.line),

            // ── Documents list ────────────────────────────────────────────────
            Expanded(
              child: visibleDocs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('📄', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text(
                            'Aucun document',
                            style: TextStyle(
                              fontSize:   16,
                              fontWeight: FontWeight.w700,
                              color:      t.textColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Ajoute ton premier document ici',
                            style: TextStyle(fontSize: 13, color: t.muted),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding:    const EdgeInsets.fromLTRB(20, 16, 20, 100),
                      itemCount:  visibleDocs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) {
                        final doc = visibleDocs[i];
                        return GestureDetector(
                          onTap: () => _openDocument(doc),
                          child: SnCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                DocIconTile(icon: doc.fileFormat.icon),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doc.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize:   12.5,
                                          fontWeight: FontWeight.w700,
                                          color:      t.textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          FileFormatBadge(
                                            label: doc.fileFormat.label,
                                            icon: doc.fileFormat.icon,
                                            color: doc.fileFormat.color,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${doc.type.label} · ${doc.date.day}/${doc.date.month}/${doc.date.year}',
                                            style: TextStyle(fontSize: 10, color: t.muted),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                FavoriteButton(
                                  isFavorite:  doc.favorite,
                                  accentColor: t.accent,
                                  onTap: () => notifier.toggleFavorite(doc.id),
                                ),
                                GestureDetector(
                                  onTap: () => _showDeleteDialog(doc, ref),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Icon(Icons.delete_outline, size: 16, color: Colors.red.shade400),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      // FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDocumentDialog(context, ref, widget.subjectId),
        backgroundColor: t.accent,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  void _showDeleteDialog(StudyDocument doc, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le document'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${doc.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                final firestoreService = ref.read(firestoreServiceProvider);
                final storageService = ref.read(storageServiceProvider);
                
                // Supprimer le fichier de Firebase Storage
                if (doc.fileName != null) {
                  await storageService.deleteFile(
                    subjectId: doc.subjectId,
                    fileName: doc.fileName!,
                  );
                }
                
                // Supprimer le document de Firestore
                await firestoreService.deleteDocument(doc.subjectId, doc.id);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Document supprimé avec succès'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la suppression: $e'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Future<void> _openDocument(StudyDocument doc) async {
    if (doc.filePath == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Document de démo: ${doc.fileName ?? doc.fileFormat.label}'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      String localPath = doc.filePath!;
      
      // Si filePath est une URL Firebase Storage, télécharger le fichier
      if (doc.filePath!.startsWith('http')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Téléchargement du fichier...'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        final tempDir = await getTemporaryDirectory();
        final fileName = doc.fileName ?? 'document${doc.fileFormat.extension}';
        localPath = '${tempDir.path}/$fileName';
        
        // Télécharger le fichier
        final response = await http.get(Uri.parse(doc.filePath!));
        final file = File(localPath);
        await file.writeAsBytes(response.bodyBytes);
      }
      
      // Ouvrir le fichier local
      final result = await OpenFile.open(localPath);
      if (!mounted) return;
      
      if (result.type == ResultType.noAppToOpen) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucune application pour ouvrir ce fichier'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (result.type == ResultType.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${result.message}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur d\'ouverture: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildFilePreview(PlatformFile file, {VoidCallback? onRemove}) {
    final extension = file.extension?.toLowerCase() ?? '';
    final fileFormat = _getFileFormatFromExtension(extension);
    
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: fileFormat.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: fileFormat.color.withValues(alpha: 0.3), width: 1),
          ),
          child: Icon(fileFormat.icon, size: 30, color: fileFormat.color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                file.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    constraints: const BoxConstraints(maxWidth: 120),
                    decoration: BoxDecoration(
                      color: fileFormat.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(fileFormat.icon, size: 12, color: fileFormat.color),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            fileFormat.label,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: fileFormat.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatFileSize(file.size),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: onRemove,
        ),
      ],
    );
  }

  FileFormat _getFileFormatFromExtension(String extension) {
    switch (extension) {
      case 'pdf': return FileFormat.pdf;
      case 'doc':
      case 'docx': return FileFormat.docx;
      case 'ppt':
      case 'pptx': return FileFormat.pptx;
      case 'xls':
      case 'xlsx': return FileFormat.xlsx;
      case 'jpg':
      case 'jpeg': return FileFormat.jpg;
      case 'png': return FileFormat.png;
      case 'mp4': return FileFormat.mp4;
      case 'mp3': return FileFormat.mp3;
      default: return FileFormat.other;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _showAddDocumentDialog(BuildContext context, WidgetRef ref, String subjectId) {
    final titleController = TextEditingController();
    DocType selectedType = DocType.cours;
    bool isUploading = false;
    double uploadProgress = 0.0;
    PlatformFile? selectedFile;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Ajouter un document'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre du document',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<DocType>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: DocType.values.map((type) {
                    return DropdownMenuItem<DocType>(
                      value: type,
                      child: Text(type.label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: isUploading ? null : () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt', 'jpg', 'png', 'xlsx', 'mp4', 'mp3'],
                    );
                    if (result != null) {
                      setDialogState(() => selectedFile = result.files.first);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      color: selectedFile != null ? Colors.blue.shade50 : Colors.transparent,
                    ),
                    child: selectedFile != null
                        ? _buildFilePreview(selectedFile!, onRemove: () => setDialogState(() => selectedFile = null))
                        : Column(
                            children: [
                              Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              Text(
                                'Sélectionner un fichier',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'PDF, Word, PowerPoint, Excel, Images, Vidéo, Audio',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                              ),
                            ],
                          ),
                  ),
                ),
                if (isUploading) ...[
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: uploadProgress),
                  const SizedBox(height: 8),
                  Text('Upload: ${(uploadProgress * 100).toStringAsFixed(0)}%'),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isUploading ? null : () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: isUploading ? null : () async {
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez entrer un titre')),
                  );
                  return;
                }
                if (selectedFile == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez sélectionner un fichier')),
                  );
                  return;
                }

                setDialogState(() => isUploading = true);

                try {
                  final storageService = ref.read(storageServiceProvider);
                  final docId = 'd${DateTime.now().millisecondsSinceEpoch}';
                  
                  final file = selectedFile;
                  if (file == null || file.path == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Erreur: impossible d\'accéder au fichier')),
                    );
                    setDialogState(() => isUploading = false);
                    return;
                  }
                  
                  final fileUrl = await storageService.uploadFile(
                    fileName: file.name,
                    subjectId: subjectId,
                    fileToUpload: File(file.path!),
                    onProgress: (progress) {
                      setDialogState(() => uploadProgress = progress);
                    },
                  );

                  final newDoc = StudyDocument(
                    id: docId,
                    subjectId: subjectId,
                    title: titleController.text,
                    type: selectedType,
                    date: DateTime.now(),
                    filePath: fileUrl,
                    fileName: file.name,
                    fileFormat: _getFileFormatFromExtension(file.extension ?? ''),
                  );

                  final firestoreService = ref.read(firestoreServiceProvider);
                  await firestoreService.saveDocument(newDoc);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Document ajouté avec succès')),
                    );
                  }
                } catch (e) {
                  setDialogState(() => isUploading = false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: $e')),
                    );
                  }
                }
              },
              child: isUploading ? const Text('Upload...') : const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubjectOptions(BuildContext context, WidgetRef ref, Subject subject) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Ajouter une note'),
              onTap: () {
                Navigator.pop(context);
                _showAddGradeDialog(context, ref, subject);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifier la matière'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Utilisez l\'onglet Matières pour modifier')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGradeDialog(BuildContext context, WidgetRef ref, Subject subject) {
    final valueController = TextEditingController();
    final coefficientController = TextEditingController(text: '1');
    final labelController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une note'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: valueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Note (/20)',
                  hintText: 'Ex: 15.5',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: coefficientController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Coefficient',
                  hintText: 'Ex: 2',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: labelController,
                decoration: const InputDecoration(
                  labelText: 'Libellé',
                  hintText: 'Ex: DS1',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(valueController.text);
              final coefficient = double.tryParse(coefficientController.text) ?? 1;
              if (value == null || value < 0 || value > 20) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note invalide (doit être entre 0 et 20)')),
                );
                return;
              }
              ref.read(appProvider.notifier).addGrade(
                subject.id,
                value,
                coefficient,
                labelController.text.trim(),
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note ajoutée avec succès')),
              );
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final String value;
  final String label;
  const _StatCol({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45);
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize:   20,
            fontWeight: FontWeight.w900,
            fontFamily: 'Fraunces',
          ),
        ),
        Text(label, style: TextStyle(fontSize: 11, color: muted)),
      ],
    );
  }
}
