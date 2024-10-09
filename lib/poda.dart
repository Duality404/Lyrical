import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';


class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    required this.gradient,
    this.style,
  });

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}

void main() {
  runApp(LyricsGeneratorApp());
}

class LyricsGeneratorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lyrics Generator',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        fontFamily: 'NeueMontreal',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF262629), width: 2),
          ),
          filled: true,
          fillColor: Colors.black,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 26), // Increased by 10
          bodyMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 24), // Increased by 10
          bodySmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 22), // Increased by 10
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 32), // Increased by 10
          titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 28), // Increased by 10
          titleSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 26), // Increased by 10
        ),
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final _basicFormKey = GlobalKey<FormState>();
  final _advancedFormKey = GlobalKey<FormState>();
  late TextEditingController _languageController;
  late TextEditingController _genreController;
  late TextEditingController _descriptionController;
  late TextEditingController _keywordsController;
  late TextEditingController _moodController;
  late TextEditingController _negativePromptController;
  late List<TextEditingController> _lyricsControllers;
  int _selectedVersion = 0;
  late TabController _tabController;
  bool _isLoading = false;
  bool _showAdvancedOptions = false;
  bool isChanged = false;
  List<Color> primaryColors = const [
    Color(0xFF03001e),
     Color(0xFF7303c0),
     Color(0xFFec38bc),
     Color(0xFFfdeff9),
  ];
  List<Color> secondaryColors = const [
    Color(0xFFfdeff9),
    Color(0xFFec38bc),
    Color(0xFF7303c0),
    Color(0xFF03001e),
  ];

  final Gradient _textGradient = LinearGradient(
    colors: [
      Color(0xFF8A2387),
      Color(0xFFE94057),
      Color(0xFFF27121),
    ],
  );

  final Gradient _headingGradient = LinearGradient(
    colors: [
      Color(0xFF1a2a6c),
      Color(0xFFb21f1f),
      Color(0xFFF27121),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  final Gradient _lyricsGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 131, 131, 131),
      Color.fromARGB(255, 6, 34, 126),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  final Gradient _versionGradient = LinearGradient(
    colors: [
      Color(0xFF8A2387),
      Color(0xFFE94057),
      Color(0xFFF27121),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  bool _isGenerateLoading = false;
  bool _isRefineLoading = false;

  @override
  void initState() {
    super.initState();
    _languageController = TextEditingController();
    _genreController = TextEditingController();
    _descriptionController = TextEditingController();
    _keywordsController = TextEditingController();
    _moodController = TextEditingController();
    _negativePromptController = TextEditingController();
    lyricsControllers = List.generate(3, () => TextEditingController());
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _languageController.dispose();
    _genreController.dispose();
    _descriptionController.dispose();
    _keywordsController.dispose();
    _moodController.dispose();
    _negativePromptController.dispose();
    for (var controller in _lyricsControllers) {
      controller.dispose();
    }
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background animation
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(50), // Adjust this value to change the padding
              child: Opacity(
                opacity: 0.5, // Adjust this value to change the opacity of the background animation
                child: Lottie.asset(
                  'assets/robot.json',
                  fit: BoxFit.contain, // Changed from BoxFit.cover to BoxFit.contain
                  repeat: true,
                ),
              ),
            ),
          ),
          Container(
            color: Colors.transparent,
            child: Column(
              children: [
                SizedBox(height: 20),
                Center(
                  child: Text(
                    'Lyrical',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 40,fontFamily: 'NeueMontreal',color: Color(0xFFC33608)),
                    
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildInputForm(),
                      ),
                      VerticalDivider(thickness: 1, width: 1, color: Color(0xFF262629)),
                      Expanded(
                        flex: 1,
                        child: _buildOutputSection(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledText(String text, TextStyle? style) {
    return Text(
      text,
      style: style?.copyWith(color: Color(0xFFBA8B02)),
    );
  }

  Widget _buildInputForm() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFFFF),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              'Generate Lyrics',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 30,fontFamily: 'NeueMontreal',color: Color(0xFFFFFFFF)),
              
            ),
          ),
          SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfoForm(),
                  SizedBox(height: 16),
                  _buildAdvancedOptionsDropdown(),
                  if (_showAdvancedOptions) _buildAdvancedOptionsForm(),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          Center(
            child: AnimatedGradientButton(
              onPressed: _generateLyrics,
              child: Text('Generate Lyrics',style: TextStyle(fontFamily: 'NeueMontreal',fontWeight: FontWeight.w700, fontSize: 18),),
              isLoading: _isGenerateLoading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoForm() {
    return 
     Form(
      key: _basicFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputSection('Language', 'Specify the language for your lyrics', _languageController, 'Enter the language (e.g., English)', isRequired: true),
          SizedBox(height: 16),
          _buildInputSection('Genre', 'Choose the musical style', _genreController, 'Enter the genre (e.g., Pop, Rock)', isRequired: true),
          SizedBox(height: 16),
          _buildInputSection('Song Description', 'Briefly describe the theme or story of your song', _descriptionController, 'Song description', maxLines: 3, isRequired: true),
        ],
      ),
    );
  }

  Widget _buildAdvancedOptionsDropdown() {
    return InkWell(
      onTap: () {
        setState(() {
          _showAdvancedOptions = !_showAdvancedOptions;
        });
      },
      child: Row(
        children: [
          Icon(
            _showAdvancedOptions ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: Color(0xFF808080), // Middle color of the gradient
            size: 34,
          ),
          Text(
            'Advanced Options',
            style: TextStyle(
              fontWeight: FontWeight.w200,
              fontSize: 24,
              color: Color(0xFF808080),
            ),
            
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedOptionsForm() {
    return Form(
      key: _advancedFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          _buildInputSection('Mood', 'Set the emotional tone of your lyrics', _moodController, 'Enter the mood (e.g., happy, melancholic, energetic)'),
          SizedBox(height: 16),
          _buildInputSection('Keywords', 'Add specific words or themes to include', _keywordsController, 'Enter keywords to include'),
          SizedBox(height: 16),
          _buildInputSection('Words to Avoid', 'Specify any words or phrases to exclude', _negativePromptController, 'Enter words or phrases to avoid'),
        ],
      ),
    );
  }

  Widget _buildOutputSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                'Generated Lyrics',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 30,fontFamily: 'NeueMontreal',color: Color(0xFFFFFFFF)),
              ),
            ),
            SizedBox(height: 16),
            _buildVersionTabs(),
            SizedBox(height: 16),
            Expanded(
              flex: 5,
              child: TextField(
                controller: _lyricsControllers[_selectedVersion],
                maxLines: null,
                minLines: 20,
                style: TextStyle(color: Colors.white,fontFamily: 'NeueMontreal', fontWeight: FontWeight.w500, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Generated lyrics will appear here',
                  hintStyle: TextStyle(color: Colors.grey[600],fontFamily: 'NeueMontreal', fontWeight: FontWeight.w500, fontSize: 18),
                  fillColor: Colors.black,
                  filled: true,
                  contentPadding: EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF262629), width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF262629), width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  hoverColor: Colors.transparent,
                ),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: AnimatedGradientButton(
                onPressed: _refineLyrics,
                child: Text('Refine Lyrics',style: TextStyle(fontFamily: 'NeueMontreal',fontWeight: FontWeight.w700, fontSize: 18),),
                isLoading: _isRefineLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(String title, String subtitle, TextEditingController controller, String hintText, {int maxLines = 1, bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 25,color: Color(0xFF808080),fontFamily: 'NeueMontreal'),
        ),
        SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: Colors.white,fontFamily: 'NeueMontreal', fontWeight: FontWeight.w300, fontSize: 24)),
        SizedBox(height: 8),
        _buildInputField(title, controller, hintText, maxLines: maxLines, isRequired: isRequired),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hintText, {int maxLines = 1, bool isRequired = false}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: Colors.white,fontFamily: 'NeueMontreal', fontWeight: FontWeight.w400, fontSize: 20), // Increased by 10
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400],fontFamily: 'NeueMontreal', fontWeight: FontWeight.w400, fontSize: 20), // Increased by 10
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[600],fontFamily: 'NeueMontreal', fontWeight: FontWeight.w400, fontSize: 20), // Increased by 10
        fillColor: Colors.black,
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF262629), width: 2),
          borderRadius: BorderRadius.circular(6),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF262629), width: 2),
          borderRadius: BorderRadius.circular(6),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(6),
        ),
        hoverColor: Colors.transparent,
      ),
      validator: isRequired ? (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      } : null,
    );
  }

  Widget _buildVersionTabs() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(child: Text('Version 1',  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400, color: Color(0xFF808080)))),
              Tab(child: Text('Version 2',  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400, color: Color(0xFF808080)))),
              Tab(child: Text('Version 3',  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400, color: Color(0xFF808080)))),
            ],
            labelColor: Colors.white,  // Change this line
            unselectedLabelColor: Colors.grey,  // Change this line
            indicatorColor: Color(0xFFFFFFFF), // Middle color of the gradient
            onTap: (index) {
              setState(() {
                _selectedVersion = index;
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _generateLyrics() async {
    if (_basicFormKey.currentState!.validate() && (!_showAdvancedOptions || _advancedFormKey.currentState!.validate())) {
      setState(() => _isGenerateLoading = true);
      try {
        final response = await http.post(
          Uri.parse('https://flask-app-flax.vercel.app/api/generate_lyrics'),
          body: {
            'description': _descriptionController.text,
            'language': _languageController.text,
            'genre': _genreController.text,
            'keywords': _keywordsController.text.isNotEmpty ? _keywordsController.text : 'Not specified',
            'mood': _moodController.text.isNotEmpty ? _moodController.text : 'Not specified',
            'negative_prompt': _negativePromptController.text.isNotEmpty ? _negativePromptController.text : 'Not specified',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            for (int i = 0; i < _lyricsControllers.length; i++) {
              if (i < data['lyrics'].length) {
                _lyricsControllers[i].text = data['lyrics'][i];
              } else {
                _lyricsControllers[i].text = "No lyrics generated for this version.";
              }
            }
            _selectedVersion = 0;
          });
        } else {
          throw Exception('Failed to generate lyrics');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        setState(() => _isGenerateLoading = false);
      }
    }
  }

  Future<void> _refineLyrics() async {
    setState(() => _isRefineLoading = true);
    try {
      final response = await http.post(
        Uri.parse('https://flask-app-flax.vercel.app/api/refine_lyrics'),
        body: {
          'current_lyrics': _lyricsControllers[_selectedVersion].text,
          'keywords': _keywordsController.text.isNotEmpty ? _keywordsController.text : 'Not specified',
          'mood': _moodController.text.isNotEmpty ? _moodController.text : 'Not specified',
          'negative_prompt': _negativePromptController.text.isNotEmpty ? _negativePromptController.text : 'Not specified',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _lyricsControllers[_selectedVersion].text = data['refined_lyrics'];
        });
      } else {
        throw Exception('Failed to refine lyrics');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isRefineLoading = false);
    }
  }
}

class AnimatedGradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final bool isLoading;

  const AnimatedGradientButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, // Set a fixed width for consistency
      height: 50,  // Set a fixed height for consistency
      decoration: BoxDecoration(
        color: Color(0xFFC33608), // Solid color instead of gradient
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? LoadingAnimationWidget.twistingDots(
                    leftDotColor: const Color(0xFF1A1A3F),
                    rightDotColor: Color.fromARGB(255, 55, 198, 234),
                    size: 30,
                  )
                : DefaultTextStyle(
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
                    child: child,
                  ),
          ),
        ),
      ),
    );
  }
}