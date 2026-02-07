# Antigravity - AI-Powered Personal Finance App

A modern, cross-platform personal finance application built with Flutter, featuring AI financial assistance powered by Google's Gemini API.

## Features

### Core Functionality
- **Authentication**: Email/password and Google Sign-In support with Firebase Auth
- **Dashboard**: Real-time balance overview, expense charts, and savings progress
- **Transaction Management**: Track income and expenses with categories
- **Financial Goals**: Set and track savings goals with AI-powered planning
- **AI Assistant**: Chat with AI for financial insights and recommendations
- **Settings**: Theme selection, currency preferences, and secure API key management

### AI Features
- Smart financial tips on the dashboard
- Detailed financial report generation
- Goal planning with step-by-step recommendations
- Spending analysis and budget optimization
- Interactive chat assistant for financial questions

## Architecture

The app follows a clean architecture pattern with:
- **Presentation Layer**: BLoC pattern for state management, UI components
- **Domain Layer**: Entity definitions and business logic
- **Data Layer**: Hive for local storage, Firebase for authentication
- **Services Layer**: AI service (Gemini API), storage service, auth service

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── errors/
│   │   └── failures.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_dark_theme.dart
│   │   └── theme_cubit.dart
│   └── utils/
├── data/
│   ├── datasources/
│   ├── models/
│   │   ├── chat_message_model.dart
│   │   ├── financial_goal_model.dart
│   │   ├── settings_model.dart
│   │   ├── transaction_model.dart
│   │   └── user_model.dart
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── blocs/
│   │   ├── auth_bloc.dart
│   │   ├── chat_bloc.dart
│   │   ├── dashboard_bloc.dart
│   │   ├── goal_bloc.dart
│   │   ├── settings_bloc.dart
│   │   └── transaction_bloc.dart
│   ├── pages/
│   │   ├── chat_page.dart
│   │   ├── dashboard_page.dart
│   │   ├── goals_page.dart
│   │   ├── goal_sheets.dart
│   │   ├── login_page.dart
│   │   ├── settings_page.dart
│   │   ├── transactions_page.dart
│   │   └── transaction_sheets.dart
│   └── widgets/
│       ├── ai_tip_card.dart
│       ├── balance_card.dart
│       ├── custom_text_field.dart
│       ├── dashboard_widgets.dart
│       └── expense_chart.dart
├── services/
│   ├── ai_service.dart
│   ├── auth_service.dart
│   └── storage_service.dart
├── app.dart
└── main.dart
```

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Firebase project configuration
- Gemini API key

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/antigravity.git
cd antigravity
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
- Add your `google-services.json` (Android) to `android/app/`
- Add your `GoogleService-Info.plist` (iOS) to `ios/Runner/`

4. Run the app
```bash
flutter run
```

## Configuration

### Gemini API Key Setup
1. Get your API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Open the app and go to Settings
3. Enter your API key in the "Gemini API Key" section
4. Tap "Validate" to verify the key
5. Tap "Save" to store it securely

## Technologies Used

- **Flutter**: Cross-platform UI framework
- **Flutter BLoC**: State management
- **Hive**: Local database
- **Firebase**: Authentication
- **Google Sign-In**: OAuth authentication
- **Gemini API**: AI financial assistance
- **FL Chart**: Data visualization
- **Flutter Secure Storage**: Secure key storage
- **Intl**: Internationalization and formatting

## Security

- API keys are stored securely using `flutter_secure_storage`
- User credentials are managed by Firebase Auth
- Local data is encrypted by Hive
- No financial data is sent to external servers (except Gemini API for AI features)

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Google Gemini API for powering AI features
- Flutter team for the amazing framework
- Firebase for authentication services
- All open-source package contributors

## Disclaimer

This app provides financial information and suggestions for educational purposes only. It does not constitute professional financial advice. Always consult with a qualified financial advisor before making investment decisions.
