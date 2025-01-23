# Timesheet Tracker

Timesheet Tracker is a comprehensive cross-platform application built with Flutter, designed to help individuals and businesses efficiently track time entries, manage projects, generate invoices, and handle client communications. Whether you're on Android, iOS, Windows, or MacOS, Timesheet Tracker provides a seamless experience to streamline your time management and billing processes.

## Current Features
- **Project Management**: Create and manage multiple projects, each associated with specific clients.
- **Time Tracking**: Clock in and out, pause and resume sessions, and log time entries accurately.
- **Responsive UI**: Modern and intuitive user interface adhering to Material Design principles.

## Features Coming Soon
- **User Authentication**: Secure login and registration system to manage user accounts.
- **Automated Invoicing**: Generate invoices automatically based on tracked time and project rates.
- **Invoice Emailing**: Automatically send invoices to clients via email.
- **Tax Information**: Manage and calculate tax information for accurate billing.
- **Cross-Platform Support**: Run seamlessly on Android, iOS, Windows, and MacOS.
- **Real-Time Data Sync**: Utilize Supabase for real-time data synchronization and backend services.
- **Provider State Management**: Efficient state management using the Provider package.

## Getting Started

### Prerequisites
- **Flutter SDK**: Ensure you have Flutter installed. Follow the [official Flutter installation guide](https://flutter.dev/docs/get-started/install) for your operating system.
- **Supabase Account**: Sign up for a [Supabase](https://supabase.com/) account to manage your backend services.
- **Dart SDK**: Comes bundled with Flutter.

### Installation

1. **Clone the Repository**
   
   ```git clone https://github.com/yourusername/timesheet-tracker.git```

2. **Navigate to the Project Directory**
   
   ```cd timesheet-tracker```

3. **Install Dependencies**
   
   ```flutter pub get```

4. **Set Up Environment Variables**
   
   Create a `.env` file in the root directory and add your Supabase credentials:
   
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

5. **Run the Application**
   
   ``flutter run``
   
   Select your desired platform (Android, iOS, Windows, MacOS) to launch the application.

## Usage

1. **Manage Projects**
 - Navigate to the Projects page to add, view, or delete projects.
   
2. **Track Time**
   - Use the Clock In button to start tracking time for a selected project.
   - Pause or resume the timer as needed.
   - Clock Out to end the session and log the time entry.

4. **View Entries**
   - Access the Entries page to view all logged time entries.
   - Filter and search entries based on date, project, or client.

## Contributing
Contributions are welcome! Please follow these steps to contribute:

1. **Fork the Repository**

2. **Create a New Branch**
   
   ```git checkout -b feature/YourFeature```

3. **Commit Your Changes**
   
   ```git commit -m "Add your message here"```

4. **Push to the Branch**
   
   ```git push origin feature/YourFeature```

5. **Open a Pull Request**
   - Submit a pull request detailing your changes and enhancements.

## License
This project is licensed under the [MIT License](LICENSE).

## Contact
For any inquiries or support, please contact [morgan.mcnabb@protonmail.com](mailto:morgan.mcnabb@protonmail.com) or [brennan.davis@gmail.com](mailto:brennan.davis@gmail.com).

