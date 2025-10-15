# TODO: Implement Multiple File Selection in Send Screen

## Steps to Complete:

- [x] Step 1: Add selection tracking state variables (List<bool> _isSelectedFiles) in _SendScreenState.
- [x] Step 2: Update _pickFile method to initialize _isSelectedFiles after picking files.
- [x] Step 3: Refactor the files display section in build() to use ListView.builder with Checkbox for each file card.
- [x] Step 4: Add a getter method for selected file paths (filter based on _isSelectedFiles).
7- [x] Step 5: Update _startServerForAllFiles to _startServerForSelectedFiles: Use selected paths/names, add only selected to history, rename and update button logic/label to show count.
- [x] Step 6: Add a selection count header above the files list (e.g., "Selected: X/Y files").
- [x] Step 7: Ensure server info, QR code, and other UI elements remain functional for selected files.
- [x] Step 8: Verify no breaking changes and test the flow (pick, select/deselect, share selected).

## Followup:
- Run `flutter pub get` if dependencies change (unlikely).
- Test on device/emulator with `flutter run`.
- Update history and service calls accordingly.

---

# TODO: Implement File Fetching and Selection in Receive Screen

## Steps to Complete:

- [x] Step 1: Add _fetchAvailableFiles method to get list of files from sender's server.
- [x] Step 2: Update downloadFile in service to accept optional fileName parameter for specific file download.
- [x] Step 3: Modify _downloadFile in receive screen to take optional fileName and pass to service.
- [x] Step 4: Update _onDetect to fetch files instead of auto-download after QR scan.
- [x] Step 5: Add _buildFilesListView to display available files with download buttons.
- [x] Step 6: Update build method to show files list when available, else input view.
- [x] Step 7: Add _getFileIcon helper for file type icons.
- [x] Step 8: Add back button in files list to return to input view.

## Followup:
- Test the flow: Scan QR -> Fetch files -> Select and download specific files.
- Ensure history is updated correctly for each downloaded file.

---

# TODO: Fix Premature History Addition in Send Screen

## Steps to Complete:

- [x] Step 1: Update file_share_service.dart to change onFileDownloaded callback to accept String fileName parameter.
- [x] Step 2: In service /download handler, call onFileDownloaded with fileNameToServe after file send.
- [x] Step 3: In send_screen.dart, remove _addSelectedFilesToHistory() call from _startServerForSelectedFiles().
- [x] Step 4: Update onFileDownloaded callback in send_screen to (String fileName) => _addToHistory(fileName).
- [x] Step 5: Add _addToHistory(String fileName) method in send_screen to create and add transfer for specific file.
- [x] Step 6: Remove unused _addToHistoryAfterShare() and _addSelectedFilesToHistory() methods.
- [x] Step 7: Test the flow: select files, start server (no history), download file (adds to history).

## Followup:
- Run `flutter pub get` if dependencies change (unlikely).
- Test on device/emulator with `flutter run`.
- Ensure history only updates after successful download.
