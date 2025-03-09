import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddai_community/board/component/board_list_item.dart';
import 'package:ddai_community/board/model/board_model.dart';
import 'package:ddai_community/board/view/board_detail_screen.dart';
import 'package:ddai_community/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BoardListScreen extends StatefulWidget {
  const BoardListScreen({super.key});

  @override
  State<BoardListScreen> createState() => _BoardListScreenState();
}

class _BoardListScreenState extends State<BoardListScreen> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BoardModel>>(
        future: _fetchData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.isEmpty) {
            return Container();
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return BoardListItem(
                title: snapshot.data![index].title,
                content: snapshot.data![index].content,
                onTap: () {
                  context.goNamed(
                    BoardDetailScreen.routeName,
                  );
                },
              );
            },
          );
        });
  }

  Future<List<BoardModel>> _fetchData() async {
    try {
      List<BoardModel> boardList = [];

      await db.collection('board').get().then((event) {
        for (var doc in event.docs) {
          logger.d('${doc.data()}');

          boardList.add(
            BoardModel.fromJson(
              doc.data(),
            ),
          );
        }
      });

      return boardList;
    } catch (e) {
      logger.e(e);

      return [];
    }
  }
}
