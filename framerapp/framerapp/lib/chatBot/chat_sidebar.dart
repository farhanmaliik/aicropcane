import 'package:flutter/material.dart';
import 'package:framerapp/utils/appcolors.dart';
import 'package:framerapp/views/homescreen/nearby_stores_screen.dart';
import 'package:provider/provider.dart';
import 'chat_provider.dart';
import 'location_service.dart';

class ChatSidebar extends StatefulWidget {
  const ChatSidebar({super.key});

  @override
  State<ChatSidebar> createState() => _ChatSidebarState();
}

class _ChatSidebarState extends State<ChatSidebar> {
  String location = 'Fetching Location';
  String locationCoordinates = '';
  bool isLocationEnabled = false;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    LocationService.getLocationStream().listen((locationName) {
      setState(() {
        if (locationName != "Location services disabled" &&
            locationName != "Permission denied" &&
            locationName != "Permission permanently denied" &&
            !locationName.startsWith("Error")) {
          location = locationName;
          isLocationEnabled = true;
        } else {
          location = locationName;
          isLocationEnabled = false;
        }
      });
    });

    LocationService.getDetailedLocation().then((details) {
      if (!details.containsKey('error')) {
        setState(() {
          locationCoordinates =
          "Lat: ${details['latitude']}, Long: ${details['longitude']}";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final List<String> chats = chatProvider.recentChat;

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Drawer(
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    const Icon(Icons.history, color: Colors.black, size: 20),
                    SizedBox(width: 4,),
                    const Expanded(
                      child: Text(
                        "Chat History",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ── Rounded "New Chat" button (height ≈ 30) ──
                    SizedBox(
                      height: 30,
                      child: FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),

                          ),
                        ),
                        child: const Text(
                          'New Chat',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close,
                            color: Colors.black, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── CHAT LIST ────────────────────────────────────────────
            chats.isEmpty
                ?  Expanded(
              child: Container(
                color: Colors.grey.shade200,
                child:
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "No previous chats",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),)
            )
                : Expanded(
              child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.chat_bubble_outline),
                    title: Text(chats[index]),
                    onTap: () => Navigator.pop(context),
                  );
                },
              ),
            ),

            // ── LOCATION FOOTER ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 24),
              color: Colors.grey.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.location_on_outlined,
                              color: Colors.black87, size: 24),
                          SizedBox(width: 8),
                          Text(
                            "Location",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isLocationEnabled
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check,
                              size: 14,
                              color: isLocationEnabled
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isLocationEnabled ? "Active" : "Inactive",
                              style: TextStyle(
                                fontSize: 12,
                                color: isLocationEnabled
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (isLocationEnabled)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check,
                                size: 16, color: Colors.green),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "Location enabled for local recommendations",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey.shade700),
                              ),
                            ),
                          ],
                        ),
                        if (locationCoordinates.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            locationCoordinates,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ],
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Location access denied.Please enable location in your browser settings.",
                            style: TextStyle(color: Colors.red.shade400, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Please enable location to get local recommendations", // ← your custom msg
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 14),

                  // ── NEARBY STORES BUTTON ─────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // close drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NearbyStoresScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.store_outlined, size: 18),
                      label: const Text('Find Nearby Agri Stores & Experts'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}