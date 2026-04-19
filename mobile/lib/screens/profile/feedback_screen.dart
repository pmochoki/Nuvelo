import 'package:flutter/material.dart';

import '../../widgets/empty_state.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Received'),
              Tab(text: 'Sent'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                EmptyState(
                  icon: Icons.sentiment_satisfied_alt_rounded,
                  title: 'No feedback yet.',
                  subtitle: 'Share your profile link to get reviews.',
                  actionLabel: 'Copy link',
                  onAction: () {},
                ),
                const EmptyState(title: 'Nothing sent'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
