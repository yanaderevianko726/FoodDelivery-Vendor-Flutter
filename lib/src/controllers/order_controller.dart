import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/route_argument.dart';
import '../models/statistic.dart';
import '../models/user.dart';
import '../repository/dashboard_repository.dart';
import '../repository/order_repository.dart';
import '../repository/user_repository.dart';

class OrderController extends ControllerMVC {
  Order order;
  List<Order> orders = <Order>[];
  List<OrderStatus> orderStatuses = <OrderStatus>[];
  List<User> drivers = <User>[];
  List<String> selectedStatuses;
  List<Statistic> statistics = <Statistic>[];
  GlobalKey<ScaffoldState> scaffoldKey;

  OrderController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForStatistics({String message}) async {
    final Stream<Statistic> stream = await getStatistics();
    stream.listen((Statistic _stat) {
      setState(() {
        statistics.add(_stat);
      });
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {});
  }

  void listenForOrderStatus({String message, bool insertAll}) async {
    final Stream<OrderStatus> stream = await getOrderStatuses();
    stream.listen((OrderStatus _orderStatus) {
      setState(() {
        orderStatuses.add(_orderStatus);
      });
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (insertAll != null && insertAll) {
        orderStatuses.insert(0, new OrderStatus.fromJSON({'id': '0', 'status': context != null ? S.of(context).all : ''}));
      }
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void listenForDrivers({String message}) async {
    final Stream<User> stream = await getDriversOfMarket(this.order?.productOrders[0]?.product?.market?.id ?? '0');
    stream.listen((User _driver) {
      setState(() {
        drivers.add(_driver);
      });
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void listenForOrders({statusesIds, String message}) async {
    final Stream<Order> stream = await getOrders(statusesIds: statusesIds);
    stream.listen((Order _order) {
      setState(() {
        orders.add(_order);
      });
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void listenForOrder({String id, String message, bool withDrivers = false}) async {
    final Stream<Order> stream = await getOrder(id);
    stream.listen((Order _order) {
      setState(() => order = _order);
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      selectedStatuses = [order.orderStatus.id];
      if (withDrivers) {
        listenForDrivers();
      }
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  Future<void> selectStatus(List<String> statusesIds) async {
    orders.clear();
    listenForOrders(statusesIds: statusesIds);
  }

  Future<void> refreshOrder() async {
    listenForOrder(id: order.id, message: S.of(context).order_refreshed_successfuly);
  }

  Future<void> refreshOrders() async {
    orders.clear();
    statistics.clear();
    listenForStatistics();
    listenForOrders(statusesIds: selectedStatuses, message: S.of(context).order_refreshed_successfuly);
  }

  void doUpdateOrder(Order _order) async {
    updateOrder(_order).then((value) {
      Navigator.of(context).pushNamed('/OrderDetails', arguments: RouteArgument(id: order.id));
//      FocusScope.of(context).unfocus();
//      setState(() {
//        this.order.orderStatus.id = '5';
//      });
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).thisOrderUpdatedSuccessfully),
      ));
    });
  }

  void doCancelOrder(Order order) {
    cancelOrder(order).then((value) {
      setState(() {
        order.active = false;
      });
    }).catchError((e) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(e),
      ));
    }).whenComplete(() {
      //refreshOrders();
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).orderIdHasBeenCanceled(order.id)),
      ));
    });
  }
}
