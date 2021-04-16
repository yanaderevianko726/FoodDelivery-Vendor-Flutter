import 'dart:convert';

import 'package:http/http.dart' as http;

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/statistic.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

Future<Stream<Statistic>> getStatistics() async {
  Map<String, dynamic> _queryParams = {};
  User _user = userRepo.currentUser.value;
  Uri uri = Helper.getUri('api/manager/dashboard/${_user.id}');
  _queryParams['api_token'] = _user.apiToken;

  uri = uri.replace(queryParameters: _queryParams);
  print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Statistic.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Statistic.fromJSON({}));
  }
}
