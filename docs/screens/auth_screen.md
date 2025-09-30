# AuthScreen

A stateful screen that hosts the `AuthForm` and manages Firebase Authentication flows for sign in and sign up.

## Constructor
```dart
const AuthScreen({ Key? key, this.initialMode = AuthMode.login })
```
- `initialMode`: default login, can be set to `AuthMode.signup` for signup-first flows

## Behavior
- Initializes local notifications for a welcome message after success
- Delegates form submission to `_submitAuthForm`
- On success: shows a local welcome notification and pops to root
- On error: surfaces error via `SnackBar`

## Navigation
- Pushed from `StartScreen`
- After successful auth, navigation returns to the first route; `MyApp` will transition to `DashboardScreen` based on auth stream