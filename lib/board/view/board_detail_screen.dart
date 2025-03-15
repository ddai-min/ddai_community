import 'package:ddai_community/board/component/comment_list_item.dart';
import 'package:ddai_community/board/component/comment_text_field.dart';
import 'package:ddai_community/board/model/board_model.dart';
import 'package:ddai_community/board/provider/board_provider.dart';
import 'package:ddai_community/common/component/default_circular_progress_indicator.dart';
import 'package:ddai_community/common/layout/default_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BoardDetailScreen extends ConsumerStatefulWidget {
  static get routeName => '/board_detail';

  final String id;

  const BoardDetailScreen({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<BoardDetailScreen> createState() => _BoardDetailScreenState();
}

class _BoardDetailScreenState extends ConsumerState<BoardDetailScreen> {
  late TextEditingController commentTextController;

  @override
  void initState() {
    super.initState();

    commentTextController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final board = ref.watch(getBoardProvider(widget.id));

    return board.when(
      loading: () => const DefaultLayout(
        title: '',
        child: Center(
          child: DefaultCircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => const DefaultLayout(
        title: '',
        child: Center(
          child: Text('로딩 중에 오류가 발생하였습니다.'),
        ),
      ),
      data: (data) => DefaultLayout(
        title: data!.title,
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16.0),
                _Writing(
                  title: data.title,
                  content: data.content,
                ),
                const SizedBox(height: 16.0),
                CommentTextField(
                  controller: commentTextController,
                  onChanged: (value) {
                    commentTextController.text = value;
                  },
                  onPressed: () async {
                    final isSuccess = await ref.read(
                      addCommentProvider(
                        AddCommentParams(
                          searchId: widget.id,
                          userName: 'userName',
                          content: commentTextController.text,
                        ),
                      ).future,
                    );

                    if (isSuccess) {
                      commentTextController.text = '';

                      ref.invalidate(getBoardProvider(widget.id));
                      ref.read(getBoardProvider(widget.id));
                    }
                  },
                ),
                _CommentList(
                  commentList: data.commentList,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Writing extends StatelessWidget {
  final String title;
  final String content;

  const _Writing({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          const Divider(),
          const SizedBox(height: 16.0),
          Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentList extends StatelessWidget {
  final List<CommentModel>? commentList;

  const _CommentList({
    required this.commentList,
  });

  @override
  Widget build(BuildContext context) {
    if (commentList == null || commentList!.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text('댓글이 없습니다.'),
        ),
      );
    } else {
      final List<Widget> list = List.generate(
        commentList!.length,
        (int index) => CommentListItem(
          commentModel: commentList![index],
        ),
      );

      return Column(
        children: list,
      );
    }
  }
}
