# ProfileScreen

Allows the authenticated user to edit display name, email, change password, and update profile image.

## Fields
- Display name (editable)
- Email (editable)
- User ID (read-only)
- Profile photo (Network/File)

## Actions
- Edit Profile → toggles form to editable state
- Save Changes → updates Firebase user profile and sends a profile update notification
- Reset Password → triggers Firebase password reset email
- Cancel → discards edits

## Image Selection
Uses `image_picker` to choose from camera or gallery when editing.