import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/providers/app_auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:validators/validators.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  TextEditingController _emailEditingController = TextEditingController();
  TextEditingController _nameEditingController = TextEditingController();
  TextEditingController _passwordEditingController = TextEditingController();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  Uint8List? _image;

  Future<void> selectImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 512,
      maxWidth: 512,
    );

    if (file != null) {
      Uint8List uint8list = await file.readAsBytes();
      setState(() {
        _image = uint8list;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _globalKey,
            autovalidateMode: _autovalidateMode,
            child: ListView(
              shrinkWrap: true,
              reverse: true,
              children: [
                // 로고
                SvgPicture.asset(
                  'assets/images/ic_instagram.svg',
                  height: 64,
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
                SizedBox(height: 20),
                // 프로필 사진
                Container(
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      _image == null
                          ? CircleAvatar(
                              radius: 64,
                              backgroundImage:
                                  AssetImage('assets/images/profile.png'))
                          : CircleAvatar(
                              radius: 64,
                              backgroundImage: MemoryImage(_image!),
                            ),
                      Positioned(
                        left: 80,
                        bottom: -10,
                        child: IconButton(
                          onPressed: () async {
                            await selectImage();
                          },
                          icon: Icon(Icons.add_a_photo),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                // 이메일
                TextFormField(
                  controller: _emailEditingController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    filled: true,
                  ),
                  validator: (value) {
                    // 아무것도 입력하지 않았을 때
                    // 공백만 입력했을 때
                    // 이메일 형식이 아닐 때
                    if (value == null ||
                        value.trim().isEmpty ||
                        !isEmail(value.trim())) {
                      return '이메일을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // 이름
                TextFormField(
                  controller: _nameEditingController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.account_circle),
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '이름을 입력해주세요.';
                    }
                    if (value.length < 3 || value.trim().isEmpty) {
                      return '이름은 최소 3글자, 최대 10글자 까지 입력 가능합니다.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // 패스워드
                TextFormField(
                  controller: _passwordEditingController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '패스워드를 입력해주세요.';
                    }
                    if (value.length < 6) {
                      return '패스워드는 6글자 이상 입력해주세요.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // 패스워드확인
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock),
                    filled: true,
                  ),
                  validator: (value) {
                    if (_passwordEditingController.text != value) {
                      return '패스워드가 일치하지 않습니다.';
                    }
                  },
                ),
                SizedBox(height: 40),

                ElevatedButton(
                  onPressed: () {
                    final form = _globalKey.currentState;

                    if (form == null || form.validate()) {
                      return;
                    }

                    setState(() {
                      _autovalidateMode = AutovalidateMode.always;
                    });


                    context.read<AppAuthProvider>().signUp(
                      email: _emailEditingController.text,
                      name: _nameEditingController.text,
                      password: _passwordEditingController.text,
                      profileImage: _image,
                    );
                  },
                  //회원가입 로직
                  child: Text('회원가입'),
                  style: ElevatedButton.styleFrom(
                    textStyle: TextStyle(fontSize: 20),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
                SizedBox(height: 10),

                TextButton(
                  onPressed: () {},
                  child: Text(
                    '이미 회원이신가요? 로그인하기',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ].reversed.toList(),
            ),
          ),
        ),
      ),
    );
  }
}
