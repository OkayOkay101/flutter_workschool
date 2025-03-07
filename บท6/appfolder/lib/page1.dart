import 'package:flutter/material.dart';

import 'page2.dart';

class PageOne extends StatelessWidget {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailNameController = TextEditingController();
  final TextEditingController phoneNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page one'),),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(labelText: 'ชื่อ :' ),
            ),
             TextField(
              controller: lastNameController,
              decoration: InputDecoration(labelText: 'นามสกุล : '),
            ),
             TextField(
              controller: emailNameController,
              decoration: InputDecoration(labelText: 'อีเมล : '),
              keyboardType: TextInputType.emailAddress,
            ),
             TextField(
              controller: phoneNameController,
              decoration: InputDecoration(labelText: 'เบอร์โทร : '),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 30,),
            ElevatedButton(onPressed: () {
              //สร้างข้อมูลที่จะส่ง
              Map<String, String> data = {
                'firstName' : firstNameController.text,
                'lastName' : lastNameController.text,
                'email' : emailNameController.text,
                'phone' : phoneNameController.text,
              };

              //ส่งข้อมูลไปยัง PageTwo
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => PageTwo(data: data)));
            }, 
            child: Text(
              'ส่งข้อมูล',
              style: TextStyle(fontSize: 20, color: Colors.pinkAccent),
            ))
          ],
        ),
      ),
    );
  }
}