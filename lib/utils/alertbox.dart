import 'package:flutter/material.dart';

class AlertBox extends StatelessWidget {
  String alertText;
  String firstText;
  String secondText;
  VoidCallback onFirstPressed;
  VoidCallback? onSecondPressed;
  VoidCallback? thirdPressed;
  bool showCancel;
  AlertBox(
      {required this.alertText,
      required this.onFirstPressed,
      this.onSecondPressed,
      required this.firstText,
      required this.secondText,
      this.showCancel = false,
      this.thirdPressed});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: const BoxDecoration(color: Colors.transparent),
          height: 200,
          child: Column(
            children: [
              Text(
                "${alertText ?? ""}",
                style: TextStyle(
                    fontFamily: "Inter", fontSize: 18, color: Colors.white),
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: onSecondPressed,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          secondText.toString(),
                          style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: 16,
                              color: Colors.white),
                        ),
                      )),
                  TextButton(
                      onPressed: onFirstPressed,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          firstText.toString(),
                          style: TextStyle(
                              fontFamily: "Canela",
                              fontSize: 16,
                              color: Colors.white),
                        ),
                      )),
                  showCancel ?TextButton(
                      onPressed: thirdPressed,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                              fontFamily: "Canela",
                              fontSize: 16,
                              color: Colors.white),
                        ),
                      )) : Container()
                ],
              ),
            ],
          ),
        ));
  }
}
