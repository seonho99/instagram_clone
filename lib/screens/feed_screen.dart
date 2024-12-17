import 'package:flutter/material.dart';
import 'package:instagram_clone/exception/custom_exception.dart';
import 'package:instagram_clone/models/feed_model.dart';
import 'package:instagram_clone/providers/feed/feed_provider.dart';
import 'package:instagram_clone/widgets/avatar_widget.dart';
import 'package:instagram_clone/widgets/error_dialog_widget.dart';
import 'package:instagram_clone/widgets/feed_card_widget.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../providers/feed/feed_state.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late final FeedProvider feedProvider;

  @override
  void initState() {
    super.initState();
    feedProvider = context.read<FeedProvider>();
    feedProvider.getFeedList();
  }

  void _getFeedList() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await feedProvider.getFeedList();
      } on CustomException catch (e) {
        errorDialogWidget(context, e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<FeedModel> feedList = context.watch<FeedState>().feedList;

    return ListView.builder(
        itemCount: feedList.length,
        itemBuilder: (context, index){
          return FeedCardWidget(feedModel: feedList[index]);
        },
    );
  }
}
