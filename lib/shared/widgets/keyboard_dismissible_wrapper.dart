import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A wrapper widget that ensures keyboard can always be dismissed
/// by tapping anywhere or by using manual dismissal methods
class KeyboardDismissibleWrapper extends StatelessWidget {
  final Widget child;
  final bool dismissOnTap;
  final VoidCallback? onKeyboardDismissed;

  const KeyboardDismissibleWrapper({
    super.key,
    required this.child,
    this.dismissOnTap = true,
    this.onKeyboardDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: dismissOnTap ? () => _dismissKeyboard(context) : null,
      onPanDown: dismissOnTap ? (_) => _dismissKeyboard(context) : null,
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }

  void _dismissKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    
    // Multiple methods to ensure keyboard dismissal
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild!.unfocus();
    }
    
    // Force unfocus on the primary focus
    if (currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    
    // Additional system-level keyboard dismissal
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    
    // Callback for additional actions
    onKeyboardDismissed?.call();
  }

  /// Static method to manually dismiss keyboard from anywhere
  static void dismissKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild!.unfocus();
    }
    
    if (currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  /// Static method to check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }
}

/// Extension to make keyboard dismissal easier to use
extension KeyboardDismissalExtension on BuildContext {
  void dismissKeyboard() {
    KeyboardDismissibleWrapper.dismissKeyboard(this);
  }
  
  bool get isKeyboardVisible {
    return KeyboardDismissibleWrapper.isKeyboardVisible(this);
  }
}