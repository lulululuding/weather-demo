import 'dart:async';
import 'package:flutter/material.dart';
import 'HourlyForecast.dart';
import 'dart:ui' as ui;

class Weather extends StatefulWidget {

  final List<HourlyForecast> hourlyList;//天气数据列表
  final String imagePath;//图片路径
  final EdgeInsetsGeometry padding;//padding
  final Size size;//大小
  final void Function(int index) onTapUp;//点击事件的回调方法

  Weather({this.hourlyList, this.imagePath, this.padding, this.size, this.onTapUp, Key key}) : super(key: key);

  @override
  _WeatherState createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {

  ui.Image iconDay;
  ui.Rect iconDayRect;
  ui.Image iconNight;
  ui.Rect iconNightRect;
  List<double> xList;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadImageByProvider(AssetImage('images/day.png')).then((ui.Image val){
      iconDay = val;
      iconDayRect = Rect.fromLTWH(0.0, 0.0, iconDay.width.toDouble(), iconDay.height.toDouble());
      setState(() {});
    });
    loadImageByProvider(AssetImage('images/night.png')).then((ui.Image val){
      iconNight = val;
      iconNightRect = Rect.fromLTWH(0.0, 0.0, iconNight.width.toDouble(), iconNight.height.toDouble());
      setState(() {});
    });
  }

  void areaListCallback(List<double> xList) {
    //print(xList);
    this.xList = xList;
  }

  void onTap(BuildContext context, TapUpDetails detail) {
    if (widget.onTapUp == null) return;
    RenderBox renderBox = context.findRenderObject();
    Offset localPosition = renderBox.globalToLocal(detail.globalPosition);
    widget.onTapUp(getIndex(localPosition));
  }

  int getIndex(Offset globalOffset) {
    int i = -1;
    double relativePositionX = globalOffset.dx - widget.padding.collapsedSize.width / 2;
    for (double a in xList) {
      i++;
      if (relativePositionX >= 0 && relativePositionX <= a) break;
    }
    return i;
  }

  @override
  Widget build(BuildContext context) {
    if ( iconDay == null || iconNight == null ) return Container();
    return GestureDetector(
      onTapUp: (TapUpDetails detail) {
        print('onTapUp');
        onTap(context, detail);
      },
      child: CustomSingleChildLayout(
        delegate: _SakaLayoutDelegate(widget.size, widget.padding),
        child: CustomPaint(
          painter: _HourlyForecastPaint(
            context,
            widget.hourlyList,
            widget.padding.deflateSize(widget.size),
            areaListCallback,
            imagePath: widget.imagePath,
            iconDay: iconDay,
            iconDayRect: iconDayRect,
            iconNight: iconNight,
            iconNightRect: iconNightRect
          ),
        ),
      ),
    );
  }
}

class _HourlyForecastPaint extends CustomPainter {

  final List<HourlyForecast> hourlyList;
  String imagePath;
  final BuildContext context;
  final Size deflatedSize;
  double tempTextSize = 10.0;
  double hourTextSize = 10.0;
  List<Offset> points;
  double increaseX;
  List<ui.Paragraph> tempTextList;
  List<ui.Paragraph> hourTextList;
  ui.ParagraphBuilder paragraphBuilder;
  ui.Image iconDay;
  ui.Image iconNight;
  ui.Rect iconDayRect;
  ui.Rect iconNightRect;
  Size iconSize = Size(20.0,20.0);
  static const double horizontalPadding = 7.0;
  static const Color color = ui.Color.fromARGB(148, 144,144, 170);
  final void Function(List<double> xList) areaListCallback;

  _HourlyForecastPaint(
    this.context,
    this.hourlyList,
    this.deflatedSize,
    this.areaListCallback,
    {
      imagePath,
      this.iconDay,
      this.iconDayRect,
      this.iconNight,
      this.iconNightRect
    }
  );

  ui.ParagraphBuilder initParagraphBuilder () {
    return ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: TextAlign.center,
        fontSize: 10.0,
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )
    )..pushStyle(
      ui.TextStyle(color: color, textBaseline: ui.TextBaseline.alphabetic)
    );
  }

  ui.Paragraph getTextParagraph (String tmp) {
    ui.ParagraphBuilder paragraphBuilder = initParagraphBuilder()..addText(tmp);
    return paragraphBuilder.build()..layout(ui.ParagraphConstraints(width:30.0));
  }

  void drawPoint(Canvas canvas) {
    canvas.save();
    canvas.translate(horizontalPadding, 0.0);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = ui.PaintingStyle.fill;
    final pointsPaint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..style = ui.PaintingStyle.fill
      ..strokeCap = ui.StrokeCap.round
      ..blendMode = BlendMode.exclusion;
    canvas.drawPoints(ui.PointMode.polygon, points, paint);
    canvas.drawPoints(ui.PointMode.points, points, pointsPaint);
    for (int i = 0; i < tempTextList.length; i++) {
      Offset point = points[i];
      // 这是在下方的文字
      canvas.drawParagraph(tempTextList[i], point - Offset(15.0, 20.0));
      // 这是在上面的文字
      canvas.drawParagraph(hourTextList[i], Offset(point.dx - 15, 0.0));
      canvas.drawImageRect(
        hourlyList[i].isDay ? iconDay : iconNight,
        hourlyList[i].isDay ? iconDayRect : iconNightRect,
        Offset(point.dx - iconSize.width / 2, this.hourTextSize + 10.0) & iconSize,
        paint
      );
    }
    canvas.restore();
  }

  init () {
    const double tmpBarMarginTop = 80.0;
    tempTextList = [];
    hourTextList = [];
    points = [];
    int highestTmp;
    int lowestTmp;
    increaseX = ( deflatedSize.width - 2 * horizontalPadding ) / ( hourlyList.length + 2 );
    hourlyList.forEach((HourlyForecast item){
      if (highestTmp == null || item.tmp > highestTmp) highestTmp = item.tmp;
      if (lowestTmp == null || item.tmp < lowestTmp) lowestTmp = item.tmp;
      tempTextList.add( getTextParagraph(item.tmp.toString()) );
      hourTextList.add( getTextParagraph(item.getHourTime()) );
    });
    final int tmpChange = highestTmp - lowestTmp;
    final usableHeight = deflatedSize.height - tmpBarMarginTop - 10.0;
    final double barSpace = tmpChange == 0 ? 0 : (deflatedSize.height - tmpBarMarginTop - 10.0) / ( highestTmp - lowestTmp );
    for (int i = 0; i < hourlyList.length; i++) {
      final double offsetY = barSpace == 0 ? usableHeight / 2 : tmpBarMarginTop + barSpace * ( highestTmp - hourlyList[i].tmp );
      points.add( Offset( 1.5 * i * increaseX , offsetY ) );
    }
    areaListCallback(points.map((point) => point.dx + increaseX ).toList());
  }

  @override
  void paint(Canvas canvas, Size size) {
    init();
    var rect = Offset.zero & size;
    canvas.clipRect(rect);//剪切画布
    drawPoint(canvas);//绘制点和折线和对应的数字、图标等
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

}

//通过ImageProvider读取Image
Future<ui.Image> loadImageByProvider(ImageProvider provider, { ImageConfiguration config = ImageConfiguration.empty}) async {
  Completer<ui.Image> completer = Completer<ui.Image>(); //完成的回调
  ImageStreamListener listener;
  ImageStream stream = provider.resolve(config); //获取图片流
  listener = ImageStreamListener((ImageInfo frame, bool sync) { //监听
    final ui.Image image = frame.image;
    completer.complete(image); //完成
    stream.removeListener(listener); //移除监听
  });
  stream.addListener(listener); //添加监听
  return completer.future; //返回
}

class _SakaLayoutDelegate extends SingleChildLayoutDelegate {
  final Size size;
  final EdgeInsetsGeometry padding;

  _SakaLayoutDelegate(this.size, this.padding)
      : assert(size != null),
        assert(padding != null);

  @override
  Size getSize(BoxConstraints constraints) {
    return size;
  }

  @override
  bool shouldRelayout(_SakaLayoutDelegate oldDelegate) {
    return this.size != oldDelegate.size;
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.tight(padding.deflateSize(size));
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset((size.width - childSize.width) / 2,
        (size.height - childSize.height) / 2);
  }
}