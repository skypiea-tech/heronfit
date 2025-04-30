import 'package:flutter/material.dart';
import 'dart:async';
import '../models/exercise_model.dart';
import '../controllers/exercise_controller.dart';
// Import GoRouter
import 'package:solar_icons/solar_icons.dart'; // Add this import
import 'package:heronfit/core/theme.dart'; // Import HeronFitTheme
import '../widgets/add_exercise_list_item.dart'; // Import the new widget

class AddExerciseScreen extends StatefulWidget {
  final String? workoutId;

  const AddExerciseScreen({super.key, this.workoutId});

  @override
  AddExerciseScreenState createState() => AddExerciseScreenState();
}

class AddExerciseScreenState extends State<AddExerciseScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  Timer? _debounce;
  String _searchQuery = '';
  List<Exercise> _exercises = [];
  bool _isLoading = true;
  bool _isSearching = false;
  final ExerciseController _exerciseController = ExerciseController();

  List<String> _availableEquipment = [];
  final List<String> _selectedEquipment = [];
  bool _isFilterExpanded = false;
  bool _isLoadingEquipment = false;

  @override
  void initState() {
    super.initState();
    _loadExercises();
    _loadAvailableEquipment();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_searchQuery.isEmpty &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_exerciseController.isFetchingMore &&
        _exerciseController.hasMorePages &&
        !_isSearching) {
      _loadMoreExercises();
    }
  }

  Future<void> _loadExercises() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final exercises = await _exerciseController.fetchExercises();
      setState(() {
        _exercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error loading exercises: $e');
    }
  }

  Future<void> _loadMoreExercises() async {
    if (_searchQuery.isNotEmpty || _isSearching) return;

    try {
      final exercises = await _exerciseController.fetchMoreExercises();
      setState(() {
        _exercises = exercises;
      });
    } catch (e) {
      _showErrorDialog('Error loading more exercises: $e');
    }
  }

  Future<void> _searchExercises(String query) async {
    setState(() {
      _isSearching = true;
      _isLoading = true;
    });

    try {
      final exercises = await _exerciseController.searchExercisesWithFilter(
        query: query,
        equipmentFilter: _selectedEquipment.isEmpty ? null : _selectedEquipment,
      );
      setState(() {
        _exercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error searching exercises: $e');
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _loadAvailableEquipment() async {
    setState(() {
      _isLoadingEquipment = true;
    });

    try {
      final equipment = await _exerciseController.getAvailableEquipment();
      setState(() {
        _availableEquipment = equipment;
        _isLoadingEquipment = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingEquipment = false;
      });
      debugPrint('Error loading equipment: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      final trimmedValue = value.trim();
      if (trimmedValue != _searchQuery) {
        setState(() {
          _searchQuery = trimmedValue;
        });

        if (trimmedValue.isEmpty) {
          _exerciseController.resetPagination();
          _loadExercises();
        } else {
          _searchExercises(trimmedValue);
        }
      }
    });
  }

  void _toggleEquipment(String equipment) {
    setState(() {
      if (_selectedEquipment.contains(equipment)) {
        _selectedEquipment.remove(equipment);
      } else {
        _selectedEquipment.add(equipment);
      }
    });
    _searchExercises(_searchQuery);
  }

  void _clearFilters() {
    setState(() {
      _selectedEquipment.clear();
    });
    _searchExercises(_searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: HeronFitTheme.primary,
              size: 30,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            'Add Exercise',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: HeronFitTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                SolarIconsOutline.filter,
                color:
                    _selectedEquipment.isNotEmpty
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(153),
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  _isFilterExpanded = !_isFilterExpanded;
                });
              },
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextFormField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search Exercises...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(153),
                    ),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: HeronFitTheme.bgPrimary,
                  ),
                ),
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: _isFilterExpanded ? null : 0,
              child:
                  _isFilterExpanded
                      ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Filter by Equipment',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                if (_selectedEquipment.isNotEmpty)
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size(50, 30),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: _clearFilters,
                                    child: Text('Clear All'),
                                  ),
                              ],
                            ),
                            SizedBox(height: 8),
                            _isLoadingEquipment
                                ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                                : Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children:
                                      _availableEquipment.map((equipment) {
                                        final isSelected = _selectedEquipment
                                            .contains(equipment);
                                        return FilterChip(
                                          label: Text(
                                            _capitalizeWords(equipment),
                                          ),
                                          selected: isSelected,
                                          onSelected:
                                              (_) =>
                                                  _toggleEquipment(equipment),
                                          backgroundColor:
                                              Theme.of(
                                                context,
                                              ).colorScheme.surface,
                                          selectedColor: Theme.of(
                                            context,
                                          ).colorScheme.primary.withAlpha(51),
                                          checkmarkColor:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16.0,
                                            ),
                                            side: BorderSide(
                                              color:
                                                  isSelected
                                                      ? Theme.of(
                                                        context,
                                                      ).colorScheme.primary
                                                      : Colors.grey.withAlpha(
                                                        128,
                                                      ),
                                            ),
                                          ),
                                          padding: EdgeInsets.zero,
                                        );
                                      }).toList(),
                                ),
                            SizedBox(height: 8),
                            Divider(),
                          ],
                        ),
                      )
                      : SizedBox.shrink(),
            ),
            if (_selectedEquipment.isNotEmpty && !_isFilterExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Filtered by ${_selectedEquipment.length} equipment types',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Spacer(),
                    InkWell(
                      onTap: _clearFilters,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 2.0,
                        ),
                        child: Text(
                          'Clear',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Tap to add an exercise to your workout. Long press for details. Use filters to find equipment-specific exercises.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child:
                  _isLoading
                      ? _buildSkeletonList()
                      : _exercises.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: 64,
                              color: Colors.grey.withAlpha(128),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No exercises found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            if (_selectedEquipment.isNotEmpty) ...[
                              SizedBox(height: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: _clearFilters,
                                child: Text('Clear Filters'),
                              ),
                            ],
                          ],
                        ),
                      )
                      : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount:
                            _exercises.length +
                            (_exerciseController.hasMorePages &&
                                    _searchQuery.isEmpty &&
                                    !_isSearching
                                ? 1
                                : 0),
                        itemBuilder: (context, index) {
                          if (index == _exercises.length &&
                              _searchQuery.isEmpty &&
                              !_isSearching) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          if (index >= _exercises.length) {
                            return const SizedBox.shrink();
                          }

                          final exercise = _exercises[index];

                          return AddExerciseListItem(
                            key: ValueKey(
                              exercise.id,
                            ), // Add key for potential list updates
                            exercise: exercise,
                            searchQuery: _searchQuery,
                            buildHighlightedText: _buildHighlightedText,
                            capitalizeWords: _capitalizeWords,
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  TextSpan _buildHighlightedText(
    String text,
    String highlight,
    TextStyle style,
  ) {
    if (highlight.isEmpty ||
        !text.toLowerCase().contains(highlight.toLowerCase())) {
      return TextSpan(text: text, style: style);
    }

    final TextStyle highlightStyle = style.copyWith(
      fontWeight: FontWeight.bold,
    );

    List<TextSpan> spans = [];
    int start = 0;
    int indexOfHighlight;
    while ((indexOfHighlight = text.toLowerCase().indexOf(
          highlight.toLowerCase(),
          start,
        )) !=
        -1) {
      if (indexOfHighlight > start) {
        spans.add(
          TextSpan(text: text.substring(start, indexOfHighlight), style: style),
        );
      }
      spans.add(
        TextSpan(
          text: text.substring(
            indexOfHighlight,
            indexOfHighlight + highlight.length,
          ),
          style: highlightStyle,
        ),
      );
      start = indexOfHighlight + highlight.length;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: style));
    }

    return TextSpan(
      children: spans.isNotEmpty ? spans : [TextSpan(text: text, style: style)],
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => _buildSkeletonItem(),
    );
  }

  Widget _buildSkeletonItem() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16.0,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: 8.0),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: 14.0,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: 4.0),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: 13.0,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalizeWords(String text) {
    if (text.isEmpty) return '';
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
