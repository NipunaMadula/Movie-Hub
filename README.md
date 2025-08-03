# 🎬 Movie Hub

A beautifully animated Flutter application for discovering and managing your favorite movies using The Movie Database (TMDB) API.

## ✨ Features

### 🎭 **Core Functionality**
- **Movie Discovery**: Browse popular, now playing, top-rated, and upcoming movies
- **Real-time Search**: Search movies with debounced input for optimal performance
- **Favorites System**: Add/remove movies from favorites with persistent storage
- **Infinite Scroll**: Lazy loading with pagination for smooth browsing
- **Detailed View**: Comprehensive movie information with backdrop images

### 🌟 **Enhanced Animations**
- **Hero Animations**: Smooth transitions for movie posters and titles
- **Page Transitions**: Custom fade, slide, and scale transitions
- **Staggered Loading**: Sequential fade-in animations for movie grid
- **Smooth Navigation**: Platform-specific transition animations
- **Interactive Elements**: Animated buttons and loading states

### 🎯 **User Experience**
- **Comprehensive Error Handling**: Network-aware error messages
- **Offline Support**: Graceful handling of connection issues
- **Pull-to-Refresh**: Intuitive refresh mechanism
- **Responsive Design**: Optimized for different screen sizes
- **Visual Feedback**: Loading indicators and success/error states

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (2.18+)
- TMDB API Key

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/NipunaMadula/Movie-Hub.git
   cd Movie-Hub/movie_hub
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Key**
   - Create a `.env` file in the root directory
   - Add your TMDB API key:
     ```
     TMDB_API_KEY=your_api_key_here
     ```
   - Get your API key from [TMDB](https://www.themoviedb.org/settings/api)

4. **Run the application**
   ```bash
   flutter run
   ```

## 🏗️ Project Structure

```
lib/
├── main.dart                    # App entry point with global theme
├── models/
│   └── movie.dart              # Movie data model
├── screens/
│   ├── home_screen.dart        # Main screen with movie grid
│   ├── movie_detail_screen.dart # Detailed movie view
│   └── favorites_screen.dart   # Favorites management
├── services/
│   ├── api_service.dart        # TMDB API integration
│   └── favorites_service.dart  # Local storage for favorites
├── utils/
│   └── page_transitions.dart   # Custom page transition animations
└── widgets/
    └── fade_in_widget.dart     # Reusable animation widgets
```

## 🎨 Animation Features

### Hero Animations
- Movie posters smoothly transition between screens
- Titles maintain visual continuity during navigation
- Favorites icon animates during transitions

### Page Transitions
- **FadePageRoute**: Elegant fade transitions
- **SlidePageRoute**: Slide animations for favorites
- **ScalePageRoute**: Bouncy scale effect for movie details

### Staggered Animations
- Movie cards fade in sequentially (100ms intervals)
- Optimized for performance with visible-item staggering
- Smooth slide-up effects with customizable offsets

## 🔧 Technical Details

### Dependencies
- `flutter_dotenv`: Environment variable management
- `http`: API communication
- `shared_preferences`: Local data persistence
- `shimmer`: Loading skeleton animations

### API Integration
- **TMDB API v3**: Movie data source
- **Pagination**: Efficient data loading
- **Multiple Endpoints**: Popular, Now Playing, Top Rated, Upcoming
- **Search**: Real-time movie search with debouncing

### State Management
- **StatefulWidget**: Local state management
- **FuturesBuilder**: Async data handling
- **Shared Preferences**: Persistent favorites storage

### Performance Optimizations
- **Lazy Loading**: Infinite scroll with pagination
- **Image Caching**: Network image optimization
- **Debounced Search**: Reduced API calls
- **Efficient Animations**: 60fps performance targeting

## 📱 Screenshots

The app features a clean, modern design with:
- Grid-based movie layout
- Smooth category tabs (Popular → Now Playing → Top Rated → Upcoming)
- Comprehensive error handling with user-friendly messages
- Beautiful movie detail screens with backdrop images
- Persistent favorites with visual feedback

## 🎯 Future Enhancements

- [ ] Watchlist functionality
- [ ] Movie trailers integration
- [ ] User ratings and reviews
- [ ] Social sharing features
- [ ] Dark theme support
- [ ] Advanced filtering options

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [The Movie Database (TMDB)](https://www.themoviedb.org/) for providing the movie data API
- Flutter team for the amazing framework and animation capabilities
- The open-source community for inspiration and resources
