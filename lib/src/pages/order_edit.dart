import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/order_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/DrawerWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';

class OrderEditWidget extends StatefulWidget {
  final RouteArgument routeArgument;

  OrderEditWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _OrderEditWidgetState createState() {
    return _OrderEditWidgetState();
  }
}

class _OrderEditWidgetState extends StateMVC<OrderEditWidget> {
  OrderController _con;

  _OrderEditWidgetState() : super(OrderController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForOrder(id: widget.routeArgument.id, withDrivers: true);
    _con.listenForOrderStatus();
//    _con.listenForDrivers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      drawer: DrawerWidget(),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: FlatButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(S.of(context).confirmation),
                    content: Text("Would you please confirm if you want to save changes"),
                    actions: <Widget>[
                      // usually buttons at the bottom of the dialog
                      FlatButton(
                        textColor: Theme.of(context).focusColor,
                        child: new Text(S.of(context).confirm),
                        onPressed: () {
                          _con.doUpdateOrder(_con.order);
                        },
                      ),
                      FlatButton(
                        child: new Text(S.of(context).dismiss),
                        textColor: Theme.of(context).accentColor,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                });
          },
          padding: EdgeInsets.symmetric(vertical: 14),
          color: Theme.of(context).accentColor,
          shape: StadiumBorder(),
          child: Text(
            S.of(context).saveChanges,
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.headline6.merge(TextStyle(color: Theme.of(context).primaryColor)),
          ),
        ),
      ),
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Theme.of(context).hintColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          S.of(context).editOrder,
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[
          new ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor),
        ],
      ),
      body: _con.order == null
          ? CircularLoadingWidget(height: 400)
          : ListView(
              primary: true,
              shrinkWrap: false,
              children: [
                Container(
//                  margin: EdgeInsets.only(top: 95, bottom: 65),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.9),
                    boxShadow: [
                      BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    S.of(context).order_id + ": #${_con.order.id}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: Theme.of(context).textTheme.headline4,
                                  ),
                                  Text(
                                    _con.order.orderStatus.status,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                  Text(
                                    DateFormat('yyyy-MM-dd HH:mm').format(_con.order.dateTime),
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Helper.getPrice(Helper.getTotalOrdersPrice(_con.order), context, style: Theme.of(context).textTheme.headline4),
                                Text(
                                  _con.order.payment?.method ?? S.of(context).cash_on_delivery,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: Theme.of(context).textTheme.caption,
                                ),
                                Text(
                                  S.of(context).items + ':' + _con.order.productOrders?.length?.toString() ?? 0,
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                ExpansionTile(
                    tilePadding: EdgeInsets.symmetric(horizontal: 20),
//                    title: Text("Assign Delivery Boy"),
                    title: Text(S.of(context).orderStatus),
                    initiallyExpanded: true,
                    children: List.generate(_con.orderStatuses.length, (index) {
                      var _status = _con.orderStatuses.elementAt(index);
                      return RadioListTile(
                        dense: true,
                        groupValue: true,
                        controlAffinity: ListTileControlAffinity.trailing,
                        value: _con.order.orderStatus.id == _status.id,
                        onChanged: (value) {
                          setState(() {
                            _con.order.orderStatus = _status;
                          });
                        },
                        title: Text(
                          " " + _status.status,
                          style: Theme.of(context).textTheme.bodyText1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          maxLines: 1,
                        ),
                      );
                    })),
                ExpansionTile(
                    tilePadding: EdgeInsets.symmetric(horizontal: 20),
                    title: Text(S.of(context).assignDeliveryBoy),
                    initiallyExpanded: true,
                    children: List.generate(_con.drivers.length, (index) {
                      var _driver = _con.drivers.elementAt(index);
                      return RadioListTile(
                        dense: true,
                        groupValue: true,
                        controlAffinity: ListTileControlAffinity.trailing,
                        value: _con.order.driver.id == _driver.id,
                        onChanged: (value) {
                          setState(() {
                            _con.order.driver = _driver;
                          });
                        },
                        title: Text(
                          " " + _driver.name,
                          style: Theme.of(context).textTheme.bodyText1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          maxLines: 1,
                        ),
                      );
                    })),
                ExpansionTile(
                    tilePadding: EdgeInsets.symmetric(horizontal: 20),
                    childrenPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    title: Text(S.of(context).generalInformation),
                    initiallyExpanded: true,
                    children: [
                      TextField(
                        keyboardType: TextInputType.text,
                        onChanged: (String value) {
                          _con.order.hint = value;
                        },
                        controller: TextEditingController()..text = _con.order.hint,
                        cursorColor: Theme.of(context).accentColor,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: S.of(context).hint,
                          labelStyle: Theme.of(context).textTheme.headline5,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          contentPadding: EdgeInsets.all(18),
                          hintStyle: Theme.of(context).textTheme.caption,
                          hintText: S.of(context).insertAnAdditionalInformationForThisOrder,
                          border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        onChanged: (String value) {
                          _con.order.tax = double.tryParse(value);
                        },
                        controller: TextEditingController()..text = _con.order.tax.toString(),
                        cursorColor: Theme.of(context).accentColor,
                        decoration: InputDecoration(
                          labelText: S.of(context).tax,
                          labelStyle: Theme.of(context).textTheme.headline5,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          contentPadding: EdgeInsets.all(18),
                          hintStyle: Theme.of(context).textTheme.caption,
                          hintText: S.of(context).insertAnAdditionalInformationForThisOrder,
                          border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        onChanged: (String value) {
                          _con.order.deliveryFee = double.tryParse(value);
                        },
                        controller: TextEditingController()..text = _con.order.deliveryFee.toString(),
                        cursorColor: Theme.of(context).accentColor,
                        decoration: InputDecoration(
                          labelText: S.of(context).delivery_fee,
                          labelStyle: Theme.of(context).textTheme.headline5,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          contentPadding: EdgeInsets.all(18),
                          hintStyle: Theme.of(context).textTheme.caption,
                          hintText: S.of(context).insertAnAdditionalInformationForThisOrder,
                          border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                        ),
                      ),
                      SizedBox(height: 20),
                    ]),
              ],
            ),
    );
  }
}
