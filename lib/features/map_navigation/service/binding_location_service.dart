import '../core/binding_location_api.dart';

class BindingLocationService {
  final BindingLocationApi _api;

  BindingLocationService({BindingLocationApi? api}) : _api = api ?? BindingLocationApi();

  Future<BindingLocationResult> getBinderLocation(String partnerOpenid) async {
    return await _api.getBinderLocation(partnerOpenid);
  }

  Future<Map<String, BindingLocationResult>> getBinderLocations(
    List<String> partnerOpenids,
  ) async {
    return await _api.getBinderLocations(partnerOpenids);
  }
}

final bindingLocationService = BindingLocationService();