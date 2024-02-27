import 'dart:developer';

import 'package:demo_api/post_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController _scrollController = ScrollController();
  late var provider;
  var subscription;

  ConnectivityResult? result = ConnectivityResult.wifi;
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      getConnectionResult();
      subscription = Connectivity()
          .onConnectivityChanged
          .listen((ConnectivityResult result) {
        if (result == ConnectivityResult.none) {
          log("not internet connection");
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("No Internet Connection"),
            duration: Duration(seconds: 4),
          ));
        }
        // Got a new connectivity status!
      });
      provider = Provider.of<PostProvider>(context, listen: false);
      provider.fetchPosts();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        provider.loadMorePosts();
      }
    });
  }

  @override
  dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future<void> _refreshPosts() async {
    await Provider.of<PostProvider>(context, listen: false).fetchPosts();
  }

  final searchCont = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      body: Consumer<PostProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.posts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (provider.error != '') {
            return Center(
              child: Text('Error: ${provider.error}'),
            );
          } else {
            return RefreshIndicator(
              onRefresh: _refreshPosts,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: provider.posts.length + 1,
                itemBuilder: (context, index) {
                  if (index == provider.posts.length) {
                    return provider.hasMore
                        ? const Center(child: CircularProgressIndicator())
                        : Container();
                  }
                  return Column(
                    children: [
                      // TextField(
                      //   controller: searchCont,
                      //   onChanged: (value) {},
                      // ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            elevation: 5,
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          title: const Text('Post Details'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                provider.posts[index].title,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                provider.posts[index].body,
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              style: TextButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                backgroundColor: Colors.blue,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: const Text('Ok'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    title: Text(
                                      provider.posts[index].title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          provider.posts[index].body,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            // color: Colors
                                            //     .grey,
                                          ),
                                        ))))),
                      ),
                    ],
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  void getConnectionResult() async {
    result = await (Connectivity().checkConnectivity());
  }
}
