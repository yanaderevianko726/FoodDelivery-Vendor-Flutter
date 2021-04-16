import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

Future<Stream<Order>> getOrders({List<String> statusesIds}) async {
  Uri uri = Helper.getUri('api/orders');
  Map<String, dynamic> _queryParams = {};
  User _user = userRepo.currentUser.value;

  _queryParams['api_token'] = _user.apiToken;
  _queryParams['with'] = 'productOrders;productOrders.product;productOrders.options;orderStatus;deliveryAddress;payment';
  _queryParams['orderBy'] = 'id';
  _queryParams['sortedBy'] = 'asc';

  if (statusesIds != null && statusesIds.isNotEmpty) {
    _queryParams['statuses[]'] = statusesIds;
  }
  uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Order.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Order.fromJSON({}));
  }
}

Future<Stream<Order>> getNearOrders(Address myAddress, Address areaAddress) async {
  Uri uri = Helper.getUri('api/orders');
  Map<String, dynamic> _queryParams = {};
  User _user = userRepo.currentUser.value;

  _queryParams['api_token'] = _user.apiToken;
  _queryParams['limit'] = '6';
  _queryParams['with'] = 'productOrders;productOrders.product;productOrders.options;orderStatus;deliveryAddress;payment';
  _queryParams['search'] = 'delivery_address_id:null';
  _queryParams['searchFields'] = 'delivery_address_id:<>';
  _queryParams['orderBy'] = 'id';
  _queryParams['sortedBy'] = 'desc';
  uri = uri.replace(queryParameters: _queryParams);

  //final String url = '${GlobalConfiguration().getValue('api_base_url')}orders?${_apiToken}with=driver;productOrders;productOrders.product;productOrders.options;orderStatus;deliveryAddress&search=driver.id:${_user.id};order_status_id:$orderStatusId&searchFields=driver.id:=;order_status_id:=&searchJoin=and&orderBy=id&sortedBy=desc';
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Order.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Order.fromJSON({}));
  }
}

Future<Stream<Order>> getOrdersHistory() async {
  Uri uri = Helper.getUri('api/orders');
  Map<String, dynamic> _queryParams = {};
  final String orderStatusId = "5"; // for delivered status
  User _user = userRepo.currentUser.value;

  _queryParams['api_token'] = _user.apiToken;
  _queryParams['with'] = 'driver;productOrders;productOrders.product;productOrders.options;orderStatus;deliveryAddress;payment';
  _queryParams['search'] = 'driver.id:${_user.id};order_status_id:$orderStatusId;delivery_address_id:null';
  _queryParams['searchFields'] = 'driver.id:=;order_status_id:=;delivery_address_id:<>';
  _queryParams['searchJoin'] = 'and';
  _queryParams['orderBy'] = 'id';
  _queryParams['sortedBy'] = 'desc';
  uri = uri.replace(queryParameters: _queryParams);

  //final String url = '${GlobalConfiguration().getString('api_base_url')}orders?${_apiToken}with=driver;productOrders;productOrders.product;productOrders.options;orderStatus;deliveryAddress&search=driver.id:${_user.id};order_status_id:$orderStatusId&searchFields=driver.id:=;order_status_id:=&searchJoin=and&orderBy=id&sortedBy=desc';
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Order.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Order.fromJSON({}));
  }
}

Future<Stream<Order>> getOrder(orderId) async {
  Uri uri = Helper.getUri('api/orders/$orderId');
  Map<String, dynamic> _queryParams = {};
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Stream.value(new Order());
  }

  _queryParams['api_token'] = _user.apiToken;
  _queryParams['with'] = 'driver;user;productOrders;productOrders.product;productOrders.options;orderStatus;deliveryAddress;payment';
  uri = uri.replace(queryParameters: _queryParams);
  print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getObjectData(data)).map((data) {
      return Order.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Order.fromJSON({}));
  }
}

Future<Stream<Order>> getRecentOrders() async {
  Uri uri = Helper.getUri('api/orders');
  Map<String, dynamic> _queryParams = {};
  User _user = userRepo.currentUser.value;

  _queryParams['api_token'] = _user.apiToken;
  _queryParams['limit'] = '4';
  _queryParams['with'] = 'driver;productOrders;productOrders.product;productOrders.options;orderStatus;deliveryAddress;payment';
  _queryParams['search'] = 'driver.id:${_user.id};delivery_address_id:null';
  _queryParams['searchFields'] = 'driver.id:=;delivery_address_id:<>';
  _queryParams['searchJoin'] = 'and';
  _queryParams['orderBy'] = 'id';
  _queryParams['sortedBy'] = 'desc';
  uri = uri.replace(queryParameters: _queryParams);

  //final String url = '${GlobalConfiguration().getString('api_base_url')}orders?${_apiToken}with=driver;productOrders;productOrders.product;productOrders.options;orderStatus;deliveryAddress&search=driver.id:${_user.id};order_status_id:$orderStatusId&searchFields=driver.id:=;order_status_id:=&searchJoin=and&orderBy=id&sortedBy=desc';
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Order.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Order.fromJSON({}));
  }
}

Future<Stream<OrderStatus>> getOrderStatuses() async {
  Uri uri = Helper.getUri('api/order_statuses');
  Map<String, dynamic> _queryParams = {};
  User _user = userRepo.currentUser.value;

  _queryParams['api_token'] = _user.apiToken;
  _queryParams['orderBy'] = 'id';
  _queryParams['sortedBy'] = 'asc';
  _queryParams['filter'] = 'id;status';
  uri = uri.replace(queryParameters: _queryParams);

  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return OrderStatus.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(OrderStatus.fromJSON({}));
  }
}

Future<Order> updateOrder(Order order) async {
  Uri uri = Helper.getUri('api/orders/${order.id}');
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Order();
  }
  Map<String, dynamic> _queryParams = {};
  _queryParams['api_token'] = _user.apiToken;
  uri = uri.replace(queryParameters: _queryParams);

  //final String url = '${GlobalConfiguration().getString('api_base_url')}orders/${order.id}?$_apiToken';
  final client = new http.Client();
  final response = await client.put(
    uri.toString(),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(order.editableMap()),
  );
  return Order.fromJSON(json.decode(response.body)['data']);
}

Future<Order> cancelOrder(Order order) async {
  Uri uri = Helper.getUri('api/orders/${order.id}');
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Order();
  }
  Map<String, dynamic> _queryParams = {};
  _queryParams['api_token'] = _user.apiToken;
  uri = uri.replace(queryParameters: _queryParams);

  //final String url = '${GlobalConfiguration().getString('api_base_url')}orders/${order.id}?$_apiToken';
  final client = new http.Client();
  final response = await client.put(
    uri.toString(),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(order.cancelMap()),
  );
  return Order.fromJSON(json.decode(response.body)['data']);
}
