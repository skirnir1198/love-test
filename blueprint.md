# Love Test App Blueprint

## Overview

This document outlines the style, design, and features of the Love Test Flutter application. The app allows users to select from a list of "love" themed quizzes, answer a series of questions, and see a result. Firebase integration has been re-enabled.

## Current State & Features

*   **Firebase Project:** `love-test-2024` (for Android/Web), `love-test-36c8b` (for iOS)
*   **UI:**
    *   The main screen displays a list of available diagnostic quizzes.
    *   The design uses a pink and purple gradient theme.
    *   Custom fonts (`Mochiy Pop One`) are used for titles.
    *   The list items are presented as decorated cards with gradients.
*   **Data:**
    *   Quiz data is currently loaded from a local `assets/data.json` file. Firebase is configured, but data fetching from Firestore is not yet implemented.
*   **Navigation:**
    *   Tapping on a quiz navigates the user to the question view for that quiz.

## Plan for Current Change (Share Image View)

The goal is to create a new view, `ShareImageView`, to generate a stylish, shareable image of a user's diagnosis result.

**Steps Completed:**

1.  Created a new file `lib/share_image_view.dart`.
2.  Implemented the `ShareImageView` widget, which accepts a `typeName` and `title`.
3.  Designed the view with an Instagram Story-like aesthetic, featuring:
    *   A vertical gradient background (purple, pink, orange).
    *   A large, centered `typeName` with a drop shadow for readability.
    *   The `title` and app name (`#恋愛診断`) positioned at the bottom.
    *   Used `GoogleFonts` (`Mochiy Pop One` and `Noto Sans JP`) for stylish typography.
    *   The view is wrapped in an `AspectRatio` widget to maintain a 9:16 ratio.
