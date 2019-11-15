import 'package:flutter/material.dart';
import 'package:morea/morealayout.dart';
import 'dart:math' as math;

class MoreaLoading{
  AnimationController _loadingController;
  Animation<int> _loadingAnimation;
  AnimationController _controller;
  Animation _curve;
  Animation<double> _animation;
  List<String> _loadingList = [
    'Loading.',
    'Loading..',
    'Loading...',
    'Loading...'
  ];
  MoreaLoading(TickerProviderStateMixin page){
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: page,
    );
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _animation = Tween<double>(begin: -0.5, end: 18 * math.pi).animate(_curve)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });
    _controller.forward();
    _loadingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: page,
    )..repeat();
    _loadingAnimation = IntTween(begin: 0, end: 2).animate(_loadingController);
  }
  Widget loading(){
    return MoreaShadowContainer(
       child: new Center(
         child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AnimatedBuilder(
                      animation: _controller,
                      child: Image(
                          image: AssetImage('assets/icon/logo_loading.png')),
                      builder: (BuildContext context, Widget child) {
                        return Transform.rotate(
                          angle: _animation.value,
                          child: child,
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                    ),
                    AnimatedBuilder(
                      animation: _loadingController,
                      child: Text('Loading'),
                      builder: (BuildContext context, Widget child) {
                        return Text(
                          _loadingList[_loadingAnimation.value],
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Raleway',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                          textAlign: TextAlign.left,
                        );
                      },
                    )
                  ],
                ),
       )
              );
  }
  void dispose(){
    _controller.dispose();
    _loadingController.dispose();
  }
}