import 'package:chatapp/data/models/webrtc_notifier.dart';
import 'package:chatapp/state_management/riverpods.dart';
import 'package:chatapp/state_management/value_notifers.dart';
import 'package:chatapp/widgets/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart'; // ✅ Import Riverpod
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // ✅ Ensure bindings

  await Supabase.initialize(
    url: 'https://doyilkszzqqzwqbghcmt.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRveWlsa3N6enFxendxYmdoY210Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkzNzM3MjgsImV4cCI6MjA2NDk0OTcyOH0.V3TKkKSX-Uh6YWk8IH_vuRzksnd5kTvEZJEiel98SDg',
    authOptions: const FlutterAuthClientOptions(autoRefreshToken: true),
  );
  

   // ✅ Don't forget await

  runApp(const ProviderScope(child: MyApp())); // ✅ Wrap your app
}


class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    ref.read(userIdProvider.notifier).setId();
    getTheme();
    super.initState();
    ref.read(webRTCNotifierProvider.notifier).build();
  }
  void getTheme()async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isDark.value = prefs.getBool('isDark')??true;
    
  }


  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(valueListenable: isDark, builder: (context, value, child) {
      return  MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      
      
      theme: ThemeData.from(colorScheme:value? ColorScheme.dark():ColorScheme.light()),
      home: WidgetTree()
      


    );
    },);
  }
}