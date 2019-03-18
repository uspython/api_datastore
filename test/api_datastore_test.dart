import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:api_datastore/src/apiservice.dart';
import 'package:api_datastore/src/apisettings.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

void main() {
  setUp(() {
    // dio = new Dio();
    // dio.options.baseUrl = 'https://jsonplaceholder.typicode.com';
    // dio.options.headers = {'User-Agent': 'dartisan', 'XX': '8'};
    // dio.httpClientAdapter = MockAdapter();
    Intl.defaultLocale = "en Us";
    ApiSettings().baseUrl = 'https://jsonplaceholder.typicode.com';
    ApiSettings().connectTimeout = 10000;
    ApiSettings().receiveTimeout = 10000;
    ApiSettings().requestHeader = {
      HttpHeaders.userAgentHeader:
          'Qingbnb/0.1.6/en (iPhone10,6; iOS)12.1; ${Intl.defaultLocale}',
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.acceptEncodingHeader: 'gzip;q=1.0, compress;q=0.5',
      HttpHeaders.acceptLanguageHeader: '${Intl.defaultLocale};q=1.0',
      HttpHeaders.connectionHeader: 'keep-alive',
    };
  });
  group('ApiService', () {
    test('map<string, string> to query string', () {
      expect(ApiService.stringify({"foo": "test1", "bar": "test2"}),
          "?foo=test1&bar=test2");
      expect(ApiService.stringify({"foo": "test1"}), "?foo=test1");
      expect(ApiService.stringify({}), "");
      expect(ApiService.stringify(null), "");
    });

    test('get request without params', () async {
      Response response;
      response = await ApiService.get('/users/1');
      print(response);
      expect(response.statusCode.toString().startsWith("2"), true);
    });

    test('get request with params', () async {
      Response response;
      response = await ApiService.get('/posts', params: { 'userId': 1, 'id': 4 });
      print(response.data);
      expect(response.data[0]["title"], "eum et est occaecati");
    });

    test('get request with text encoding params', () async {
      Response response;
      response = await ApiService.get('/posts', params: { 'userId': 1, 'title': 'qui est esse' });
      print(response.data);
      expect(response.data[0]["title"], "qui est esse");
    });

    test('get request with chinese params', () async {
      Response response;
      response = await ApiService.get('/posts', params: { 'userId': 1, 'title': '测试' });
      print(response.data);
      expect((response.data as List).length, 0);
    });

    test('post data without params', () async {
      Response response;
      response = await ApiService.post('/posts');
      print(response.data);
      expect(response.data['id'], 101);
    });

    test('post data with params', () async {
      Response response;
      response = await ApiService.post('/posts', params: { 'title': "foo", 'body': '测试', 'userid': 1 });
      print(response.data);
      expect(response.data['id'], 101);
      expect(response.data['body'], '测试');
    });

    /*
    test('postFormData with FormData', () async {
      /// 此测试api不支持form data
      Response response;
      response = await ApiService.postForm('/posts', params: { 'title': "foo", 'body': '测试', 'userid': 1 });
      print(response.data);
      expect(response.data['id'], 101);
      expect(response.data['body'], '测试');
    });
    */

    test('put method', () async {
      Response response;
      response = await ApiService.put('/posts/1', params: { 'id': 1, 'title': 'foo', 'body': 'bar', 'userid': 1 });
      print(response.data);
      expect(response.data['id'], 1);
      expect(response.data['title'], 'foo');
    });

    test("delete method", () async {
      Response response;
      response = await ApiService.delete('/posts/1');
      print(response);
      expect(response.statusCode.toString().startsWith("2"), true);
    });

  });
}
