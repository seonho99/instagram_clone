import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:instagram_clone/exception/custom_exception.dart';
import 'package:instagram_clone/models/feed_model.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:instagram_clone/providers/profile/profile_state.dart';
import 'package:instagram_clone/repositories/feed_repository.dart';
import 'package:instagram_clone/repositories/profile_repository.dart';

class ProfileProvider extends StateNotifier<ProfileState> with LocatorMixin {
  ProfileProvider() : super(ProfileState.init()) ;

  Future<void> getProfile({
    required String uid,
  }) async {
  state = state.copyWith(profileStatus: ProfileStatus.fetching);

  try {
    UserModel userModel = await read<ProfileRepository>().getProfile(uid: uid);
    List<FeedModel> feedList = await read<FeedRepository>.getFeedList(uid: uid);

    state = state.copyWith(
      profileStatus: ProfileStatus.success,
      feedList: feedList,
      userModel: userModel,
    );
  } on CustomException catch (_){
    state = state.copyWith(profileStatus: ProfileStatus.error);
  }

  }
}