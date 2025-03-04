import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/connectivity_provider.dart';
import '../routes.dart';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../utils/UiHelper.dart';

class AppSetting extends StatelessWidget {
  const AppSetting({super.key});

  void _shareApp() {
    Share.share('Check out this amazing app: https://play.google.com/store/apps/details?id=com.holiday.car.parking.uk');
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  void _privacy() {
    _launchURL('https://holidayscarparking.uk/privacy-policy');
  }

  void _termsApp() {
    _launchURL('https://holidayscarparking.uk/terms-and-conditions');
  }

  @override
    Widget build(BuildContext context) {
      return Consumer<ConnectivityProvider>(
        builder: (context, provider, child) {
          if (!provider.isConnected) {
            _showNoInternetDialog(context);
          }

          return Scaffold(
            appBar: AppBar(),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text("Account Settings",
                          style: Theme.of(context).textTheme.headlineMedium),
                      Text(
                        "Update your settings like notifications, payments, profile edit etc.",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      ProfileMenuCard(
                        icon: Icons.person,
                        title: "Profile Information",
                        subTitle: "Change your account information",
                        press: () {
                          Navigator.pushNamed(context, AppRoutes.editProfile);
                        },
                      ),
                      ProfileMenuCard(
                        icon: Icons.privacy_tip,
                        title: "Privacy Policy",
                        subTitle: "Read our privacy policy",
                        press: _privacy,
                      ),
                      ProfileMenuCard(
                        // svgSrc: disclaimerIconSvg,
                        title: "terms & conditions",
                        subTitle: "terms-and-conditions",
                        press: _termsApp,
                        icon: Icons.help,
                      ),
                      ProfileMenuCard(
                        icon: Icons.share,
                        title: "Share App",
                        subTitle: "Share this app with your friends",
                        press: _shareApp,
                      ),
                    ],
                  ),
                ),
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


class ProfileMenuCard extends StatelessWidget {
  const ProfileMenuCard({
    super.key,
    required this.title,
    required this.subTitle,
    required this.icon,
    required this.press,
  });

  final String title, subTitle;
  final IconData icon;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        onTap: press,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: const Color(0xFFED1C24).withOpacity(0.64),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subTitle,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_outlined,
                size: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}
