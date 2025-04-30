import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Import for debugPrint
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/features/workout/models/exercise_model.dart';
import 'package:solar_icons/solar_icons.dart'; // Import icons
import 'package:heronfit/features/workout/widgets/rest_timer_dialog.dart'; // Import the dialog

// Define callback types
typedef UpdateSetDataCallback =
    void Function(int setIndex, {int? kg, int? reps, bool? completed});
typedef RemoveSetCallback = void Function(int setIndex);
typedef ShowDetailsCallback = void Function(); // New callback type

class ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final String? workoutId;
  final VoidCallback onAddSet;
  final UpdateSetDataCallback onUpdateSetData; // Callback for updating set data
  final RemoveSetCallback onRemoveSet; // Callback for removing a set
  final ShowDetailsCallback onShowDetails; // New callback for showing details

  const ExerciseCard({
    super.key, // Use super parameter
    required this.exercise,
    required this.workoutId,
    required this.onAddSet,
    required this.onUpdateSetData, // Require callback
    required this.onRemoveSet, // Require callback
    required this.onShowDetails, // Require new callback
  });

  @override
  ExerciseCardState createState() => ExerciseCardState(); // Make state public
}

// Make state class public
class ExerciseCardState extends State<ExerciseCard> {
  @override
  void dispose() {
    super.dispose();
  }

  // Method to show the rest timer dialog
  // Updated to pass required parameters to the new RestTimerDialog
  void _showRestTimerDialog(int setIndex) {
    // Pass setIndex
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        // Provide all required arguments
        return RestTimerDialog(
          initialDuration: const Duration(
            seconds: 90,
          ), // Default or from settings
          exerciseName: widget.exercise.name,
          setNumber: setIndex + 1, // Pass the current set number (1-based)
          onSkip: () {
            // Logic when skip is pressed (dialog closes itself)
            debugPrint(
              "Rest skipped for ${widget.exercise.name} Set ${setIndex + 1}",
            );
          },
          onTimerEnd: () {
            // Logic when timer finishes (dialog closes itself)
            debugPrint(
              "Rest finished for ${widget.exercise.name} Set ${setIndex + 1}",
            );
            // Optionally add sound/vibration here
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 40.0,
            color: Colors.grey.withAlpha(77), // Use withAlpha (0.3 * 255)
            offset: const Offset(0.0, 10.0),
          ),
        ],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Adjusted padding
        child: Column(
          mainAxisSize: MainAxisSize.min, // Use min to fit content
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Align items vertically
              children: [
                Expanded(
                  child: Text(
                    widget.exercise.name,
                    textAlign: TextAlign.start,
                    style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                      color: HeronFitTheme.primary,
                      fontWeight: FontWeight.bold, // Make title bold
                    ),
                    maxLines: 2, // Allow wrapping
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8), // Add spacing before the icon
                IconButton(
                  icon: const Icon(
                    SolarIconsOutline.questionCircle,
                    color: HeronFitTheme.primary, // Use a muted color
                    size: 20, // Adjust size as needed
                  ),
                  padding: EdgeInsets.zero, // Remove default padding
                  constraints: const BoxConstraints(), // Remove constraints
                  tooltip: 'View Exercise Details', // Add tooltip
                  onPressed: widget.onShowDetails, // Call the new callback
                ),
              ],
            ),
            const SizedBox(height: 16.0), // Increased spacing
            // Header Row for SET, KG, REPS
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
              ), // Add padding
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Space out headers
                children: [
                  SizedBox(
                    width: 30, // Match width of set number column
                    child: Text(
                      'SET',
                      textAlign: TextAlign.center,
                      style: HeronFitTheme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: HeronFitTheme.textMuted, // Muted color
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 70, // Adjust width for KG input
                    child: Text(
                      'KG',
                      textAlign: TextAlign.center,
                      style: HeronFitTheme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: HeronFitTheme.textMuted,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 70, // Adjust width for Reps input
                    child: Text(
                      'REPS',
                      textAlign: TextAlign.center,
                      style: HeronFitTheme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: HeronFitTheme.textMuted,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40, // Adjust width for Checkbox column
                    child: Text(
                      'DONE', // Header for checkbox
                      textAlign: TextAlign.center,
                      style: HeronFitTheme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: HeronFitTheme.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 16.0), // Use Divider instead of SizedBox
            // Sets List
            ListView.separated(
              padding: EdgeInsets.zero,
              primary: false,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: widget.exercise.sets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8.0),
              itemBuilder: (context, setsListIndex) {
                final set = widget.exercise.sets[setsListIndex];
                final kgController = TextEditingController(
                  text: set.kg > 0 ? set.kg.toString() : '',
                );
                final repsController = TextEditingController(
                  text: set.reps > 0 ? set.reps.toString() : '',
                );
                kgController.selection = TextSelection.fromPosition(
                  TextPosition(offset: kgController.text.length),
                );
                repsController.selection = TextSelection.fromPosition(
                  TextPosition(offset: repsController.text.length),
                );

                return Dismissible(
                  key: ValueKey('${widget.exercise.id}_set_$setsListIndex'),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    widget.onRemoveSet(setsListIndex);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Set ${setsListIndex + 1} removed'),
                      ),
                    );
                  },
                  background: Container(
                    color: HeronFitTheme.error.withAlpha(
                      204,
                    ), // Use withAlpha (0.8 * 255)
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(
                      SolarIconsOutline.trashBinMinimalistic,
                      color: Colors.white,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                    ), // Add vertical padding
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween, // Space out columns
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 30, // Consistent width
                          child: Text(
                            '${setsListIndex + 1}',
                            textAlign: TextAlign.center,
                            style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                              color: HeronFitTheme.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 70, // Consistent width
                          child: TextFormField(
                            controller: kgController,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: '0', // Default hint
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 4.0, // Add horizontal padding
                              ),
                              border: OutlineInputBorder(
                                // Add border
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: BorderSide(
                                  color: HeronFitTheme.primary,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) {
                              widget.onUpdateSetData(
                                setsListIndex,
                                kg: int.tryParse(value) ?? 0,
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: 70, // Consistent width
                          child: TextFormField(
                            controller: repsController,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: '0', // Default hint
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 4.0, // Add horizontal padding
                              ),
                              border: OutlineInputBorder(
                                // Add border
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: BorderSide(
                                  color: HeronFitTheme.primary,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) {
                              widget.onUpdateSetData(
                                setsListIndex,
                                reps: int.tryParse(value) ?? 0,
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: 40, // Consistent width
                          child: Transform.scale(
                            scale: 1.1, // Slightly smaller checkbox
                            child: Checkbox(
                              value: set.completed,
                              visualDensity: VisualDensity.compact,
                              activeColor:
                                  HeronFitTheme.primary, // Use theme color
                              side: BorderSide(
                                color: Colors.grey.shade400,
                              ), // Border for unchecked
                              shape: RoundedRectangleBorder(
                                // Rounded corners
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              onChanged: (bool? value) {
                                if (value != null) {
                                  widget.onUpdateSetData(
                                    setsListIndex,
                                    completed: value,
                                  );
                                  // Show timer only when checking the box (completing the set)
                                  if (value == true) {
                                    _showRestTimerDialog(setsListIndex);
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16.0),
            // Add Set Button
            ElevatedButton.icon(
              // Use icon button
              icon: const Icon(
                SolarIconsOutline.addCircle,
                size: 18,
              ), // Add icon
              label: Text(
                'Add Set',
                style: HeronFitTheme.textTheme.labelMedium?.copyWith(
                  color: HeronFitTheme.bgLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                widget.onAddSet();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(
                  double.infinity,
                  44.0,
                ), // Slightly taller button
                backgroundColor: HeronFitTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 2, // Add subtle elevation
              ),
            ),
          ],
        ),
      ),
    );
  }
}
