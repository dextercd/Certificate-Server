-module(get_certificate_handler).

-export([init/2]).

get_date(SerialNumber) ->
	case singer_serial_info:info_of(SerialNumber) of
		{_, _, _, {Year, Month, Day}} ->
			lists:flatten(io_lib:format("~2..0B/~2..0B/~B", [Day, Month, Year]));
		unknown ->
			"unknown date"
	end.

normalize_serial(SerialNumberBin) ->
	string:uppercase(binary_to_list(SerialNumberBin)).

init(Req, State) ->
	#{name := Name, serial := SerialNumberBin} = cowboy_req:match_qs([name, serial], Req),
	SerialNumber = normalize_serial(SerialNumberBin),
	Date = get_date(SerialNumber),
	Certificate = certificates:create_certificate(Name, SerialNumber, Date),
	Req1 = cowboy_req:reply(200,
		#{
			<<"content-type">> => <<"application/pdf">>,
			<<"content-disposition">> => <<"attachment; filename=certificate.pdf">>},
		Certificate,
		Req),
	{ok, Req1, State}.
