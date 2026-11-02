import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnlineOfflineSwitch extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  const OnlineOfflineSwitch({
    super.key,
    this.initialValue = true,
    required this.onChanged,
  });

  @override
  State<OnlineOfflineSwitch> createState() => _OnlineOfflineSwitchState();
}

class _OnlineOfflineSwitchState extends State<OnlineOfflineSwitch> {
  late bool isOnline;

  @override
  void initState() {
    super.initState();
    isOnline = widget.initialValue;
  }

  void toggleSwitch() {
    setState(() {
      isOnline = !isOnline;
    });
    widget.onChanged(isOnline);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleSwitch,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 80.w,
        height: 28.h,
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: Colors.green[700],
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 10),
            Text(
              isOnline ? "Online" : "Offline",
              style: TextStyle(
                color: Color(0xFF0B7317),
                fontWeight: FontWeight.bold,
              ),
            ),
            // CustomTextGradient(titile: isOnline ? "online" : "Offline,"),
          ],
        ),
      ),
    );
  }
}
