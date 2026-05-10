import 'package:app/core/utils/logger.dart';
import 'package:app/features/purchase/data/models.dart';
import 'package:app/features/purchase/data/shop_exceptions.dart';
import 'package:app/features/purchase/data/shop_repository.dart';
import 'package:flutter/foundation.dart';

class ShopCatalog extends ChangeNotifier {
  final ShopRepository _repo;

  ShopCatalog(this._repo);

  List<Succulents> _succulents = [];
  List<Pots> _pots = [];
  bool _isLoading = false;
  ShopException? _error;

  List<Succulents> get succulents => List.unmodifiable(_succulents);
  List<Pots> get pots => List.unmodifiable(_pots);
  bool get isLoading => _isLoading;
  ShopException? get error => _error;
  bool get hasData => _succulents.isNotEmpty || _pots.isNotEmpty;

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repo.fetchSucculents(),
        _repo.fetchPots(),
      ]);
      _succulents = results[0] as List<Succulents>;
      _pots = results[1] as List<Pots>;
      log.i('Catalog loaded: ${_succulents.length} succulents, ${_pots.length} pots');
    } on ShopException catch (e) {
      log.w('Catalog fetch failed: ${e.message}');
      _error = e;
    } catch (e, st) {
      log.e('Catalog unexpected error', error: e, stackTrace: st);
      _error = UnknownShopException(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() => fetchAll();
}