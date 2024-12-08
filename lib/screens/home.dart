import 'dart:math' as math;
import 'package:sahajsampark/screens/contact.dart';
import 'package:sahajsampark/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../utils/helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  bool permissionGranted = false;
  final TextEditingController searchController = TextEditingController();

  Future<void> setContacts() async {
    if (await FlutterContacts.requestPermission()) {
      final localContacts =
          await FlutterContacts.getContacts(withProperties: true);
      setState(() {
        permissionGranted = true;
        contacts = localContacts;
        filteredContacts = contacts;
      });
    }
  }

  void filterContacts(String query) {
    final results = contacts.where((contact) {
      final searchQuery = query.toLowerCase();
      final displayName = contact.displayName.toLowerCase();
      final phoneNumbers =
          contact.phones.map((phone) => phone.normalizedNumber).toList();
      return displayName.contains(searchQuery) ||
          phoneNumbers.any((element) => element.contains(searchQuery)) ||
          phoneNumbers
              .any((element) => element.contains(searchQuery.substring(1)));
    }).toList();

    setState(() {
      filteredContacts = results;
    });
  }

  void pushRandomContact() async {
    final int randomIndex = math.Random().nextInt(filteredContacts.length);
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ContactScreen(
        contact: filteredContacts[randomIndex],
        index: randomIndex,
        fromShuffle: true,
        pushRandomContact: pushRandomContact,
      );
    }));
  }

  @override
  initState() {
    setContacts();
    searchController.addListener(() {
      filterContacts(searchController.text);
    });
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!permissionGranted) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Please grant the contacts permissions to continue.\nIf the button does not work, please grant from app settings manually.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: setContacts,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
        floatingActionButton: FloatingActionButton(
            heroTag: 'random contact',
            shape: const CircleBorder(),
            tooltip: 'Choose a Random',
            onPressed: pushRandomContact,
            child: const Icon(Icons.shuffle_rounded)),
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Sahaj Sampark'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(64.0),
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search Contacts',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ),
        body: filteredContacts.isEmpty
            ? const Center(
                child: Text('No contacts found.'),
              )
            : ListView.builder(
                itemCount: filteredContacts.length,
                itemBuilder: (context, index) {
                  final contact = filteredContacts[index];
                  return ListTile(
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return ContactScreen(
                          contact: contact,
                          index: index,
                          fromShuffle: false,
                          pushRandomContact: pushRandomContact,
                        );
                      }));
                    },
                    trailing: const Icon(Icons.chevron_right_rounded),
                    leading: CircleAvatar(
                      backgroundColor:
                          colors[index % colors.length].withOpacity(1),
                      child: contact.photoOrThumbnail != null
                          ? Image.memory(contact.photoOrThumbnail!)
                          : Text(
                              contact.displayName[0],
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge!
                                  .copyWith(
                                    color: getContrastingTextColor(
                                        colors[index % colors.length]),
                                  ),
                            ),
                    ),
                    title: Text(contact.displayName),
                    subtitle: Text(
                      contact.phones.isNotEmpty
                          ? contact.phones
                              .firstWhere(
                                (phone) => phone.normalizedNumber.isNotEmpty,
                                orElse: () => contact.phones.first,
                              )
                              .normalizedNumber
                          : contact.emails.isNotEmpty
                              ? contact.emails
                                  .firstWhere(
                                    (email) => email.address.isNotEmpty,
                                    orElse: () => contact.emails.first,
                                  )
                                  .address
                              : 'No phone or email',
                    ),
                  );
                },
              ));
  }
}
