import 'package:instagram_clone/models/feed_model.dart';
import 'package:instagram_clone/models/user_model.dart';

enum ProfileStatus {
  init,
  submitting,
  fetching,
  success,
  error,
}

class ProfileState {
  final ProfileStatus profileStatus;
  final UserModel userModel;
  final List<FeedModel> feedList;

  const ProfileState({
    required this.profileStatus,
    required this.userModel,
    required this.feedList,
  });

  factory ProfileState.init() {
    return ProfileState(
      profileStatus: ProfileStatus.init,
      userModel: UserModel.init(),
      feedList: [],
    );
  }

  ProfileState copyWith({
    ProfileStatus? profileStatus,
    UserModel? userModel,
    List<FeedModel>? feedList,
}) {
    return ProfileState(
        profileStatus: profileStatus ?? this.profileStatus,
        userModel: userModel ?? this.userModel,
        feedList: feedList ?? this.feedList,
    );
  }
}
