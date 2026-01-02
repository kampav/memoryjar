## Sensitive Firebase Config Removed from History

**What I did**
- Removed `lib/firebase_options.dart` and `lib/firebase_options.local.dart` from the git history.
- Added `lib/firebase_options.example.dart` (placeholders) and updated `.gitignore` to ignore local secrets.
- Force-pushed the cleaned history to `origin/main`.

**Important actions you _must_ take now**
1. **Rotate Firebase keys**: Go to the Firebase / Google Cloud console and rotate the API keys and any service credentials that were exposed.
2. **Re-clone the repository**: After a history rewrite, everyone should re-clone the repository to avoid history conflicts.
   - `git clone https://github.com/<owner>/<repo>.git`
3. **Restore your local config**:
   - Copy `lib/firebase_options.example.dart` to `lib/firebase_options.dart` and fill with your real config values (do not commit it).

If you want, I can provide a short message you can post to collaborators explaining the required steps and why re-cloning is necessary.
