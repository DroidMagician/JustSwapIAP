import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
   List<ProductDetails>? products;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  @override
  void initState() {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription =
        purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
          _listenToPurchaseUpdated(purchaseDetailsList);
        }, onDone: () {
          _subscription.cancel();
        }, onError: (Object error) {
          // handle error here.
        });
    //getPurchaseProducts();
    super.initState();
  }

  void _incrementCounter() {
    getPurchaseProducts();
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }
  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
          print("Pending");
        //showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          print(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            print("Deliver Products ${purchaseDetails.productID}");
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        // if (Platform.isAndroid) {
        //   if (!_kAutoConsume && purchaseDetails.productID == _kConsumableId) {
        //     final InAppPurchaseAndroidPlatformAddition androidAddition =
        //     _inAppPurchase.getPlatformAddition<
        //         InAppPurchaseAndroidPlatformAddition>();
        //     await androidAddition.consumePurchase(purchaseDetails);
        //   }
        // }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }
  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed
    print("tets=>${purchaseDetails.error}=>${purchaseDetails.productID}");
  }
  // Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
  //   // IMPORTANT!! Always verify purchase details before delivering the product.
  //   if (purchaseDetails.productID == _kConsumableId) {
  //     await ConsumableStore.save(purchaseDetails.purchaseID!);
  //     final List<String> consumables = await ConsumableStore.load();
  //     setState(() {
  //       _purchasePending = false;
  //       _consumables = consumables;
  //     });
  //   } else {
  //     setState(() {
  //       _purchases.add(purchaseDetails);
  //       _purchasePending = false;
  //     });
  //   }
  // }
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    if(purchaseDetails.status == PurchaseStatus.purchased)
      {

      }
    return Future<bool>.value(true);
  }
  getPurchaseProducts() async {
    // Set literals require Dart 2.2. Alternatively, use
// `Set<String> _kIds = <String>['product1', 'product2'].toSet()`.
    const Set<String> _kIds = <String>{
      'android.justswap.boostweek',
      'android.justswap.boostmonth'
    };
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(_kIds);
    if (response.notFoundIDs.isNotEmpty) {
      // Handle the error.
    }
    setState(() {
      products = response.productDetails;
      products?.forEach((element) {
        print("Product List === ${element.title}");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: products?.isNotEmpty == true ? ListView.builder(
            itemBuilder: (context, index) => ListTile(
                title: Text(products![index].title ?? ""),
                onTap: () {
                  getIsConsumable(products![index]);
                }),
            itemCount: products?.length) : null,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  getIsConsumable(ProductDetails product) async {
    final ProductDetails productDetails = product;
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);

    // var result = await InAppPurchase.instance
    //     .buyConsumable(purchaseParam: purchaseParam);
    var result1 =
        InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);

   // print(object);
    // if (_isConsumable(productDetails)) {
    //
    // } else {
    // InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
    // }
  }

  bool? isConsumable(String productId) {
    // Define a mapping of product identifiers to their consumable/non-consumable status
    Map<String, bool> productMapping = {
      'product1': true, // 'product1' is consumable
      'product2': false, // 'product2' is non-consumable
      // Add more products and their corresponding status here
    };

    // Check if the productId exists in the mapping and return its corresponding status
    if (productMapping.containsKey(productId)) {
      return productMapping[productId];
    }

    // If the productId is not found in the mapping, you can either consider it non-consumable by default
    // or implement additional logic based on your requirements (e.g., fetching the product status from a server)

    // Assuming it is non-consumable by default if not found in the mapping
    return false;
  }
}
