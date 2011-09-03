-module(sheriff_string_generator).
-compile(export_all).

-type list_ast():: {nil,integer()}
                |{var,integer(),atom()}
		|{cons,integer(),{var,integer(),atom()},list_ast()}.

%% @doc internal functions for generating function's name and variable's name, 
%% @doc in order to avoid conflict with name given by the user.

%% Initialise the ets table used for generating different names.
-spec database()->no_return().
database()->
    ets:new(my_table, [named_table, protected, set, {keypos, 1}]),
    ets:insert(my_table, {'sheriff_$_var', 0}).

%% It registers types defined by the user within the module, for checking 
%% purpose.
-spec register_type({atom(),integer(),[any()]})->no_return().
register_type({Type_name,_,List_of_type_arg})->
    ets:insert(my_table, {Type_name, length(List_of_type_arg)}).

%% It takes a type name and return a name for a function.
-spec name_function(atom())->atom().
name_function(Typename)-> 
    list_to_atom(lists:concat(['sheriff_$_',Typename])).

%% It initialises a variable name, used for the code generated.
-spec name_var()->'Sheriff_$_suspect'.
name_var()->
    ets:delete(my_table,'sheriff_$_var'),
    ets:insert(my_table, {'sheriff_$_var', 0}),
    'Sheriff_$_suspect'. %%the name of the main parameter to check 

%% It returns variable name to use in the code generated.
%% These name are supposed not to match with user's name, and with
%% other variable's name generated.
-spec name_var(integer())->atom().
name_var(Incr)->
    Number=ets:update_counter(my_table, 'sheriff_$_var', Incr),
    %TO TEST ADD: ???  test=is_integer(Number),
    list_to_atom(lists:concat(['Sheriff_$_suspect_',Number])).