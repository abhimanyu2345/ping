
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class StartChatPage extends StatelessWidget {
  const StartChatPage({super.key});
  Future<List<Contact>> fetchContacts()async{
     if (await FlutterContacts.requestPermission()) {
  // Get all contacts (lightly fetched)
  return await FlutterContacts.getContacts();

  }
  return [];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: fetchContacts(), builder: (context, snapshot) {
      final contacts =snapshot.data;
      return 
      Scaffold(
      appBar: AppBar(
        title: Text('select contact'),
      ),
      body: (contacts==null ||contacts.isEmpty)?

       Center(child: Text('no Contacts'))
       :
       ListView.builder(itemCount: contacts.length , itemBuilder: (context, index) {
         return Expanded(child: Text(contacts[index].displayName));
         
       },)

       





    );
      
      

    },);
  }
}