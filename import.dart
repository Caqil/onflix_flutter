import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';

class TMDBContentImporter {
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String tmdbBackdropBaseUrl = 'https://image.tmdb.org/t/p/w1280';

  // REPLACE WITH YOUR TMDB API KEY
  static const String tmdbApiKey = '41a602fdcf07f7e842050ed8ac718113';

  final PocketBase pb;
  final String pocketbaseUrl;

  // Category mapping from TMDB genres to your categories
  static const Map<int, String> genreToCategory = {
    28: 'action-adventure', // Action
    12: 'action-adventure', // Adventure
    16: 'kids-family', // Animation
    35: 'comedy', // Comedy
    80: 'crime-mystery', // Crime
    99: 'documentaries', // Documentary
    18: 'drama', // Drama
    10751: 'kids-family', // Family
    14: 'fantasy', // Fantasy
    36: 'drama', // History
    27: 'horror-thriller', // Horror
    10402: 'music-musicals', // Music
    9648: 'crime-mystery', // Mystery
    10749: 'romance', // Romance
    878: 'sci-fi', // Science Fiction
    10770: 'drama', // TV Movie
    53: 'horror-thriller', // Thriller
    10752: 'action-adventure', // War
    37: 'action-adventure', // Western
  };

  TMDBContentImporter({
    required this.pocketbaseUrl,
  }) : pb = PocketBase(pocketbaseUrl);

  // Main import method
  Future<void> importContent({
    int movieCount = 1,
    int tvShowCount = 1,
    bool includePopular = true,
    bool includeTopRated = true,
    bool includeUpcoming = true,
  }) async {
    try {
      // Authenticate with PocketBase
      await _authenticatePocketBase();

      // Get category mappings
      final categoryMap = await _getCategoryMappings();

      print('🎬 Starting TMDB content import...\n');

      if (includePopular) {
        await _importPopularMovies(movieCount ~/ 3, categoryMap);
        await _importPopularTVShows(tvShowCount ~/ 3, categoryMap);
      }

      if (includeTopRated) {
        await _importTopRatedMovies(movieCount ~/ 3, categoryMap);
        await _importTopRatedTVShows(tvShowCount ~/ 3, categoryMap);
      }

      if (includeUpcoming) {
        await _importUpcomingMovies(movieCount ~/ 3, categoryMap);
        await _importTrendingTVShows(tvShowCount ~/ 3, categoryMap);
      }

      print('🎉 Content import completed successfully!');
    } catch (error) {
      print('❌ Import failed: $error');
      rethrow;
    }
  }

  Future<void> _authenticatePocketBase() async {
    try {
      await pb.collection('_superusers').authWithPassword(
            'ganggasungain@gmail.com',
            'Aqswde!123',
          );
      print('✅ PocketBase authentication successful');
    } catch (error) {
      throw Exception('PocketBase authentication failed: $error');
    }
  }

  Future<Map<String, String>> _getCategoryMappings() async {
    try {
      final categories = await pb.collection('categories').getList();
      final Map<String, String> categoryMap = {};

      for (final category in categories.items) {
        categoryMap[category.data['slug']] = category.id;
      }

      print('✅ Retrieved ${categoryMap.length} categories');
      return categoryMap;
    } catch (error) {
      throw Exception('Failed to get categories: $error');
    }
  }

  // MOVIE IMPORTERS
  Future<void> _importPopularMovies(
      int count, Map<String, String> categoryMap) async {
    print('🎭 Importing popular movies...');
    await _importMoviesByEndpoint('movie/popular', count, categoryMap);
  }

  Future<void> _importTopRatedMovies(
      int count, Map<String, String> categoryMap) async {
    print('⭐ Importing top-rated movies...');
    await _importMoviesByEndpoint('movie/top_rated', count, categoryMap);
  }

  Future<void> _importUpcomingMovies(
      int count, Map<String, String> categoryMap) async {
    print('🔮 Importing upcoming movies...');
    await _importMoviesByEndpoint('movie/upcoming', count, categoryMap);
  }

  Future<void> _importMoviesByEndpoint(
      String endpoint, int count, Map<String, String> categoryMap) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$tmdbBaseUrl/$endpoint?api_key=$tmdbApiKey&language=en-US&page=1'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movies = data['results'] as List;

        for (int i = 0; i < count && i < movies.length; i++) {
          final movie = movies[i];
          await _createMovieContent(movie, categoryMap);
        }
      } else {
        throw Exception('TMDB API error: ${response.statusCode}');
      }
    } catch (error) {
      print('❌ Error importing movies from $endpoint: $error');
    }
  }

  // TV SHOW IMPORTERS
  Future<void> _importPopularTVShows(
      int count, Map<String, String> categoryMap) async {
    print('📺 Importing popular TV shows...');
    await _importTVShowsByEndpoint('tv/popular', count, categoryMap);
  }

  Future<void> _importTopRatedTVShows(
      int count, Map<String, String> categoryMap) async {
    print('⭐ Importing top-rated TV shows...');
    await _importTVShowsByEndpoint('tv/top_rated', count, categoryMap);
  }

  Future<void> _importTrendingTVShows(
      int count, Map<String, String> categoryMap) async {
    print('🔥 Importing trending TV shows...');
    await _importTVShowsByEndpoint('trending/tv/week', count, categoryMap);
  }

  Future<void> _importTVShowsByEndpoint(
      String endpoint, int count, Map<String, String> categoryMap) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$tmdbBaseUrl/$endpoint?api_key=$tmdbApiKey&language=en-US&page=1'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tvShows = data['results'] as List;

        for (int i = 0; i < count && i < tvShows.length; i++) {
          final tvShow = tvShows[i];
          await _createTVShowContent(tvShow, categoryMap);
        }
      } else {
        throw Exception('TMDB API error: ${response.statusCode}');
      }
    } catch (error) {
      print('❌ Error importing TV shows from $endpoint: $error');
    }
  }

  // CONTENT CREATORS
  Future<void> _createMovieContent(
      Map<String, dynamic> movieData, Map<String, String> categoryMap) async {
    try {
      // Get detailed movie info including cast and crew
      final detailsResponse = await http.get(
        Uri.parse(
            '$tmdbBaseUrl/movie/${movieData['id']}?api_key=$tmdbApiKey&append_to_response=credits,videos'),
      );

      if (detailsResponse.statusCode != 200) {
        print('❌ Failed to get details for movie: ${movieData['title']}');
        return;
      }

      final details = json.decode(detailsResponse.body);
      final credits = details['credits'];
      final videos = details['videos']['results'] as List;

      // Find trailer
      final trailer = videos.firstWhere(
        (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube',
        orElse: () => null,
      );

      // Map genres to categories
      final List<String> contentCategories = [];
      if (details['genres'] != null) {
        for (final genre in details['genres']) {
          final categorySlug = genreToCategory[genre['id']];
          if (categorySlug != null && categoryMap.containsKey(categorySlug)) {
            contentCategories.add(categoryMap[categorySlug]!);
          }
        }
      }

      // Prepare cast and crew data
      final cast = (credits['cast'] as List)
          .take(10)
          .map((actor) => {
                'name': actor['name'],
                'character': actor['character'],
                'order': actor['order'],
                'profile_path': actor['profile_path'],
              })
          .toList();

      final crew = (credits['crew'] as List)
          .where((member) => ['Director', 'Producer', 'Writer', 'Screenplay']
              .contains(member['job']))
          .take(5)
          .map((member) => {
                'name': member['name'],
                'job': member['job'],
                'department': member['department'],
              })
          .toList();

      // Create slug from title
      final slug = _createSlug(details['title']);

      // Check if content already exists
      final existingContent = await _checkContentExists(slug);
      if (existingContent) {
        print('⚠️  Movie already exists: ${details['title']}');
        return;
      }

      final contentData = {
        'title': details['title'],
        'slug': slug,
        'description': _generateRichDescription(details),
        'shortDescription': details['overview'] ?? '',
        'type': 'movie',
        'status': 'published',
        'releaseDate': details['release_date'],
        'duration': details['runtime'] ?? 0,
        'rating': _mapContentRating(details['adult']),
        'imdbRating': details['vote_average']?.toDouble() ?? 0.0,
        'imdbId': details['imdb_id'],
        'categories': contentCategories,
        'languages': _extractLanguages(details),
        'productionCountries': _extractCountries(details),
        'isFeatured': details['vote_average'] >= 8.0,
        'isTrending': details['popularity'] >= 50.0,
        'viewCount': (details['popularity'] * 1000).round(),
        'likesCount': (details['vote_count'] * 0.1).round(),
        'cast': cast,
        'crew': crew,
        'trailerUrl': trailer != null
            ? 'https://www.youtube.com/watch?v=${trailer['key']}'
            : null,
        'metadata': {
          'tmdbId': details['id'],
          'budget': details['budget'],
          'revenue': details['revenue'],
          'popularity': details['popularity'],
          'voteCount': details['vote_count'],
          'originalLanguage': details['original_language'],
          'originalTitle': details['original_title'],
          'adult': details['adult'],
          'homepage': details['homepage'],
        },
        'seoKeywords': _generateSEOKeywords(details),
      };

      final result = await pb.collection('content').create(body: contentData);
      print('✅ Created movie: ${details['title']} (ID: ${result.id})');

      // Download and attach images if available
      await _downloadAndAttachImages(
          result.id, details['poster_path'], details['backdrop_path']);
    } catch (error) {
      print('❌ Failed to create movie ${movieData['title']}: $error');
    }
  }

  Future<void> _createTVShowContent(
      Map<String, dynamic> tvData, Map<String, String> categoryMap) async {
    try {
      // Get detailed TV show info
      final detailsResponse = await http.get(
        Uri.parse(
            '$tmdbBaseUrl/tv/${tvData['id']}?api_key=$tmdbApiKey&append_to_response=credits,videos'),
      );

      if (detailsResponse.statusCode != 200) {
        print('❌ Failed to get details for TV show: ${tvData['name']}');
        return;
      }

      final details = json.decode(detailsResponse.body);
      final credits = details['credits'];
      final videos = details['videos']['results'] as List;

      // Find trailer
      final trailer = videos.firstWhere(
        (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube',
        orElse: () => null,
      );

      // Map genres to categories
      final List<String> contentCategories = [];
      if (details['genres'] != null) {
        for (final genre in details['genres']) {
          final categorySlug = genreToCategory[genre['id']];
          if (categorySlug != null && categoryMap.containsKey(categorySlug)) {
            contentCategories.add(categoryMap[categorySlug]!);
          }
        }
      }

      // Prepare cast and crew data
      final cast = (credits['cast'] as List)
          .take(10)
          .map((actor) => {
                'name': actor['name'],
                'character': actor['character'],
                'order': actor['order'],
                'profile_path': actor['profile_path'],
              })
          .toList();

      final crew = (credits['crew'] as List)
          .where((member) => [
                'Creator',
                'Executive Producer',
                'Producer',
                'Writer'
              ].contains(member['job']))
          .take(5)
          .map((member) => {
                'name': member['name'],
                'job': member['job'],
                'department': member['department'],
              })
          .toList();

      // Create slug from name
      final slug = _createSlug(details['name']);

      // Check if content already exists
      final existingContent = await _checkContentExists(slug);
      if (existingContent) {
        print('⚠️  TV show already exists: ${details['name']}');
        return;
      }

      final averageEpisodeRuntime =
          details['episode_run_time']?.isNotEmpty == true
              ? details['episode_run_time'][0]
              : 45;

      final contentData = {
        'title': details['name'],
        'slug': slug,
        'description': _generateRichDescription(details),
        'shortDescription': details['overview'] ?? '',
        'type': 'series',
        'status': details['status'] == 'Ended' ? 'published' : 'published',
        'releaseDate': details['first_air_date'],
        'duration': averageEpisodeRuntime,
        'rating': _mapTVRating(details),
        'imdbRating': details['vote_average']?.toDouble() ?? 0.0,
        'categories': contentCategories,
        'languages': _extractLanguages(details),
        'productionCountries': _extractCountries(details),
        'isFeatured': details['vote_average'] >= 8.0,
        'isTrending': details['popularity'] >= 50.0,
        'viewCount': (details['popularity'] * 1000).round(),
        'likesCount': (details['vote_count'] * 0.1).round(),
        'cast': cast,
        'crew': crew,
        'trailerUrl': trailer != null
            ? 'https://www.youtube.com/watch?v=${trailer['key']}'
            : null,
        'metadata': {
          'tmdbId': details['id'],
          'numberOfSeasons': details['number_of_seasons'],
          'numberOfEpisodes': details['number_of_episodes'],
          'popularity': details['popularity'],
          'voteCount': details['vote_count'],
          'originalLanguage': details['original_language'],
          'originalName': details['original_name'],
          'status': details['status'],
          'type': details['type'],
          'homepage': details['homepage'],
          'networks': details['networks']?.map((n) => n['name']).toList(),
          'seasons': details['seasons'],
        },
        'seoKeywords': _generateSEOKeywords(details),
      };

      final result = await pb.collection('content').create(body: contentData);
      print('✅ Created TV show: ${details['name']} (ID: ${result.id})');

      // Create series entry
      await _createSeriesEntry(result.id, details);

      // Download and attach images if available
      await _downloadAndAttachImages(
          result.id, details['poster_path'], details['backdrop_path']);
    } catch (error) {
      print('❌ Failed to create TV show ${tvData['name']}: $error');
    }
  }

  Future<void> _createSeriesEntry(
      String contentId, Map<String, dynamic> details) async {
    try {
      final seriesData = {
        'content': contentId,
        'totalSeasons': details['number_of_seasons'] ?? 1,
        'totalEpisodes': details['number_of_episodes'] ?? 1,
        'status': _mapSeriesStatus(details['status']),
        'firstAirDate': details['first_air_date'],
        'lastAirDate': details['last_air_date'],
        'network': details['networks']?.isNotEmpty == true
            ? details['networks'][0]['name']
            : 'Unknown',
      };

      await pb.collection('series').create(body: seriesData);
    } catch (error) {
      print('❌ Failed to create series entry: $error');
    }
  }

  // HELPER METHODS
  String _createSlug(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  Future<bool> _checkContentExists(String slug) async {
    try {
      final existing = await pb.collection('content').getList(
            filter: 'slug = "$slug"',
          );
      return existing.items.isNotEmpty;
    } catch (error) {
      return false;
    }
  }

  String _generateRichDescription(Map<String, dynamic> details) {
    final overview = details['overview'] ?? '';
    final genres = details['genres']?.map((g) => g['name']).join(', ') ?? '';
    final releaseYear = details['release_date']?.substring(0, 4) ??
        details['first_air_date']?.substring(0, 4) ??
        '';

    return '''
<p><strong>${details['title'] ?? details['name']}</strong> ($releaseYear)</p>
<p><em>Genres: $genres</em></p>
<p>$overview</p>
${details['tagline'] != null ? '<p><em>"${details['tagline']}"</em></p>' : ''}
    '''
        .trim();
  }

  String _mapContentRating(bool? adult) {
    return adult == true ? 'R' : 'PG-13';
  }

  String _mapTVRating(Map<String, dynamic> details) {
    // Simple mapping based on content
    final overview = (details['overview'] ?? '').toLowerCase();
    if (overview.contains('kids') || overview.contains('children'))
      return 'TV-Y7';
    if (overview.contains('family')) return 'TV-PG';
    return 'TV-14';
  }

  String _mapSeriesStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'ended':
      case 'canceled':
        return 'completed';
      case 'returning series':
        return 'ongoing';
      default:
        return 'ongoing';
    }
  }

  List<String> _extractLanguages(Map<String, dynamic> details) {
    final languages = <String>[];

    if (details['original_language'] != null) {
      languages.add(details['original_language']);
    }

    if (details['spoken_languages'] != null) {
      for (final lang in details['spoken_languages']) {
        if (lang['iso_639_1'] != null &&
            !languages.contains(lang['iso_639_1'])) {
          languages.add(lang['iso_639_1']);
        }
      }
    }

    return languages.take(5).toList();
  }

  String _extractCountries(Map<String, dynamic> details) {
    if (details['production_countries'] != null) {
      return (details['production_countries'] as List)
          .map((country) => country['name'])
          .join(', ');
    }
    return '';
  }

  List<String> _generateSEOKeywords(Map<String, dynamic> details) {
    final keywords = <String>[];

    // Add title words
    final title = details['title'] ?? details['name'] ?? '';
    keywords.addAll(title.toLowerCase().split(' '));

    // Add genres
    if (details['genres'] != null) {
      for (final genre in details['genres']) {
        keywords.add(genre['name'].toLowerCase());
      }
    }

    // Add year
    final year = details['release_date']?.substring(0, 4) ??
        details['first_air_date']?.substring(0, 4);
    if (year != null) keywords.add(year);

    return keywords.where((k) => k.isNotEmpty).take(10).toList();
  }

  Future<void> _downloadAndAttachImages(
      String recordId, String? posterPath, String? backdropPath) async {
    try {
      final Map<String, List<int>> filesToUpload = {};

      // Download poster image
      if (posterPath != null && posterPath.isNotEmpty) {
        final posterUrl = '$tmdbImageBaseUrl$posterPath';
        final posterBytes = await _downloadImage(posterUrl);
        if (posterBytes != null) {
          filesToUpload['posterImage'] = posterBytes;
          print('📸 Downloaded poster image');
        }
      }

      // Download backdrop image
      if (backdropPath != null && backdropPath.isNotEmpty) {
        final backdropUrl = '$tmdbBackdropBaseUrl$backdropPath';
        final backdropBytes = await _downloadImage(backdropUrl);
        if (backdropBytes != null) {
          filesToUpload['backdropImage'] = backdropBytes;
          print('📸 Downloaded backdrop image');
        }
      }

      // Upload images to PocketBase if we have any
      if (filesToUpload.isNotEmpty) {
        await _uploadImagesToPocketBase(
            recordId, filesToUpload, posterPath, backdropPath);
      }
    } catch (error) {
      print('❌ Failed to download/upload images for record $recordId: $error');
    }
  }

  Future<List<int>?> _downloadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print(
            '❌ Failed to download image from $imageUrl: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('❌ Error downloading image from $imageUrl: $error');
      return null;
    }
  }

  Future<void> _uploadImagesToPocketBase(
    String recordId,
    Map<String, List<int>> filesToUpload,
    String? posterPath,
    String? backdropPath,
  ) async {
    try {
      // PocketBase requires multipart form data for file uploads
      // We'll use the http package directly for file uploads

      for (final entry in filesToUpload.entries) {
        final fieldName = entry.key;
        final imageBytes = entry.value;

        // Get file extension and create filename
        String extension = 'jpg';
        String originalPath = '';

        if (fieldName == 'posterImage' && posterPath != null) {
          originalPath = posterPath;
          extension = posterPath.split('.').last.toLowerCase();
        } else if (fieldName == 'backdropImage' && backdropPath != null) {
          originalPath = backdropPath;
          extension = backdropPath.split('.').last.toLowerCase();
        }

        final filename =
            '${fieldName}_${DateTime.now().millisecondsSinceEpoch}.$extension';

        await _uploadSingleImage(recordId, fieldName, imageBytes, filename);
      }

      print(
          '✅ Successfully uploaded ${filesToUpload.length} image(s) to PocketBase for record $recordId');
    } catch (error) {
      print(
          '❌ Failed to upload images to PocketBase for record $recordId: $error');
    }
  }

  Future<void> _uploadSingleImage(String recordId, String fieldName,
      List<int> imageBytes, String filename) async {
    try {
      // Create multipart request
      final uri =
          Uri.parse('${pb.baseUrl}/api/collections/content/records/$recordId');
      final request = http.MultipartRequest('PATCH', uri);

      // Add authentication header
      final authToken = pb.authStore.token;
      if (authToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $authToken';
      }

      // Add the image file
      final multipartFile = http.MultipartFile.fromBytes(
        fieldName,
        imageBytes,
        filename: filename,
      );
      request.files.add(multipartFile);

      // Send the request
      final response = await request.send();

      if (response.statusCode == 200) {
        print('✅ Uploaded $fieldName successfully');
      } else {
        final responseBody = await response.stream.bytesToString();
        print(
            '❌ Failed to upload $fieldName: ${response.statusCode} - $responseBody');
      }
    } catch (error) {
      print('❌ Error uploading $fieldName: $error');
    }
  }
}

// Usage example:
void main() async {
  final importer = TMDBContentImporter(
    pocketbaseUrl: 'http://localhost:8090',
  );

  try {
    await importer.importContent(
      movieCount: 30, // Import 30 movies
      tvShowCount: 20, // Import 20 TV shows
      includePopular: true,
      includeTopRated: true,
      includeUpcoming: true,
    );
  } catch (e) {
    print('Import failed: $e');
  }
}
