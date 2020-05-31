-module(deldir).
-export([del_dir_contents/1, del_dir_recursive/1]).

del_dir_recursive(Dir) ->
	case file:del_dir(Dir) of
		{error, eexist} -> % Remove contents and try again
			del_dir_contents(Dir),
			del_dir_recursive(Dir);
		Status -> Status
	end.

del_dir_contents(Dir) ->
	{ok, Contents} = file:list_dir_all(Dir),
	[case remove_file_or_dir(filename:join([Dir, Entry])) of
		ok -> ok;
		{error, enoent} -> ok
	end || Entry <- Contents],
	ok.

remove_file_or_dir(Location) ->
	case file:read_file_info(Location) of
		{ok, Info} ->
			case Info of
				#{type := directory} -> del_dir_recursive(Location);
				_ -> file:delete(Location)
			end;
		{error, enoent} -> ok % Already removed
	end.
