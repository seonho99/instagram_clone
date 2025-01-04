import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:instagram_clone/models/feed_model.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:instagram_clone/providers/feed/feed_state.dart';
import 'package:instagram_clone/providers/user/user_state.dart';
import 'package:instagram_clone/repositories/feed_repository.dart';

import '../../exception/custom_exception.dart';

class FeedProvider extends StateNotifier<FeedState> with LocatorMixin {
  FeedProvider() : super(FeedState.init());

  Future<void> likeFeed({
    required String feedId,
    required List<String> feedLikes,
  }) async {
    state.copyWith(feedStatus: FeedStatus.submitting);

    try {
      UserModel userModel = read<UserState>().userModel;

      FeedModel feedModel = await read<FeedRepository>().likeFeed(
        feedId: feedId,
        feedLikes: feedLikes,
        uid: userModel.uid,
        userLikes: userModel.likes,
      );

      List<FeedModel> newFeedList = state.feedList.map((feed) {
        return feed.feedId == feedId ? feedModel : feed;
      }).toList();

      state.copyWith(feedStatus: FeedStatus.success, feedList: newFeedList);
    } on CustomException catch (_) {
      state = state.copyWith(feedStatus: FeedStatus.error);
      rethrow;
    }
  }

  Future<void> getFeedList() async {
    try {
      state = state.copyWith(feedStatus: FeedStatus.fetching);

      List<FeedModel> feedList = await read<FeedRepository>().getFeedList();

      state = state.copyWith(
        feedList: feedList,
        feedStatus: FeedStatus.success,
      );
    } on CustomException catch (_) {
      state = state.copyWith(feedStatus: FeedStatus.error);
      rethrow;
    }
  }

  Future<void> uploadFeed({
    required List<String> files,
    required String desc,
  }) async {
    try {
      state = state.copyWith(feedStatus: FeedStatus.submitting);

      String uid = read<User>().uid;
      FeedModel feedModel = await read<FeedRepository>()
          .uploadFeed(files: files, desc: desc, uid: uid);

      state = state.copyWith(
        feedStatus: FeedStatus.success,
        feedList: [feedModel, ...state.feedList],
      );
    } on CustomException catch (_) {
      state = state.copyWith(feedStatus: FeedStatus.error);
      rethrow;
    }
  }
}
