// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:fm_proj/pages/homePage.dart';
// import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
//
// class ErrorH extends StatefulWidget {
//   const ErrorH({super.key});
//
//   @override
//   State<ErrorH> createState() => _ErrorHState();
// }
//
// class _ErrorHState extends State<ErrorH> {
//   bool connection = false;
//   StreamSubscription? _internetSub;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _internetSub = InternetConnection().onStatusChange.listen((event) {
//       switch (event) {
//         case InternetStatus.connected:
//           setState(() {
//             connection = true;
//           });
//           break;
//         case InternetStatus.disconnected:
//           setState(() {
//             connection = false;
//           });
//           break;
//         default:
//           setState(() {
//             connection = false;
//           });
//       }
//       print(event);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return !connection
//         ? Scaffold(
//             body: Container(
//               child: Center(
//                   child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.signal_cellular_connected_no_internet_0_bar,
//                     size: 30,
//                   ),
//                   Text("No Internet"),
//                 ],
//               )),
//             ),
//           )
//         : Homepage();
//   }
// }
