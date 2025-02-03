import 'package:flutter/material.dart';

class CompanyDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> company;

  const CompanyDetailsWidget({Key? key, required this.company}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${company['name']}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text('${company['parking_type']}'),
        ],
      ),
    );
  }
}
