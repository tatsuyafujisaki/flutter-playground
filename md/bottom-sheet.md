# How to set the height of [showModalBottomSheet](https://api.flutter.dev/flutter/material/showModalBottomSheet.html)

1. If you want the bottom sheet to cover roughly the bottom half of the screen, no special setting is required.
2. If you want to stretch the bottom sheet to the top of the screen except for the status bar, write the following:

   ```dart
   showModalBottomSheet<void>(
     context: context,
     builder: (_) => ...,
     // Stretches the bottom sheet to full height.
     isScrollControlled: true,
     // Prevents the full-height bottom sheet from overlapping the status bar.
     useSafeArea: true,
   );
   ```

3. If you want to stretch the bottom sheet to a certain percentage of the screen height, write the following:

   ```dart
   showModalBottomSheet<void>(
     context: context,
     builder: (_) => FractionallySizedBox(
       heightFactor: 0.8, // 80% of the screen height
       child: ...,
     ),
     // Stretches the bottom sheet to full height.
     isScrollControlled: true,
     // Prevents the full-height bottom sheet from overlapping the status bar.
     useSafeArea: true,
   );
   ```
