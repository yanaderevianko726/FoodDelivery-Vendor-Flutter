import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/order.dart';
import '../repository/order_repository.dart';

class OrderDetailsController extends ControllerMVC {
  Order order;
  double deliveryFee = 0.0;
  GlobalKey<ScaffoldState> scaffoldKey;

  OrderDetailsController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForOrder({String id, String message}) async {
    final Stream<Order> stream = await getOrder(id);
    stream.listen((Order _order) {
      setState(() => order = _order);
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

  Future<void> refreshOrder() async {
    listenForOrder(id: order.id, message: S.of(context).order_refreshed_successfuly);
  }

//  void doDeliveredOrder(Order _order) async {
//    deliveredOrder(_order).then((value) {
//      setState(() {
//        this.order.orderStatus.id = '5';
//      });
//      scaffoldKey?.currentState?.showSnackBar(SnackBar(
//        content: Text('The order deliverd successfully to client'),
//      ));
//    });
//  }
}
