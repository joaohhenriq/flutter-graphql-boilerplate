import 'package:app_boilerplate/components/add_task.dart';
import 'package:app_boilerplate/components/todo_item_tile.dart';
import 'package:app_boilerplate/data/online_fetch.dart';
import 'package:app_boilerplate/data/todo_fetch.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../model/todo_item.dart';

class All extends StatefulWidget {
  All({Key key}) : super(key: key);

  @override
  _AllState createState() => _AllState();
}

class _AllState extends State<All> {

  VoidCallback refetchQuery;
  static GraphQLClient _client;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => runOnlineMutation(context));
    super.initState();
  }

  runOnlineMutation(context){
    _client = GraphQLProvider.of(context).value;
    Future.doWhile(
        () async {
          _client.mutate(
            MutationOptions(
              document: OnlineFetch.updateStatus,
              variables: {
                "now": DateTime.now().toUtc().toIso8601String(),
              }
            )
          );
          await Future.delayed(Duration(seconds: 30));
          return true;
        }
    );
  }

  @override
  Widget build(BuildContext context) {

    print("All tab");
    return Column(
      children: <Widget>[
        Mutation(
          options: MutationOptions(
            document: TodoFetch.addTodo,
          ),
          builder: (RunMutation runMutation, QueryResult result){
            return AddTask(
              onAdd: (value) {
                runMutation({'title': value, 'isPublic': false});
              },
            );
          },
          onCompleted: (dynamic resultData){
            refetchQuery();
          },
        ),
        Expanded(
          child: Query(
            options: QueryOptions(
              document: TodoFetch.fetchAll,
              variables: {"is_public": false},
            ),
            builder: (QueryResult result, {VoidCallback refetch}) {
              refetchQuery = refetch;
              if (result.errors != null) {
                return Text(result.errors.toString());
              }
              if (result.loading) {
                return Center(child: CircularProgressIndicator(),);
              }
              final List<LazyCacheMap> todos =
                  (result.data["todos"] as List<dynamic>).cast<LazyCacheMap>();
              return ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  dynamic responseData = todos[index];
                  return TodoItemTile(
                    item: TodoItem.fromElements(
                      responseData["id"],
                      responseData["title"],
                      responseData["is_completed"],
                    ),
                    toggleDocument: TodoFetch.toggleTodo,
                    toggleRunMutation: {'id': responseData["id"], 'isCompleted': !responseData["is_completed"]},
                    deleteDocument: TodoFetch.deleteTodo,
                    deleteRunMutation: {'id': responseData["id"]},
                    refetchQuery: refetchQuery,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }


}
