import 'package:flutter/material.dart';

class Pndtlist extends StatefulWidget {
  @override
  _LicenseListPageState createState() => _LicenseListPageState();
}

class _LicenseListPageState extends State<Pndtlist> {
  final List<Map<String, String>> licenses = [
    {
      "name": "Business License for Software Development Firm",
      "license number": "BL-2021-001"
    },
    {
      "name": "Medical Equipment Certification",
      "license number": "ME-2022-002"
    },
    {
      "name": "Environmental Safety Compliance",
      "license number": "ES-2023-003"
    },
    {
      "name": "ISO 9001:2015 Quality Management Certificate",
      "license number": "ISO-2020-004"
    },
    {
      "name": "Company Registration Certificate",
      "license number": "CR-2019-005"
    },
    {
      "name": "Cybersecurity Compliance License",
      "license number": "CS-2024-006"
    },
  ];

  List<Map<String, String>> filteredLicenses = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    filteredLicenses = licenses;
  }

  void filterSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredLicenses = licenses
          .where((license) =>
              license["name"]!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Filter Options",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.confirmation_number),
                title: const Text("Sort by License Number"),
                onTap: () {
                  setState(() {
                    filteredLicenses.sort((a, b) =>
                        a["license number"]!.compareTo(b["license number"]!));
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text("Sort by Name"),
                onTap: () {
                  setState(() {
                    filteredLicenses
                        .sort((a, b) => a["name"]!.compareTo(b["name"]!));
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Licenses"),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: filterSearch,
                      decoration: InputDecoration(
                        hintText: "Search Licenses...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(60),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[300],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.filter_list, size: 28),
                    onPressed: showFilterOptions,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: filteredLicenses.length,
                  itemBuilder: (context, index) {
                    return buildLicenseCard(
                      context,
                      filteredLicenses[index]["name"]!,
                      filteredLicenses[index]["license number"]!,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLicenseCard(
      BuildContext context, String name, String licenseNumber) {
    double cardWidth = MediaQuery.of(context).size.width * 0.48;

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.assignment,
                  color: Colors.blue,
                  size: 28,
                ),
              ),
              const Icon(Icons.more_vert, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: cardWidth - 24,
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "$licenseNumber",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
