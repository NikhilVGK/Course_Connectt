import 'package:flutter/foundation.dart';
import '../services/recommendation_service.dart';
import '../models/recommendation_response.dart';

class RecommendationProvider with ChangeNotifier {
  final RecommendationService _service = RecommendationService();
  RecommendationResponse? _recommendation;
  bool _isLoading = false;
  String? _error;

  RecommendationResponse? get recommendation => _recommendation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getRecommendations(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recommendation = await _service.getRecommendations(query);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _recommendation = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _recommendation = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}