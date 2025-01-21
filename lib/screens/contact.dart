import 'dart:developer';

import 'package:sahajsampark/utils/constants.dart';
import 'package:sahajsampark/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  final Contact contact;
  final int index;
  final Function pushRandomContact;
  final bool fromShuffle;
  const ContactScreen(
      {super.key,
      required this.pushRandomContact,
      required this.contact,
      required this.index,
      this.fromShuffle = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(),
          tooltip: 'Reshuffle',
          onPressed: () async {
            Navigator.of(context).pop();
            await Future.delayed(const Duration(milliseconds: 500));
            pushRandomContact();
          },
          child: const Icon(Icons.shuffle_rounded)),
      appBar: AppBar(
        centerTitle: true,
        title: Text(contact.displayName),
      ),
      body: ListView(
        children: [
          const SizedBox(
            height: 16,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64.0),
            child: Hero(
              tag: fromShuffle ? 'random contact' : index,
              child: FittedBox(
                fit: BoxFit.fill,
                child: CircleAvatar(
                  backgroundColor:
                      colors[index % colors.length].withOpacity(0.5),
                  child: contact.photoOrThumbnail != null
                      ? Image.memory(contact.photoOrThumbnail!)
                      : Text(
                          contact.displayName[0],
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: getContrastingTextColor(
                                        colors[index % colors.length]
                                            .withOpacity(0.5)),
                                  ),
                        ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (contact.phones.isNotEmpty)
                  ...contact.phones.map((phone) => ListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        onTap: () async {
                          await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Select action'),
                                  actions: [
                                    TextButton(
                                        onPressed: () async {
                                          await launchUrl(
                                              Uri.parse('tel:${phone.number}'));
                                        },
                                        child: const Text('Call')),
                                    TextButton(
                                        onPressed: () async {
                                          final phoneNumber = phone.number
                                              .replaceAll('+', '')
                                              .replaceAll(' ', '');
                                          await launchUrl(Uri.parse(
                                              'https://wa.me:/$phoneNumber'));
                                        },
                                        child: const Text('WhatsApp')),
                                    TextButton(
                                        onPressed: () async {
                                          final phoneNumber =
                                              phone.number.replaceAll(' ', '');
                                          final url =
                                              'https://t.me/$phoneNumber';
                                          log(url);
                                          await launchUrl(Uri.parse(url));
                                        },
                                        child: const Text('Telegram')),
                                  ],
                                );
                              });
                        },
                        title: Text(
                          phone.label.name.toTitleCase(),
                        ),
                        subtitle: Text(phone.number),
                        trailing: const Icon(Icons.info_rounded),
                      )),
                if (contact.emails.isNotEmpty)
                  ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    onTap: () async {
                      await launchUrl(
                          Uri.parse('mailto:${contact.emails.first.address}'));
                    },
                    title: const Text('Email'),
                    subtitle: Text(contact.emails.first.address),
                    trailing: const Icon(Icons.email_rounded),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
