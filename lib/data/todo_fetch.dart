class TodoFetch {

  static String fetchAll =
  """
    query getTodos (\$is_public: Boolean!){
      todos(
        where: {is_public: {_eq: \$is_public}},
        order_by: {created_at: desc}
      ){
        __typename
        id
        title
        is_completed
      }
    }
  """;

  static String fetchActive =
      """
        query getActiveTodos {
          todos (
            where: {is_public: {_eq: true}, is_completed: {_eq: false}},
            order_by: {created_at: desc}
          ) {
            __typename
            is_completed
            id
            title
          }
        }
      """;

  static String fetchCompleted =
      """
        query getCompletedTodos{
          todos(
            where: {is_public: {_eq: true}, is_completed: {_eq: true}},
            order_by: {created_at: desc}
          ) {
            __typename
            is_completed
            id
            title
          }
        }
      """;
}