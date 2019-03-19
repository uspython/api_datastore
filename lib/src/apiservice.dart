/*
 * @Author: jeffzhao
 * @Date: 2019-03-17 12:08:06
 * @Last Modified by: jeffzhao
 * @Last Modified time: 2019-03-19 11:36:40
 * Copyright Zhaojianfei. All rights reserved.
 */
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'apisettings.dart';
import 'callback_options.dart';

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
//dio.interceptors..add(CookieManager(CookieJar()))..add(LogInterceptor());
//(dio.transformer as DefaultTransformer).jsonDecodeCallback = parseJson;

_parseAndDecode(String response) {
  return jsonDecode(response);
}

parseJson(String text) {
  return compute(_parseAndDecode, text);
}

class ApiService {
  /// Get method, [path] is url path, [params] is Map<String, dynamic>
  ///
  /// ```dart
  ///ApiService.get('/test', params: { 'foo': 'bar'});
  /// ```
  /// return a [Future<Response<T>>]
  static Future<Response<T>> get<T>(String path,
      {Map<String, dynamic> params, CallbackOptions callbacks}) {
    return _connect<T>(
      '$path${stringify(params)}',
      options: Options(method: "GET"),
      callbacks: callbacks ?? CallbackOptions.fromEmpty()
    );
  }

  /// Post method, [path] is url path, [params] is Map<String, dynamic>
  ///
  /// ```dart
  ///ApiService.post('/test', params: { 'foo': 'bar'});
  /// ```
  /// return a [Future<Response<T>>]
  static Future<Response<T>> post<T>(String path,
      {Map<String, dynamic> params, CallbackOptions callbacks}) {
    return _connect<T>(
      path,
      params: params,
      options: Options(
        method: "POST",
        contentType: ContentType.parse(
                "application/x-www-form-urlencoded; charset=utf-8"),
                sendTimeout: 60 * 1000
        ),
      callbacks: callbacks ?? CallbackOptions.fromEmpty()
      );
  }

  /// Post form data method, [path] is url path, [params] is Map<String, dynamic>
  ///
  /// ```dart
  ///ApiService.postForm('/test', params: { 'foo': 'bar'});
  /// ```
  /// return a [Future<Response<T>>]
  static Future<Response<T>> postForm<T>(String path,
      {Map<String, dynamic> params, CallbackOptions callbacks}) {
    final formData = FormData.from(params);
    return _connect<T>(
      path,
      params: formData,
      options: Options(method: 'POST', sendTimeout: 10 * 60 * 1000),
      callbacks: callbacks ?? CallbackOptions.fromEmpty()
    );
  }

  /// Put method, [path] is url path, [params] is Map<String, dynamic>
  ///
  /// ```dart
  ///ApiService.put('/test', params: { 'foo': 'bar'});
  /// ```
  /// return a [Future<Response<T>>]
  static Future<Response<T>> put<T>(String path,
      {Map<String, dynamic> params, CallbackOptions callbacks}) {
    return _connect<T>(path,
        params: params,
        options: Options(
          method: "PUT",
          sendTimeout: 10 * 60 * 1000,
          contentType: ContentType.parse("application/json; charset=UTF-8"),
        ),
        callbacks: callbacks ?? CallbackOptions.fromEmpty()
        );
  }

  /// Delete method, [path] is url path, [params] is Map<String, dynamic>
  ///
  /// ```dart
  ///ApiService.delete('/test');
  /// ```
  /// return a [Future<Response<T>>]
  static Future<Response<T>> delete<T>(String path, { CallbackOptions callbacks }) {
    return _connect<T>(path, callbacks: callbacks ?? CallbackOptions.fromEmpty());
  }

  static Future<Response<T>> _connect<T>(String path,
      {Map<String, dynamic> params, Options options, CallbackOptions callbacks}) {

    (dio.transformer as DefaultTransformer).jsonDecodeCallback = parseJson;
    // dio.interceptors.add(LogInterceptor(responseBody: false));
    dio.interceptors.addAll(callbacks.interceptors);
    return dio.request<T>(path, data: params, options: options);

  }

  /// Return a query string, [params] could be null
  static String stringify(Map<String, dynamic> params) {
    if ((params ?? {}).keys.length == 0) return "";

    final Map<String, String> p = Map.fromIterable(params.keys,
        key: ($0) => $0, value: ($0) => params[$0].toString());
    final outgoingUri = Uri(queryParameters: p);
    return outgoingUri.toString();
  }
}
