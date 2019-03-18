/*
 * @Author: jeffzhao
 * @Date: 2019-03-17 12:08:06
 * @Last Modified by:   jeffzhao
 * @Last Modified time: 2019-03-17 12:08:06
 * Copyright Zhaojianfei. All rights reserved.
 */
import 'dart:io';
import 'package:dio/dio.dart';
import 'apisettings.dart';

var dio = Dio(new BaseOptions(
  baseUrl: ApiSettings().baseUrl,
  connectTimeout: ApiSettings().connectTimeout,
  receiveTimeout: ApiSettings().receiveTimeout,
  headers: {
    HttpHeaders.userAgentHeader:
      ApiSettings().requestHeader[HttpHeaders.userAgentHeader],
    HttpHeaders.acceptHeader: 'application/json',
    HttpHeaders.acceptEncodingHeader: 'gzip;q=1.0, compress;q=0.5',
    HttpHeaders.acceptLanguageHeader:
      ApiSettings().requestHeader[HttpHeaders.acceptLanguageHeader],
    HttpHeaders.connectionHeader: 'keep-alive',
  },
  responseType: ResponseType.json,
));

class ApiService {
  /// Get method, [path] is url path, [params] is Map<String, dynamic>
  ///
  /// ```dart
  ///ApiService.get('/test', params: { 'foo': 'bar'});
  /// ```
  /// return a [Future<Response<T>>]
  static Future<Response<T>> get<T>(String path, { Map<String, dynamic> params }) {
    return dio.get<T>(path + stringify(params));
  }
  /// Post method, [path] is url path, [params] is Map<String, dynamic>
  ///
  /// ```dart
  ///ApiService.post('/test', params: { 'foo': 'bar'});
  /// ```
  /// return a [Future<Response<T>>]
  static Future<Response<T>> post<T>(String path, { Map<String, dynamic> params }) {
    return dio.post<T>(path, data: params, options: Options(
      contentType: ContentType.parse("application/x-www-form-urlencoded; charset=utf-8"),
      sendTimeout: 60 * 1000
    ));
  }
  /// Post form data method, [path] is url path, [params] is Map<String, dynamic>
  ///
  /// ```dart
  ///ApiService.postForm('/test', params: { 'foo': 'bar'});
  /// ```
  /// return a [Future<Response<T>>]
  static Future<Response<T>> postForm<T>(String path, { Map<String, dynamic> params }) {
    final formData = FormData.from(params);
    return dio.post<T>(path, data: formData, options: Options(
      sendTimeout: 10 * 60 * 1000
    ));
  }
  /// Put method, [path] is url path, [params] is Map<String, dynamic>
  ///
  /// ```dart
  ///ApiService.put('/test', params: { 'foo': 'bar'});
  /// ```
  /// return a [Future<Response<T>>]
  static Future<Response<T>> put<T>(String path, { Map<String, dynamic> params }) {
    return dio.put<T>(path, data: params, options: Options(
      sendTimeout: 10 * 60 * 1000,
      contentType: ContentType.parse("application/json; charset=UTF-8"),
    ));
  }
  /// Delete method, [path] is url path, [params] is Map<String, dynamic>
  ///
  /// ```dart
  ///ApiService.delete('/test');
  /// ```
  /// return a [Future<Response<T>>]
  static Future<Response<T>> delete<T>(String path) {
    return dio.delete<T>(path);
  }
  /// Return a query string, [params] could be null
  static String stringify(Map<String, dynamic> params) {
    if ((params ?? {}).keys.length == 0) return "";

    final Map<String, String>  p = Map.fromIterable(params.keys,
                                                    key: ($0) => $0,
                                                    value: ($0) => params[$0].toString());
    final outgoingUri = Uri(queryParameters: p);
    return outgoingUri.toString();
  }
}
