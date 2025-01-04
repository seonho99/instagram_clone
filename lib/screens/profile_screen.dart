import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/exception/custom_exception.dart';
import 'package:instagram_clone/models/feed_model.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:instagram_clone/providers/profile/profile_provider.dart';
import 'package:instagram_clone/providers/profile/profile_state.dart';
import 'package:instagram_clone/providers/user/user_state.dart';
import 'package:instagram_clone/widgets/error_dialog_widget.dart';
import 'package:instagram_clone/widgets/feed_card_widget.dart';
import 'package:provider/provider.dart';

import '../utils/logger.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileProvider profileProvider;

  @override
  void initState() {
    super.initState();
    profileProvider = context.read<ProfileProvider>();
    _getProfile();
  }

  void _getProfile() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await profileProvider.getProfile(uid: widget.uid);
      } on CustomException catch (e) {
        errorDialogWidget(context, e);
      }
    });
  }

  Widget _profileInfoWidget({
    required int num,
    required String label,
  }) {
    return Column(
      children: [
        Text(
          num.toString(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _customButtonWidget({
    required AsyncCallback asyncCallback,
    required String text,
  }) {
    return TextButton(
      onPressed: () async {
        try {
          await asyncCallback();
        } on CustomException catch (e) {
          errorDialogWidget(context, e);
        }
      },
      child: Text(text),
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(
          color: Colors.grey,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ProfileState profileState = context.watch<ProfileState>();
    // 프로필을 확인하려는 유저의 정보
    UserModel userModel = profileState.userModel;
    List<FeedModel> feedList = profileState.feedList;

    // 현재 접속중인 유저의 정보
    UserModel currentUserModel = context.read<UserState>().userModel;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: userModel.profileImage == null
                            ? ExtendedAssetImageProvider(
                                'assets/images/profile.png')
                            : ExtendedNetworkImageProvider(
                                userModel.profileImage!),
                        radius: 40,
                      ),
                      SizedBox(height: 5),
                      Text(userModel.name),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _profileInfoWidget(
                            num: userModel.feedCount, label: 'feeds'),
                        _profileInfoWidget(
                            num: userModel.followers.length, label: 'follower'),
                        _profileInfoWidget(
                            num: userModel.following.length,
                            label: 'following'),
                      ],
                    ),
                  ),
                ],
              ),
              currentUserModel.uid == userModel.uid
                  ? _customButtonWidget(
                      asyncCallback: context.read<AuthProvider>().signOut,
                      text: 'Sign Out',
                    )
                  : _customButtonWidget(
                      asyncCallback: () async {
                        await context.read<ProfileProvider>().followUser(
                              currentUserId: currentUserModel.uid,
                              followId: userModel.uid,
                            );
                      },
                      text: userModel.followers.contains(currentUserModel.uid)
                          ? 'Unfollow'
                          : 'Follow',
                    ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 3,
                    mainAxisSpacing: 3,
                  ),
                  itemCount: feedList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProfileScreen(feedModel: feedList[index]),
                          ),
                        );
                      },
                      child: ExtendedImage.network(
                        feedList[index].imageUrls[0],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
