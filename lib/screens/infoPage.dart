import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:isro/models/user.dart';
import 'package:isro/providers/userProvider.dart';
import 'package:isro/screens/splashScreen.dart';
import 'package:isro/services/isroHelper.dart';
import 'package:isro/services/userOperations.dart';
import 'package:provider/provider.dart';

class Infopage extends StatefulWidget {
  const Infopage({super.key});

  @override
  State<Infopage> createState() => _InfopageState();
}

class _InfopageState extends State<Infopage> {
  UserClass? _user;
  UserClassOperations operations = UserClassOperations();
  IsroHelper isroHelper = IsroHelper();

  List<Map<String, dynamic>> satellites = [];
  List<Map<String, dynamic>> centres = [];
  List<Map<String, dynamic>> spacecrafts = [];

  // Pagination trackers
  int satelliteLimit = 5;
  int centreLimit = 5;
  int spacecraftLimit = 5;

  bool loading = true;

  void _getuserInformation() async {
    String userEmail =
        Provider.of<userProvider>(context, listen: false).email ?? '';

    UserClass? fetchedUser = await operations.getUser(userEmail);
    print(userEmail);

    if (fetchedUser != null) {
      setState(() {
        _user = fetchedUser;
      });
    } else {
      print("User not found!");
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
    _getuserInformation();
  }

  void getData() async {
    try {
      final data1 = await isroHelper.fetchSatellites();
      final data2 = await isroHelper.fetchCentres();
      final data3 = await isroHelper.fetchSpacecrafts();
      setState(() {
        satellites = data1;
        centres = data2;
        spacecrafts = data3;
        loading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        loading = false;
      });
    }
  }

  Widget buildHorizontalCards(List<Map<String, dynamic>> list, int limit) {
    final displayList = list.take(limit).toList();
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayList.length,
        itemBuilder: (context, index) {
          final item = displayList[index];

          // Get name/id separately
          final name = item['id'] ?? item['name'] ?? 'Unknown';

          // Filter out name/id from other fields
          final otherEntries = Map.of(item)
            ..remove('id')
            ..remove('name');

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 180,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      ...otherEntries.entries.map((entry) {
                        return Text(
                          "${entry.value}",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildVerticalCards(
      List<Map<String, dynamic>> list, int limit, IconData icon) {
    final displayList = list.take(limit).toList();
    return Column(
      children: displayList.map((item) {
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: Icon(icon, color: Colors.deepPurple),
            title: Text(item['name'] ?? 'Unknown'),
            subtitle: item.containsKey('Place')
                ? Text("${item['Place']} - ${item['State']}")
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget loadMoreButton(Function loadMoreFunc) {
    return TextButton(
      onPressed: () => setState(() => loadMoreFunc()),
      child: const Text("Load More"),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(
                        'https://www.shutterstock.com/image-vector/man-character-face-avatar-glasses-600nw-542759665.jpg'),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hey, ${_user?.userName ?? 'Explorer'}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Ready to explore ISRO?",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        // Clear user from provider
                        Provider.of<userProvider>(context, listen: false)
                            .removeValue();

                        // Sign out from Firebase
                        await FirebaseAuth.instance.signOut();

                        // Navigate to StartPage
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => StartPage()),
                          (route) => false,
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize
                            .min, // 👈 keeps Row only as wide as needed
                        children: [
                          Icon(Icons.logout, color: Colors.purple, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            "Log Out",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),

              // Customer Satellites
              const Text(
                "Customer Satellites",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple),
              ),
              const SizedBox(height: 8),
              buildHorizontalCards(satellites, satelliteLimit),
              if (satellites.length > satelliteLimit)
                loadMoreButton(() => satelliteLimit += 5),

              const SizedBox(height: 20),

              // Centres
              const Text(
                "Centres",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple),
              ),
              const SizedBox(height: 8),
              buildVerticalCards(centres, centreLimit, Icons.location_city),
              if (centres.length > centreLimit)
                loadMoreButton(() => centreLimit += 5),

              const SizedBox(height: 20),

              // Spacecrafts
              const Text(
                "Spacecrafts",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple),
              ),
              const SizedBox(height: 8),
              buildVerticalCards(
                  spacecrafts, spacecraftLimit, Icons.satellite_alt),
              if (spacecrafts.length > spacecraftLimit)
                loadMoreButton(() => spacecraftLimit += 5),
            ],
          ),
        ),
      ),
    );
  }
}
