import 'dart:developer';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:wyyapp/batch_manager/view.dart';
import 'package:wyyapp/search/result.dart';
import 'package:wyyapp/utils/Song.dart';
import 'package:wyyapp/playlist_square/view.dart';
import '../../utils.dart';
import 'logic.dart';

class PlayListDetailPage extends StatelessWidget {
  final int playListId;

  PlayListDetailPage({Key? key, required this.playListId}) : super(key: key);

  final logic = Get.put(PlayListDetailLogic());
  final state = Get.find<PlayListDetailLogic>().state;

  @override
  Widget build(BuildContext context) {
    state.playListId = playListId;
    return FutureBuilder(
      future: Future(
        () async => {
          log("haha"),
          await logic.getPlayDetail(),
          log("haha"),
        },
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else {
          return NestedScrollView(
            scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverLayoutBuilder(
                  builder: (context, constraints) {
                    return SliverAppBar(
                      stretch: true,
                      toolbarHeight: 50,
                      title: const Text(
                        '歌单',
                      ),
                      pinned: true,
                      floating: false,
                      //此处的距离计算可以推断出和上下两个bar的相隔距离，如果不需要可以直接设置为0
                      expandedHeight: Get.height * 0.3 + 100,
                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.pin,
                        centerTitle: true,
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            ImageFiltered(
                              imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: CachedNetworkImage(
                                imageUrl: Get.find<PlayListDetailLogic>().state.playDetail["coverImgUrl"],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: GetBuilder<PlayListDetailLogic>(
                                  builder: (controller) {
                                    return const PlayHeader();
                                  },
                                ), /*UserHeaderCard()*/
                              ),
                            ),
                          ],
                        ),
                      ),
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(50),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.play_circle_fill_outlined,
                                      color: Colors.red,
                                    ),
                                    Gap(10),
                                    Text("播放全部"),
                                  ],
                                ),
                                onTap: () {
                                  Get.to(
                                      () => BatchManagerPage(songList: state.songlist, type: BatchType.addToPlaylist));
                                },
                              ),
                              Text("(共${Get.find<PlayListDetailLogic>().state.playDetail["trackCount"]}首)",
                                  style: const TextStyle(color: Colors.grey)),
                              const Spacer(),
                              IconButton(
                                onPressed: () {
                                  Get.to(
                                    () => BatchManagerPage(
                                      songList: Get.find<PlayListDetailLogic>().state.songlist,
                                      type: BatchType.download,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.download_rounded),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ];
            },
            body: SizedBox(
              width: Get.width,
              child: GetBuilder<PlayListDetailLogic>(
                builder: (controller) {
                  return ListView.separated(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    itemCount: state.songlist.length,
                    itemBuilder: (BuildContext context, int index) {
                      var item = state.songlist[index];
                      return SizedBox(
                        height: 50,
                        child: MusicItem(
                          head: Text(
                            "${index + 1}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          title: item["name"] ?? "默认名字",
                          titleExtend: item["alia"] == null || item["alia"].isEmpty ? "" : "(${item["alia"][0]})",
                          subTitle: item["ar"][0]["name"] ?? "默认歌手 - ${item["al"]["name"] ?? "默认专辑"}",
                          onTapTile: () {
                            SongManager.playMusic(item);
                          },
                          tail: [
                            PopupMenuButton(
                              position: PopupMenuPosition.under,
                              itemBuilder: (context) {
                                return [
                                  PopupMenuItem(
                                    value: 1,
                                    onTap: () {
                                      // SongManager.downloadSongById(item["id"]);
                                    },
                                    child: const Text("下载"),
                                  ),
                                  PopupMenuItem(
                                    value: 2,
                                    onTap: () {
                                      SongManager.addSongToNextPlay(item);
                                    },
                                    child: const Text("下一首播放"),
                                  ),
                                  PopupMenuItem(
                                    value: 3,
                                    onTap: () {
                                      SongManager.addSongToLastPlay(item);
                                    },
                                    child: const Text("添加到播放列表"),
                                  ),
                                ];
                              },
                            )
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const Gap(10);
                    },
                  );
                },
              ),
            ),
          );
        }
      },
    );
  }
}

class PlayHeader extends StatelessWidget {
  const PlayHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.horizontal,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 20,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Get.to(() => const DetailShow());
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: Get.find<PlayListDetailLogic>().state.playDetail["coverImgUrl"],
                  fit: BoxFit.cover,
                  width: 120,
                  height: 120,
                ),
              ),
            ),
            const Gap(20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    Get.find<PlayListDetailLogic>().state.playDetail["name"] ?? "默认名字",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const Gap(10),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        ClipOval(
                          child: Get.find<PlayListDetailLogic>().state.creator["avatarUrl"] == null
                              ? Image.asset(
                                  'images/analyze.png',
                                  fit: BoxFit.cover,
                                  width: 20,
                                  height: 20,
                                )
                              : Image.network(
                                  Get.find<PlayListDetailLogic>().state.creator["avatarUrl"],
                                  fit: BoxFit.cover,
                                  width: 20,
                                  height: 20,
                                ),
                        ),
                        const Gap(10),
                        Text(
                          Get.find<PlayListDetailLogic>().state.creator["nickname"] ?? "默认名字",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const Gap(10),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => PlaylistSquarePage());
                    },
                    child: Flex(
                      direction: Axis.horizontal,
                      children: List.generate(
                        (Get.find<PlayListDetailLogic>().state.playDetail["tags"] ?? []).length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(126, 148, 185, 0.4),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            Get.find<PlayListDetailLogic>().state.playDetail["tags"][index] + ">",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
        Text(
          Get.find<PlayListDetailLogic>().state.playDetail["description"] ?? "默认描述",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BuildIcon(
                icon: Icons.share,
                text: changeNumber(Get.find<PlayListDetailLogic>().state.playDetail["shareCount"] ?? 0)),
            BuildIcon(
                icon: Icons.comment_bank,
                text: changeNumber(Get.find<PlayListDetailLogic>().state.playDetail["commentCount"] ?? 0)),
            BuildIcon(
                icon: Icons.add,
                text: changeNumber(Get.find<PlayListDetailLogic>().state.playDetail["subscribedCount"] ?? 0)),
          ],
        )
      ],
    );
  }
}

class BuildIcon extends StatelessWidget {
  final IconData icon;
  final String text;

  const BuildIcon({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (Get.width * 0.9 - 40) / 3,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(126, 148, 185, 0.4),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const Gap(5),
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

//***************************** 点击头像照片之后.. *****************************//

class DetailShow extends StatelessWidget {
  const DetailShow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: Get.width,
        height: Get.height,
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Image.network(
                Get.find<PlayListDetailLogic>().state.playDetail["coverImgUrl"],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      //叉号
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(
                  height: Get.height * 0.4,
                  child: Wrap(
                    direction: Axis.vertical,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 20,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          Get.find<PlayListDetailLogic>().state.playDetail["coverImgUrl"],
                          fit: BoxFit.cover,
                          width: Get.width * 0.6,
                          height: Get.width * 0.6,
                        ),
                      ),
                      SizedBox(
                        height: Get.height * 0.05 / 2,
                        child: AutoSizeText(
                          Get.find<PlayListDetailLogic>().state.playDetail["name"] ?? "默默认名字默认名字默认名字默认名字默认名字默认名字认名字",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              "标签:",
                              style: TextStyle(color: Colors.white),
                            ),
                            ...List.generate(
                              (Get.find<PlayListDetailLogic>().state.playDetail["tags"] ?? []).length,
                              (index) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(126, 148, 185, 0.4),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  Get.find<PlayListDetailLogic>().state.playDetail["tags"][index],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(30),
                        Text(
                          Get.find<PlayListDetailLogic>().state.playDetail["description"] ?? "默认描述",
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontFamily: "Microsoft YaHei"),
                          strutStyle: const StrutStyle(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
                //保存封面按钮
                GestureDetector(
                  onTap: () async {
                    await downLoadImage(Get.find<PlayListDetailLogic>().state.playDetail["coverImgUrl"]);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.download_rounded,
                          color: Colors.red,
                        ),
                        Gap(10),
                        Text(
                          "保存封面",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
