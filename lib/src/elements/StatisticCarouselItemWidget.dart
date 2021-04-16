import 'package:flutter/material.dart';

import '../helpers/helper.dart';
import '../models/statistic.dart';

class StatisticCarouselItemWidget extends StatelessWidget {
  final double marginLeft;
  final Statistic statistic;

  StatisticCarouselItemWidget({Key key, this.marginLeft, this.statistic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsetsDirectional.only(start: this.marginLeft, end: 20, top: 25, bottom: 25),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 25),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(5)),
        boxShadow: [
          BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      width: 110,
      height: 130,
      child: Column(
        children: [
          if (statistic.description == "total_earning")
            Helper.getPrice(double.tryParse(statistic.value), context,
                style: Theme.of(context).textTheme.headline2.merge(
                      TextStyle(height: 1),
                    ))
          else
            Text(
              statistic.value,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline2.merge(TextStyle(height: 1)),
            ),
          SizedBox(height: 8),
          Text(
            Helper.of(context).trans(statistic.description),
            textAlign: TextAlign.center,
            maxLines: 3,
            style: Theme.of(context).textTheme.caption,
          )
        ],
      ),
    );
  }
}
