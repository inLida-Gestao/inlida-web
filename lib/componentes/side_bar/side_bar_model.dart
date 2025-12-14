import '/flutter_flow/flutter_flow_util.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'side_bar_widget.dart' show SideBarWidget;
import 'package:flutter/material.dart';

class SideBarModel extends FlutterFlowModel<SideBarWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for Carousel widget.
  CarouselSliderController? carouselController;
  int carouselCurrentIndex = 1;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
