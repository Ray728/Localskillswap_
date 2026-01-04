import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'skill_model.dart';
import 'api_service.dart';
import 'localization.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _currentLang = 'tr';

  void _changeLanguage(String langCode) {
    setState(() {
      _currentLang = langCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skill Swap Online',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
              color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      home: HomeScreen(
        currentLang: _currentLang,
        onLanguageChanged: _changeLanguage,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String currentLang;
  final Function(String) onLanguageChanged;

  const HomeScreen(
      {super.key, required this.currentLang, required this.onLanguageChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<Skill> _allSkills = [];
  List<Skill> _filteredSkills = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  String t(String key) {
    return AppStrings.languages[widget.currentLang]![key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _refreshSkills();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSkills = _allSkills.where((skill) {
        return skill.title.toLowerCase().contains(query) ||
            skill.offer.toLowerCase().contains(query); // Ищем и по предложению тоже
      }).toList();
    });
  }

  Future<void> _refreshSkills() async {
    setState(() => _isLoading = true);
    final data = await _apiService.getSkills();
    setState(() {
      _allSkills = data;
      _filteredSkills = data;
      _isLoading = false;
    });
    if (_searchController.text.isNotEmpty) _onSearchChanged();
  }

  Future<void> _deleteSkill(int id) async {
    final originalList = List<Skill>.from(_allSkills);
    setState(() {
      _allSkills.removeWhere((s) => s.id == id);
      _filteredSkills.removeWhere((s) => s.id == id);
    });

    final success = await _apiService.deleteSkill(id);

    if (!success) {
      setState(() {
        _allSkills = originalList;
        _filteredSkills = originalList;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ошибка удаления")),
        );
      }
    }
  }

  void _navigateToAddSkill() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSkillScreen(currentLang: widget.currentLang),
      ),
    );
    if (result == true) _refreshSkills();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t('title')),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.black87),
            onSelected: widget.onLanguageChanged,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'tr', child: Text("🇹🇷 Türkçe")),
              const PopupMenuItem(value: 'az', child: Text("🇦🇿 Azərbaycan")),
              const PopupMenuItem(value: 'en', child: Text("🇺🇸 English")),
              const PopupMenuItem(value: 'ru', child: Text("🇷🇺 Русский")),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: t('label_skill'),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSkills.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off,
                      size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(
                    t('empty_text'),
                    style: const TextStyle(
                        fontSize: 18, color: Colors.grey),
                  ),
                ],
              ).animate().fade(),
            )
                : RefreshIndicator(
              onRefresh: _refreshSkills,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredSkills.length,
                itemBuilder: (context, index) {
                  final skill = _filteredSkills[index];
                  return _buildSkillCard(skill, index);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddSkill,
        label: Text(t('add_btn')),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSkillCard(Skill skill, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SkillDetailScreen(
              skill: skill,
              currentLang: widget.currentLang,
            ),
          ),
        );
      },
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Hero(
                tag: 'avatar_${skill.id}',
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor:
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Text(
                    skill.ownerName.isNotEmpty
                        ? skill.ownerName[0].toUpperCase()
                        : "?",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Что ищут
                    Text(
                      skill.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    // 🔥 Что предлагают взамен (отображаем зеленым)
                    if (skill.offer.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.swap_horiz, size: 16, color: Colors.green),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              skill.offer,
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.italic
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          skill.location,
                          style:
                          const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Silinsin mi?"),
                      content: const Text("Bu ilanı silmek istediğinize emin misiniz?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("İptal"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            if (skill.id != null) {
                              _deleteSkill(skill.id!);
                            }
                          },
                          child: const Text("Sil", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ).animate().fade(delay: (100 * index).ms).slideX(),
    );
  }
}

// --- ЭКРАН ДЕТАЛЕЙ ---
class SkillDetailScreen extends StatelessWidget {
  final Skill skill;
  final String currentLang;

  const SkillDetailScreen(
      {super.key, required this.skill, required this.currentLang});

  String t(String key) {
    return AppStrings.languages[currentLang]![key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(skill.title,
                  style: const TextStyle(color: Colors.black87)),
              background: Container(
                color: Colors.deepPurple.shade50,
                child: Center(
                  child: Hero(
                    tag: 'avatar_${skill.id}',
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.deepPurple.shade100,
                      child: Text(
                        skill.ownerName.isNotEmpty
                            ? skill.ownerName[0].toUpperCase()
                            : "?",
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailRow(Icons.person, t('author'), skill.ownerName),
                    const SizedBox(height: 15),
                    _detailRow(Icons.location_pin, t('where'), skill.location),
                    const SizedBox(height: 15),

                    // 🔥 Новое поле в деталях
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.shade200)
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.swap_horiz, color: Colors.green),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Bunun karşılığında:", style: TextStyle(fontSize: 12, color: Colors.green)),
                                Text(skill.offer, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),
                    Text(t('desc_header'),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(
                      skill.description,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(t('sent_msg'))),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(t('btn_contact')),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value,
                style:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ],
        ),
      ],
    );
  }
}

// --- ЭКРАН ДОБАВЛЕНИЯ ---
class AddSkillScreen extends StatefulWidget {
  final String currentLang;
  const AddSkillScreen({super.key, required this.currentLang});

  @override
  State<AddSkillScreen> createState() => _AddSkillScreenState();
}

class _AddSkillScreenState extends State<AddSkillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  final _titleController = TextEditingController();
  final _offerController = TextEditingController(); // 🔥 НОВЫЙ КОНТРОЛЛЕР
  final _descController = TextEditingController();
  final _locController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isSubmitting = false;

  String t(String key) {
    return AppStrings.languages[widget.currentLang]![key] ?? key;
  }

  Future<void> _saveSkill() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      final newSkill = Skill(
        title: _titleController.text,
        offer: _offerController.text, // 🔥 Сохраняем "взамен"
        description: _descController.text,
        location: _locController.text,
        ownerName: _nameController.text,
      );

      final success = await _apiService.createSkill(newSkill);

      setState(() => _isSubmitting = false);

      if (success && mounted) {
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ошибка соединения с сервером")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t('new_skill_title'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(_nameController, t('label_name'), Icons.person),
              _buildField(_titleController, t('label_skill'), Icons.star), // Что ищу

              // 🔥 НОВОЕ ПОЛЕ "Что даю взамен"
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: _offerController,
                  decoration: InputDecoration(
                    labelText: "Karşılığında ne vereceksiniz?", // "Что дадите взамен?"
                    hintText: "Örn: İngilizce öğretebilirim",
                    prefixIcon: const Icon(Icons.swap_horiz, color: Colors.green),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    filled: true,
                    fillColor: Colors.green.shade50, // Слегка зеленый, чтобы отличался
                  ),
                  validator: (v) => v!.isEmpty ? t('fill_error') : null,
                ),
              ),

              _buildField(
                  _descController, t('label_desc'), Icons.description,
                  lines: 3),
              _buildField(_locController, t('label_loc'), Icons.map),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _saveSkill,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(t('btn_publish'),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
      TextEditingController controller, String label, IconData icon,
      {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: lines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        validator: (v) => v!.isEmpty ? t('fill_error') : null,
      ),
    );
  }
}