import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/market_controller.dart';
import '../elements/CardWidget.dart';
import '../elements/EmptyMarketsWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../models/route_argument.dart';

class MarketsWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  MarketsWidget({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _MarketsWidgetState createState() => _MarketsWidgetState();
}

class _MarketsWidgetState extends StateMVC<MarketsWidget> {
  MarketController _con;

  _MarketsWidgetState() : super(MarketController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForMarkets();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
          onPressed: () => widget.parentScaffoldKey.currentState.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).myMarkets,
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _con.refreshMarkets,
        child: _con.markets.isEmpty
            ? EmptyMarketsWidget()
            : ListView.builder(
                shrinkWrap: true,
                primary: true,
                itemCount: _con.markets.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/Details',
                          arguments: RouteArgument(
                            id: _con.markets.elementAt(index).id,
                            heroTag: 'my_markets',
                          ));
                    },
                    child: CardWidget(market: _con.markets.elementAt(index), heroTag: 'my_markets'),
                  );
                },
              ),
      ),
    );
  }
}
