import 'package:flutter/material.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class ViewDeatils extends StatefulWidget {
  final dynamic company;
   ViewDeatils({super.key, this.company, });

  @override
  State<ViewDeatils> createState() => _ViewDeatilsState();
}

class _ViewDeatilsState extends State<ViewDeatils> {
  final String htmlContent = """
    <h2>Welcome to Home</h2>
    <p>This is an <b>HTML</b> content example.</p>
    <ul>
      <li>Item 1</li>
      <li>Item 2</li>
      <li>Item 3</li>
    </ul>
  """;



  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(title: Text("Company Details "),
        centerTitle: true,
        ),
        body: Column(
          children: <Widget>[
            ButtonsTabBar(
              backgroundColor: Theme.of(context).primaryColor,
              unselectedBackgroundColor: Theme.of(context).cardColor,
              labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold,color: Colors.white),
              unselectedLabelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold,),
              tabs: [
                Tab(text: "    Info   "),
                Tab(text: "       Arrival / Return     "),
                Tab(text: "       Map         "),
                Tab(text: "      Terms and Conditions    "),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TabBarView(
                  children: <Widget>[
                    SizedBox(
                      height: double.infinity, // Allows scrolling inside the available space
                      child: SingleChildScrollView(
                        child: HtmlWidget(widget.company['overview']),
                      ),
                    ),
                    SizedBox(
                      height: double.infinity, // Allows scrolling inside the available space
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            HtmlWidget(widget.company['return_proc']),
                            HtmlWidget(widget.company['arival']),
                          ],
                        ),
                      ),
                    ),
                    Center(child: Text("👤 Profile Screen")),
                    SizedBox(
                      height: double.infinity, // Allows scrolling inside the available space
                      child: SingleChildScrollView(
                        child: HtmlWidget(widget.company['term_condition']),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
