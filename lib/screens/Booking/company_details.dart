import 'package:flutter/material.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';

import '../../providers/connectivity_provider.dart';
import '../../utils/UiHelper.dart';

class ViewDeatils extends StatefulWidget {
  final dynamic company;
   ViewDeatils({super.key, this.company, });

  @override
  State<ViewDeatils> createState() => _ViewDeatilsState();
}

class _ViewDeatilsState extends State<ViewDeatils> {



  @override
  Widget build(BuildContext context) {

    return Consumer<ConnectivityProvider>(
      builder: (context, provider, child) {
        if (!provider.isConnected) {
          _showNoInternetDialog(context);
        }

        return DefaultTabController(
          length: 3,
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
                    // Tab(text: "       Map         "),
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
                        SizedBox(
                          height: double.infinity, // Allows scrolling inside the available space
                          child: SingleChildScrollView(
                            child: HtmlWidget(
                              widget.company['term_condition'],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void _showNoInternetDialog(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => NoInternetDialog(
          checkConnectivity: () {
            Provider.of<ConnectivityProvider>(context, listen: false).checkConnectivity();
          },
        ),
      );
    });
  }
}
