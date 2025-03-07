import 'package:flutter/material.dart';

class PageTwo extends StatelessWidget {
 final Map<String, String> data;

 PageTwo({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page two'),),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text('ชื่อ :${data['firstName']}',
            style: TextStyle(fontSize: 18, color: Colors.blueGrey),),

            Text('นามสกุล :${data['lastName']}',
            style: TextStyle(fontSize: 18, color: Colors.blueGrey),),

            Text('Email :${data['email']}',
            style: TextStyle(fontSize: 18, color: Colors.blueGrey),),

            Text('เบอร์โทร :${data['phone']}',
            style: TextStyle(fontSize: 18, color: Colors.blueGrey),),
          ],
        ),
        ),

    );
  }
}