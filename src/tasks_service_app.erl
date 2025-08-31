%%%-------------------------------------------------------------------
%% @doc tasks_service public API
%% @end
%%%-------------------------------------------------------------------

-module(tasks_service_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([
        {'_', [{"/", tasks_handler, []}]}
    ]),
    {ok, _} = cowboy:start_clear(my_http_listener,
        [{port, 8080}],
        #{env => #{dispatch => Dispatch}}
    ),
    tasks_service_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
