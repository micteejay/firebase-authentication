# AuthForm

Stateful authentication form widget supporting login and signup flows, with optional Google Sign-In and biometric quick-login.

## Import
```dart
import 'package:your_app/widgets/auth/auth_form.dart';
```

## Constructor
```dart
const AuthForm(
  this.submitFn,
  this.isLoading, {
  Key? key,
  this.isLogin = true,
  this.onModeChanged,
})
```

## Properties
- `bool isLoading`: disables submit and shows a progress indicator
- `bool isLogin`: selects login vs signup UI state
- `void Function(bool isLogin)? onModeChanged`: called when user toggles between login and signup
- `void Function(String email, String password, String userName, bool isLogin, BuildContext ctx) submitFn`: invoked on valid submit

## Behavior
- Validates email and password; name required on signup
- Stores credentials securely on successful login for biometric quick-login
- Supports Google Sign-In and account linking edge case handling
- Offers "Forgot password" dialog which sends a reset email

## Example
```dart
AuthForm(
  (email, password, userName, isLogin, ctx) {
    // authenticate with Firebase
  },
  isLoading,
  isLogin: true,
  onModeChanged: (isLogin) {
    // update UI if needed
  },
)
```