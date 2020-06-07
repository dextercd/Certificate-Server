-module(certificates).
-export([create_certificate/3]).

new_workspace(PurposeStr) ->
	Path = filename:join(["/tmp", PurposeStr ++ integer_to_list(rand:uniform(9999999999999))]),
	ok = file:make_dir(Path),
	Path.

create_certificate(Name, SerialNumber, Date) ->
	SourceFile = filename:join([code:priv_dir(certificate_server), "tex/certificate.tex"]),
	Workspace = new_workspace("certificate"),
	{ok, _} = file:copy(SourceFile, filename:join([Workspace, "certificate.tex"])),
	ok = file:write_file(filename:join([Workspace, "name.txt"]), Name),
	ok = file:write_file(filename:join([Workspace, "serial.txt"]), SerialNumber),
	ok = file:write_file(filename:join([Workspace, "date.txt"]), Date),
	os:cmd("cd " ++ Workspace ++ "; luatex certificate.tex"),
	{ok, FileContents} = file:read_file(filename:join([Workspace, "certificate.pdf"])),
	ok = deldir:del_dir_recursive(Workspace),
	FileContents.
