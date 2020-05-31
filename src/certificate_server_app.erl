%%%-------------------------------------------------------------------
%% @doc certificate_server public API
%% @end
%%%-------------------------------------------------------------------

-module(certificate_server_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
	Dispatch = cowboy_router:compile([
		{'_', [
			{"/", cowboy_static, {priv_file, certificate_server, "static/index.html"}},
			{"/get-certificate", get_certificate_handler, start}]}
	]),
	{ok, _} = cowboy:start_clear(my_http_listener,
		[{port, 8080}],
		#{env => #{dispatch => Dispatch}}),
    certificate_server_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
