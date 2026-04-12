import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../config/cloudbase_config.dart';
import '../../utils/logger.dart';

/// Hello World 云函数测试页面
///
/// 演示 Flutter 前端如何通过 HTTP API 调用 CloudBase 云函数
class HelloApiTestPage extends StatefulWidget {
  const HelloApiTestPage({super.key});

  @override
  State<HelloApiTestPage> createState() => _HelloApiTestPageState();
}

class _HelloApiTestPageState extends State<HelloApiTestPage> {
  String _result = '点击按钮调用 hello-api 云函数';
  bool _isLoading = false;
  final Dio _dio = Dio();

  /// 调用 hello-api 云函数
  Future<void> _callHelloApi() async {
    setState(() {
      _isLoading = true;
      _result = '正在请求...';
    });

    try {
      // 构造云函数 HTTP 访问 URL
      // 格式：https://{envId}.service.tcloudbase.com/{函数名}/{路由路径}
      final url =
          'https://${CloudBaseConfig.envId}.service.tcloudbase.com/hello-api/hello';

      Logs.network.info('🌐 请求 hello-api: GET $url');

      final response = await _dio.get<Map<String, dynamic>>(url);

      Logs.network.info('✅ hello-api 响应: ${response.data}');

      setState(() {
        _result = '请求成功！\n\n'
            '状态码: ${response.statusCode}\n'
            '响应数据:\n${_formatJson(response.data)}';
      });
    } on DioException catch (e) {
      Logs.network.info('❌ hello-api 请求失败: ${e.message}');
      setState(() {
        _result = '请求失败！\n\n'
            '错误类型: ${e.type}\n'
            '错误信息: ${e.message}\n'
            '状态码: ${e.response?.statusCode}\n'
            '响应: ${e.response?.data}';
      });
    } catch (e) {
      Logs.network.info('❌ 未知错误: $e');
      setState(() {
        _result = '未知错误: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 调用健康检查端点
  Future<void> _callHealthCheck() async {
    setState(() {
      _isLoading = true;
      _result = '正在请求健康检查...';
    });

    try {
      final url =
          'https://${CloudBaseConfig.envId}.service.tcloudbase.com/hello-api/health';

      Logs.network.info('🌐 请求健康检查: GET $url');

      final response = await _dio.get<Map<String, dynamic>>(url);

      setState(() {
        _result = '健康检查成功！\n\n'
            '状态码: ${response.statusCode}\n'
            '响应数据:\n${_formatJson(response.data)}';
      });
    } on DioException catch (e) {
      setState(() {
        _result = '健康检查失败！\n\n'
            '错误: ${e.message}\n'
            '响应: ${e.response?.data}';
      });
    } catch (e) {
      setState(() {
        _result = '未知错误: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatJson(Map<String, dynamic>? data) {
    if (data == null) return 'null';
    return data.entries.map((e) => '  ${e.key}: ${e.value}').join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('云函数调用测试'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 说明卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '调用原理',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Flutter 通过 HTTP 请求访问 CloudBase 云函数:\n'
                      'URL: https://{envId}.service.tcloudbase.com/{函数名}/{路径}\n'
                      '函数名: hello-api\n'
                      '环境: ${CloudBaseConfig.envId}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _callHelloApi,
                    icon: const Icon(Icons.waving_hand),
                    label: const Text('调用 Hello API'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _callHealthCheck,
                    icon: const Icon(Icons.health_and_safety),
                    label: const Text('健康检查'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 结果显示区域
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '响应结果',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          if (_isLoading)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: SelectableText(
                            _result,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
