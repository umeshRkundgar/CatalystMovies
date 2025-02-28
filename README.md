# CatalystMovies - iOS Movie Browsing App

## App Description
CatalystMovies is an iOS app that lets users browse movies. The app shows:
- **Trending Movies:** A horizontal list of movies that are trending.
- **Movie Categories:** Movies are organized into categories such as Now Playing, Popular, Top Rated, and Upcoming.
- **Movie Details:** When a movie is tapped, the app displays details like the poster, backdrop, title, description, release year, duration, and genre.
- **Trailers:** Users can watch the trailer for a movie within the app.
- **Cast:** Users can see the cast list with images and names.

**Note:**  
- The **“Watch”** and **“Year”** buttons in the details screen are currently placeholders and **do not** perform any action.  
- Only the **“Trailer”** button is functional for now, allowing users to view the movie trailer.

## Build/Run Instructions
1. **Requirements:**
   - Xcode 13 or later.
   - Swift 5 or higher.
   - A valid TMDb API key (set in the project).

2. **Setup:**
   - Unzip the provided archive.
   - Open `CatalystMovies.xcodeproj` in Xcode.
   - Ensure the TMDb API key is correctly set (in Info.plist or a configuration file).

3. **Run:**
   - Select the desired device or simulator.
   - Press **Cmd+R** to build and run the app.

## Architecture Explanation
CatalystMovies uses the MVVM (Model-View-ViewModel) pattern:
- **Model:** Contains the data structures like `Movie`, `MovieResponse`, and `MovieDetails` which mirror the TMDb API responses.
- **ViewModel:** The `HomeViewModel` handles API calls and data processing. It uses callbacks (like `onDataUpdated` and `onError`) to inform the view controller when data changes or if errors occur.
- **View Controllers:** `HomeViewController` and `MovieDetailsViewController` display the UI. They listen for updates from the ViewModel and update the UI accordingly.
- **Benefits:** This structure separates the UI from the business logic, making the app easier to maintain and scale.

## Libraries and Design Rationale
- **URLSession:** Used for network requests. It is lightweight and built into iOS.
- **AVKit & WebKit:** Used to play movie trailers inside the app.
- **Auto Layout, Storyboards, and XIBs:** Used for a responsive UI that works on different devices.
- **MVVM Architecture:** Separates business logic from the UI, making it easier to manage and test.
- **Custom Extensions:** For example, an extension on `UIImageView` helps load images asynchronously.

## Known Issues/Limitations
- **Internet Connection:** The app requires an internet connection to fetch data. There is no offline mode.
- **Trailer Playback:** Some YouTube videos may not play if there are embedding restrictions.
- **API Rate Limits:** Excessive API calls might hit TMDb’s rate limits. A caching strategy could help.
- **Support portrait mode,landscape left and landscape right mode:** The UI is mainly optimized for portrait mode, landscape left and landscape right mode.
- **Error Handling:** While the app displays error alerts, more sophisticated error recovery (like automatic retries) is not implemented.
