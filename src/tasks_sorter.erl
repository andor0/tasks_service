-module(tasks_sorter).
-export[sort/1].

-record(state, {
    index,
    processed_tasks,
    sorted_tasks
}).

sort(#{<<"tasks">> := Tasks}) ->
    sort(
        Tasks,
        #state{
            index = lists:foldl(fun(Task = #{<<"name">> := Name}, Acc) -> Acc#{Name => Task} end, #{}, Tasks),
            processed_tasks = #{},
            sorted_tasks = []
        }
    );
sort(_) ->
    {error, invalid_tasks_format}.

sort([], State) ->
    {ok, #{<<"tasks">> => lists:reverse(State#state.sorted_tasks)}};
sort([Task | RestTasks], State) ->
    case process_dependicies(Task, State) of
        {ok, State2} -> sort(RestTasks, State2);
        Error -> Error
    end.

process_dependicies(Task, State) ->
    process_task_dependicies(Task, [], get_requires(Task), State).

process_task_dependicies(Task, [], [], State) ->
    {ok, update_state(Task, State)};
process_task_dependicies(Task, [{PrevTask, PrevTaskDeps} | TasksStack], [], State) ->
    process_task_dependicies(PrevTask, TasksStack, PrevTaskDeps, update_state(Task, State));

% ignore the case of a self-reference in the task requires.
process_task_dependicies(Task = #{<<"name">> := Name}, TasksStack, [Name | Deps], State) ->
    process_task_dependicies(Task, TasksStack, Deps, State);
process_task_dependicies(Task, TasksStack, [Name | Deps], State) ->
    case maps:find(Name, State#state.index) of
        {ok, DepTask} ->
            process_task_dependicies(DepTask, [{Task, Deps} | TasksStack], get_requires(DepTask), State);
        _ -> {error, {task_not_found, Name}}
    end.

get_requires(Task) -> maps:get(<<"requires">>, Task, []).

update_state(Task = #{<<"name">> := Name}, State = #state{processed_tasks = ProcessedTasks}) ->
    case maps:is_key(Name, State#state.processed_tasks) of
        true -> State;
        false ->
            State#state{
                processed_tasks = ProcessedTasks#{Name => true},
                sorted_tasks = [Task | State#state.sorted_tasks]
            }
    end.

