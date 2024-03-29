import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:wyyapp/LoginPrefs.dart';
import '../config.dart';
import '../tab_view/view.dart';
import 'logic.dart';


class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final logic = Get.put(LoginLogic());
  final state = Get.find<LoginLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () async {
                  await logic.loginAsVisitor();
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 30, right: 20),
                  child: const Text(
                    "立即体验",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              )
            ],
          ),
          Column(
            children: [
              Container(
                height: 60,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(left: 40, right: 40),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(242, 243, 245, 1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  textAlign: TextAlign.center,
                  controller: state.phoneController,
                  decoration: InputDecoration(
                    hintText: "请输入手机号",
                    hintStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 10,
                      bottom: 10,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        state.phoneController.clear();
                      },
                      child: const Icon(Icons.clear),
                    ),
                    suffixIconColor: Colors.grey,
                  ),
                ),
              ),
              const Gap(10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xfffe3a3b),
                  shadowColor: null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  minimumSize: const Size(300, 50),
                ),
                onPressed: () async {
                  // await logic.getQrKey();
                  await logic.getQrCode();
                },
                child: const Text(
                  "一键登录",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          //生成二维码

          GestureDetector(
            onTap: () async {
              await logic.getQrKey();
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: const Text(
                "扫码登录",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "登录遇到问题",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                VerticalDivider(
                  width: 20,
                  color: Colors.grey,
                ),
                Text(
                  "其他登录方式",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
