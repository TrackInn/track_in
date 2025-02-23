import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Tenderlist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TenderScreen(),
    );
  }
}

class TenderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total EMD",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    SizedBox(height: 5),
                    Text("Count: 2431",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Total Amount:",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                            Text("\$62,745",
                                style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Pending Amount:",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                            Text("\$12,500",
                                style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Filter Option
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.filter_alt_rounded, color: Colors.white),
                  label: Text("Filter", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    shadowColor: Colors.black45,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    tenderlistitem("Yulia Polishchuk", "19 October 15:58",
                        "\$2351.00", Colors.green),
                    tenderlistitem("Youtube Music", "21 October 19:20",
                        "\$5.50", Colors.red),
                    tenderlistitem("Bogdan Nikitin", "02 Minutes Ago",
                        "\$61.00", Colors.red),
                    tenderlistitem(
                        "iTunes", "14 September 12:25", "\$3.50", Colors.green),
                    tenderlistitem("Easy Pay", "12 October 17:10", "\$15.00",
                        Colors.green),
                    tenderlistitem("Yulia Polishchuk", "19 October 15:58",
                        "\$2351.00", Colors.red),
                    tenderlistitem("Youtube Music", "21 October 19:20",
                        "\$5.50", Colors.red),
                    tenderlistitem("Bogdan Nikitin", "02 Minutes Ago",
                        "\$61.00", Colors.green),
                    tenderlistitem(
                        "iTunes", "14 September 12:25", "\$3.50", Colors.red),
                    tenderlistitem(
                        "Easy Pay", "12 October 17:10", "\$15.00", Colors.red),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tenderlistitem(String title, String date, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 1,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: ListTile(
          tileColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(Icons.attach_money, color: color),
          ),
          title: Text(title, style: TextStyle(color: Colors.black)),
          subtitle: Text(date, style: TextStyle(color: Colors.black38)),
          trailing: Text(amount,
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
