
# ISRO Quiz App

![Flutter](https://img.shields.io/badge/Flutter-2.10-blue?logo=flutter&logoColor=white)  
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)

## Overview

ISRO Quiz App is an educational mobile application built using **Flutter** and **Firebase** that allows users to test their knowledge about space, rockets, and spacecraft. The app provides quizzes across multiple subjects and difficulty levels, tracks scores, and maintains user progress.

## Features

* **User Authentication**: Register and login using email and password.
* **Check ISRO Website**: Direct link to ISRO’s official website from the app.
* **Quiz Categories**: Subjects include Spacecrafts, Rockets, and ISRO.
* **Difficulty Levels**: Each subject has three levels – Easy, Medium, Hard.
* **Timed Quizzes**: Each question has a countdown timer.
* **Score Tracking**: Final score calculated at the end of each quiz.
* **Completed Quizzes**: Users can view their completed quizzes and scores.
* **Info Portal**: Access additional information and resources related to ISRO.
* **Dynamic Question Loading**: Questions fetched from local JSON files stored in assets.
* **Result Page**: Displays score and correct/incorrect answers after completing a quiz.

## Database Structure (Firebase Firestore)

**Collection:** `users`

Example Document:

```json
{
  "email": "bass.chuck@yahoo.com",
  "name": "Chuck",
  "password": "123456789",
  "quizzes": [
    {
      "level": "Easy",
      "quiz": "Rockets",
      "score": 0
    },
    {
      "level": "Easy",
      "quiz": "Spacecrafts",
      "score": 8
    }
  ]
}
```

## Firebase Functions

1. **User Registration**: Adds a new user to Firebase Authentication and Firestore.
2. **User Login**: Authenticates user credentials.
3. **Fetch Completed Quizzes**: Retrieves quizzes a user has completed along with scores.
4. **Update Quiz Score**: Updates the score for a specific quiz and level.
5. **Map JSON Questions**: Matches questions from local JSON data to quiz subjects and difficulty levels.

## Project Structure

```
lib/
 ├─ models/
 │   └─ user.dart
 ├─ providers/
 │   └─ userProvider.dart
 ├─ screens/
 │   ├─ homePage.dart
 │   ├─ loginPage.dart
 │   ├─ registerPage.dart
 │   ├─ quiz.dart
 │   ├─ quizHome.dart
 │   ├─ startPage.dart
 │   ├─ infoPage.dart
 │   └─ resultPage.dart
 ├─ services/
 │   ├─ userOperations.dart
 │   ├─ isroHelper.dart
 │   └─ questionService.dart
 └─ main.dart
assets/
 ├─ images/
 │   └─ bg.png
 └─ questions/
    └─ *.json
```

## Installation

1. Clone the repository:

   ```bash
   git clone <repo_link>
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Configure Firebase:

   * Add your `google-services.json` for Android and `GoogleService-Info.plist` for iOS.

4. Run the app:

   ```bash
   flutter run
   ```

## Notes

* The app was initially built in a **15-hour sprint**, so some features are in a rough draft state.
* Future improvements can include additional subjects, question categories, and enhanced UI/UX.

## Demo

[Short demo video link here]

---

For any questions or support, please contact: **[your-email@example.com](mailto:your-email@example.com)**
