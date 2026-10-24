# IT 126 – Module 3, Lesson 2: Investigating Data Persistence

## Activity

This Flutter app demonstrates a simple student task list using a Dart `List<String>` held in the state of a `StatefulWidget`.

### Features
- Text field for entering a task title
- Add Task button
- Displays the tasks added during the current app session
- Rejects empty or whitespace-only titles
- Uses in-memory data only; no database or persistent storage is implemented

### How to run
1. Install Flutter and set up a supported emulator or connect a device.
2. Extract this project and open a terminal in the project folder.
3. Run:
   ```bash
   flutter pub get
   flutter run
   ```
4. Add two or more tasks and confirm that they appear in the list.
5. Stop/terminate the application completely, then launch it again.
6. Observe that the previously added tasks are no longer displayed.

### Activity observations
- While the app is running, the tasks appear because they are held in the `_tasks` Dart list and the widget rebuilds after `setState`.
- After the app process ends and the app is launched again, the list starts empty because the tasks were not written to persistent storage.
- This activity intentionally does not use SQLite, files, or another persistence mechanism.

## Analysis

### 1. What happened to the task titles when you added them to the list?
Each title was appended to the in-memory `List<String>` named `_tasks`. The app then rebuilt its interface and displayed the updated list.

### 2. Why could the application display the tasks while it was running?
The list remained available in the running app's memory. Calling `setState` notified Flutter that the state had changed, allowing the interface to rebuild and show the newly added tasks.

### 3. What happened after the application process ended and the application was relaunched?
The previously added task titles were gone, and the list was empty after relaunch. The in-memory objects from the previous process were not preserved.

### 4. Would keeping the list inside a StatefulWidget automatically make the tasks persistent? Explain your answer.
No. A `StatefulWidget` can keep state while its relevant state object exists, including across ordinary rebuilds. It does not automatically save that state to durable storage when the application process ends.

### 5. What would the application need to do to preserve the tasks between sessions?
It would need to write the task data to persistent storage and load it again when the app starts. For structured task records, SQLite is one suitable option; files or key-value storage may suit other data needs.

### 6. If the application eventually stored hundreds or thousands of tasks, what problems might arise from managing all the data manually in memory?
The app would still lack persistence unless it separately saved the data. Searching, filtering, updating, and deleting records could also require more manually written logic, and keeping that logic organized becomes harder as the number of records and task attributes grows. Memory use and UI performance may also become concerns depending on how the data is handled.

### 7. How could separating the operations that save and retrieve tasks from the UI make the application easier to maintain?
A separate data-access component or repository can centralize saving, retrieving, updating, and deleting. The UI can focus on displaying tasks and handling user input, while data-access logic can be changed or tested separately. This reduces duplicated database logic across screens and makes the application easier to maintain.

## Submission checklist
- [x] Flutter/Dart source code included
- [x] Analysis answers included in this `README.md`
- [ ] Run and verify the app on a Flutter-supported device/emulator
- [ ] Push the complete project to a public GitHub repository
- [ ] Submit only the public GitHub repository URL

## Important note
This project implements the lesson's initial **Activity** and its seven **Analysis** questions. It intentionally does not implement the later SQLite-based **Application: Developing a Local Task Manager**, because that is a separate exercise in the course material.
