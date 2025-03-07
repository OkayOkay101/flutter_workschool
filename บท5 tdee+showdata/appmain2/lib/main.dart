import 'package:flutter/material.dart';

void main() {
  runApp(BmrTdeeCalculatorApp());
}

class BmrTdeeCalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BmrTdeeCalculator(),
    );
  }
}

class BmrTdeeCalculator extends StatefulWidget {
  @override
  _BmrTdeeCalculatorState createState() => _BmrTdeeCalculatorState();
}

class _BmrTdeeCalculatorState extends State<BmrTdeeCalculator> {
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  String gender = "male"; // Default gender
  String activityLevel = "1.2"; // Default activity level
  double? bmr;
  double? tdee;

  void calculateBmrTdee() {
    final int age = int.tryParse(ageController.text) ?? 0;
    final double weight = double.tryParse(weightController.text) ?? 0;
    final double height = double.tryParse(heightController.text) ?? 0;

    if (age > 0 && weight > 0 && height > 0) {
      setState(() {
        if (gender == "male") {
          bmr = 66 + (13.7 * weight) + (5 * height) - (6.8 * age);
        } else {
          bmr = 665 + (9.6 * weight) + (1.8 * height) - (4.7 * age);
        }
        tdee = bmr! * double.parse(activityLevel);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue,
                  child: Text(
                    'เปลี่ยนชี่อด้วย',//เปลี่ยนชี่อด้วย11111111111111111111111111111111111111111
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("เพศ : "),
                  Row(
                    children: [
                      Radio(
                        value: "male",
                        groupValue: gender,
                        onChanged: (value) {
                          setState(() {
                            gender = value.toString();
                          });
                        },
                      ),
                      Text("ชาย"),
                      Radio(
                        value: "female",
                        groupValue: gender,
                        onChanged: (value) {
                          setState(() {
                            gender = value.toString();
                          });
                        },
                      ),
                      Text("หญิง"),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'ป้อนอายุ',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'ป้อนน้ำหนัก (กก.)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'ป้อนส่วนสูง (ซม.)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: activityLevel,
                items: [
                  DropdownMenuItem(value: "1.2", child: Text("ไม่ออกกำลังกาย")),
                  DropdownMenuItem(
                      value: "1.375",
                      child: Text("ออกกำลังกายเบาๆ (1-3 วัน/สัปดาห์)")),
                  DropdownMenuItem(
                      value: "1.55",
                      child: Text("ออกกำลังกายปานกลาง (4-5 วัน/สัปดาห์)")),
                  DropdownMenuItem(
                      value: "1.7",
                      child: Text("ออกกำลังกายหนัก (6-7 วัน/สัปดาห์)")),
                  DropdownMenuItem(
                      value: "1.9", child: Text("นักกีฬา (วันละ 2 ครั้ง)")),
                ],
                onChanged: (value) {
                  setState(() {
                    activityLevel = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: "กิจกรรมที่ทำประจำวัน",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: calculateBmrTdee,
                  child: Text("คำนวณ", style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(height: 20),
              if (bmr != null && tdee != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("BMR : ${bmr!.toStringAsFixed(2)} cal"),
                    Text("TDEE : ${tdee!.toStringAsFixed(2)} cal"),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
