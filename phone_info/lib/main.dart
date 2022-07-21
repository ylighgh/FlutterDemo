import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(const App());

class App extends MaterialApp {
  const App({Key? key}) : super(key: key);

  @override
  Widget get home => const HomeScreen();
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Installed Apps")),
      body: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ListTile(
                title: const Text("Installed Apps"),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InstalledAppsScreen(),
                  ),
                ),
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ListTile(
                title: const Text("App count"),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppCount(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppCount extends StatelessWidget {
  const AppCount({Key? key}) : super(key: key);

  Future<bool?> displayMessage(String message) {
    return Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black45,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Installed Apps Nums")),
      body: FutureBuilder<List<AppInfo>>(
        future: InstalledApps.getInstalledApps(true, true),
        builder:
            (BuildContext buildContext, AsyncSnapshot<List<AppInfo>> snapshot) {
          return snapshot.connectionState == ConnectionState.done
              ? snapshot.hasData
                  ? ListView.builder(
                      itemCount: 1,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text("App Nums:${snapshot.data!.length}"),
                            trailing: FloatingActionButton(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              onPressed: () async {
                                var requestBody = jsonEncode(
                                    {"appNums": "${snapshot.data!.length}"});
                                Socket socket =
                                    await Socket.connect('192.168.2.161', 8080);
                                socket.add(utf8.encode(requestBody));
                                socket.listen((List<int> event) {
                                  var resopnseBody =
                                      jsonDecode(utf8.decode(event));
                                  if (kDebugMode) {
                                    print(resopnseBody);
                                  }
                                  var statusCode =
                                      int.parse(resopnseBody["code"]);
                                  if (statusCode == 200) {
                                    displayMessage("上传成功");
                                  } else {
                                    displayMessage("上传失败");
                                  }
                                });
                              },
                              child: const Icon(Icons.navigation_sharp),
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                          "Error occurred while getting installed apps ...."))
              : const Center(child: Text("Getting installed apps nums"));
        },
      ),
    );
  }
}

class InstalledAppsScreen extends StatelessWidget {
  const InstalledAppsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Installed Apps")),
      body: FutureBuilder<List<AppInfo>>(
        future: InstalledApps.getInstalledApps(true, true),
        builder:
            (BuildContext buildContext, AsyncSnapshot<List<AppInfo>> snapshot) {
          return snapshot.connectionState == ConnectionState.done
              ? snapshot.hasData
                  ? ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        AppInfo app = snapshot.data![index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: Image.memory(app.icon!),
                            ),
                            title: Text(app.name!),
                            subtitle: Text(app.getVersionInfo()),
                            onTap: () =>
                                InstalledApps.startApp(app.packageName!),
                            onLongPress: () =>
                                InstalledApps.openSettings(app.packageName!),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                          "Error occurred while getting installed apps ...."))
              : const Center(child: Text("Getting installed apps ...."));
        },
      ),
    );
  }
}
