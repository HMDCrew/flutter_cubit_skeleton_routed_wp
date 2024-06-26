import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:products/products.dart';

import '../cache/local_store.dart';

part 'shop_state.dart';

class ShopCubit extends Cubit<ShopState> {
  final ProductsApi _api;
  final int pageSize;
  final LocalStore localStore;

  int currentPage;
  List shopProducts = [];
  ShopCubit(this._api, this.localStore, {this.pageSize = 10, this.currentPage = 1})
      : super(const ShopLoading());

  void onInit({required int page}) async =>
      shopProducts.isEmpty ? getProducts(page: currentPage) : false;

  void loadMoreProducts() async => getProducts(page: currentPage += 1);

  void getProducts({required int page}) async {
    currentPage = page;

    final pageResult = await _api.getAllProducts(
      page: page,
      pageSize: pageSize,
    );

    pageResult.isError ||
            pageResult.asValue == null ||
            pageResult.asValue!.value.isEmpty
        ? showError('no products found')
        : setPageData(pageResult.asValue!.value);
  }

  void search(int page, String query) async {
    final searchResults = await _api.findProducts(
      page: page,
      pageSize: pageSize,
      searchTerm: query,
    );

    searchResults.isError ||
            searchResults.asValue == null ||
            searchResults.asValue!.value.isEmpty
        ? showError('no products found')
        : setPageData(searchResults.asValue!.value);
  }

  void setPageData(List result) {
    shopProducts.addAll(result);
    emit(ShopLoaded(prods: shopProducts, page: currentPage));
  }

  void showError(String error) {
    emit(ErrorShop(error));
  }
}
