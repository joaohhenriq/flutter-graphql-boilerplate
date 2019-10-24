class OnlineFetch {
  static String updateStatus =
      """
        mutation updateLastSeen(\$now: timestamptz!){
          update_users(where: {}, _set:  {last_seen: \$now}) {
            affected_rows
          }
        }
      """;

  static String fetchUsers =
      """
        subscription fetchOnlineUsers {
          online_users {
            user {
              name
            }
          }
        }
      """;
}