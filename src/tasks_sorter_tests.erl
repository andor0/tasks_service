-module(tasks_sorter_tests).
-include_lib("eunit/include/eunit.hrl").

-define(UNSORTED_TASKS,
    #{<<"tasks">> =>
        [
            #{
                <<"command">> => <<"touch /tmp/file1">>,
                <<"name">> => <<"task-1">>
            },
            #{
                <<"command">> => <<"cat /tmp/file1">>,
                <<"name">> => <<"task-2">>,
                <<"requires">> => [<<"task-3">>]
            },
            #{
                <<"command">> => <<"echo 'Hello World!' > /tmp/file1">>,
                <<"name">> => <<"task-3">>,
                <<"requires">> => [<<"task-1">>]
            },
            #{
                <<"command">> => <<"rm /tmp/file1">>,
                <<"name">> => <<"task-4">>,
                <<"requires">> => [<<"task-2">>,<<"task-3">>]
            }
        ]
    }
).

-define(SORTED_TASKS,
    #{<<"tasks">> =>
        [
            #{
                <<"command">> => <<"touch /tmp/file1">>,
                <<"name">> => <<"task-1">>
            },
            #{
                <<"command">> => <<"echo 'Hello World!' > /tmp/file1">>,
                <<"name">> => <<"task-3">>,
                <<"requires">> => [<<"task-1">>]
            },
            #{
                <<"command">> => <<"cat /tmp/file1">>,
                <<"name">> => <<"task-2">>,
                <<"requires">> => [<<"task-3">>]
            },
            #{
                <<"command">> => <<"rm /tmp/file1">>,
                <<"name">> => <<"task-4">>,
                <<"requires">> => [<<"task-2">>,<<"task-3">>]
            }
        ]
    }
).

-define(INVALID_UNSORTED_TASKS,
    #{<<"tasks">> =>
        [
            #{
                <<"command">> => <<"touch /tmp/file1">>,
                <<"name">> => <<"task-1">>
            },
            #{
                <<"command">> => <<"cat /tmp/file1">>,
                <<"name">> => <<"task-2">>,
                <<"requires">> => [<<"task-3">>]
            },
            #{
                <<"command">> => <<"echo 'Hello World!' > /tmp/file1">>,
                <<"name">> => <<"task-3">>,
                <<"requires">> => [<<"task-1">>]
            },
            #{
                <<"command">> => <<"rm /tmp/file1">>,
                <<"name">> => <<"task-4">>,
                <<"requires">> => [<<"task-2">>,<<"task-3">>,<<"task-5">>] % task-5 doesn't exists
            }
        ]
    }
).

sort_test() ->
    ?assertEqual({ok, ?SORTED_TASKS}, tasks_sorter:sort(?UNSORTED_TASKS)),
    ?assertEqual({error,{task_not_found,<<"task-5">>}}, tasks_sorter:sort(?INVALID_UNSORTED_TASKS)).