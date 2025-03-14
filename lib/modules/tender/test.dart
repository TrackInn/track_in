import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter UI',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Column(
        children: [
          // Blue Section (Top Part)
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.blue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20), // Add space to move the search bar lower
                // Search Bar Section
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search "Payments"',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                SizedBox(height: 16),
                // Balance Section (Centered)
                Center(
                  child: Column(
                    children: [
                      Text(
                        '\$20,000',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Available Balance',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      // Add Money Button (Centered)
                      ElevatedButton(
                        onPressed: () {},
                        child: Text('Add Money'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // White Section (Bottom Part)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Transaction Section
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Transactions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Transaction List
                  Expanded(
                    child: ListView(
                      children: [
                        TransactionItem('Spending', -500),
                        TransactionItem('Income', 3000),
                        TransactionItem('Bills', -800),
                        TransactionItem('Savings', 1000),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Navigation Bar
          BottomNavigationBar(
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.send), label: 'Send'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.request_page), label: 'Request'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance), label: 'Bank'),
            ],
            currentIndex: 0,
            selectedItemColor: Colors.blue,
            onTap: (index) {
              // Handle navigation
            },
          ),
        ],
      ),
    );
  }

  Widget TransactionItem(String title, int amount) {
    Color amountColor = amount < 0 ? Colors.red : Colors.green;
    return ListTile(
      title: Text(title),
      trailing: Text('\$${amount.abs()}', style: TextStyle(color: amountColor)),
    );
  }
}
