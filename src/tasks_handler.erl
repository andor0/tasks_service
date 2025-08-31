-module(tasks_handler).
-export[init/2].

init(Req0=#{method := <<"POST">>}, State) ->
    Req1 = handle_request(Req0),
    {ok, Req1, State};
init(Req0, State) ->
    Req = cowboy_req:reply(404,
        #{<<"content-type">> => <<"text/plain">>},
        <<"Not found">>,
        Req0),
    {ok, Req, State}.

handle_request(Req0) ->
    {ok, Data, Req1} = cowboy_req:read_body(Req0),
    handle_request(
        Req1,
        tasks_sorter:sort(json:decode(Data)),
        lists:filter(fun({K, _}) -> K == <<"render">> end, cowboy_req:parse_qs(Req1))
    ).

handle_request(Req0, {ok, #{<<"tasks">> := Tasks}}, []) ->
    Resp = #{
        <<"tasks">> => lists:map(fun(X) -> maps:remove(<<"requires">>, X) end, Tasks)
    },
    cowboy_req:reply(200,
        #{<<"content-type">> => <<"application/json">>},
        json:encode(Resp),
    Req0);
handle_request(Req0, {ok, #{<<"tasks">> := Tasks}}, [{<<"render">>, _}]) ->
    Commands = lists:map( fun(#{<<"command">> := Command}) -> [Command, <<"\n">>] end, Tasks),
    cowboy_req:reply(200,
        #{<<"content-type">> => <<"text/plain">>},
        iolist_to_binary([[<<"#!/usr/bin/env bash">>, <<"\n">>], Commands]),
    Req0);
handle_request(Req0, {error, {Error, Reason}}, _) ->
    cowboy_req:reply(400,
        #{<<"content-type">> => <<"application/json">>},
        json:encode(#{<<"error">> => #{Error => Reason}}),
    Req0).
