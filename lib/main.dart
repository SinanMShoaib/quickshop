import 'dart:async'; // Gives us Timer for the splash screen delay
import 'package:flutter/material.dart'; // Core Flutter Material widgets
import 'package:webview_flutter/webview_flutter.dart'; // WebView package for showing websites

class Product { // Simple model class for one product
  String name, description; // Product name and description text
  double price; // Product price
  Product(this.name, this.price, this.description); // Constructor that sets all fields
}

List<Product> products = [ // In-memory product list (no database, as required)
  Product('Headphones', 49.99, 'Wireless over-ear headphones.'), // Sample product 1
  Product('MC Notes', 2.50, 'Tracks steps, heart rate and sleep.'), // Sample product 2
  Product('Bird', 25.00, 'Its a BRID...No! Its a Plane... NO!! ITs just a bird =].'), // Sample product 3
];

void msg(BuildContext c, String t) => ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(t), duration: const Duration(seconds: 1))); // Helper that shows a short message at the bottom

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, title: 'QuickShop', home: SplashScreen())); // App entry point, starts on the splash screen

// ---------------- 1. SPLASH SCREEN ----------------
class SplashScreen extends StatefulWidget { // Stateful so we can start a timer in initState
  const SplashScreen({super.key}); // Constructor
  @override
  State<SplashScreen> createState() => _SplashScreenState(); // Creates the state object
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() { // Runs once when the screen first appears
    super.initState(); // Always call the parent initState
    Timer(const Duration(seconds: 2), () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()))); // After 2 seconds replace splash with Home
  }

  @override
  Widget build(BuildContext context) => const Scaffold( // Basic page layout
        backgroundColor: Colors.blue, // Blue background
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [ // Centre the content vertically
          Icon(Icons.shopping_cart, size: 100, color: Colors.white), // App logo icon
          Text('QuickShop', style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)), // App name
          Text('Welcome! Happy shopping.', style: TextStyle(color: Colors.white)), // Welcome message
        ])),
      );
}

// ---------------- 2. HOME SCREEN + DRAWER ----------------
class HomeScreen extends StatefulWidget { // Stateful so the list refreshes after adding a product
  const HomeScreen({super.key}); // Constructor
  @override
  State<HomeScreen> createState() => _HomeScreenState(); // Creates the state object
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> go(Widget page) async { // Helper to open a page from the drawer
    Navigator.pop(context); // Close the drawer first
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page)); // Open the page and wait until user comes back
    setState(() {}); // Rebuild so newly added products appear
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('QuickShop')), // AppBar showing the app name
        drawer: Drawer(child: ListView(children: [ // Side navigation drawer
          const DrawerHeader(child: Text('QuickShop Menu', style: TextStyle(fontSize: 24))), // Drawer title area
          ListTile(leading: const Icon(Icons.home), title: const Text('Home'), onTap: () => Navigator.pop(context)), // Home: just close drawer
          ListTile(leading: const Icon(Icons.list), title: const Text('Products'), onTap: () => Navigator.pop(context)), // Products are shown on Home, so just close drawer
          ListTile(leading: const Icon(Icons.add), title: const Text('Add Product'), onTap: () => go(const AddProductScreen())), // Open Add Product screen
          ListTile(leading: const Icon(Icons.public), title: const Text('WebView'), onTap: () => go(const WebViewScreen())), // Open WebView screen
          ListTile(leading: const Icon(Icons.touch_app), title: const Text('Gesture / Animation'), onTap: () => go(const GestureScreen())), // Open gestures, animation and counter screen
        ])),
        body: ListView.builder( // Scrollable list built from the products list
          itemCount: products.length, // Number of cards to build
          itemBuilder: (_, i) => GestureDetector( // Wraps each card to detect gestures
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailsScreen(products[i]))), // onTap: open product details
            onDoubleTap: () => msg(context, '${products[i].name} added to favourites ❤'), // onDoubleTap: mark as favourite
            onLongPress: () => msg(context, 'Long press: ${products[i].description}'), // onLongPress: show extra info
            child: Card(child: ListTile( // Card widget for each product
              leading: const Icon(Icons.shopping_bag, size: 40), // Product icon
              title: Text(products[i].name), // Product name
              subtitle: Text('\$${products[i].price.toStringAsFixed(2)}'), // Product price
              trailing: const Icon(Icons.arrow_forward_ios), // Arrow showing it can be opened for details
            )),
          ),
        ),
      );
}

// ---------------- 3. PRODUCT DETAILS ----------------
class DetailsScreen extends StatelessWidget { // Stateless because it only displays data
  final Product p; // The product that was tapped
  const DetailsScreen(this.p, {super.key}); // Constructor receives the product

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(p.name)), // Title is the product name
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [ // Centre the details
          const Icon(Icons.shopping_bag, size: 120), // Product icon
          Text(p.name, style: const TextStyle(fontSize: 26)), // Product name
          Text('\$${p.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20)), // Product price
          Padding(padding: const EdgeInsets.all(16), child: Text(p.description)), // Product description
          ElevatedButton(onPressed: () => msg(context, '${p.name} added to cart!'), child: const Text('Add to Cart')), // Add to Cart with visible response
        ])),
      );
}

// ---------------- 4. ADD PRODUCT ----------------
class AddProductScreen extends StatefulWidget { // Stateful because it holds form controllers
  const AddProductScreen({super.key}); // Constructor
  @override
  State<AddProductScreen> createState() => _AddProductScreenState(); // Creates the state object
}

class _AddProductScreenState extends State<AddProductScreen> {
  final formKey = GlobalKey<FormState>(); // Key used to validate the form
  final name = TextEditingController(), price = TextEditingController(), desc = TextEditingController(); // Controllers to read/clear each field

  void add() { // Called when Add Product is pressed
    if (!formKey.currentState!.validate()) return; // Stop if any field is invalid
    products.add(Product(name.text, double.parse(price.text), desc.text)); // Add new product to the in-memory list
    name.clear(); price.clear(); desc.clear(); // Clear all input fields after success
    msg(context, 'Product added!'); // Confirm to the user
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Add Product')), // Screen title
        body: Form(key: formKey, child: ListView(padding: const EdgeInsets.all(16), children: [ // Form with padding
          TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Product Name'), validator: (v) => v!.trim().isEmpty ? 'Enter a name' : null), // Name field, must not be empty
          TextFormField(controller: price, decoration: const InputDecoration(labelText: 'Product Price'), keyboardType: TextInputType.number, validator: (v) => (double.tryParse(v!) ?? 0) <= 0 ? 'Enter a valid price' : null), // Price field, must be a positive number
          TextFormField(controller: desc, decoration: const InputDecoration(labelText: 'Product Description'), validator: (v) => v!.trim().isEmpty ? 'Enter a description' : null), // Description field, must not be empty
          const SizedBox(height: 20), // Space above the button
          ElevatedButton(onPressed: add, child: const Text('Add Product')), // Submits the form
        ])),
      );
}

// ---------------- 5, 6, 7. GESTURES + ANIMATION + COUNTER ----------------
class GestureScreen extends StatefulWidget { // Stateful because swipe text, animation and counter change
  const GestureScreen({super.key}); // Constructor
  @override
  State<GestureScreen> createState() => _GestureScreenState(); // Creates the state object
}

class _GestureScreenState extends State<GestureScreen> {
  String drag = 'Swipe or drag inside the box'; // Text showing which drag was detected
  bool big = false; // Controls the animated box size/colour
  int count = 0; // Counter value

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Gesture / Animation')), // Screen title
        body: ListView(padding: const EdgeInsets.all(16), children: [ // Scrollable page content
          GestureDetector( // Designated drag area
            onHorizontalDragUpdate: (d) => setState(() => drag = 'Horizontal swipe ${d.delta.dx > 0 ? 'right →' : 'left ←'}'), // onHorizontalDrag: detect left/right swipe
            onVerticalDragUpdate: (d) => setState(() => drag = 'Vertical drag ${d.delta.dy > 0 ? 'down ↓' : 'up ↑'}'), // onVerticalDrag: detect up/down drag
            child: Container(height: 150, color: Colors.amber, alignment: Alignment.center, child: Text(drag)), // Visible box that shows the result
          ),
          const SizedBox(height: 20), // Spacing
          GestureDetector( // Tap to trigger the animation
            onTap: () => setState(() => big = !big), // Toggle size/colour on tap
            child: Center(child: AnimatedContainer( // Animated widget required by task 6
              duration: const Duration(milliseconds: 500), // Animation length
              width: big ? 200 : 100, height: big ? 200 : 100, // Size changes when tapped
              color: big ? Colors.green : Colors.red, // Colour changes when tapped
              alignment: Alignment.center, child: const Text('Tap me', style: TextStyle(color: Colors.white)), // Label inside box
            )),
          ),
          const SizedBox(height: 20), // Spacing
          Text('Counter: $count', textAlign: TextAlign.center, style: const TextStyle(fontSize: 28)), // Displays current counter value
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [ // Buttons side by side
            ElevatedButton(onPressed: () => setState(() => count--), child: const Text('Decrement')), // Decrease counter with setState
            const SizedBox(width: 10), // Gap between buttons
            ElevatedButton(onPressed: () => setState(() => count++), child: const Text('Increment')), // Increase counter with setState
          ]),
        ]),
      );
}

// ---------------- 8. WEBVIEW ----------------
class WebViewScreen extends StatelessWidget { // Shows a website inside the app
  const WebViewScreen({super.key}); // Constructor

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('WebView')), // Screen title
        body: WebViewWidget(controller: WebViewController() // The WebView widget with its controller
          ..setJavaScriptMode(JavaScriptMode.unrestricted) // Allow JavaScript so sites work properly
          ..loadRequest(Uri.parse('https://flutter.dev'))), // Load a public website
      );
}
