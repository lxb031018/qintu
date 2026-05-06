// 路由模型 - 重新导出拆分后的子模块
// 注意：此文件保持向后兼容，所有内容已拆分到以下文件：
// - route_segment_models.dart: 路段/步骤模型（TransitSegment, WalkStep, DriveStep 等）
// - route_option_model.dart: 路线选项模型（RouteOption, RoutingException）

export 'route_segment_models.dart';
export 'route_option_model.dart';
export 'package:qintu/models/location/lat_lng.dart';