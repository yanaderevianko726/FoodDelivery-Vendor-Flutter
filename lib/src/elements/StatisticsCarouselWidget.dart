import 'package:flutter/material.dart';

import '../elements/StatisticsCarouselLoaderWidget.dart';
import '../models/statistic.dart';
import 'StatisticCarouselItemWidget.dart';

class StatisticsCarouselWidget extends StatelessWidget {
  final List<Statistic> statisticsList;

  StatisticsCarouselWidget({Key key, this.statisticsList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return statisticsList.isEmpty
        ? StatisticsCarouselLoaderWidget()
        : Container(
            height: 190,
            color: Theme.of(context).primaryColor.withOpacity(0.7),
//            padding: EdgeInsets.symmetric(vertical: 30),
            child: ListView.builder(
              itemCount: statisticsList.length,
              itemBuilder: (context, index) {
                double _marginLeft = 0;
                (index == 0) ? _marginLeft = 20 : _marginLeft = 0;
                return StatisticCarouselItemWidget(
                  marginLeft: _marginLeft,
                  statistic: statisticsList.elementAt(index),
                );
              },
              scrollDirection: Axis.horizontal,
            ));
  }
}
