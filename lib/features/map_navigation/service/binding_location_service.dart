import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/binding_location_api.dart';
import 'location_category_service.dart';

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

  List<BinderLocationData> convertToBinderDataList(
    Map<String, String> openidToNickname,
    Map<String, BindingLocationResult> locationResults,
  ) {
    final results = <BinderLocationData>[];
    for (final entry in locationResults.entries) {
      final openid = entry.key;
      final result = entry.value;
      final nickname = openidToNickname[openid] ?? '绑定者';
      if (result.isSuccess && result.location != null) {
        results.add(BinderLocationData(
          openid: openid,
          nickname: nickname,
          address: result.location!.address,
          lat: result.location!.latitude,
          lng: result.location!.longitude,
        ));
      }
    }
    return results;
  }
}

final bindingLocationServiceProvider = Provider<BindingLocationService>((ref) => BindingLocationService());