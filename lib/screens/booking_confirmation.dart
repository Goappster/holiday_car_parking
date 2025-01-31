import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(const BookingConfirmation());
}

const String svgString = '''
<svg width="390" height="800" viewBox="0 0 390 748" fill="none" xmlns="http://www.w3.org/2000/svg">
<g filter="url(#filter0_d_2031_4069)">
<path fill-rule="evenodd" clip-rule="evenodd" d="M44 40C32.9543 40 24 48.9543 24 60V679.465V680H24.0288C24.0098 679.824 24 679.646 24 679.465C24 676.811 26.1071 674.659 28.7064 674.659C31.3057 674.659 33.4128 676.811 33.4128 679.465C33.4128 679.646 33.4031 679.824 33.384 680H37.6285C37.6073 679.824 37.5965 679.646 37.5965 679.465C37.5965 676.811 39.9377 674.659 42.8258 674.659C45.7139 674.659 48.0552 676.811 48.0552 679.465C48.0552 679.646 48.0443 679.824 48.0231 680H51.2245C51.2033 679.824 51.1925 679.646 51.1925 679.465C51.1925 676.811 53.5337 674.659 56.4218 674.659C59.3099 674.659 61.6512 676.811 61.6512 679.465C61.6512 679.646 61.6403 679.824 61.6191 680H65.8636C65.8445 679.824 65.8347 679.646 65.8347 679.465C65.8347 676.811 67.9418 674.659 70.5411 674.659C73.1404 674.659 75.2476 676.811 75.2476 679.465C75.2476 679.646 75.2378 679.824 75.2187 680H79.46C79.441 679.824 79.4312 679.646 79.4312 679.465C79.4312 676.811 81.5383 674.659 84.1376 674.659C86.7369 674.659 88.844 676.811 88.844 679.465C88.844 679.646 88.8342 679.824 88.8152 680H93.0597C93.0385 679.824 93.0277 679.646 93.0277 679.465C93.0277 676.811 95.3689 674.659 98.257 674.659C101.145 674.659 103.486 676.811 103.486 679.465C103.486 679.646 103.476 679.824 103.454 680H106.656C106.635 679.824 106.624 679.646 106.624 679.465C106.624 676.811 108.965 674.659 111.853 674.659C114.741 674.659 117.082 676.811 117.082 679.465C117.082 679.646 117.071 679.824 117.05 680H121.295C121.276 679.824 121.266 679.646 121.266 679.465C121.266 676.811 123.373 674.659 125.972 674.659C128.572 674.659 130.679 676.811 130.679 679.465C130.679 679.646 130.669 679.824 130.65 680H134.891C134.872 679.824 134.862 679.646 134.862 679.465C134.862 676.811 136.97 674.659 139.569 674.659C142.168 674.659 144.275 676.811 144.275 679.465C144.275 679.646 144.265 679.824 144.246 680H148.491C148.47 679.824 148.459 679.646 148.459 679.465C148.459 676.811 150.8 674.659 153.688 674.659C156.576 674.659 158.918 676.811 158.918 679.465C158.918 679.646 158.907 679.824 158.886 680H162.087C162.066 679.824 162.055 679.646 162.055 679.465C162.055 676.811 164.397 674.659 167.285 674.659C170.173 674.659 172.514 676.811 172.514 679.465C172.514 679.646 172.503 679.824 172.482 680H176.726C176.707 679.824 176.697 679.646 176.697 679.465C176.697 676.811 178.804 674.659 181.403 674.659C184.003 674.659 186.11 676.811 186.11 679.465C186.11 679.646 186.1 679.824 186.081 680H190.322C190.303 679.824 190.294 679.646 190.294 679.465C190.294 676.811 192.401 674.659 195 674.659C197.599 674.659 199.706 676.811 199.706 679.465C199.706 679.646 199.697 679.824 199.678 680H203.919C203.9 679.824 203.89 679.646 203.89 679.465C203.89 676.811 205.997 674.659 208.596 674.659C211.196 674.659 213.303 676.811 213.303 679.465C213.303 679.646 213.293 679.824 213.274 680H217.518C217.497 679.824 217.486 679.646 217.486 679.465C217.486 676.811 219.827 674.659 222.715 674.659C225.603 674.659 227.945 676.811 227.945 679.465C227.945 679.646 227.934 679.824 227.913 680H231.115C231.093 679.824 231.082 679.646 231.082 679.465C231.082 676.811 233.424 674.659 236.312 674.659C239.2 674.659 241.541 676.811 241.541 679.465C241.541 679.646 241.53 679.824 241.509 680H245.754C245.735 679.824 245.725 679.646 245.725 679.465C245.725 676.811 247.832 674.659 250.431 674.659C253.03 674.659 255.138 676.811 255.138 679.465C255.138 679.646 255.128 679.824 255.109 680H259.35C259.331 679.824 259.321 679.646 259.321 679.465C259.321 676.811 261.428 674.659 264.028 674.659C266.627 674.659 268.734 676.811 268.734 679.465C268.734 679.646 268.724 679.824 268.705 680H272.95C272.929 679.824 272.918 679.646 272.918 679.465C272.918 676.811 275.259 674.659 278.147 674.659C281.035 674.659 283.376 676.811 283.376 679.465C283.376 679.646 283.366 679.824 283.344 680H286.546C286.525 679.824 286.514 679.646 286.514 679.465C286.514 676.811 288.855 674.659 291.743 674.659C294.631 674.659 296.972 676.811 296.972 679.465C296.972 679.646 296.962 679.824 296.94 680H301.185C301.166 679.824 301.156 679.646 301.156 679.465C301.156 676.811 303.263 674.659 305.862 674.659C308.462 674.659 310.569 676.811 310.569 679.465C310.569 679.646 310.559 679.824 310.54 680H314.781C314.762 679.824 314.752 679.646 314.752 679.465C314.752 676.811 316.86 674.659 319.459 674.659C322.058 674.659 324.165 676.811 324.165 679.465C324.165 679.646 324.155 679.824 324.136 680H328.381C328.359 679.824 328.349 679.646 328.349 679.465C328.349 676.811 330.69 674.659 333.578 674.659C336.466 674.659 338.807 676.811 338.807 679.465C338.807 679.646 338.796 679.824 338.775 680H341.977C341.956 679.824 341.945 679.646 341.945 679.465C341.945 676.811 344.286 674.659 347.174 674.659C350.062 674.659 352.404 676.811 352.404 679.465C352.404 679.646 352.393 679.824 352.372 680H356.616C356.597 679.824 356.587 679.646 356.587 679.465C356.587 676.811 358.694 674.659 361.294 674.659C363.893 674.659 366 676.811 366 679.465C366 679.646 365.99 679.824 365.971 680H366V62C366 49.8497 356.15 40 344 40H44Z" fill="white"/>
</g>
<defs>
<filter id="filter0_d_2031_4069" x="-20" y="0" width="450" height="800" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">
<feFlood flood-opacity="0" result="BackgroundImageFix"/>
<feColorMatrix in="SourceAlpha" type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0" result="hardAlpha"/>
<feOffset dx="10" dy="14"/>
<feGaussianBlur stdDeviation="27"/>
<feColorMatrix type="matrix" values="0 0 0 0 0.0588235 0 0 0 0 0.0509804 0 0 0 0 0.137255 0 0 0 0.13 0"/>
<feBlend mode="normal" in2="BackgroundImageFix" result="effect1_dropShadow_2031_4069"/>
<feBlend mode="normal" in="SourceGraphic" in2="effect1_dropShadow_2031_4069" result="shape"/>
</filter>
</defs>
</svg>
  ''';


class BookingConfirmation extends StatefulWidget {
  const BookingConfirmation({super.key});

  @override
  State<BookingConfirmation> createState() => _BookingConfirmationState();
}

class _BookingConfirmationState extends State<BookingConfirmation> {


  late var company;
  late var startDate;
  late var endDate;
  late var startTime;
  late var endTime;
  late var endTimsavedReferenceNoe;

  late double bookingPrice;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    company = args['company'];
    startDate = args['startDate'];
    endDate = args['endDate'];
    startTime = args['startTime'];
    endTime = args['endTime'];
    endTimsavedReferenceNoe = args['endTimsavedReferenceNoe'];

    bookingPrice = (args['totalPrice'] as num).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
          children: [
            // SVG Background
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: const BoxDecoration(boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.1),
                      blurRadius: 50,
                      spreadRadius: 0,
                      offset: Offset(
                        0,
                        10,
                      ),
                    ),
                  ]),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).cardColor, // Using theme color
                      BlendMode.srcIn, // Apply color filter to SVG
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0), // Adjust the radius as needed
                      child: SvgPicture.string(
                        svgString, // Your SVG string
                       width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  ),
                ),
              ),
            ),
            // Foreground Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Lottie.asset('assets/payment_confirm.json', height: 250, fit: BoxFit.fill),
                  const Text(
                    'Booking Successful!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '£${bookingPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w700, color: Colors.green),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: _buildCompanyLogo(company),
                    title:  Text('${company['name']}'),
                    subtitle: Text('${company['parking_type']}'),
                  ),
                  DottedDashedLine(height: 0, width: double.infinity, axis: Axis.horizontal, dashColor: Theme.of(context).dividerColor, ),
                  ListTile(
                    title: Text('Drop-Off'),
                    trailing: Text('$startDate at $startTime'),
                  ),
                  ListTile(
                    title: Text('Return'),
                    trailing: Text('$endDate at $endTime'),
                  ),
                  ListTile(
                    title: const Text('Booking Price'),
                    trailing: Text(
                      '£${bookingPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700, color: Colors.green),
                    ),
                  ),
                  // SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Image.asset('assets/images/barcode.png'),
                         Text('$endTimsavedReferenceNoe', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

    );
  }

  Widget _buildCompanyLogo(Map<String, dynamic> company) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(3)),
      child: company['park_api'] == 'DB'
          ? CachedNetworkImage(imageUrl: 'https://airportparkbooking.uk/storage/${company['logo']}',
        height: 40, width: 60, fit: BoxFit.cover,
        errorWidget: (context, url, error) => const Icon(Icons.error),
      )
          : company['park_api'] == 'holiday'
          ? CachedNetworkImage(
        imageUrl: company['logo'],
        height: 40,
        width: 60,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => const Icon(Icons.error),
      )
          : null,
    );
  }
}
