# StartScreen

Landing screen presenting branding and navigation to login or signup.

## Purpose
- Introduces the app
- Provides entry points to authentication flows

## Actions
- "Login" → pushes `AuthScreen(initialMode: AuthMode.login)`
- "Sign Up" → pushes `AuthScreen(initialMode: AuthMode.signup)`

## Usage
The screen is displayed by `MyApp` when there is no authenticated user.