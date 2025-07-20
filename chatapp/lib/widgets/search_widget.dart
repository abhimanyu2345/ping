import 'package:flutter/material.dart';

typedef StringCallBack = void Function(String? query);
TextEditingController searchController =TextEditingController();

class SearchWidget extends StatelessWidget {
  const SearchWidget({super.key, required this.onSearched});
  final StringCallBack onSearched ;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
                    icon: const Icon(Icons.search),
                    color: Colors.black.withAlpha(100),
                    
                    shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    offset: Offset(50,50),
                    
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        
                        
                        child: TextField(
                          
                        controller: searchController,
                        onChanged: (value) {
                          onSearched(searchController.text);
                          
                        },
                        onTapOutside: (event) {
                          

                          onSearched(null);
                        },
                        decoration:InputDecoration(
                          fillColor: Colors.transparent,
                           
                          border: InputBorder.none,
                          constraints: BoxConstraints(
                          
                            minWidth: 100,
                            maxWidth: MediaQuery.of(context).size.width*.75

                          )
                        ),
                      ),)
                    ]);
  }
}