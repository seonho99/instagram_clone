import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/exception/custom_exception.dart';

void errorDialogWidget(BuildContext context, CustomException e){
  showDialog(
      context: context,
      barrierDismissible: false, // 확인버튼 외에 선택 안됨
      builder: (context){
        return AlertDialog(
          // 에러 코드
          title: Text(e.code),
          // 에러 내용
          content: Text(e.message),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('확인'),),
          ],
        );
      },);
}