import 'package:flutter/material.dart';

class AlertBox extends StatelessWidget {
  String alertText;
  VoidCallback onYesPressed;
  AlertBox({required this.alertText, required this.onYesPressed});

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
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12)),
                        child: const Text(
                          "No",
                          style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: 16,
                              color: Colors.white),
                        ),
                      )),
                  TextButton(
                      onPressed: onYesPressed,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12)),
                        child: const Text(
                          "Yes",
                          style: TextStyle(
                              fontFamily: "Canela",
                              fontSize: 16,
                              color: Colors.white),
                        ),
                      ))
                ],
              ),
            ],
          ),
        ));
  }
}
