// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ddai_community/main.dart';

// class FirestoreProvider<T> {
//   Future<T> getWhere({
//     required String collection,
//     required String where,
//   }) async {
//     T model;

//     try {
//       await firestore.collection(collection).where(where).get().then((event) {
//         Timestamp timestamp = event.docs.first['date'];
//         DateTime date = timestamp.toDate();

//         model = T(
//           id: event.docs.first['id'],
//           title: event.docs.first['title'],
//           content: event.docs.first['content'],
//           userName: event.docs.first['userName'],
//           date: date,
//           commentList: (event.docs.first['commentList'] as List<dynamic>)
//               .map((e) => CommentModel.fromJson(e))
//               .toList(),
//         );
//       });

//       return boardModel;
//     } catch (e) {
//       logger.e(e);

//       return null;
//     }
//   }
// }
